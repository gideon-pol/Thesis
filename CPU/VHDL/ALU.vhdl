library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library IEEE_PROPOSED;
use IEEE_PROPOSED.FLOAT_PKG.ALL;

entity ALU is
    Port ( input_1 : in STD_LOGIC_VECTOR(31 downto 0);
           input_2 : in STD_LOGIC_VECTOR(31 downto 0);
           clock : in STD_LOGIC;
           op_code : in STD_LOGIC_VECTOR(7 downto 0);
           alu_out : out STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
           cmp_flag : out STD_LOGIC := '0');
end ALU;

architecture Behavioral of ALU is
    signal op_lower_bits : STD_LOGIC_VECTOR(3 downto 0);
    signal op_upper_bits : STD_LOGIC_VECTOR(3 downto 0);
    signal cmp_flags : STD_LOGIC_VECTOR(2 downto 0) := "000";
    
    function int_alu ( input_1 : in STD_LOGIC_VECTOR(31 downto 0);
                       input_2 : in STD_LOGIC_VECTOR(31 downto 0);
                       op_code : in STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        
        if op_code = "0000" then
            report "int addition coming in";
            return STD_LOGIC_VECTOR(resize(signed(input_1) + signed(input_2), 32));
        elsif op_code = "0001" then
            return STD_LOGIC_VECTOR(resize(signed(input_1) - signed(input_2), 32));
        elsif op_code = "0010" then
            report "int miltiplication coming in";
            return STD_LOGIC_VECTOR(resize(signed(input_1) * signed(input_2), 32));
        else
            return input_1;
        end if;
    end function;
begin

op_lower_bits <= op_code(3 downto 0);
op_upper_bits <= op_code(7 downto 4);

with op_upper_bits select
    alu_out <= int_alu(input_1, input_2, op_lower_bits) when "0001",
               input_2 when others;

with op_lower_bits select
    cmp_flag <= cmp_flags(1) when "0001",
                NOT(cmp_flags(1)) when "0010",
                cmp_flags(0) when "0011",
                cmp_flags(2) when "0100",
                '1' when others;
                
process(clock)
begin
    if rising_edge(clock) then  
        if op_code = "00011000" then
                cmp_flags(0) <= '1' when (signed(input_1) > signed(input_2)) else '0';
                cmp_flags(1) <= '1' when (signed(input_1) = signed(input_2)) else '0';
                cmp_flags(2) <= '1' when (signed(input_1) < signed(input_2)) else '0';
        end if;
    end if;
end process;
end Behavioral;
