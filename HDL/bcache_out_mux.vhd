----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/10/2023 10:47:23 PM
-- Design Name: 
-- Module Name: bcache_out_mux - Behavioral
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

entity bcache_out_mux is
  Port ( 
         sel   : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
         inputs: in  bcache_bus;
         output: out STD_LOGIC_VECTOR (binary_cache_port2_data_size -1 downto 0)
  
  );
end bcache_out_mux;

architecture Behavioral of bcache_out_mux is

begin
    output <= inputs(to_integer(unsigned(sel)));
end Behavioral;
