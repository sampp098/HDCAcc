----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2023 07:25:04 AM
-- Design Name: 
-- Module Name: ROT_PE - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROT_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            cache_selects : in  binary_cache_select_array(ROT_threads-1 downto 0);
            in_valids     : in  std_logic_vector(ROT_threads-1 downto 0);
            load_carry_in : in  std_logic_vector(ROT_threads-1 downto 0);
            
            --cary_ins      : in  ROT_carry_in_vector(ROT_threads-1 downto 0);
            rot_amounts   : in  ROT_amount_vector(ROT_threads-1 downto 0);
            inputs        : in  bcache_bus;
            outputs       : out ROT_outputs
        );
end ROT_PE;

architecture Behavioral of ROT_PE is

component ROT_thread is
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
end component;

begin
    
   uROT_threads: for i in 0 to ROT_threads-1 generate
        uROT_thread: ROT_thread
            port map( clk => clk,
                      rst => rst,
                      cache_select   => cache_selects(i),
                      in_valid       => in_valids(i),
                      reload_carry_in=> load_carry_in(i),
                      rot_amount     => rot_amounts(i),
                      inputs         => inputs,
                      output         => outputs(i)
                     );
   end generate uROT_threads;

end Behavioral;
