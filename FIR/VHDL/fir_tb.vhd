library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.ALL;

entity FIRFilter_TB is
end FIRFilter_TB;

architecture Behavioral of FIRFilter_TB is
    -- Constants
    constant CLK_PERIOD : time := 20 ns;
    
    -- Components
--    component FIRFilter is
--        generic (
--            DATA_WIDTH : integer := 8;
--            TAP_COUNT : integer := 16
--        );
--        port (
--            clk : in std_logic;
--            reset : in std_logic;
--            input : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);  -- Input data
--            output : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)-- Output data
--        );
--    end component FIRFilter;

    -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal input : signed(15 downto 0) := x"0000";
    signal output : signed(15 downto 0);

begin
    -- Instantiate the FIR filter
    uut: entity FIRFilter
    port map (
        clk => clk,
        reset => reset,
        input => input,
        output => output
    );

    -- Clock process
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

    -- Stimulus process
    stimulus_process: process
    begin
        -- Apply reset
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        -- Apply input values and check output
        input <= x"0001";
        wait for 20 ns;
        assert output = x"01" report "Output mismatch for input value x'01'" severity error;

        input <= x"0002";
        wait for 20 ns;
        assert output = x"03" report "Output mismatch for input value x'02'" severity error;

        input <= x"0003";
        wait for 20 ns;
        assert output = x"06" report "Output mismatch for input value x'03'" severity error;

        -- Add more test cases here...

        wait;
    end process stimulus_process;
end Behavioral;