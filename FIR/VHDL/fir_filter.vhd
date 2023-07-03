library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIRFilter is
    generic (
        DATA_WIDTH : integer := 16;
        TAP_COUNT : integer := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        input : in signed(DATA_WIDTH-1 downto 0);
        output : out signed(DATA_WIDTH-1 downto 0)
    );
end FIRFilter;

architecture behav of FIRFilter is
    type TapArray is array (0 to TAP_COUNT-1) of signed(DATA_WIDTH-1 downto 0);
    type RegArray is array (0 to TAP_COUNT) of signed(DATA_WIDTH-1 downto 0);
    signal taps : TapArray := (others => to_signed(5, DATA_WIDTH));
    signal m_result : TapArray;
    signal a_result : RegArray;

begin
    mults: for i in 0 to TAP_COUNT-1 generate
    begin
        m_result(i) <= resize(input * taps(i), DATA_WIDTH);
    end generate;

    a_result(TAP_COUNT) <= to_signed(0, DATA_WIDTH);
    adds: for i in 0 to TAP_COUNT-1 generate
        signal reg : signed(DATA_WIDTH-1 downto 0);
    begin
        process (clk)
        begin
            if reset = '1' then
                reg <= to_signed(0, DATA_WIDTH);
            else
                if rising_edge(clk) then
                    reg <= resize(m_result(i) + a_result(i+1), DATA_WIDTH);
                end if;
            end if;
        end process;

        a_result(i) <= reg;
    end generate;

    output <= a_result(0);
end behav;
