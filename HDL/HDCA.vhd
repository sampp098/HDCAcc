----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2023 01:42:58 PM
-- Design Name: 
-- Module Name: HDCA - Behavioral
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

entity HDCA is
    generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI_CTRL
		C_S_AXI_CTRL_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_CTRL_ADDR_WIDTH	: integer	:= 5;

		-- Parameters of Axi Slave Bus Interface S_AXIS_input
		C_S_AXIS_input_TDATA_WIDTH	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface M_AXIS_output
		C_M_AXIS_output_TDATA_WIDTH	: integer	:= 32;
		C_M_AXIS_output_START_COUNT	: integer	:= 32
	);
    Port ( 
    
        clk   : in std_logic;
        reset : in std_logic;
    -- Ports of Axi Slave Bus Interface S_AXI_CTRL
		s_axi_ctrl_aclk	: in std_logic;
		s_axi_ctrl_aresetn	: in std_logic;
		s_axi_ctrl_awaddr	: in std_logic_vector(C_S_AXI_CTRL_ADDR_WIDTH-1 downto 0);
		s_axi_ctrl_awprot	: in std_logic_vector(2 downto 0);
		s_axi_ctrl_awvalid	: in std_logic;
		s_axi_ctrl_awready	: out std_logic;
		s_axi_ctrl_wdata	: in std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
		s_axi_ctrl_wstrb	: in std_logic_vector((C_S_AXI_CTRL_DATA_WIDTH/8)-1 downto 0);
		s_axi_ctrl_wvalid	: in std_logic;
		s_axi_ctrl_wready	: out std_logic;
		s_axi_ctrl_bresp	: out std_logic_vector(1 downto 0);
		s_axi_ctrl_bvalid	: out std_logic;
		s_axi_ctrl_bready	: in std_logic;
		s_axi_ctrl_araddr	: in std_logic_vector(C_S_AXI_CTRL_ADDR_WIDTH-1 downto 0);
		s_axi_ctrl_arprot	: in std_logic_vector(2 downto 0);
		s_axi_ctrl_arvalid	: in std_logic;
		s_axi_ctrl_arready	: out std_logic;
		s_axi_ctrl_rdata	: out std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
		s_axi_ctrl_rresp	: out std_logic_vector(1 downto 0);
		s_axi_ctrl_rvalid	: out std_logic;
		s_axi_ctrl_rready	: in std_logic;
    
        -- Ports of Axi Stream Slave Bus Interface S_AXIS_input
		s_axis_input_aclk	: in std_logic;
		s_axis_input_aresetn	: in std_logic;
		s_axis_input_tready	: out std_logic;
		s_axis_input_tdata	: in std_logic_vector(C_S_AXIS_input_TDATA_WIDTH-1 downto 0);
		s_axis_input_tkeep	: in std_logic_vector((C_S_AXIS_input_TDATA_WIDTH/8)-1 downto 0);
		s_axis_input_tlast	: in std_logic;
		s_axis_input_tvalid	: in std_logic;
    
        -- Ports of Axi Stream Master Bus Interface M_AXIS_output
		m_axis_output_aclk	: in std_logic;
		m_axis_output_aresetn	: in std_logic;
		m_axis_output_tvalid	: out std_logic;
		m_axis_output_tdata	: out std_logic_vector(C_M_AXIS_output_TDATA_WIDTH-1 downto 0);
		m_axis_output_tkeep	: out std_logic_vector((C_M_AXIS_output_TDATA_WIDTH/8)-1 downto 0);
		m_axis_output_tlast	: out std_logic;
		m_axis_output_tready	: in std_logic
    );
end HDCA;

-----------------------------------------------------
-----------------------------------------------------
------------- AXI Ctrl here -------------------------
-----------------------------------------------------

architecture Behavioral of HDCA is

component axi_ctrl is
	generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
        input_reg0 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        input_reg1 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        input_reg2 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        input_reg3 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        input_reg4 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        input_reg5 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        input_reg6 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        input_reg7 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        
        output_reg0 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        output_reg1 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        output_reg2 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        output_reg3 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        output_reg4 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        output_reg5 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        output_reg6 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        output_reg7 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end component;


-----------------------------------------------------
-----------------------------------------------------
------------- AXI Stream Switch here ----------------
-----------------------------------------------------

component stream_switch is

    Port (
        --switch control signals
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        cmd_valid : in  STD_LOGIC;
        wr_nrd    : in  std_logic;
        mem_select: in  std_logic_vector(clogb2(total_cache_count)-1 downto 0);
        busy      : out std_logic;
        
        -- Ports of Axi Stream Slave Bus Interface S_AXIS_input
		s_axis_input_aclk	: in std_logic;
		s_axis_input_aresetn: in std_logic;
		s_axis_input_tready	: out std_logic;
		s_axis_input_tdata	: in std_logic_vector(C_S_AXIS_input_TDATA_WIDTH-1 downto 0);
		s_axis_input_tkeep	: in std_logic_vector((C_S_AXIS_input_TDATA_WIDTH/8)-1 downto 0);
		s_axis_input_tlast	: in std_logic;
		s_axis_input_tvalid	: in std_logic;
    
        -- Ports of Axi Stream Master Bus Interface M_AXIS_output
		m_axis_output_aclk	: in std_logic;
		m_axis_output_aresetn	: in std_logic;
		m_axis_output_tvalid	: out std_logic;
		m_axis_output_tdata	: out std_logic_vector(C_M_AXIS_output_TDATA_WIDTH-1 downto 0);
		m_axis_output_tkeep	: out std_logic_vector((C_M_AXIS_output_TDATA_WIDTH/8)-1 downto 0);
		m_axis_output_tlast	: out std_logic;
		m_axis_output_tready	: in std_logic;
        
        -- cache ports
        data_in_array: in stream_bus;
        data_out     : out std_logic_vector(cache_port1_data_size-1 downto 0);
        wr_en        : out std_logic_vector(total_cache_count-1 downto 0);
        rd_en        : out std_logic_vector(total_cache_count-1 downto 0);
        addr         : out std_logic_vector(clogb2(max_cache_depth)-1 downto 0)
    );
end component;

-----------------------------------------------------
-----------------------------------------------------
------------- Cache Components here -----------------
-----------------------------------------------------

component binary_cache is
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
end component;

component int_cache is
    port(
        clk: in std_logic;
        rst: in std_logic;
        --port1
        addr1 : in  std_logic_vector(clogb2(int_cache_bytes)-3 downto 0);  --two bit from LSB are dropped
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
end component;

-----------------------------------------------------
-----------------------------------------------------
------------- Control module here -------------------
-----------------------------------------------------

component control is
    port(
        clk       : in std_logic;
        reset     : in std_logic;
        --port1
        addr1   : in std_logic_vector(clogb2(i_cache_depth)-1 downto 0);
        wr_en1  : in std_logic;
        rd_en1  : in std_logic;
        din1    : in std_logic_vector(cache_port1_data_size-1 downto 0);
        dout1   : out std_logic_vector(cache_port1_data_size-1 downto 0);
        
        ----------------------------------
        --------- Control registers ------
        
        input_reg0 : in std_logic_vector(31 downto 0);
        input_reg1 : in std_logic_vector(31 downto 0);
        input_reg2 : in std_logic_vector(31 downto 0);
        input_reg3 : in std_logic_vector(31 downto 0);
        output_reg4 : out std_logic_vector(31 downto 0);
        output_reg5 : out std_logic_vector(31 downto 0);
        output_reg6 : out std_logic_vector(31 downto 0);
        output_reg7 : out std_logic_vector(31 downto 0);
        
        ----------------------------------
        --------- Control signals   ------
        rst     : out std_logic;
        
        ctrl_sw_busy      : in std_logic;
        ctrl_sw_cmd_valid : out std_logic;
        ctrl_sw_wr_nrd    : out std_logic;
        ctrl_sw_mem_select: out std_logic_vector(clogb2(total_cache_count)-1 downto 0) := (others => '0');
        
        ctrl_wr_en_bus    : out std_logic_vector(total_cache_count-1 downto 0);
        ctrl_rd_en_bus    : out std_logic_vector(total_cache_count-1 downto 0);
        ctrl_addr_bus     : out address_bus;
        
        ctrl_xor_cache_selects     : out binary_cache_select_array(XOR_threads-1 downto 0);
        ctrl_xor_in_valids         : out std_logic_vector(XOR_threads-1 downto 0);
        ctrl_xor_Load_A_nBs        : out std_logic_vector(XOR_threads-1 downto 0);
        
        ctrl_rot_cache_selects     : out binary_cache_select_array(ROT_threads-1 downto 0);
        ctrl_rot_in_valids         : out std_logic_vector(ROT_threads-1 downto 0);
        ctrl_rot_load_carry_in     : out std_logic_vector(ROT_threads-1 downto 0);
        ctrl_rot_amounts           : out ROT_amount_vector(ROT_threads-1 downto 0);
        
        ctrl_psum_cache_selects    : out binary_cache_select_array(PSUM_threads-1 downto 0);
        ctrl_psum_in_valids        : out std_logic_vector(PSUM_threads-1 downto 0);
        ctrl_psum_reloads          : out std_logic_vector(PSUM_threads-1 downto 0);
        
        ctrl_maj_cache_selects     : out int_cache_select_array(MAJ_threads-1 downto 0);
        ctrl_maj_in_valids         : out std_logic_vector(MAJ_threads-1 downto 0);
        ctrl_maj_load_Ts           : out std_logic_vector(MAJ_threads-1 downto 0);
        ctrl_maj_T                 : out int_vector(MAJ_threads-1 downto 0);
        
        ctrl_bcache_In_sels        : out bcache_In_selects := (others => (others =>'0'));
        ctrl_intcache_In_sels      : out intcache_selects:= (others => (others =>'0'))
        
        );
end component;

-----------------------------------------------------
-----------------------------------------------------
------------- Multiplexers here ---------------------
-----------------------------------------------------

component bcache_In_MUX is
    port(   --clk              : in  std_logic;
            en               : in  std_logic;
            in_select        : in  std_logic_vector(bcache_In_select_size-1 downto 0);
            inputs           : in  bcache_in_mux_inputs;
            output           : out std_logic_vector(binary_cache_port2_data_size-1 downto 0)
        );
end component;

component INTCache_In_MUX is
    port(   --clk              : in  std_logic;
            en               : in  std_logic;
            in_select        : in  std_logic_vector(clogb2(PSUM_threads)-1 downto 0);
            inputs           : in  PSUM_Outputs;
            output           : out int_vector(int_cache_port2_data_size-1 downto 0)
        );
end component;
-----------------------------------------------------
-----------------------------------------------------
------------- Processing Elements -------------------
-----------------------------------------------------

component ROT_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            cache_selects : in  binary_cache_select_array(ROT_threads-1 downto 0);
            in_valids     : in  std_logic_vector(ROT_threads-1 downto 0);
            load_carry_in : in  std_logic_vector(ROT_threads-1 downto 0);
            
            --cary_ins      : in  ROT_carry_in_vector(ROT_threads-1 downto 0);
            rot_amounts   : in  ROT_amount_vector(ROT_threads-1 downto 0);
            inputs        : in  bcache_bus;
            outputs       : out ROT_outputs
        );
end component;

component XOR_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            cache_selects : in  binary_cache_select_array(XOR_threads-1 downto 0);
            in_valids     : in  std_logic_vector(XOR_threads-1 downto 0);
            load_A_nBs    : in  std_logic_vector(XOR_threads-1 downto 0);
            
            inputs        : in  bcache_bus;
            outputs       : out XOR_outputs
        );
end component;



component PSUM_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            in_valids     : in  std_logic_vector(PSUM_threads-1 downto 0);
            reloads       : in  std_logic_vector(PSUM_threads-1 downto 0);
            cache_selects : in  binary_cache_select_array(PSUM_threads-1 downto 0);
            inputs        : in  bcache_bus;
            outputs       : out PSUM_outputs
        );
end component;

component MAJ_PE is
    port(   clk           : in  std_logic;
            rst           : in  std_logic;
            in_valids     : in  std_logic_vector(MAJ_threads-1 downto 0);
            load_Ts       : in  std_logic_vector(MAJ_threads-1 downto 0);
            cache_selects : in  int_cache_select_array(MAJ_threads-1 downto 0);
            Ts            : in  int_vector(MAJ_threads-1 downto 0);
            inputs        : in  intcache_bus;
            outputs       : out MAJ_outputs
        );
end component;

-----------------------------------------------------
-----------------------------------------------------
------------------ Signals here ---------------------
-----------------------------------------------------
signal rst : std_logic := '0';

signal sw_data_in_array  : stream_bus;


signal ctrl_sw_cmd_valid : std_logic := '0';
signal ctrl_sw_wr_nrd    : std_logic := '0';
signal ctrl_sw_mem_select:  std_logic_vector(clogb2(total_cache_count)-1 downto 0) := (others => '0');
signal ctrl_sw_busy      : std_logic;

signal ctrl_wr_en_bus   : std_logic_vector(total_cache_count-1 downto 0);
signal ctrl_rd_en_bus   : std_logic_vector(total_cache_count-1 downto 0);

signal ctrl_xor_cache_selects     : binary_cache_select_array(XOR_threads-1 downto 0);
signal ctrl_xor_in_valids         : std_logic_vector(XOR_threads-1 downto 0) := (others => '0');
signal ctrl_xor_Load_A_nBs        : std_logic_vector(XOR_threads-1 downto 0) := (others => '0');

signal ctrl_rot_cache_selects     : binary_cache_select_array(ROT_threads-1 downto 0);
signal ctrl_rot_in_valids         : std_logic_vector(ROT_threads-1 downto 0) := (others => '0');
signal ctrl_rot_load_carry_in     : std_logic_vector(ROT_threads-1 downto 0);
signal ctrl_rot_amounts           : ROT_amount_vector(ROT_threads-1 downto 0) := (others => (others =>'0'));

signal ctrl_psum_cache_selects: binary_cache_select_array(PSUM_threads-1 downto 0);
signal ctrl_psum_in_valids    : std_logic_vector(PSUM_threads-1 downto 0) := (others => '0');
signal ctrl_psum_reloads      : std_logic_vector(PSUM_threads-1 downto 0) := (others => '0');

signal ctrl_maj_cache_selects: int_cache_select_array(MAJ_threads-1 downto 0);
signal ctrl_maj_in_valids    : std_logic_vector(MAJ_threads-1 downto 0) := (others => '0');
signal ctrl_maj_load_Ts      : std_logic_vector(MAJ_threads-1 downto 0) := (others => '0');
signal ctrl_maj_T            : int_vector(MAJ_threads-1 downto 0):= ( others => (others => '0'));

signal ctrl_bcache_In_sels : bcache_In_selects := (others => (others =>'0'));
signal ctrl_intcache_In_sels : intcache_selects:= (others => (others =>'0'));

signal sw_data_out     : std_logic_vector(cache_port1_data_size-1 downto 0);
signal sw_wr_en        : std_logic_vector(total_cache_count-1 downto 0);
signal sw_rd_en        : std_logic_vector(total_cache_count-1 downto 0);
signal sw_addr         : std_logic_vector(clogb2(max_cache_depth)-1 downto 0);

signal data_in_bus             : bcache_bus;
signal bcache_p2_data_out_bus  : bcache_bus;
signal intcache_p2_data_out_bus: intcache_bus;
signal intdata_in_bus          : intcache_bus;

--signal wr_en_bus   : std_logic_vector(clogb2(total_cache_count)-1 downto 0);
--signal rd_en_bus   : std_logic_vector(clogb2(total_cache_count)-1 downto 0);

signal ctrl_addr_bus    : address_bus;

--XOR and XOR Mux



signal xor_data_outs              : XOR_outputs := ( others => (others => '0'));


--ROT and ROT Mux

signal rot_data_outs              : ROT_outputs := ( others => (others => '0'));


--PSUM and PSUM Mux

signal psum_data_outs         : PSUM_outputs := ( others => (others => (others => '0')));

--MAJ and MAJ Mux

signal maj_data_outs         : maj_outputs := ( others => (others => '0'));

--Bcache Input Mux
signal binary_pe_outs : bcache_in_mux_inputs;


--------------------------------------------------------------------------
-----------------------                  ---------------------------------
----------------------  Control registers --------------------------------
------------------------                 ---------------------------------
--------------------------------------------------------------------------

signal reg0 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
signal reg1 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
signal reg2 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
signal reg3 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
signal reg4 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
signal reg5 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
signal reg6 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
signal reg7 : std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);

begin
    ctrl_registers : axi_ctrl
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_CTRL_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_CTRL_ADDR_WIDTH
	)
	port map (
	    input_reg0 => reg0,
        input_reg1 => reg1,
        input_reg2 => reg2,
        input_reg3 => reg3,
        input_reg4 => reg4,
        input_reg5 => reg5,
        input_reg6 => reg6,
        input_reg7 => reg7,
                   
        output_reg0 => reg0,   
        output_reg1 => reg1,
        output_reg2 => reg2,
        output_reg3 => reg3,
        output_reg4 => reg4,
        output_reg5 => reg5,
        output_reg6 => reg6,
        output_reg7 => reg7,
        
		S_AXI_ACLK	=> s_axi_ctrl_aclk,
		S_AXI_ARESETN	=> s_axi_ctrl_aresetn,
		S_AXI_AWADDR	=> s_axi_ctrl_awaddr,
		S_AXI_AWPROT	=> s_axi_ctrl_awprot,
		S_AXI_AWVALID	=> s_axi_ctrl_awvalid,
		S_AXI_AWREADY	=> s_axi_ctrl_awready,
		S_AXI_WDATA	=> s_axi_ctrl_wdata,
		S_AXI_WSTRB	=> s_axi_ctrl_wstrb,
		S_AXI_WVALID	=> s_axi_ctrl_wvalid,
		S_AXI_WREADY	=> s_axi_ctrl_wready,
		S_AXI_BRESP	=> s_axi_ctrl_bresp,
		S_AXI_BVALID	=> s_axi_ctrl_bvalid,
		S_AXI_BREADY	=> s_axi_ctrl_bready,
		S_AXI_ARADDR	=> s_axi_ctrl_araddr,
		S_AXI_ARPROT	=> s_axi_ctrl_arprot,
		S_AXI_ARVALID	=> s_axi_ctrl_arvalid,
		S_AXI_ARREADY	=> s_axi_ctrl_arready,
		S_AXI_RDATA	=> s_axi_ctrl_rdata,
		S_AXI_RRESP	=> s_axi_ctrl_rresp,
		S_AXI_RVALID	=> s_axi_ctrl_rvalid,
		S_AXI_RREADY	=> s_axi_ctrl_rready
	);
    u_stream_switch: stream_switch
        port map(   clk => clk,
                    rst => rst,
                    cmd_valid  => ctrl_sw_cmd_valid,
                    wr_nrd     => ctrl_sw_wr_nrd,
                    mem_select => ctrl_sw_mem_select,
                    busy       => ctrl_sw_busy,
                    
                    s_axis_input_aclk => s_axis_input_aclk,
                    s_axis_input_aresetn => s_axis_input_aresetn,
                    s_axis_input_tready => s_axis_input_tready,
                    s_axis_input_tdata => s_axis_input_tdata,
                    s_axis_input_tkeep => s_axis_input_tkeep,
                    s_axis_input_tlast => s_axis_input_tlast,
                    s_axis_input_tvalid => s_axis_input_tvalid,
                    
                    m_axis_output_aclk => m_axis_output_aclk,
                    m_axis_output_aresetn=> m_axis_output_aresetn,
                    m_axis_output_tvalid=> m_axis_output_tvalid,
                    m_axis_output_tdata=> m_axis_output_tdata,
                    m_axis_output_tkeep=> m_axis_output_tkeep,
                    m_axis_output_tlast=> m_axis_output_tlast,
                    m_axis_output_tready=> m_axis_output_tready,
                    
                    data_in_array => sw_data_in_array,
                    data_out => sw_data_out,
                    wr_en => sw_wr_en,
                    rd_en => sw_rd_en,
                    addr  => sw_addr
                    
                );
    
    
    binary_caches: for i in 0 to binary_cache_count-1 generate
        U_bcache: binary_cache
            port map(clk => clk,
                     rst => rst,
                     --port1
                     addr1  => sw_addr(clogb2(binary_cache_depth)-1 downto 0),
                     wr_en1 => sw_wr_en(i),
                     rd_en1 => sw_rd_en(i),
                     din1   => sw_data_out,
                     dout1  => sw_data_in_array(i),
                     --port2
                     addr2 =>  ctrl_addr_bus(i)(clogb2(binary_cache_depth)-1 downto 0),
                     wr_en2 => ctrl_wr_en_bus(i),
                     rd_en2 => ctrl_rd_en_bus(i),
                     din2   => data_in_bus(i),
                     dout2  => bcache_p2_data_out_bus(i)
                     );
    end generate binary_caches;
    
    int_caches: for i in binary_cache_count to total_DCache_count-1 generate
        U_intcache: int_cache
            port map(clk => clk,
                     rst => rst,
                     --port1
                     addr1  => sw_addr(clogb2(int_cache_bytes)-3 downto 0),
                     wr_en1 => sw_wr_en(i),
                     rd_en1 => sw_rd_en(i),
                     din1   => sw_data_out,
                     dout1  => sw_data_in_array(i),
                     --port2
                     addr2  =>  ctrl_addr_bus(i)(clogb2(int_cache_depth)-1 downto 0),
                     wr_en2 =>  ctrl_wr_en_bus(i),
                     rd_en2 =>  ctrl_rd_en_bus(i),
                     din2   =>  intdata_in_bus(i-binary_cache_count),--data_in_bus(i),
                     dout2  =>  intcache_p2_data_out_bus(i-binary_cache_count)--data_out_bus(i)
                     );
    end generate int_caches;
    
    U_control: control
    port map(   clk   => clk,
                reset => reset,
                
                --port1
                addr1  => sw_addr(clogb2(i_cache_depth)-1 downto 0),
                wr_en1 => sw_wr_en(total_cache_count-1),
                rd_en1 => sw_rd_en(total_cache_count-1),
                din1   => sw_data_out,
                dout1  => sw_data_in_array(total_cache_count-1),
                -----------------------------------------------
                --------------- Control registers -------------
                
                input_reg0 => reg0,
                input_reg1 => reg1,
                input_reg2 => reg2,
                input_reg3 => reg3,
                output_reg4 => reg4,
                output_reg5 => reg5,
                output_reg6 => reg6,
                output_reg7 => reg7,
                
                -----------------------------------------------
                --------------- Control signals   -------------
                rst => rst,
                
                ctrl_sw_busy      => ctrl_sw_busy,
                ctrl_sw_cmd_valid => ctrl_sw_cmd_valid,
                ctrl_sw_wr_nrd    => ctrl_sw_wr_nrd,
                ctrl_sw_mem_select=> ctrl_sw_mem_select,
                
                ctrl_wr_en_bus    => ctrl_wr_en_bus,
                ctrl_rd_en_bus    => ctrl_rd_en_bus,
                ctrl_addr_bus     => ctrl_addr_bus,
                
                ctrl_xor_cache_selects     => ctrl_xor_cache_selects,
                ctrl_xor_in_valids         => ctrl_xor_in_valids,
                ctrl_xor_Load_A_nBs        => ctrl_xor_Load_A_nBs,
                
                ctrl_rot_cache_selects     => ctrl_rot_cache_selects,
                ctrl_rot_in_valids         => ctrl_rot_in_valids,
                ctrl_rot_load_carry_in     => ctrl_rot_load_carry_in,
                ctrl_rot_amounts           => ctrl_rot_amounts,
                
                ctrl_psum_cache_selects    => ctrl_psum_cache_selects,
                ctrl_psum_in_valids        => ctrl_psum_in_valids,
                ctrl_psum_reloads          => ctrl_psum_reloads,
                
                ctrl_maj_cache_selects     => ctrl_maj_cache_selects,
                ctrl_maj_in_valids         => ctrl_maj_in_valids,
                ctrl_maj_load_Ts           => ctrl_maj_load_Ts,
                ctrl_maj_T                 => ctrl_maj_T,
                
                ctrl_bcache_In_sels        => ctrl_bcache_In_sels,
                ctrl_intcache_In_sels      => ctrl_intcache_In_sels
                );
                     
   ----------------------------
   -----------MUX Port Map-----
   U_binary_cache_MUXs: for i in 0 to binary_cache_count-1 generate
        U_binary_cache_MUX: bcache_In_MUX
                            port map(   en => ctrl_wr_en_bus(i),
                                        in_select => ctrl_bcache_In_sels(i), 
                                        inputs    => binary_pe_outs,
                                        output    => data_in_bus(i)
                                     );
   end generate U_binary_cache_MUXs;
   
   U_int_cache_MUXs: for i in binary_cache_count to total_DCache_count-1 generate
        U_int_cache_MUX: INTCache_In_MUX
                            port map(   en => ctrl_wr_en_bus(i),
                                        in_select => ctrl_intcache_In_sels(i-binary_cache_count),
                                        inputs    => psum_data_outs,
                                        output    => intdata_in_bus(i-binary_cache_count)
                                     );
   end generate U_int_cache_MUXs;
   
   ----------------------------
   ------ PE Port Map ---------
   uXOR_PE: XOR_PE
    port map( 
            clk           => clk,
            rst           => rst,
            cache_selects => ctrl_xor_cache_selects,
            in_valids     => ctrl_xor_in_valids,
            load_A_nBs    => ctrl_xor_load_A_nBs,

            inputs        => bcache_p2_data_out_bus,
            outputs       => xor_data_outs -- binary_pe_outs(XOR_threads-1 downto ROT_threads)
        );
        
   uROT_PE: ROT_PE
    port map( 
            clk           => clk,
            rst           => rst,
            cache_selects => ctrl_rot_cache_selects,
            in_valids     => ctrl_rot_in_valids,
            load_carry_in => ctrl_rot_load_carry_in,
            rot_amounts   => ctrl_rot_amounts,
            inputs        => bcache_p2_data_out_bus,
            outputs       => rot_data_outs --binary_pe_outs(ROT_threads-1 downto 0)
        );
        
    uPSUM_PE: PSUM_PE
    port map( 
            clk           => clk,
            rst           => rst,
            cache_selects => ctrl_psum_cache_selects,
            in_valids     => ctrl_psum_in_valids,
            reloads       => ctrl_psum_reloads,
            inputs        => bcache_p2_data_out_bus,
            outputs       => psum_data_outs
        );
    
    uMAJ_PE: MAJ_PE
    port map( 
            clk           => clk,
            rst           => rst,
            in_valids     => ctrl_maj_in_valids,
            load_Ts       => ctrl_maj_load_Ts,
            cache_selects => ctrl_maj_cache_selects,
            Ts            => ctrl_maj_T,
            inputs        => intcache_p2_data_out_bus,
            outputs       => maj_data_outs -- binary_pe_outs(ROT_threads+XOR_threads+MAJ_threads-1 downto ROT_threads+XOR_threads)
        );

u_ROT_OUT_assign: for i in 0 to ROT_threads -1 generate
    binary_pe_outs (i) <= rot_data_outs(i);
end generate;
u_XOR_OUT_assign: for i in 0 to XOR_threads -1 generate
    binary_pe_outs (i+ROT_threads) <= xor_data_outs(i);
end generate;
u_MAJ_OUT_assign: for i in 0 to MAJ_threads -1 generate
    binary_pe_outs (i+ROT_threads+XOR_threads) <= maj_data_outs(i);
end generate;

end Behavioral;
