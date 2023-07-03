library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.ALL;

entity FIRFilter_TB is
end FIRFilter_TB;

architecture Behavioral of FIRFilter_TB is
    constant CLK_PERIOD : time := 20 ns;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal input : signed(15 downto 0) := x"0000";
    signal output : signed(15 downto 0);

begin
    uut: entity FIRFilter
    port map (
        clk => clk,
        reset => reset,
        input => input,
        output => output
    );

    clk_process: process
    begin
        while now < 500 ns loop
            clk <= '1';
            wait for CLK_PERIOD / 2;
            clk <= '0';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process clk_process;

    stimulus_process: process
    begin
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        input <= x"0001";
        wait for 20 ns;
        assert output = x"01" report "Output mismatch for input value x'01'" severity error;

        input <= x"0002";
        wait for 20 ns;
        assert output = x"03" report "Output mismatch for input value x'02'" severity error;

        input <= x"0003";
        wait for 20 ns;
        assert output = x"06" report "Output mismatch for input value x'03'" severity error;

        wait;
    end process;
end Behavioral;
