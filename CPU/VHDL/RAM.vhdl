library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM is
    Port (addr : in STD_LOGIC_VECTOR(15 downto 0);
    data_in : in STD_LOGIC_VECTOR(31 downto 0);
    write : in STD_LOGIC := '0';
    clock : in STD_LOGIC := '0';
    data_out : out STD_LOGIC_VECTOR(31 downto 0) := x"00000000");
end RAM;

architecture behavior of RAM is
    type ram_arr is array(integer range <>) of STD_LOGIC_VECTOR(31 downto 0);
    signal data : ram_arr(0 to 1023);
begin

process(clock)
begin
    if(rising_edge(clock)) then
        if(write='1') then
            data(to_integer(unsigned(addr))) <= data_in;
        else
            data_out <= data(to_integer(unsigned(addr)));
        end if;
    end if;
end process;
end architecture;
