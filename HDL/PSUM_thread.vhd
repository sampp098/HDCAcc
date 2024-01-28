----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2023 08:32:39 PM
-- Design Name: 
-- Module Name: PSUM_thread - Behavioral
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

entity PSUM_thread is
    port(   clk             : in  std_logic;
            rst             : in  std_logic;
            cache_select    : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
            in_valid        : in  std_logic;
            reload          : in  std_logic;

            inputs          : in  bcache_bus;
            output          : out int_vector(int_cache_port2_data_size-1 downto 0)
        );
end PSUM_thread;

architecture Behavioral of PSUM_thread is
component ADD_1bit is
    port(   clk             : in  std_logic;
            rst             : in  std_logic;
            in_valid        : in  std_logic;
            reload          : in  std_logic;
    
            input           : in  std_logic;
            output          : out std_logic_vector(int_size-1 downto 0)
        );
end component;

component bcache_out_mux is
  Port ( 
         sel   : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
         inputs: in  bcache_bus;
         output: out STD_LOGIC_VECTOR (binary_cache_port2_data_size -1 downto 0)
  
  );
end component;
    
signal selected_cache_data: std_logic_vector(binary_cache_port2_data_size-1 downto 0);
begin
    
    
    
    add_1bit_vector: for i in 0 to binary_cache_port2_data_size-1 generate
        uAdd_1bit: ADD_1bit
            port map( 
                      clk      => clk,
                      rst      => rst,
                      in_valid => in_valid,
                      reload   => reload,
                      input    => selected_cache_data(i),
                      output   => output(i)
                     );
    end generate add_1bit_vector;
    
    uPSUM_In_MUX: bcache_out_mux
        port map( sel     => cache_select,
                  inputs  => inputs,
                  output  => selected_cache_data
                  );

end Behavioral;
