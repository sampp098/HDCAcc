----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/11/2023 10:01:10 PM
-- Design Name: 
-- Module Name: XOR_PE - Behavioral
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

entity XOR_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            cache_selects : in  binary_cache_select_array(XOR_threads-1 downto 0);
            in_valids     : in  std_logic_vector(XOR_threads-1 downto 0);
            load_A_nBs     : in  std_logic_vector(XOR_threads-1 downto 0);
            
            inputs        : in  bcache_bus;
            outputs       : out XOR_outputs
        );
end XOR_PE;

architecture Behavioral of XOR_PE is
    component XOR_thread is
        port(   clk             : in  std_logic;
                rst             : in  std_logic;
                cache_select    : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
                in_valid        : in  std_logic;
                load_A_nB       : in  std_logic;

                inputs          : in  bcache_bus;
                output          : out std_logic_vector(binary_cache_port2_data_size-1 downto 0)
            );
    end component;
begin

    uXOR_threads: for i in 0 to XOR_threads-1 generate
        uXOR_thread: XOR_thread
            port map( clk => clk,
                      rst => rst,
                      cache_select   => cache_selects(i),
                      in_valid       => in_valids(i),
                      load_A_nB      => load_A_nBs(i),
                      inputs         => inputs,
                      output         => outputs(i)
                     );
   end generate uXOR_threads; 
end Behavioral;
