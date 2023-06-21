library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.ALL;

entity CPU is
  Port (
    clock : in std_logic;
    reset : in std_logic;
--    op : out std_logic_vector(7 downto 0);
    halted: out std_logic
  );
end CPU;

architecture structure of CPU is
--    signal clock : STD_LOGIC := '0';
--    signal reset : STD_LOGIC := '0';
--    signal halted : STD_LOGIC := '0';
    
    signal stage_fetch : STD_LOGIC := '0';
    signal stage_register : STD_LOGIC := '0';
    signal stage_exec : STD_LOGIC := '0';
    signal stage_store : STD_LOGIC := '1';

    signal IR : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    signal LITR : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";

    signal PC : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
    
    signal RA : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    signal RB : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    
    signal rom_d0 : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    signal rom_d1 : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    
    signal op_code : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal reg1 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal reg2 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal literal_flag : STD_LOGIC := '0';

    signal write_reg : STD_LOGIC := '0';
    signal write_mem : STD_LOGIC := '0';
    signal write_pc : STD_LOGIC := '0';
    signal read_mem : STD_LOGIC := '0';
    
    signal stop : STD_LOGIC := '0';
    
    signal alu_output : STD_LOGIC_VECTOR(31 downto 0);
    signal cmp_flag : STD_LOGIC;
    
    signal value : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    
    signal regfile_write_clock : STD_LOGIC := '0';
    
    signal ram_addr : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
    signal ram_clock : STD_LOGIC := '0';
    signal ram_data_in : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    signal ram_data_out : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
    
    signal input_y : STD_LOGIC_VECTOR(31 downto 0);
begin

--reset <= '1', '0' after 10 ns;

--process
--begin
--    clock <= '1';
--    wait for 5 ns;
--    clock <= '0';
--    wait for 5 ns;
--end process;
 
rom_inst : entity ROM
    port map(
        addr => pc,
        data_out_0 => rom_d0,
        data_out_1 => rom_d1
    );

ram_addr <= RA(15 downto 0) when read_mem='0' else input_y(15 downto 0);
ram_clock <= stage_exec or stage_store;
ram_data_in <= RA when write_mem='0' else input_y;

ram_inst : entity RAM
    port map(
        addr => ram_addr,
        clock => ram_clock,
        write => write_mem,
        data_in => ram_data_in,
        data_out => ram_data_out
    );

value <= ram_data_out when read_mem='1' else alu_output;
regfile_write_clock <= stage_store and write_reg;
registerfile_inst : entity RegisterFile
    port map(
        ra_select => reg1,
        rb_select => reg2,
        write_in => value,
        write_clock => regfile_write_clock,
        read_clock => stage_register,
        reset => reset,
        ra => ra,
        rb => rb
    );
    
input_y <= RB when literal_flag='0' else litr;
alu_inst : entity ALU
    port map(
        input_1 => RA,
        input_2 => input_y,
        clock => stage_exec,
        op_code => op_code,
        alu_out => alu_output,
        cmp_flag => cmp_flag
    );

process(clock, reset)
begin
    if reset = '1' then
        stage_fetch <= '1';
        stage_register <= '0';
        stage_exec <= '0';
        stage_store <= '0';
    else 
        if rising_edge(clock) and halted='0' then
            stage_store <= stage_exec;
            stage_exec <= stage_register;
            stage_register <= stage_fetch;
            stage_fetch <= stage_store;
        end if;
    end if;
end process;
    
process(stage_store, reset)
begin
    if reset = '1' then
        pc <= x"0000";
    else
        if rising_edge(stage_store) then
            if write_pc='1' and cmp_flag='1' then
                report "PC: jumping to address " & integer'image(to_integer(unsigned(input_y(15 downto 0))));
                pc <= input_y(15 downto 0);
            else
                case literal_flag is
                    when '0' => pc <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(pc)) + 1, 16));
                    when '1' => pc <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(pc)) + 2, 16));
                    when others => null;
                end case;
            end if;
        end if;
    end if;
end process;

process(stage_fetch, reset)
begin
    if reset = '1' then
        ir <= x"00000000";
        litr <= x"00000000";
    else
        if rising_edge(stage_fetch) then
            ir <= rom_d0;
            litr <= rom_d1;
            report "LITR: " & integer'image(to_integer(unsigned(litr)));
        end if;
    end if;
end process;

process(ir)
begin
    op_code <= ir(23 downto 16);
    reg1 <= ir(15 downto 12);
    reg2 <= ir(11 downto 8);
    literal_flag <= ir(1);
    report "IR: op code of next instruction: " & integer'image(to_integer(unsigned(op_code)));
end process;

process(op_code)
begin
    halted <= '1' when op_code = x"ff" else '0';
    write_reg <= '1' when (op_code = x"02" or op_code = x"04" or op_code(7 downto 4) = "0001") else '0';
    write_mem <= '1' when (op_code = x"03") else '0';
    write_pc <= '1' when op_code(7 downto 4) = "0100" else '0';
    read_mem <= '1' when op_code = x"04" else '0';
end process;

end architecture;
