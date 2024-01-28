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

entity MAJ_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            in_valids     : in  std_logic_vector(MAJ_threads-1 downto 0);
            load_Ts       : in  std_logic_vector(MAJ_threads-1 downto 0);
            cache_selects : in  int_cache_select_array(MAJ_threads-1 downto 0);
            Ts            : in  int_vector(MAJ_threads-1 downto 0);
            inputs        : in  intcache_bus;
            outputs       : out MAJ_outputs
        );
end MAJ_PE;

architecture Behavioral of MAJ_PE is

component MAJ_thread is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            in_valid      : in  std_logic;
            load_T        : in  std_logic;
            cache_select  : in  STD_LOGIC_VECTOR (clogb2(int_cache_count-1)-1 downto 0);
            T             : in  std_logic_vector(int_size-1 downto 0);
            inputs        : in  intcache_bus;
            output        : out std_logic_vector(binary_cache_port2_data_size-1 downto 0)
        );
end component;

begin
    
   uMAJ_threads: for i in 0 to MAJ_threads-1 generate
        uMAJ_thread: MAJ_thread
            port map( clk => clk,
                      rst => rst,
                      cache_select   => cache_selects(i),
                      in_valid       => in_valids(i),
                      load_T         => load_Ts(i),
                      T              => Ts(i),
                      inputs         => inputs,
                      output         => outputs(i)
                     );
   end generate uMAJ_threads; 

end Behavioral;
