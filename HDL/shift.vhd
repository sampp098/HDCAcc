----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/21/2023 10:14:52 PM
-- Design Name: 
-- Module Name: shift - Behavioral
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

entity shift is
      generic(
        amount: integer := 1
      );
      Port (
        carry_in      : in  std_logic_vector(ROT_amount_max-1 downto 0); 
        input         : in  std_logic_vector(binary_cache_port2_data_size-1 downto 0);
        output        : out std_logic_vector(binary_cache_port2_data_size-1 downto 0);
        carry_out     : out std_logic_vector(ROT_amount_max-1 downto 0)
      );
end shift;

architecture Behavioral of shift is
constant zero: std_logic_vector(ROT_amount_max-1 downto 0) := (others => '0');
begin
    
    output    <= carry_in(amount-1 downto 0)&input(binary_cache_port2_data_size-1 downto amount);
    carry_out <= zero(ROT_amount_max-1 downto amount) & input(amount-1 downto 0);

end Behavioral;
