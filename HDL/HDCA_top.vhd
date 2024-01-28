----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2023 05:04:49 AM
-- Design Name: 
-- Module Name: HDCA_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HDCA_top is
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
    
        clk : in std_logic;
        rst : in std_logic;
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
end HDCA_top;

architecture Behavioral of HDCA_top is 

signal inv_rst : std_logic := '0';
signal inv_clk : std_logic := '0';

component HDCA is
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
    
        clk : in std_logic;
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
end component;
begin
U_HDCA: HDCA 
    generic map(
        C_S_AXI_CTRL_DATA_WIDTH => C_S_AXI_CTRL_DATA_WIDTH,
		C_S_AXI_CTRL_ADDR_WIDTH	=> C_S_AXI_CTRL_ADDR_WIDTH,

		-- Parameters of Axi Slave Bus Interface S_AXIS_input
		C_S_AXIS_input_TDATA_WIDTH => C_S_AXIS_input_TDATA_WIDTH,

		-- Parameters of Axi Master Bus Interface M_AXIS_output
		C_M_AXIS_output_TDATA_WIDTH	=> C_M_AXIS_output_TDATA_WIDTH,
		C_M_AXIS_output_START_COUNT	=> C_M_AXIS_output_START_COUNT
    )
    port map(
        clk => inv_clk,
        reset => inv_rst,
    -- Ports of Axi Slave Bus Interface S_AXI_CTRL
		s_axi_ctrl_aclk	=> inv_clk,
		s_axi_ctrl_aresetn => s_axi_ctrl_aresetn,
		s_axi_ctrl_awaddr => s_axi_ctrl_awaddr,
		s_axi_ctrl_awprot => s_axi_ctrl_awprot,
		s_axi_ctrl_awvalid => s_axi_ctrl_awvalid,
		s_axi_ctrl_awready => s_axi_ctrl_awready,
		s_axi_ctrl_wdata => s_axi_ctrl_wdata,
		s_axi_ctrl_wstrb => s_axi_ctrl_wstrb,
		s_axi_ctrl_wvalid => s_axi_ctrl_wvalid,
		s_axi_ctrl_wready => s_axi_ctrl_wready,
		s_axi_ctrl_bresp => s_axi_ctrl_bresp,
		s_axi_ctrl_bvalid => s_axi_ctrl_bvalid,
		s_axi_ctrl_bready => s_axi_ctrl_bready,
		s_axi_ctrl_araddr => s_axi_ctrl_araddr,
		s_axi_ctrl_arprot => s_axi_ctrl_arprot,
		s_axi_ctrl_arvalid => s_axi_ctrl_arvalid,
		s_axi_ctrl_arready => s_axi_ctrl_arready,
		s_axi_ctrl_rdata => s_axi_ctrl_rdata,
		s_axi_ctrl_rresp => s_axi_ctrl_rresp,
		s_axi_ctrl_rvalid => s_axi_ctrl_rvalid,
		s_axi_ctrl_rready => s_axi_ctrl_rready,
    
        -- Ports of Axi Stream Slave Bus Interface S_AXIS_input
		s_axis_input_aclk => inv_clk,
		s_axis_input_aresetn => s_axis_input_aresetn,
		s_axis_input_tready => s_axis_input_tready,
		s_axis_input_tdata => s_axis_input_tdata,
		s_axis_input_tkeep => s_axis_input_tkeep,
		s_axis_input_tlast => s_axis_input_tlast,
		s_axis_input_tvalid => s_axis_input_tvalid,
    
        -- Ports of Axi Stream Master Bus Interface M_AXIS_output
		m_axis_output_aclk => inv_clk,
		m_axis_output_aresetn => m_axis_output_aresetn,
		m_axis_output_tvalid => m_axis_output_tvalid,
		m_axis_output_tdata => m_axis_output_tdata,
		m_axis_output_tkeep => m_axis_output_tkeep,
		m_axis_output_tlast => m_axis_output_tlast,
		m_axis_output_tready => m_axis_output_tready
              );
inv_rst <= not rst;
inv_clk <=  clk;
end Behavioral;
