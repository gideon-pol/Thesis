library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROM is
    Port (addr : in STD_LOGIC_VECTOR(15 downto 0) := x"0000";
    data_out_0 : out STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    data_out_1 : out STD_LOGIC_VECTOR(31 downto 0) := x"00000000");
end ROM;

architecture Behavioral of ROM is
    type rom_arr is array(integer range <>) of STD_LOGIC_VECTOR(31 downto 0);
    constant data : rom_arr(0 to 31) := (x"00020002", x"00000000", x"00021002", x"00000001", x"00023002", x"0000000a", x"00030002", x"00000000", x"00121002", x"00000002", x"00040000", x"00100002", x"00000001", x"00113002", x"00000001", x"00030000", x"00180002", x"0000000a", x"00440002", x"00000008", x"00ff0000", others => x"00000000");
begin

data_out_0 <= data(to_integer(unsigned(addr)));
data_out_1 <= data(to_integer(unsigned(addr))+1);

end Behavioral;
