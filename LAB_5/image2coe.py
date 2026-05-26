#!/usr/bin/env python3
"""
image2coe.py
Converts any image to a 100x100, 12-bit RGB .coe file for Xilinx Core Generator.

Usage:
    python image2coe.py <image_path> [--width W] [--height H]

Color encoding: 4 bits per channel (R, G, B) -> 12-bit word
    word = R[11:8] | G[7:4] | B[3:0]   (matches rgb_out on the ZedBoard)
"""

import argparse
from pathlib import Path
import numpy as np
from PIL import Image


def image_to_coe(image_path: str, width: int = 100, height: int = 100) -> None:
    src = Path(image_path)
    img = Image.open(src).convert("RGB")
    img = img.resize((width, height), Image.LANCZOS)

    data = np.array(img, dtype=np.uint32)   # shape (H, W, 3), values 0-255

    # Reduce to 4 bits per channel (0-15)
    r = data[:, :, 0] // 16
    g = data[:, :, 1] // 16
    b = data[:, :, 2] // 16

    # Pack: R*256 + G*16 + B  ->  bits [11:8]=R, [7:4]=G, [3:0]=B
    packed = r * 256 + g * 16 + b          # shape (H, W)

    # Flatten row-major
    flat = packed.flatten()                 # row 0 first, then row 1, ...

    coe_path = src.with_suffix(".coe")
    with open(coe_path, "w") as f:
        f.write("memory_initialization_radix=10;\r\n")
        f.write("memory_initialization_vector=\r\n")
        for val in flat:
            f.write(f"{val},\r\n")

    print(f"Written: {coe_path}  ({len(flat)} entries)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert image to Xilinx .coe ROM file")
    parser.add_argument("image", help="Path to source image")
    parser.add_argument("--width",  type=int, default=100)
    parser.add_argument("--height", type=int, default=100)
    args = parser.parse_args()

    image_to_coe(args.image, args.width, args.height)
