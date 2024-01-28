----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2023 08:36:24 PM
-- Design Name: 
-- Module Name: ADD_1bit - Behavioral
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

entity ADD_1bit is
    port(   clk             : in  std_logic;
            rst             : in  std_logic;
            in_valid        : in  std_logic;
            reload          : in  std_logic;
    
            input           : in  std_logic;
            output          : out std_logic_vector(int_size-1 downto 0)
        );
end ADD_1bit;

architecture Behavioral of ADD_1bit is

signal acc: std_logic_vector(int_size-1 downto 0) := (others => '0');

begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or reload = '1' then
                acc <= (others=> '0');
            elsif in_valid = '1' and input = '1' then
                acc <= std_logic_vector(unsigned(acc) + 1);
            end if;
        end if;
    end process;
    
    output <= acc;

end Behavioral;
