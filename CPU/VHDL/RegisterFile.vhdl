----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2023 05:07:09 PM
-- Design Name: 
-- Module Name: RegisterFile - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
    Port (
        ra_select : in STD_LOGIC_VECTOR(3 downto 0);
        rb_select : in STD_LOGIC_VECTOR(3 downto 0);
        write_in : in STD_LOGIC_VECTOR(31 downto 0);
        write_clock : in STD_LOGIC;
        read_clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        RA : out STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        RB : out STD_LOGIC_VECTOR(31 downto 0) := x"00000000"
     );
end RegisterFile;

architecture Behavioral of RegisterFile is
    type register_arr is array(integer range <>) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : register_arr(3 downto 0) := (others=>x"00000000");
begin

process(read_clock, reset)
begin
    if reset = '1' then
        RA <= x"00000000";
        RB <= x"00000000";
    else
        if rising_edge(read_clock) then
            RA <= registers(to_integer(unsigned(ra_select)));
            RB <= registers(to_integer(unsigned(rb_select)));
            report "REGISTERFILE: reading "&
                integer'image(to_integer(unsigned(ra_select)))&":"&
                integer'image(to_integer(unsigned(registers(to_integer(unsigned(ra_select))))))&" "&
                integer'image(to_integer(unsigned(rb_select)))&":"&
                integer'image(to_integer(unsigned(registers(to_integer(unsigned(rb_select))))));
                
        end if;
    end if;
end process;

process(write_clock, reset)
begin
    if reset = '1' then
        registers <= (others=>x"00000000");
    else
        if rising_edge(write_clock) then
            report "REGISTERFILE: register " & integer'image(to_integer(unsigned(ra_select))) & " was assigned the value " & integer'image(to_integer(unsigned(write_in)));
            registers(to_integer(unsigned(ra_select))) <= write_in;
        end if;
    end if;
end process;

end Behavioral;
