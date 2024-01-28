----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2023 02:13:45 PM
-- Design Name: 
-- Module Name: HDC_Package - Behavioral
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
use IEEE.NUMERIC_STD.ALL; 

package HDC_Package is
    function clogb2 (bit_depth : integer) return integer;
    function max    (a,b       : integer) return integer;
    function min    (a,b       : integer) return integer;
    
    constant int_size: integer := 8;
    type int_vector  is array(natural range <>) of std_logic_vector(int_size-1 downto 0);
    
    type byte_array is array(natural range <>) of std_logic_vector(7 downto 0);
    
    constant int_cache_count    : integer := 2;
    constant binary_cache_count : integer := 2;
    constant total_cache_count  : integer := int_cache_count+ binary_cache_count+1;
    constant total_DCache_count : integer := int_cache_count+ binary_cache_count;
    
    constant cache_port1_data_size           : integer := 32;
    constant binary_cache_port2_data_size    : integer := cache_port1_data_size;
    constant int_cache_port2_data_size       : integer := 32;
    constant i_cache_port2_data_size         : integer := 32;
    
    constant binary_cache_depth       : integer := 32;
    constant int_cache_depth          : integer := 32;
    constant int_cache_bytes          : integer := (int_size/8)*binary_cache_port2_data_size*int_cache_depth;
    constant i_cache_depth            : integer := 32;
    
    constant max_cache_depth    : integer := max(max(binary_cache_depth, (int_cache_bytes/4)), i_cache_depth);
    
	constant C_S_AXIS_input_TDATA_WIDTH	: integer	:= 32;
	constant C_M_AXIS_output_TDATA_WIDTH: integer	:= 32;
	
    type stream_bus    is array(total_cache_count-1 downto 0) of std_logic_vector(cache_port1_data_size-1 downto 0);
    type address_bus is array(total_cache_count-1 downto 0) of std_logic_vector(clogb2(max_cache_depth)-1 downto 0); 
    
    
    type binary_cache_select_array  is array(natural range <>) of   STD_LOGIC_VECTOR(clogb2(binary_cache_count-1)-1 downto 0);
    type int_cache_select_array  is array(natural range <>)    of   STD_LOGIC_VECTOR(clogb2(int_cache_count-1)-1    downto 0);
    ----------------------------------------------------
    ----------------------------------------------------
    -------------       PE Constants      --------------
    ----------------------------------------------------
    ----------------------------------------------------
    constant ROT_amount_max : integer := 8; 
    constant ROT_threads    : integer := 1;
    constant XOR_threads    : integer := 1;
    constant PSUM_threads   : integer := 1;
    constant MAJ_threads    : integer := 1;

    type XOR_outputs        is array(XOR_threads-1 downto 0) of std_logic_vector(binary_cache_port2_data_size-1 downto 0);

    type ROT_outputs        is array(ROT_threads-1 downto 0) of   std_logic_vector(binary_cache_port2_data_size-1 downto 0);
    type ROT_amount_vector  is array(natural range <>)       of   std_logic_vector(clogb2(ROT_amount_max)-1 downto 0);
    

    type PSUM_outputs is array(PSUM_threads-1 downto 0) of int_vector(int_cache_port2_data_size-1 downto 0);
    
    type MAJ_outputs        is array(MAJ_threads-1 downto 0) of   std_logic_vector(binary_cache_port2_data_size-1 downto 0);
    ----------------------------------------------------
    ----------------------------------------------------
    ----------------   MUX Constants -------------------
    ----------------------------------------------------
    type bcache_bus   is array(binary_cache_count-1 downto 0) of std_logic_vector(binary_cache_port2_data_size-1 downto 0);
    type intcache_bus is array(int_cache_count-1    downto 0) of int_vector(int_cache_port2_data_size-1 downto 0);
    
    type     bcache_in_mux_inputs   is array((ROT_threads+XOR_threads+MAJ_threads)-1 downto 0) of   std_logic_vector(binary_cache_port2_data_size-1 downto 0);
    constant bcache_In_select_size : integer  := clogb2(ROT_threads+XOR_threads+MAJ_threads);
    constant intcache_In_select_size: integer := clogb2(PSUM_threads);
    type     bcache_In_selects      is array(binary_cache_count-1 downto 0) of std_logic_vector(bcache_In_select_size-1 downto 0);
    type     intcache_selects       is array(int_cache_count-1 downto 0)    of std_logic_vector(intcache_In_select_size-1 downto 0);   
    
    
    ----------------------------------------------------
    ----------------------------------------------------
    ----------------   instruction config --------------
    ----------------------------------------------------
    constant opcodeBits: integer := 4;
    constant instSize  : integer := 32;
    
    constant BcacheSelectBits    : integer := clogb2(binary_cache_count);
    constant IntcacheSelectBits  : integer := clogb2(int_cache_count);

    constant xorThreadEnableBits  : integer := xor_Threads;
    constant rotThreadEnableBits  : integer := rot_Threads;
    constant majThreadEnableBits  : integer := maj_Threads;
    constant psumThreadEnableBits : integer := psum_Threads;
    
    constant xorAddressSize     : integer := (instSize-opcodeBits-xorThreadEnableBits)/xor_Threads;
    constant rotAddressSize     : integer := (instSize-opcodeBits-rotThreadEnableBits)/rot_Threads;
    constant majBAddressSize    : integer := (instSize-opcodeBits-majThreadEnableBits)/maj_Threads;
    constant majIntAddressSize  : integer := (instSize-opcodeBits-majThreadEnableBits)/maj_Threads;
    constant psumBAddressSize   : integer := (instSize-opcodeBits-psumThreadEnableBits)/psum_Threads;
    constant psumIntAddressSize : integer := (instSize-opcodeBits-psumThreadEnableBits)/psum_Threads;
    
    constant shiftBitsSize : integer := (instSize-opcodeBits-rotThreadEnableBits)/rot_Threads;
    constant levelBitsSize : integer := (instSize-opcodeBits-majThreadEnableBits)/maj_Threads;
    
    constant BAddressSize   : integer := min(min(min(xorAddressSize, rotAddressSize),majBAddressSize),psumBAddressSize);
    constant IntAddressSize : integer := min(psumIntAddressSize, majIntAddressSize);
    constant BRowsSelect    : integer := BAddressSize - BcacheSelectBits;
    constant IntRowsSelect  : integer := IntAddressSize - IntcacheSelectBits;
end HDC_Package;

package body HDC_Package is
  function clogb2 (bit_depth : integer) return integer is            
	 	variable depth  : integer := bit_depth;                               
	 	variable count  : integer := 1;                                       
	 begin                                                                   
	 	 for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	      if (bit_depth <= 2) then                                           
	        count := 1;                                                      
	      else                                                               
	        if(depth <= 1) then                                              
	 	       count := count;                                                
	 	     else                                                             
	 	       depth := depth / 2;                                            
	          count := count + 1;                                            
	 	     end if;                                                          
	 	   end if;                                                            
	   end loop;                                                             
	   return(count);        	                                              
	 end;
	 function max    (a,b     : integer) return integer is
	 begin
       if a >= b then
           return (a);
       end if;
       return (b);
	 end;
	 function min    (a,b     : integer) return integer is
	 begin
       if b < a then
           return (b);
       end if;
       return (a);
	 end;
end HDC_Package;
