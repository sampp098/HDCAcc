----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2023 05:19:53 PM
-- Design Name: 
-- Module Name: binary_cache - Behavioral
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

entity binary_cache is
    port(
        clk: in std_logic;
        rst: in std_logic;
        --port1
        addr1 : in  std_logic_vector(clogb2(binary_cache_depth)-1 downto 0);
        wr_en1: in  std_logic;
        rd_en1: in  std_logic;
        din1  : in  std_logic_vector(cache_port1_data_size-1 downto 0);
        dout1 : out std_logic_vector(cache_port1_data_size-1 downto 0);
        
        --port2
        addr2 : in  std_logic_vector(clogb2(binary_cache_depth)-1 downto 0);
        wr_en2: in  std_logic;
        rd_en2: in  std_logic;
        din2  : in  std_logic_vector(binary_cache_port2_data_size-1 downto 0);
        dout2 : out std_logic_vector(binary_cache_port2_data_size-1 downto 0)
    );
end binary_cache;

architecture Behavioral of binary_cache is

type memory is array(binary_cache_depth-1 downto 0) of std_logic_vector(cache_port1_data_size-1 downto 0);
signal mem: memory := (others => (others => '0'));

begin
    write_process:process(clk)
    begin
        if rising_edge (clk) then
            if rst ='1' then
                mem <= (others => (others => '0'));
            else
                if    wr_en1 = '1' and wr_en2='0' then
                    mem(to_integer(unsigned(addr1))) <= din1  after 5ps;
                elsif wr_en1 = '0' and wr_en2='1' then
                    mem(to_integer(unsigned(addr2))) <= din2  after 5ps;
                end if;   
            end if;
        end if;  
    end process;
    
    read_process:process(clk)
    begin
        if rising_edge (clk) then
            if rst ='1' then
                dout1 <= (others => '0');
                dout2 <= (others => '0');
            else
                if    rd_en1 = '1' then
                    dout1 <= mem(to_integer(unsigned(addr1)))  after 5ps;
                else
                    dout1 <= (others => '0');
                end if;   
                
                if    rd_en2 = '1' then
                    dout2 <= mem(to_integer(unsigned(addr2)))  after 5ps;
                else
                    dout2 <= (others => '0');
                end if;   
            end if;
        end if;  
    end process;
    
end Behavioral;
