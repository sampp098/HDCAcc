----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2023 01:58:54 PM
-- Design Name: 
-- Module Name: stream_switch - Behavioral
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

entity stream_switch is

    Port (
        
        --switch control signals
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        cmd_valid : in  STD_LOGIC;
        wr_nrd    : in  std_logic;
        mem_select: in  std_logic_vector(clogb2(total_cache_count)-1 downto 0);
        busy      : out std_logic;
        
        -- Ports of Axi Stream Slave Bus Interface S_AXIS_input
		s_axis_input_aclk	: in std_logic;
		s_axis_input_aresetn: in std_logic;
		s_axis_input_tready	: out std_logic;
		s_axis_input_tdata	: in std_logic_vector(C_S_AXIS_input_TDATA_WIDTH-1 downto 0);
		s_axis_input_tkeep	: in std_logic_vector((C_S_AXIS_input_TDATA_WIDTH/8)-1 downto 0);
		s_axis_input_tlast	: in std_logic;
		s_axis_input_tvalid	: in std_logic;
    
        -- Ports of Axi Stream Master Bus Interface M_AXIS_output
		m_axis_output_aclk	: in std_logic;
		m_axis_output_aresetn	: in std_logic;
		m_axis_output_tvalid	: out std_logic;
		m_axis_output_tdata	: out std_logic_vector(C_M_AXIS_output_TDATA_WIDTH-1 downto 0);
		m_axis_output_tkeep	: out std_logic_vector((C_M_AXIS_output_TDATA_WIDTH/8)-1 downto 0);
		m_axis_output_tlast	: out std_logic;
		m_axis_output_tready	: in std_logic;
        
        -- cache ports
        data_in_array: in stream_bus;
        data_out     : out std_logic_vector(cache_port1_data_size-1 downto 0);
        wr_en        : out std_logic_vector(total_cache_count-1 downto 0);
        rd_en        : out std_logic_vector(total_cache_count-1 downto 0);
        addr         : out std_logic_vector(clogb2(max_cache_depth)-1 downto 0)
    );
end stream_switch;

architecture Behavioral of stream_switch is
    type state is ( idle,
	 				 reading,
	 				 finish_reading,
	 				 writing,
	 				 finish_writing);

	 signal cstate  : state;
	 
	 
	 signal   write_stream_pointer  : integer :=0;
	 signal   read_stream_pointer : integer :=0;
	 signal   MAX_WORDS     : integer :=32;
	 
	 signal start_read_stream_pulse : std_logic := '0';
	 signal start_write_stream_pulse: std_logic := '0';
	 signal read_stream_pulse_ff : std_logic := '0';
	 signal write_stream_pulse_ff: std_logic := '0';
	 
	 signal mem_select_dec_ff: std_logic_vector(total_cache_count-1 downto 0);
	 signal mem_select_ff    : std_logic_vector(clogb2(total_cache_count)-1 downto 0);
	 signal output_tlast     : std_logic := '0';
begin

-- Instantiation of Axi Bus Interface S_AXIS_input
process(s_axis_input_aclk)
	begin
	  if (falling_edge (s_axis_input_aclk)) then
	    if(s_axis_input_aresetn = '0') then

	      cstate <= idle;
	      busy <= '0';
	      
	      read_stream_pointer <= 0;
	      s_axis_input_tready <= '0';
	      
	      write_stream_pointer <= 0;
	      m_axis_output_tlast <= '0';
	      m_axis_output_tvalid <= '0';
	      
	      wr_en <= (others => '0');
	      rd_en <= (others => '0');
	      
	      mem_select_ff     <= (others => '0');
	      mem_select_dec_ff <= (others => '0');
	    else
	      case cstate is
	      when idle =>
	           if(cmd_valid = '1' and wr_nrd = '0' )then --read from stream and write into the cache
	              cstate <= reading;
                  busy   <= '1';
                  
                  read_stream_pointer <= 0;
                  write_stream_pointer <= 0;
                  
                  s_axis_input_tready <= '0';
                  
	              m_axis_output_tlast <= '0';
	              m_axis_output_tvalid <= '0';
	              
	              mem_select_ff <= mem_select;
	              --decoder
	              for i in 0 to total_cache_count-1 loop
	                   if TO_INTEGER(unsigned(mem_select)) = i then
	                       mem_select_dec_ff(i) <= '1';
	                   else
	                       mem_select_dec_ff(i) <= '0';
	                   end if;
	              end loop;
	              if TO_INTEGER(unsigned(mem_select)) < binary_cache_count then
	                   MAX_WORDS <= binary_cache_depth;
	              elsif TO_INTEGER(unsigned(mem_select)) = total_DCache_count then  
	                   MAX_WORDS <= i_cache_depth;
	              else
	                   MAX_WORDS <= int_cache_depth;
	              end if;
	           elsif(cmd_valid = '1' and wr_nrd = '1' )then --read from the cache and write into the stream
	               
	              cstate <= writing;
                  busy   <= '1';
                  
                  read_stream_pointer <= 0;
                  write_stream_pointer <= 0;
                  
                  s_axis_input_tready <= '0';                  
	              m_axis_output_tlast <= '0';
	              m_axis_output_tvalid <= '0';
	              
	              mem_select_ff <= mem_select;
	              
	              --decoder
	              for i in 0 to total_cache_count-1 loop
	                   if TO_INTEGER(unsigned(mem_select)) = i then
	                       mem_select_dec_ff(i) <= '1';
	                   else
	                       mem_select_dec_ff(i) <= '0';
	                   end if;
	              end loop;
	              if TO_INTEGER(unsigned(mem_select)) < binary_cache_count then
	                   MAX_WORDS <= binary_cache_depth;
	              elsif TO_INTEGER(unsigned(mem_select)) = total_DCache_count then  
	                   MAX_WORDS <= i_cache_depth;
	              else
	                   MAX_WORDS <= int_cache_depth;
	              end if;
	           else
	              cstate <= idle;
                  busy <= '0';

                  read_stream_pointer <= 0;
                  write_stream_pointer <= 0;
                  
                  s_axis_input_tready <= '0';                  
	              m_axis_output_tlast <= '0';
	              m_axis_output_tvalid <= '0';
                  mem_select_dec_ff <= (others => '0');
	           end if;
	      when reading =>
	           
	           if(s_axis_input_TLAST = '0' and s_axis_input_tvalid= '1' and read_stream_pointer < MAX_WORDS)then
	               busy   <= '1';
	               s_axis_input_tready <= '1';
	               cstate <= reading;
	               
                   
                   wr_en <= mem_select_dec_ff;
                   rd_en <= (others => '0');

                   
                   addr <= std_logic_vector(TO_UNSIGNED(read_stream_pointer, addr'length));
                   data_out <= s_axis_input_tdata;
                   read_stream_pointer <=  read_stream_pointer+1 after 15ps;
               elsif(s_axis_input_TLAST = '1' and s_axis_input_tvalid= '1' and read_stream_pointer < MAX_WORDS)then
	               busy   <= '0';
	               s_axis_input_tready <= '1';
	               cstate <= idle;
	               
                   
                   wr_en <= mem_select_dec_ff;
                   rd_en <= (others => '0');

                   
                   addr <= std_logic_vector(TO_UNSIGNED(read_stream_pointer, addr'length));
                   data_out <= s_axis_input_tdata;
                   read_stream_pointer <=  0 after 15ps;
               elsif(s_axis_input_tvalid= '1' and read_stream_pointer >= MAX_WORDS)then
                  if(s_axis_input_TLAST = '1')then
                       cstate <= idle;
                       busy   <= '0';
                       s_axis_input_tready <= '0';
                       wr_en <= (others => '0');
                  else
                       busy   <= '1';
                       cstate <= finish_reading;
                       s_axis_input_tready <= '1';
                  end if;

                  read_stream_pointer <= 0;
                  wr_en <= mem_select_dec_ff;
                  rd_en <= (others => '0');

                  
                  addr <= std_logic_vector(TO_UNSIGNED(read_stream_pointer, addr'length));                 
               else
                  s_axis_input_tready <= '1';
                  busy   <= '1';
               end if;
          when writing =>
               busy   <= '1';
               if(m_axis_output_tready = '1' and write_stream_pointer < MAX_WORDS-1) then--continue transaction befor the last transaction
                    write_stream_pointer <= write_stream_pointer+1;
                    output_tlast <= '0';
	                m_axis_output_tvalid <= '1';
	                
	                m_axis_output_tdata  <= data_in_array(to_integer(unsigned(mem_select_ff)));
	                rd_en <= mem_select_dec_ff;
                    wr_en <= (others => '0');
                    addr <= std_logic_vector(TO_UNSIGNED(read_stream_pointer, addr'length));
                   
	           elsif(m_axis_output_tready = '1' and write_stream_pointer >= MAX_WORDS-1) then--Last transaction
                    m_axis_output_tdata  <= data_in_array(to_integer(unsigned(mem_select_ff)));
	                rd_en <= mem_select_dec_ff ;
                    wr_en <= (others => '0');
                    addr <= std_logic_vector(TO_UNSIGNED(read_stream_pointer, addr'length));
                    
                    write_stream_pointer <= 0;
                    cstate <= finish_writing;
                    output_tlast <= '1';
	                m_axis_output_tvalid <= '1';
               end if;
	      when finish_reading =>
	           if(s_axis_input_TLAST = '1')then
	              cstate <= idle;
	              busy   <= '0';
	              wr_en <= (others => '0');
                  --read_stream_done<= '0';
                  read_stream_pointer <= 0;
                  s_axis_input_tready <= '0';
	           else
	              busy   <= '1';
	              cstate <= finish_reading;
                  --read_stream_done<= '0';
                  read_stream_pointer <= 0;
                  s_axis_input_tready <= '1';
	           end if;
	      when finish_writing =>
	           if(m_axis_output_tready = '1' and  output_tlast = '1') then
                   write_stream_pointer <= 0;
                   cstate <= idle;
                   output_tlast <= '0';
	               m_axis_output_tvalid <= '0';
	               busy <= '0';
	               rd_en <= (others => '0');
	           else
	               busy <= '1';
	           end if;
	      when others =>
	           
	      end case;
	    end if;
	  end if;
	end process;

    m_axis_output_tlast <= output_tlast;
end Behavioral;
