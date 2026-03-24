--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package ROM_pkg is

    constant C_SPRITE_W  : integer := 9;
    constant C_SPRITE_H  : integer := 9;
    constant C_SPRITE_SZ : integer := C_SPRITE_W * C_SPRITE_H; -- 81 pixels

    type sprite_t     is array (0 to C_SPRITE_SZ - 1) of unsigned(11 downto 0);
    type sprite_bank_t is array (natural range <>) of sprite_t;

    -- Each row of 9 pixels, top to bottom
    constant SPRITE_CAT_CALICO : sprite_t := (
      0 => x"000",  -- (0,0)  #000000
      1 => x"000",  -- (0,1)  #000000
      2 => x"000",  -- (0,2)  #000000
      3 => x"000",  -- (0,3)  #000000
      4 => x"000",  -- (0,4)  #000000
      5 => x"000",  -- (0,5)  #000000
      6 => x"000",  -- (0,6)  #000000
      7 => x"000",  -- (0,7)  #000000
      8 => x"000",  -- (0,8)  #000000
      9 => x"000",  -- (1,0)  #000000
     10 => x"FB0",  -- (1,1)  #FFB100
     11 => x"000",  -- (1,2)  #000000
     12 => x"000",  -- (1,3)  #000000
     13 => x"000",  -- (1,4)  #000000
     14 => x"000",  -- (1,5)  #000000
     15 => x"000",  -- (1,6)  #000000
     16 => x"D80",  -- (1,7)  #D38100
     17 => x"000",  -- (1,8)  #000000
     18 => x"000",  -- (2,0)  #000000
     19 => x"950",  -- (2,1)  #9C5F00
     20 => x"FB0",  -- (2,2)  #FFB100
     21 => x"000",  -- (2,3)  #000000
     22 => x"000",  -- (2,4)  #000000
     23 => x"000",  -- (2,5)  #000000
     24 => x"D80",  -- (2,6)  #D38100
     25 => x"950",  -- (2,7)  #9C5F00
     26 => x"000",  -- (2,8)  #000000
     27 => x"000",  -- (3,0)  #000000
     28 => x"FB0",  -- (3,1)  #FFB100
     29 => x"FB0",  -- (3,2)  #FFB100
     30 => x"FB0",  -- (3,3)  #FFB100
     31 => x"EEF",  -- (3,4)  #EBEAF7
     32 => x"D80",  -- (3,5)  #D38100
     33 => x"D80",  -- (3,6)  #D38100
     34 => x"D80",  -- (3,7)  #D38100
     35 => x"000",  -- (3,8)  #000000
     36 => x"000",  -- (4,0)  #000000
     37 => x"FB0",  -- (4,1)  #FFB100
     38 => x"FB0",  -- (4,2)  #FFB100
     39 => x"EEF",  -- (4,3)  #EBEAF7
     40 => x"EEF",  -- (4,4)  #EBEAF7
     41 => x"EEF",  -- (4,5)  #EBEAF7
     42 => x"D80",  -- (4,6)  #D38100
     43 => x"D80",  -- (4,7)  #D38100
     44 => x"000",  -- (4,8)  #000000
     45 => x"000",  -- (5,0)  #000000
     46 => x"EEF",  -- (5,1)  #EBEAF7
     47 => x"334",  -- (5,2)  #343341
     48 => x"EEF",  -- (5,3)  #EBEAF7
     49 => x"EEF",  -- (5,4)  #EBEAF7
     50 => x"EEF",  -- (5,5)  #EBEAF7
     51 => x"334",  -- (5,6)  #343341
     52 => x"EEF",  -- (5,7)  #EBEAF7
     53 => x"000",  -- (5,8)  #000000
     54 => x"000",  -- (6,0)  #000000
     55 => x"EEF",  -- (6,1)  #EBEAF7
     56 => x"EEF",  -- (6,2)  #EBEAF7
     57 => x"EEF",  -- (6,3)  #EBEAF7
     58 => x"FAB",  -- (6,4)  #FFAEB0
     59 => x"EEF",  -- (6,5)  #EBEAF7
     60 => x"EEF",  -- (6,6)  #EBEAF7
     61 => x"EEF",  -- (6,7)  #EBEAF7
     62 => x"000",  -- (6,8)  #000000
     63 => x"000",  -- (7,0)  #000000
     64 => x"000",  -- (7,1)  #000000
     65 => x"EEF",  -- (7,2)  #EBEAF7
     66 => x"EEF",  -- (7,3)  #EBEAF7
     67 => x"EEF",  -- (7,4)  #EBEAF7
     68 => x"EEF",  -- (7,5)  #EBEAF7
     69 => x"EEF",  -- (7,6)  #EBEAF7
     70 => x"000",  -- (7,7)  #000000
     71 => x"000",  -- (7,8)  #000000
     72 => x"000",  -- (8,0)  #000000
     73 => x"000",  -- (8,1)  #000000
     74 => x"000",  -- (8,2)  #000000
     75 => x"000",  -- (8,3)  #000000
     76 => x"000",  -- (8,4)  #000000
     77 => x"000",  -- (8,5)  #000000
     78 => x"000",  -- (8,6)  #000000
     79 => x"000",  -- (8,7)  #000000
     80 => x"000"   -- (8,8)  #000000
);
    constant SPRITE_HEART : sprite_t := (
        x"000", x"F00", x"F00", x"000", x"F00", x"F00", x"000", x"000", x"000",
        x"F00", x"F00", x"F00", x"F00", x"F00", x"F00", x"F00", x"000", x"000",
        x"F00", x"F00", x"F00", x"F00", x"F00", x"F00", x"F00", x"000", x"000",
        x"F00", x"F00", x"F00", x"F00", x"F00", x"F00", x"F00", x"000", x"000",
        x"000", x"F00", x"F00", x"F00", x"F00", x"F00", x"000", x"000", x"000",
        x"000", x"000", x"F00", x"F00", x"F00", x"000", x"000", x"000", x"000",
        x"000", x"000", x"000", x"F00", x"000", x"000", x"000", x"000", x"000",
        x"000", x"000", x"000", x"000", x"000", x"000", x"000", x"000", x"000",
        x"000", x"000", x"000", x"000", x"000", x"000", x"000", x"000", x"000"
    );

    -- TODO [ ]: Replace SPRITE_SWORD with SPRITE_CAT_CALICO (SPRITE_SWORD is not declared)
    --          and update the range to (0 to 2) once all three sprites are in the bank
    constant SPRITE_BANK : sprite_bank_t(0 to 1) := (SPRITE_SWORD, SPRITE_HEART);
end ROM_pkg;

package body ROM_pkg is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end ROM_pkg;
