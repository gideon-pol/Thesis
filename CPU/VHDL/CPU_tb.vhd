----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2023 07:23:33 PM
-- Design Name: 
-- Module Name: CPU_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.ALL;

use work.all;

entity CPU_tb is

end CPU_tb;

architecture bench of CPU_tb is
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal enable : boolean := false;
    signal op : std_logic_vector(7 downto 0) := "00000000";

begin
    process
    begin
        clock <= not clock;
        wait for 10 ns;
    end process;
        
    cpu_instance : entity CPU
    port map(
        clock => clock,
        reset => reset
--        op => op
--        eta2 => enable,
--        result => op
    );
    
    process(clock)
    begin
        if(rising_edge(clock)) then
            if(enable = false) then
                reset <= '1';
                enable <= true;
            else
                reset <= '0';
            end if;
        end if;
    end process;
end bench;
