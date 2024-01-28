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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity INTCache_In_MUX is
    port(   --clk              : in  std_logic;
            en               : in  std_logic;
            in_select        : in  std_logic_vector(clogb2(PSUM_threads)-1 downto 0);
            inputs           : in  PSUM_Outputs;
            output           : out int_vector(int_cache_port2_data_size-1 downto 0)
        );
end INTCache_In_MUX;

architecture Behavioral of INTCache_In_MUX is

begin

    
output <= inputs(to_integer(unsigned(in_select))) when en = '1';

end Behavioral;