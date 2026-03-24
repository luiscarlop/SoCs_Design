#!/usr/bin/env python3
"""
svg_to_rom.py
─────────────────────────────────────────────────────────────────────────────
Converts a pixel-art SVG into a VHDL ROM constant for ISE 14.7 / Artix-7.

  • Reads the SVG viewBox to get the pixel grid dimensions (e.g. 9×9)
  • Rasterises the SVG by sampling the centre of every pixel cell
  • Converts each 24-bit colour (8 bits/channel) → 12-bit (4 bits/channel)
    by keeping the most-significant nibble of each channel
  • Prints the VHDL ROM constant AND a colour-palette report

Two rendering backends are supported (first available is used):
  1. cairosvg + Pillow  — handles any SVG (install with: pip install cairosvg Pillow)
  2. Built-in rasteriser — no extra dependencies, handles rect / polygon /
                           rectilinear-path SVGs (all typical pixel-art files)

Usage
─────
    python svg_to_rom.py <sprite.svg> [SPRITE_NAME]

    SPRITE_NAME defaults to the filename without extension (uppercased).
    Redirect stdout to save the output:

        python svg_to_rom.py cat-calico.svg CAT_CALICO > rom_cat.vhd
─────────────────────────────────────────────────────────────────────────────
"""

import sys
import re
import io
import xml.etree.ElementTree as ET
from collections import Counter


# ─────────────────────────────────────────────────────────────
# Colour helpers
# ─────────────────────────────────────────────────────────────

def hex_to_rgb(h: str) -> tuple:
    h = h.lstrip('#')
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)

def rgb24_to_rgb12(r: int, g: int, b: int) -> tuple:
    """
    Reduce each 8-bit channel to 4 bits by keeping the top nibble.
    e.g.  0xEB → 0xE,  0xB1 → 0xB,  0x00 → 0x0
    """
    return r >> 4, g >> 4, b >> 4

def rgb12_hex(r4: int, g4: int, b4: int) -> str:
    return f"{r4:X}{g4:X}{b4:X}"


# ─────────────────────────────────────────────────────────────
# SVG helpers
# ─────────────────────────────────────────────────────────────

def get_svg_grid_size(svg_path: str) -> tuple:
    """Return (width, height) in grid pixels from the SVG viewBox."""
    tree = ET.parse(svg_path)
    root = tree.getroot()
    vb = root.get("viewBox") or root.get("viewbox")
    if vb:
        parts = vb.split()
        return int(float(parts[2])), int(float(parts[3]))
    w = int(float(root.get("width", 9)))
    h = int(float(root.get("height", 9)))
    return w, h


# ─────────────────────────────────────────────────────────────
# Backend 1 — cairosvg + Pillow (optional)
# ─────────────────────────────────────────────────────────────

def _try_cairosvg(svg_path: str, grid_w: int, grid_h: int, scale: int = 20):
    """
    Returns a flat list of (R,G,B) tuples in row-major order, or None if
    cairosvg / Pillow are not available.
    """
    try:
        import cairosvg
        from PIL import Image
    except ImportError:
        return None

    png_bytes = cairosvg.svg2png(
        url=svg_path,
        output_width=grid_w * scale,
        output_height=grid_h * scale,
    )
    img = Image.open(io.BytesIO(png_bytes)).convert("RGBA")
    half = scale // 2
    pixels = []
    for row in range(grid_h):
        for col in range(grid_w):
            r, g, b, a = img.getpixel((col * scale + half, row * scale + half))
            pixels.append((0, 0, 0) if a < 128 else (r, g, b))
    return pixels


# ─────────────────────────────────────────────────────────────
# Backend 2 — built-in rasteriser (no dependencies)
# ─────────────────────────────────────────────────────────────

def _point_in_polygon(px: float, py: float, poly: list) -> bool:
    """Ray-casting even-odd rule."""
    inside = False
    n = len(poly)
    j = n - 1
    for i in range(n):
        xi, yi = poly[i]
        xj, yj = poly[j]
        if ((yi > py) != (yj > py)) and \
           (px < (xj - xi) * (py - yi) / (yj - yi) + xi):
            inside = not inside
        j = i
    return inside

def _parse_path_polygons(d: str) -> list:
    """
    Parse a rectilinear SVG path (M H V h v Z only) into a list of polygons.
    Each polygon is a list of (x, y) vertex tuples.
    Handles multiple sub-paths (used for holes via even-odd fill rule).
    """
    tokens = re.findall(r'[MHVhvZz]|[-+]?\d*\.?\d+', d)
    polygons, points = [], []
    x = y = 0.0
    i = 0
    while i < len(tokens):
        cmd = tokens[i]; i += 1
        if cmd == 'M':
            if points:
                polygons.append(points)
            points = []
            x, y = float(tokens[i]), float(tokens[i + 1]); i += 2
            points.append((x, y))
        elif cmd == 'H':
            x = float(tokens[i]); i += 1
            points.append((x, y))
        elif cmd == 'V':
            y = float(tokens[i]); i += 1
            points.append((x, y))
        elif cmd == 'h':
            x += float(tokens[i]); i += 1
            points.append((x, y))
        elif cmd == 'v':
            y += float(tokens[i]); i += 1
            points.append((x, y))
        elif cmd in ('Z', 'z'):
            if points:
                polygons.append(points)
            points = []
    if points:
        polygons.append(points)
    return polygons

def _parse_polygon_points(pts_str: str) -> list:
    nums = list(map(float, re.findall(r'[-+]?\d*\.?\d+', pts_str)))
    return [(nums[i], nums[i + 1]) for i in range(0, len(nums) - 1, 2)]

def _builtin_rasterise(svg_path: str, grid_w: int, grid_h: int) -> list:
    """
    Rasterise supported SVG elements (rect, polygon, path) using the
    even-odd point-in-polygon test. Layers are applied in document order
    (later elements paint over earlier ones), matching SVG semantics.
    """
    tree = ET.parse(svg_path)
    root = tree.getroot()

    # Build ordered list of (rgb_tuple, list_of_polygons)
    layers = []
    for elem in root.iter():
        tag = elem.tag.split('}')[-1]   # strip namespace if present
        fill = elem.get('fill', '')
        if not fill or fill == 'none':
            continue
        colour = hex_to_rgb(fill)

        if tag == 'rect':
            x0 = float(elem.get('x', 0))
            y0 = float(elem.get('y', 0))
            w  = float(elem.get('width', 1))
            h  = float(elem.get('height', 1))
            layers.append((colour, [
                [(x0, y0), (x0 + w, y0), (x0 + w, y0 + h), (x0, y0 + h)]
            ]))

        elif tag == 'polygon':
            pts = _parse_polygon_points(elem.get('points', ''))
            layers.append((colour, [pts]))

        elif tag == 'path':
            polys = _parse_path_polygons(elem.get('d', ''))
            layers.append((colour, polys))

    # Rasterise: start with black, paint layers in order
    grid = [(0, 0, 0)] * (grid_w * grid_h)
    for colour, polygons in layers:
        for row in range(grid_h):
            for col in range(grid_w):
                cx, cy = col + 0.5, row + 0.5     # sample pixel centre
                # Even-odd: count how many sub-polygons contain this point
                hits = sum(1 for p in polygons if _point_in_polygon(cx, cy, p))
                if hits % 2 == 1:
                    grid[row * grid_w + col] = colour
    return grid


# ─────────────────────────────────────────────────────────────
# Report builders
# ─────────────────────────────────────────────────────────────

def build_palette_report(pixels: list) -> str:
    palette = Counter(pixels)
    lines = [
        "-- ─── Colour Palette ─────────────────────────────────────────────────────",
        "-- #  24-bit (original)   12-bit (VGA)  Pixels  Quant. error",
        "-- ───────────────────────────────────────────────────────────────────────",
    ]
    for idx, (rgb24, count) in enumerate(sorted(palette.items())):
        r, g, b = rgb24
        r4, g4, b4 = rgb24_to_rgb12(r, g, b)
        r_b, g_b, b_b = r4 * 17, g4 * 17, b4 * 17   # reconstruct for error calc
        err = ((r - r_b) ** 2 + (g - g_b) ** 2 + (b - b_b) ** 2) ** 0.5
        lines.append(
            f"-- {idx:2d}  #{r:02X}{g:02X}{b:02X}           "
            f"x\"{r4:X}{g4:X}{b4:X}\"       "
            f"{count:4d}px  Δ={err:.1f}"
        )
    lines.append("-- ───────────────────────────────────────────────────────────────────────")
    return "\n".join(lines)


def build_pixel_preview(pixels: list, grid_w: int, grid_h: int) -> str:
    lines = ["-- ─── Pixel Preview (12-bit colour per cell) ──────────────────────────────"]
    for row in range(grid_h):
        row_hex = "  ".join(
            rgb12_hex(*rgb24_to_rgb12(*pixels[row * grid_w + col]))
            for col in range(grid_w)
        )
        lines.append(f"--  row {row}: {row_hex}")
    lines.append("-- ─────────────────────────────────────────────────────────────────────────")
    return "\n".join(lines)


def build_vhdl_rom(pixels: list, sprite_name: str, grid_w: int, grid_h: int) -> str:
    total = grid_w * grid_h
    addr_bits = (total - 1).bit_length()
    lines = [
        f"-- Sprite : {sprite_name}  ({grid_w}×{grid_h} = {total} pixels)",
        f"-- Addr   : {addr_bits} bits  (0 to {total - 1})",
        f"-- Data   : 12-bit RGB  (RRRRGGGGBBBB)",
        f"",
        f"constant SPRITE_{sprite_name} : sprite_t := (",
    ]
    for i, (r, g, b) in enumerate(pixels):
        r4, g4, b4 = rgb24_to_rgb12(r, g, b)
        hx    = rgb12_hex(r4, g4, b4)
        comma = "," if i < total - 1 else " "
        row, col = i // grid_w, i % grid_w
        lines.append(
            f'    {i:3d} => x"{hx}"{comma}  -- ({row},{col})  #{r:02X}{g:02X}{b:02X}'
        )
    lines.append(");")
    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    svg_path = sys.argv[1]
    sprite_name = (
        sys.argv[2] if len(sys.argv) >= 3
        else svg_path.rsplit("/", 1)[-1].rsplit(".", 1)[0]
                     .upper().replace("-", "_")
    )

    grid_w, grid_h = get_svg_grid_size(svg_path)

    # Try cairosvg first; fall back to the built-in rasteriser
    pixels = _try_cairosvg(svg_path, grid_w, grid_h)
    if pixels is not None:
        backend = "cairosvg + Pillow"
    else:
        pixels  = _builtin_rasterise(svg_path, grid_w, grid_h)
        backend = "built-in rasteriser (cairosvg not installed)"

    print(f"-- Input   : {svg_path}")
    print(f"-- Grid    : {grid_w}×{grid_h} pixels")
    print(f"-- Sprite  : {sprite_name}")
    print(f"-- Backend : {backend}")
    print()
    print(build_palette_report(pixels))
    print()
    print(build_pixel_preview(pixels, grid_w, grid_h))
    print()
    print(build_vhdl_rom(pixels, sprite_name, grid_w, grid_h))


if __name__ == "__main__":
    main()
