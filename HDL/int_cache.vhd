----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2023 05:19:53 PM
-- Design Name: 
-- Module Name: int_cache - Behavioral
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

entity int_cache is

port(
        clk: in std_logic;
        rst: in std_logic;
        --port1
        addr1 : in  std_logic_vector(clogb2(int_cache_bytes)-3 downto 0); --two bit from LSB are dropped
        wr_en1: in  std_logic;
        rd_en1: in  std_logic;
        din1  : in  std_logic_vector(cache_port1_data_size-1 downto 0);
        dout1 : out std_logic_vector(cache_port1_data_size-1 downto 0);
        
        --port2
        addr2 : in  std_logic_vector(clogb2(int_cache_depth)-1 downto 0);
        wr_en2: in  std_logic;
        rd_en2: in  std_logic;
        din2  : in  int_vector(int_cache_port2_data_size-1 downto 0);
        dout2 : out int_vector(int_cache_port2_data_size-1 downto 0)
    );
end int_cache;

architecture Behavioral of int_cache is

--type memory is array(int_cache_depth-1 downto 0) of std_logic_vector(cache_data_size-1 downto 0);
signal mem : byte_array(int_cache_bytes-1 downto 0);
--signal mem: memory := (others => (others => '0'));
begin
    write_process:process(clk)
        variable address_2 : std_logic_vector(clogb2(int_cache_depth)-1+5 downto 0);
        variable address_1 : std_logic_vector(clogb2(int_cache_bytes)-1 downto 0);
    begin
        address_2 := addr2 & "00000";
        address_1 := addr1 & "00";
        if rising_edge (clk) then
            if rst ='1' then
                mem <= (others => (others => '0'));
            else
                if    wr_en1 = '1' and wr_en2='0' then
                    mem(to_integer(unsigned(address_1)))   <= din1(7 downto 0);
                    mem(to_integer(unsigned(address_1)+1)) <= din1(15 downto 8);
                    mem(to_integer(unsigned(address_1)+2)) <= din1(23 downto 16);
                    mem(to_integer(unsigned(address_1)+3)) <= din1(31 downto 24);
                    
                elsif wr_en1 = '0' and wr_en2='1' then
                    for i in 0 to 31 loop
                        mem(to_integer(unsigned(address_2)+i)) <= din2(i);
                    end loop;
                end if;   
            end if;
        end if;  
    end process;
    
    read_process:process(clk)
        variable address_2 : std_logic_vector(clogb2(int_cache_depth)-1+5 downto 0);
        variable address_1 : std_logic_vector(clogb2(int_cache_bytes)-1 downto 0);
    begin
        address_2 := addr2 & "00000";
        address_1 := addr1 & "00";
        if rising_edge (clk) then
            if rst ='1' then
                dout1 <= (others => '0');
                dout2 <= (others => (others => '0'));
            else
                if    rd_en1 = '1' then
                    dout1(7 downto 0)   <= mem(to_integer(unsigned(address_1)));
                    dout1(15 downto 8)  <= mem(to_integer(unsigned(address_1)+1));
                    dout1(23 downto 16) <= mem(to_integer(unsigned(address_1)+2));
                    dout1(31 downto 24) <= mem(to_integer(unsigned(address_1)+3));
                else
                    dout1 <= (others => '0');
                end if;   
                
                if    rd_en2 = '1' then
                    for i in 0 to 31 loop
                        dout2(i) <= mem(to_integer(unsigned(address_2)+i));
                    end loop;
                else
                    dout2 <= (others => (others => '0'));
                end if;   
            end if;
        end if;  
    end process;
    
end Behavioral;
