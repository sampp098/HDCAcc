----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/11/2023 10:08:04 PM
-- Design Name: 
-- Module Name: XOR_thread - Behavioral
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

entity XOR_thread is
    port(   clk             : in  std_logic;
            rst             : in  std_logic;
            cache_select    : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
            in_valid        : in  std_logic;
            load_A_nB       : in  std_logic;

            inputs          : in  bcache_bus;
            output          : out std_logic_vector(binary_cache_port2_data_size-1 downto 0)
        );
end XOR_thread;

architecture Behavioral of XOR_thread is
    component bcache_out_mux is
      Port ( 
             sel   : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
             inputs: in  bcache_bus;
             output: out STD_LOGIC_VECTOR (binary_cache_port2_data_size -1 downto 0)
      
      );
    end component;
    
    signal selected_cache_data: std_logic_vector(binary_cache_port2_data_size-1 downto 0);
    
    signal A,B:     std_logic_vector(binary_cache_port2_data_size-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                A <= (others=> '0');
                B <= (others=> '0');
            elsif in_valid = '1' then
                if load_A_nB = '1' then
                    A <= selected_cache_data;
                else
                    B <= selected_cache_data;
                end if;
            end if;
        end if;
    end process;
    
    uXOR_In_MUX: bcache_out_mux
        port map( sel     => cache_select,
                  inputs  => inputs,
                  output  => selected_cache_data
                  );
                  
    xor_vector: for i in 0 to binary_cache_port2_data_size-1 generate
        output(i) <= A(i) xor B(i);
    end generate xor_vector;

end Behavioral;
