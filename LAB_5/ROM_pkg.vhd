library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package ROM_pkg is

    constant C_SPRITE_W  : integer := 9;
    constant C_SPRITE_H  : integer := 9;
    constant C_SPRITE_SZ : integer := C_SPRITE_W * C_SPRITE_H;

    type sprite_t      is array (0 to C_SPRITE_SZ - 1) of unsigned(11 downto 0);
    type sprite_bank_t is array (natural range <>) of sprite_t;

    constant SPRITE_CAT_CALICO : sprite_t := (others => x"FB0");
    constant SPRITE_ALPACA      : sprite_t := (others => x"D80");
    constant SPRITE_CAT_BLACK   : sprite_t := (others => x"334");
    constant SPRITE_CAT_WHITE   : sprite_t := (others => x"EEF");
    constant SPRITE_GITHUB_BIG  : sprite_t := (others => x"0F0");
    constant SPRITE_INSTAGRAM_DETAILED : sprite_t := (others => x"F0F");

    constant SPRITE_BANK : sprite_bank_t(0 to 5) := (
        0 => SPRITE_CAT_CALICO,
        1 => SPRITE_CAT_BLACK,
        2 => SPRITE_CAT_WHITE,
        3 => SPRITE_ALPACA,
        4 => SPRITE_GITHUB_BIG,
        5 => SPRITE_INSTAGRAM_DETAILED
    );

    type t_window is record
        x0 : integer; -- pixel start (2 pixels before display)
        x1 : integer; -- pixel end
        y0 : integer; -- line start
        y1 : integer; -- line end
    end record;

    type t_windows_array is array(0 to 3) of t_window;

    constant C_WINDOW : t_windows_array := (
        0 => (x0 => 110, x1 => 209, y0 => 70, y1 => 169),  -- quadrant 0
        1 => (x0 => 430, x1 => 529, y0 => 70, y1 => 169),  -- quadrant 1
        2 => (x0 => 110, x1 => 209, y0 => 310, y1 => 409), -- quadrant 2
        3 => (x0 => 430, x1 => 529, y0 => 310, y1 => 409)  -- quadrant 3
    );

    constant C_CENTER : t_window := (x0 => 270, x1 => 369, y0 => 190, y1 => 289); -- point (270, 190) is left upper corner of the sprite

end ROM_pkg;