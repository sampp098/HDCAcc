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

entity MAJ_thread is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            in_valid      : in  std_logic;
            load_T        : in  std_logic;
            cache_select  : in  STD_LOGIC_VECTOR (clogb2(int_cache_count-1)-1 downto 0);
            T             : in  std_logic_vector(int_size-1 downto 0);
            inputs        : in  intcache_bus;
            output        : out std_logic_vector(binary_cache_port2_data_size-1 downto 0)
    );
end MAJ_thread;

architecture Behavioral of MAJ_thread is

component MAJ_1bit is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            in_valid      : in  std_logic;
            T             : in  std_logic_vector(int_size-1 downto 0);
            input         : in  std_logic_vector(int_size-1 downto 0);
            output        : out std_logic
        );
end component;

component intcache_out_mux is
  Port ( 
         sel   : in  STD_LOGIC_VECTOR (clogb2(binary_cache_count-1)-1 downto 0);
         inputs: in  intcache_bus;
         output: out int_vector(binary_cache_port2_data_size-1 downto 0)
  
  );
end component;

signal selected_cache_data: int_vector(binary_cache_port2_data_size-1 downto 0);
signal T_dff :  std_logic_vector(int_size-1 downto 0) := (others => '0');
begin
   
   process(clk)
   begin
        if rising_edge(clk) then
            if (rst = '1') then
                T_dff <= (others => '0');
            elsif load_T = '1' then
                T_dff <= T;
            end if;
        end if;
   end process;
   
   maj_1bit_vector: for i in 0 to binary_cache_port2_data_size-1 generate
        uMAJ_1bit: MAJ_1bit
            port map( 
                      clk      => clk,
                      rst      => rst,
                      in_valid => in_valid,
                      T        => T_dff,
                      input    => selected_cache_data(i),
                      output   => output(i)
                     );
    end generate maj_1bit_vector;
    
    uMAJ_In_MUX: intcache_out_mux
        port map( sel     => cache_select,
                  inputs  => inputs,
                  output  => selected_cache_data
                  );

end Behavioral;
