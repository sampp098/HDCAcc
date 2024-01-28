----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2023 08:26:07 PM
-- Design Name: 
-- Module Name: PSUM_PE - Behavioral
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

entity PSUM_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            in_valids     : in  std_logic_vector(PSUM_threads-1 downto 0);
            reloads       : in  std_logic_vector(PSUM_threads-1 downto 0);
            cache_selects : in  binary_cache_select_array(PSUM_threads-1 downto 0);
            inputs        : in  bcache_bus;
            outputs       : out PSUM_outputs
        );
end PSUM_PE;

architecture Behavioral of PSUM_PE is
    component PSUM_thread is
        port(   clk             : in  std_logic;
                rst             : in  std_logic;
                cache_select    : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
                in_valid        : in  std_logic;
                reload          : in  std_logic;

                inputs          : in  bcache_bus;
                output          : out int_vector(int_cache_port2_data_size-1 downto 0)
            );
    end component;
begin

    uPSUM_threads: for i in 0 to PSUM_threads-1 generate
        uPSUM_thread: PSUM_thread
            port map( clk => clk,
                      rst => rst,
                      cache_select   => cache_selects(i),
                      in_valid       => in_valids(i),
                      reload         => reloads(i),
                      inputs         => inputs,
                      output         => outputs(i)
                     );
   end generate uPSUM_threads;
   
end Behavioral;
