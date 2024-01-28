----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/21/2023 09:47:04 PM
-- Design Name: 
-- Module Name: ROT_thread - Behavioral
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

entity ROT_thread is
    port(   clk             : in  std_logic;
            rst             : in  std_logic;
            cache_select    : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
            in_valid        : in  std_logic;
            reload_carry_in : in  std_logic;
            --cary_ins      : in  ROT_carry_in_vector(ROT_threads-1 downto 0);
            rot_amount      : in  std_logic_vector(clogb2(ROT_amount_max)-1 downto 0);
            inputs          : in  bcache_bus;
            output          : out std_logic_vector(binary_cache_port2_data_size-1 downto 0)
        );
end ROT_thread;

architecture Behavioral of ROT_thread is
constant shit_num : integer := ROT_amount_max;
component shift is
      generic(
        amount: integer := 1
      );
      Port (
        carry_in      : in  std_logic_vector(ROT_amount_max-1 downto 0); 
        input         : in  std_logic_vector(binary_cache_port2_data_size-1 downto 0);
        output        : out std_logic_vector(binary_cache_port2_data_size-1 downto 0);
        carry_out     : out std_logic_vector(ROT_amount_max-1 downto 0)
      );
end component;

component bcache_out_mux is
  Port ( 
         sel   : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
         inputs: in  bcache_bus;
         output: out STD_LOGIC_VECTOR (binary_cache_port2_data_size -1 downto 0)
  
  );
end component;

signal carry_out_tmp: std_logic_vector(ROT_amount_max-1 downto 0) := (others => '0');
signal carry_in_tmp:  std_logic_vector(ROT_amount_max-1 downto 0) := (others => '0');
signal input_tmp:     std_logic_vector(binary_cache_port2_data_size-1 downto 0) := (others => '0');

type shift_out_list_t is array(shit_num-1 downto 0) of std_logic_vector(binary_cache_port2_data_size-1 downto 0);
type carry_out_list_t is array(shit_num-1 downto 0) of std_logic_vector(ROT_amount_max-1 downto 0);
signal shift_out_list : shift_out_list_t := (others =>(others => '0'));
signal carry_out_list : carry_out_list_t := (others =>(others => '0'));

signal carry_out : std_logic_vector(ROT_amount_max-1 downto 0);

signal selected_cache_data: std_logic_vector(binary_cache_port2_data_size-1 downto 0);
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                input_tmp <= (others=> '0');
                carry_in_tmp <= (others => '0');
            elsif in_valid = '1' then
                if reload_carry_in = '1' then
                    input_tmp <= selected_cache_data;
                    carry_in_tmp <= (others => '0');
                else
                    carry_in_tmp <= carry_out;
                    input_tmp <= selected_cache_data;
                end if;
            end if;
        end if;
    end process;
    
    
    uROT_In_MUX: bcache_out_mux
        port map( sel     => cache_select,
                  inputs  => inputs,
                  output  => selected_cache_data
                  );
    
    shifter_list: for i in 0 to shit_num-1 generate
        u_shift: shift
        generic map(
                     amount => i+1
            )
        port map(   
                    carry_in => carry_in_tmp,
                    input    => input_tmp,
                    output   =>shift_out_list(i),
                    carry_out=>carry_out_list(i)
                );
    
    end generate shifter_list;
    
    output    <= shift_out_list(to_integer(unsigned(rot_amount)));
    carry_out <= carry_out_list(to_integer(unsigned(rot_amount)));
    
end Behavioral;
