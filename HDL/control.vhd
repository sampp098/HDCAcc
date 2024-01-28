----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2023 09:40:31 PM
-- Design Name: 
-- Module Name: control - Behavioral
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
library xil_defaultlib;
use xil_defaultlib.HDC_Package.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control is
    port(
        clk     : in std_logic;
        reset     : in std_logic;
        --port1
        addr1   : in std_logic_vector(clogb2(i_cache_depth)-1 downto 0);
        wr_en1  : in std_logic;
        rd_en1  : in std_logic;
        din1    : in std_logic_vector(cache_port1_data_size-1 downto 0);
        dout1   : out std_logic_vector(cache_port1_data_size-1 downto 0);
        
        ----------------------------------
        --------- Control registers ------
        
        input_reg0 : in std_logic_vector(31 downto 0);
        input_reg1 : in std_logic_vector(31 downto 0);
        input_reg2 : in std_logic_vector(31 downto 0);
        input_reg3 : in std_logic_vector(31 downto 0);
        output_reg4 : out std_logic_vector(31 downto 0);
        output_reg5 : out std_logic_vector(31 downto 0);
        output_reg6 : out std_logic_vector(31 downto 0);
        output_reg7 : out std_logic_vector(31 downto 0);
        
        ----------------------------------
        --------- Control signals   ------
        rst     : out std_logic;
        ctrl_sw_busy      : in std_logic;
        ctrl_sw_cmd_valid : out std_logic;
        ctrl_sw_wr_nrd    : out std_logic;
        ctrl_sw_mem_select: out std_logic_vector(clogb2(total_cache_count)-1 downto 0) := (others => '0');
        
        ctrl_wr_en_bus    : out std_logic_vector(total_cache_count-1 downto 0);
        ctrl_rd_en_bus    : out std_logic_vector(total_cache_count-1 downto 0);
        ctrl_addr_bus     : out address_bus;
        
        ctrl_xor_cache_selects     : out binary_cache_select_array(XOR_threads-1 downto 0);
        ctrl_xor_in_valids         : out std_logic_vector(XOR_threads-1 downto 0);
        ctrl_xor_Load_A_nBs        : out std_logic_vector(XOR_threads-1 downto 0);
        
        ctrl_rot_cache_selects     : out binary_cache_select_array(ROT_threads-1 downto 0);
        ctrl_rot_in_valids         : out std_logic_vector(ROT_threads-1 downto 0);
        ctrl_rot_load_carry_in     : out std_logic_vector(ROT_threads-1 downto 0);
        ctrl_rot_amounts           : out ROT_amount_vector(ROT_threads-1 downto 0);
        
        ctrl_psum_cache_selects    : out binary_cache_select_array(PSUM_threads-1 downto 0);
        ctrl_psum_in_valids        : out std_logic_vector(PSUM_threads-1 downto 0);
        ctrl_psum_reloads          : out std_logic_vector(PSUM_threads-1 downto 0);
        
        ctrl_maj_cache_selects     : out int_cache_select_array(MAJ_threads-1 downto 0);
        ctrl_maj_in_valids         : out std_logic_vector(MAJ_threads-1 downto 0);
        ctrl_maj_load_Ts           : out std_logic_vector(MAJ_threads-1 downto 0);
        ctrl_maj_T                 : out int_vector(MAJ_threads-1 downto 0);
        
        ctrl_bcache_In_sels        : out bcache_In_selects := (others => (others =>'0'));
        ctrl_intcache_In_sels      : out intcache_selects:= (others => (others =>'0'))
        );
end control;

architecture Behavioral of control is 

component inst_cache is
    port(
        clk: in std_logic;
        rst: in std_logic;
        --port1
        addr1 : in  std_logic_vector(clogb2(i_cache_depth)-1 downto 0);
        wr_en1: in  std_logic;
        rd_en1: in  std_logic;
        din1  : in  std_logic_vector(cache_port1_data_size-1 downto 0);
        dout1 : out std_logic_vector(cache_port1_data_size-1 downto 0);
        
        --port2
        addr2 : in  std_logic_vector(clogb2(i_cache_depth)-1 downto 0);
        --wr_en2: in  std_logic;
        rd_en2: in  std_logic;
        --din2  : in  std_logic_vector(i_cache_port2_data_size-1 downto 0);
        dout2 : out std_logic_vector(i_cache_port2_data_size-1 downto 0)
    );
end component;
signal rst_tmp : std_logic := '0';
signal start_ff : std_logic := '0';

signal PC      : std_logic_vector(clogb2(i_cache_depth)-1 downto 0) := (others => '0');
signal opcode  : std_logic_vector(3 downto 0) := (others => '0');
--signal wr_en2  : std_logic := '0';
signal rd_en2  : std_logic := '0';
--signal din2    : std_logic_vector(i_cache_port2_data_size-1 downto 0) := (others => '0');
signal inst   : std_logic_vector(i_cache_port2_data_size-1 downto 0) := (others => '0');
--signal ctrl_sw_cmd_valid : std_logic := '0';
--signal ctrl_sw_wr_nrd    : std_logic := '0';
--signal ctrl_sw_mem_select:  std_logic_vector(clogb2(total_cache_count)-1 downto 0) := (others => '0');
signal ctrl_sw_busy_ff      : std_logic := '0';

--signal ctrl_wr_en_bus   : std_logic_vector(total_cache_count-1 downto 0);
--signal ctrl_rd_en_bus   : std_logic_vector(total_cache_count-1 downto 0);

--signal ctrl_xor_cache_selects     : binary_cache_select_array(ROT_threads-1 downto 0);
--signal ctrl_xor_in_valids         : std_logic_vector(XOR_threads-1 downto 0) := (others => '0');
--signal ctrl_xor_Load_A_nBs        : std_logic_vector(XOR_threads-1 downto 0) := (others => '0');

--signal ctrl_rot_cache_selects     : binary_cache_select_array(ROT_threads-1 downto 0);
--signal ctrl_rot_in_valids         : std_logic_vector(ROT_threads-1 downto 0) := (others => '0');
--signal ctrl_rot_load_carry_in     : std_logic_vector(ROT_threads-1 downto 0);
--signal ctrl_rot_amounts           : ROT_amount_vector(ROT_threads-1 downto 0) := (others => (others =>'0'));

--signal ctrl_psum_cache_selects: binary_cache_select_array(PSUM_threads-1 downto 0);
--signal ctrl_psum_in_valids    : std_logic_vector(PSUM_threads-1 downto 0) := (others => '0');
--signal ctrl_psum_reloads      : std_logic_vector(PSUM_threads-1 downto 0) := (others => '0');

--signal ctrl_maj_cache_selects: int_cache_select_array(MAJ_threads-1 downto 0);
--signal ctrl_maj_in_valids    : std_logic_vector(MAJ_threads-1 downto 0) := (others => '0');
--signal ctrl_maj_load_Ts      : std_logic_vector(MAJ_threads-1 downto 0) := (others => '0');
--signal ctrl_maj_T            : int_vector(MAJ_threads-1 downto 0):= ( others => (others => '0'));

type execute_states is ( 
						fetch,
						--fetch_simulation,
						decode,
						NOP_1,
						BLD_1,
						BLD_2,
						BSTR_1,  
						ILD_1,  
						ISTR_1, 
						XORLDA_1,
						XORLDB_1,
						XORSTR_1,
						ROTLDB_1,
						ROTLDS_1,
						ROTSTR_1,
						PSUMLDS_1,
						PSUMSTR_1,
						MAJLDL_1,
						MAJLDS_1,
						MAJSTR_1
					   );
signal execute_state  : execute_states;


constant inst_NOP     : std_logic_vector(3 downto 0) := "0000";
constant inst_BLD     : std_logic_vector(3 downto 0) := "0001";
constant inst_BSTR    : std_logic_vector(3 downto 0) := "0010";
constant inst_ILD     : std_logic_vector(3 downto 0) := "0011";
constant inst_ISTR    : std_logic_vector(3 downto 0) := "0100";

constant inst_XORLDA  : std_logic_vector(3 downto 0) := "0101";
constant inst_XORLDB  : std_logic_vector(3 downto 0) := "0110";
constant inst_XORSTR  : std_logic_vector(3 downto 0) := "0111";

constant inst_ROTLDB  : std_logic_vector(3 downto 0) := "1000";
constant inst_ROTLDS  : std_logic_vector(3 downto 0) := "1001";
constant inst_ROTSTR  : std_logic_vector(3 downto 0) := "1010";

constant inst_PSUMLDS : std_logic_vector(3 downto 0) := "1011";
constant inst_PSUMSTR : std_logic_vector(3 downto 0) := "1100";

constant inst_MAJLDL  : std_logic_vector(3 downto 0) := "1101";
constant inst_MAJLDS  : std_logic_vector(3 downto 0) := "1110";
constant inst_MAJSTR  : std_logic_vector(3 downto 0) := "1111";

	 
    
    type control_states is (
					   idle,
					   inst_read,
					   execute,
					   finish);
	signal cstate : control_states := idle;
begin
    
-- add instruction cache here
   U_Icache: inst_cache
        port map(clk => clk,
                 rst => rst_tmp,
                 --port1
                 addr1  => addr1,
                 wr_en1 => wr_en1,
                 rd_en1 => rd_en1,
                 din1   => din1,
                 dout1  => dout1,
                 --port2
                 addr2 =>  PC,
                 --wr_en2 => wr_en2,
                 rd_en2 => rd_en2,
                 --din2   => din2,
                 dout2  => inst
                 );

-----------------------------------
-----------------------------------
---------- control      -----------
-----------------------------------
-----------------------------------
    status_process: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                rst_tmp <= '1';
                start_ff <= '0';
                ctrl_sw_busy_ff <= '0';
            else
                ctrl_sw_busy_ff <= ctrl_sw_busy;
                
                rst_tmp  <=  input_reg0(0);
                start_ff <=  input_reg0(1);
            end if;
        end if;   
    end process;   
    
--    read_inst_process: process(clk)
--    begin
--        if rising_edge(clk) then
--            if rst_tmp ='1' then
--                ctrl_sw_cmd_valid <= '0';
--                ctrl_sw_wr_nrd    <= '0';
--                ctrl_sw_busy_ff <= '0';
--            else
--                ctrl_sw_busy_ff <= ctrl_sw_busy;
--                if input_reg0(1) = '1' and start_ff = '0' then
--                    ctrl_sw_cmd_valid <= '1';
--                    ctrl_sw_wr_nrd    <= '0'; 
--                else
--                    ctrl_sw_cmd_valid <= '0';
--                    ctrl_sw_wr_nrd    <= '0';
--                    ctrl_sw_mem_select<= std_logic_vector(to_unsigned(total_cache_count-1, ctrl_sw_mem_select'length));
--                end if;
--            end if;
--        end if;   
--    end process;
    
--    HDC_status_process: process(clk)
--    begin
--        if rising_edge(clk) then
--            if rst_tmp ='1' then
--                cstate <= idle;
--                rd_en2 <= '0';
--            else
--                case cstate is
--                    when idle =>
--                        if input_reg0(1) = '1' and start_ff = '0' then
--                            cstate <= inst_read;
--                        end if;
--                    when inst_read =>
--                        if ctrl_sw_busy_ff='1' and ctrl_sw_busy='0' then
--                            cstate <= execute;
--                        end if;
--                    when execute =>
                        
--                    when finish =>
                        
--                end case;
--            end if;
--        end if;   
--    end process;

    execute_process: process(clk)
    variable value:        std_logic_vector(27 downto 0)  := (others => '0');
    variable cache_select: std_logic_vector(5 downto 0)  := (others => '0');
    variable row_select:   std_logic_vector(21 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if rst_tmp ='1' then
                cstate <= idle;
                
                ctrl_sw_cmd_valid <= '0';
                ctrl_sw_wr_nrd    <= '0';

                
                ctrl_xor_in_valids  <= (others => '0');
                ctrl_rot_in_valids  <= (others => '0');
                ctrl_maj_in_valids  <= (others => '0');
                ctrl_psum_in_valids <= (others => '0');
                
                ctrl_rd_en_bus      <= (others => '0');
                ctrl_wr_en_bus      <= (others => '0');
                ctrl_addr_bus       <= (others => (others => '0'));
                                    
                rd_en2 <= '1';
                
                execute_state <= fetch;
            elsif cstate = idle then
                if input_reg0(1) = '1' and start_ff = '0' then
                    cstate <= inst_read;
                    ctrl_sw_cmd_valid <= '1';
                    ctrl_sw_wr_nrd    <= '0';
                    ctrl_sw_mem_select<= std_logic_vector(to_unsigned(total_cache_count-1, ctrl_sw_mem_select'length));
                end if;
            elsif cstate = inst_read then
                ctrl_sw_cmd_valid <= '0';
                ctrl_sw_wr_nrd    <= '0';
                
                if ctrl_sw_busy_ff='1' and ctrl_sw_busy='0' then
                    cstate <= execute;
                end if;
            elsif cstate = execute and to_integer(unsigned(PC)) < i_cache_depth then
                case execute_state is
                    when fetch  =>
                        ctrl_bcache_In_sels    <= (others => (others => '0'));
                        ctrl_intcache_In_sels  <= (others => (others => '0'));
                        
                        ctrl_rd_en_bus         <= (others=>'0');
                        ctrl_wr_en_bus         <= (others=>'0');
                        
                        ctrl_xor_in_valids     <= (others => '0');
                        ctrl_xor_Load_A_nBs    <= (others => '0');
                        ctrl_xor_cache_selects <= (others => (others => '0'));
                        
                        ctrl_rot_cache_selects   <= (others => (others => '0'));
                        ctrl_rot_in_valids       <= (others => '0');
                        ctrl_rot_load_carry_in   <= (others => '0');
                        
                        ctrl_psum_cache_selects  <= (others => (others => '0'));
                        ctrl_psum_in_valids      <= (others => '0');
                        ctrl_psum_reloads        <= (others => '0');
                        
                        ctrl_maj_cache_selects   <= (others => (others => '0'));
                        ctrl_maj_in_valids       <= (others => '0');
                        ctrl_maj_load_Ts         <= (others => '0');
                        
                        rd_en2 <= '0';
                        --execute_state <= fetch_simulation;
                        execute_state <= decode;
                    --when fetch_simulation => --remove before synthesis 
                        --execute_state <= decode;
                    when decode =>
                        if opcode = inst_NOP     then
                            execute_state <= NOP_1;
                        elsif opcode = inst_BLD   then
                            execute_state <= BLD_1;
						elsif opcode = inst_BSTR   then
                            execute_state <= BSTR_1;
                        elsif opcode = inst_ILD   then
                            execute_state <= ILD_1;
                        elsif opcode = inst_ISTR  then
                            execute_state <= ISTR_1;
                        elsif opcode = inst_XORLDA  then
                            execute_state <= XORLDA_1;
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to binary_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_rd_en_bus(i) <= '1';
--                                    ctrl_addr_bus (i)(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                                      ctrl_addr_bus (i) <= inst(clogb2(max_cache_depth)-1 downto 0);
                                else
                                    ctrl_rd_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
                        elsif opcode = inst_XORLDB     then
                            execute_state <= XORLDB_1;
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to binary_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_rd_en_bus(i) <= '1';
--                                    ctrl_addr_bus (i)(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                                     ctrl_addr_bus (i) <= inst(clogb2(max_cache_depth)-1 downto 0);
                                else
                                    ctrl_rd_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
						elsif opcode = inst_XORSTR     then
                            --execute_state <= fetch;
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to binary_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_wr_en_bus(i) <= '1';
                                    ctrl_addr_bus (i) <= inst(clogb2(max_cache_depth)-1 downto 0);
                                    ctrl_bcache_In_sels(i) <= std_logic_vector(to_unsigned(0+ROT_threads, bcache_In_select_size));
                                    
                                else
                                    --ctrl_bcache_In_sels(i)(0+ROT_threads) <= '0'; 
                                    ctrl_wr_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
                            PC <= std_logic_vector(unsigned(PC)+1);
                            execute_state <= fetch;
                            rd_en2 <= '1';
                        elsif opcode = inst_ROTLDB     then
                            value := inst(27 downto 0);
                            ctrl_rot_load_carry_in(0) <= '1';
                            ctrl_rot_amounts(0) <= value(clogb2(ROT_amount_max)-1 downto 0);
                            PC <= std_logic_vector(unsigned(PC)+1);
                            execute_state <= fetch;
                            rd_en2 <= '1';
						elsif opcode = inst_ROTLDS     then
                            execute_state <= ROTLDS_1;
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to binary_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_rd_en_bus(i) <= '1';
--                                    ctrl_addr_bus (i)(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                                    ctrl_addr_bus (i) <= row_select(clogb2(max_cache_depth)-1 downto 0);
                                else
                                    ctrl_rd_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
						elsif opcode = inst_ROTSTR     then
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to binary_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_wr_en_bus(i) <= '1';
                                    ctrl_addr_bus (i) <= row_select(clogb2(max_cache_depth)-1 downto 0);
                                    ctrl_bcache_In_sels(i) <= std_logic_vector(to_unsigned(0, bcache_In_select_size));
                                    
                                else
                                    --ctrl_bcache_In_sels(i)(0+ROT_threads) <= '0'; 
                                    ctrl_wr_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
                            PC <= std_logic_vector(unsigned(PC)+1);
                            execute_state <= fetch;
                            rd_en2 <= '1';
                        elsif opcode = inst_PSUMLDS    then
                            execute_state <= PSUMLDS_1;
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to binary_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_rd_en_bus(i) <= '1';
--                                    ctrl_addr_bus (i)(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                                     ctrl_addr_bus (i) <= inst(clogb2(max_cache_depth)-1 downto 0);
                                else
                                    ctrl_rd_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
                        elsif opcode = inst_PSUMSTR then
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            ctrl_psum_reloads(0) <= '1';
                            for i in 0 to int_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_wr_en_bus(i+binary_cache_count) <= '1';
                                    ctrl_addr_bus (i+binary_cache_count) <= row_select(clogb2(max_cache_depth)-1 downto 0);
                                    ctrl_intcache_In_sels(i) <= std_logic_vector(to_unsigned(0, intcache_In_select_size));
                                    
                                else
                                    --ctrl_bcache_In_sels(i)(0+ROT_threads) <= '0'; 
                                    ctrl_wr_en_bus(i+binary_cache_count) <= '0';
                                    ctrl_addr_bus (i+binary_cache_count) <= (others => '0');
                                end if;
                            end loop;
                            PC <= std_logic_vector(unsigned(PC)+1);
                            execute_state <= fetch;
                            rd_en2 <= '1';
                        elsif opcode = inst_MAJLDL    then
                            value := inst(27 downto 0);
                            ctrl_maj_load_Ts(0) <= '1';
                            ctrl_maj_T(0) <= value(int_size-1 downto 0);
                            PC <= std_logic_vector(unsigned(PC)+1);
                            execute_state <= fetch;
                            rd_en2 <= '1';
                        elsif opcode = inst_MAJLDS     then
                            execute_state <= MAJLDS_1;
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to int_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_rd_en_bus(i+binary_cache_count) <= '1';
--                                    ctrl_addr_bus (i)(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                                    ctrl_addr_bus (i+binary_cache_count) <= row_select(clogb2(max_cache_depth)-1 downto 0);
                                else
                                    ctrl_rd_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
						elsif opcode = inst_MAJSTR     then
                            --execute_state <= MAJSTR_1;
                            cache_select := inst(27 downto 22);
                            row_select   := inst(21 downto 0);
                            for i in 0 to binary_cache_count-1 loop
                                if i = to_integer(unsigned(cache_select)) then
                                    ctrl_wr_en_bus(i) <= '1';
                                    ctrl_addr_bus (i) <= inst(clogb2(max_cache_depth)-1 downto 0);
                                    ctrl_bcache_In_sels(i) <= std_logic_vector(to_unsigned(0+ROT_threads+XOR_threads, bcache_In_select_size));
                                    
                                else
                                    --ctrl_bcache_In_sels(i)(0+ROT_threads) <= '0'; 
                                    ctrl_wr_en_bus(i) <= '0';
                                    ctrl_addr_bus (i) <= (others => '0');
                                end if;
                            end loop;
                            PC <= std_logic_vector(unsigned(PC)+1);
                            execute_state <= fetch;
                            rd_en2 <= '1';
                        else
                            execute_state <= NOP_1;
                        end if;
                    when NOP_1 =>
                        PC <= std_logic_vector(unsigned(PC)+1);
                        execute_state <= fetch;
                        rd_en2 <= '1';
                    when BLD_1  =>
                        ctrl_sw_cmd_valid <= '1';
                        ctrl_sw_wr_nrd    <= '0';
                        ctrl_sw_mem_select<= std_logic_vector(to_unsigned(0, ctrl_sw_mem_select'length));
                        execute_state <= BLD_2;
                    when BLD_2  =>
                        ctrl_sw_cmd_valid <= '0';
                        ctrl_sw_wr_nrd    <= '0';
                        if ctrl_sw_busy_ff='1' and ctrl_sw_busy='0' then
                            PC <= std_logic_vector(unsigned(PC)+1);
                            execute_state <= fetch;
                            rd_en2 <= '1';
                        end if;
                    when BSTR_1  =>
                    
                    when ILD_1 =>
                    
                    when ISTR_1 =>
                    
                    when XORLDA_1    =>
                        -- thread
                        cache_select := inst(27 downto 22);
                        row_select   := inst(21 downto 0);
                        ctrl_rd_en_bus <= (others=>'0');
--                        ctrl_addr_bus (to_integer(unsigned(cache_select)))(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                            
                        ctrl_xor_Load_A_nBs(0)    <=  '1';
                        ctrl_xor_in_valids (0)    <=  '1';
                        ctrl_xor_cache_selects(0) <=  cache_select(BcacheSelectBits-1 downto 0);
                        PC <= std_logic_vector(unsigned(PC)+1);
                        execute_state <= fetch;
                        rd_en2 <= '1';
                    when XORLDB_1    =>
                        cache_select := inst(27 downto 22);
                        row_select   := inst(21 downto 0);
                        ctrl_rd_en_bus <= (others=>'0');
--                        ctrl_addr_bus (to_integer(unsigned(cache_select)))(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                            
                        ctrl_xor_Load_A_nBs(0)    <=  '0';
                        ctrl_xor_in_valids (0)    <=  '1';
                        ctrl_xor_cache_selects(0) <=  cache_select(BcacheSelectBits-1 downto 0);
                        PC <= std_logic_vector(unsigned(PC)+1);
                        execute_state <= fetch;
                        rd_en2 <= '1';
                    when XORSTR_1    =>
                        --OK
                    when ROTLDB_1    =>
                        --OK
                    when ROTLDS_1    =>
                        cache_select := inst(27 downto 22);
                        row_select   := inst(21 downto 0);
                        ctrl_rd_en_bus <= (others=>'0');
--                        ctrl_addr_bus (to_integer(unsigned(cache_select)))(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                            
                        --ctrl_xor_Load_A_nBs(0)    <=  '0';
                        ctrl_rot_in_valids (0)    <=  '1';
                        ctrl_rot_cache_selects(0) <=  cache_select(BcacheSelectBits-1 downto 0);
                        PC <= std_logic_vector(unsigned(PC)+1);
                        execute_state <= fetch;
                        rd_en2 <= '1';
                    when ROTSTR_1    =>
                        --OK
                    when PSUMLDS_1   =>
                        cache_select := inst(27 downto 22);
                        row_select   := inst(21 downto 0);
                        ctrl_rd_en_bus <= (others=>'0');
--                        ctrl_addr_bus (to_integer(unsigned(cache_select)))(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                            
                        ctrl_psum_in_valids (0)    <=  '1';
                        ctrl_psum_cache_selects(0) <=  cache_select(BcacheSelectBits-1 downto 0);
                        PC <= std_logic_vector(unsigned(PC)+1);
                        execute_state <= fetch;
                        rd_en2 <= '1';
                    when PSUMSTR_1=>
                        --OK
                    when MAJLDL_1   =>
                        --OK
                    when MAJLDS_1    =>
                        cache_select := inst(27 downto 22);
                        row_select   := inst(21 downto 0);
                        ctrl_rd_en_bus <= (others=>'0');
--                        ctrl_addr_bus (to_integer(unsigned(cache_select)))(BRowsSelect-1 downto 0) <= row_select(BRowsSelect-1 downto 0);
                            
                        ctrl_maj_in_valids (0)    <=  '1';
                        ctrl_maj_cache_selects(0) <=  cache_select(intcacheSelectBits-1 downto 0);
                        PC <= std_logic_vector(unsigned(PC)+1);
                        execute_state <= fetch;
                        rd_en2 <= '1';
                    when MAJSTR_1    =>
                    --OK
                    when others =>
                        PC <= std_logic_vector(unsigned(PC)+1);
                        execute_state <= fetch;
                        rd_en2 <= '1';
                end case;
            elsif cstate = execute and to_integer(unsigned(PC)) >= i_cache_depth then
                cstate <= finish;
            end if;
        end if; 
    end process;
rst    <= rst_tmp;
opcode <= inst(31 downto 28);


--------------------------------------
--- Thread and  cache interconnect ---




end Behavioral;

