set proj_dir ./$proj_name
set bd_tcl_dir ./scripts
#set board vision_som
#set device k26
#set rev None
#set output {xsa}
#set xdc_list {./xdc/pin.xdc}


set proj_board [get_board_parts "*:zedboard:*" -latest_file_version]
create_project -name $proj_name -force -dir $proj_dir -part [get_property PART_NAME [get_board_parts $proj_board]]
#set_property board_part $proj_board [current_project]
set_property board_part avnet.com:zedboard:part0:1.4 [current_project]
reset_property board_connections [get_projects HDCA_zedboard]

#import_files -fileset constrs_1 $xdc_list

#set_property board_connections {som240_1_connector xilinx.com:kv260_carrier:som240_1_connector:1.3}  [current_project]


update_ip_catalog

# Create block diagram design and set as current design
set design_name $proj_name
create_bd_design "design_1"
current_bd_design "design_1"

#import HDCA processor

add_files -norecurse -scan_for_includes ./HDL/HDCA_top.vhd
#import_files -norecurse ./HDL/HDCA_top.vhd

add_files -norecurse -scan_for_includes {./HDL/HDC_Package.vhd ./HDL/HDCA.vhd}
#import_files -norecurse {./HDL/HDC_Package.vhd ./HDL/HDCA.vhd}

add_files -norecurse -scan_for_includes {./HDL/MAJ_PE.vhd ./HDL/PSUM_PE.vhd ./HDL/XOR_PE.vhd ./HDL/ROT_PE.vhd}
#import_files -norecurse {./HDL/MAJ_PE.vhd ./HDL/PSUM_PE.vhd ./HDL/XOR_PE.vhd ./HDL/ROT_PE.vhd}

add_files -norecurse -scan_for_includes {./HDL/stream_switch.vhd ./HDL/binary_cache.vhd ./HDL/control.vhd ./HDL/int_cache.vhd}
#import_files -norecurse {./HDL/stream_switch.vhd ./HDL/binary_cache.vhd ./HDL/control.vhd ./HDL/int_cache.vhd}

add_files -norecurse -scan_for_includes {./HDL/bcache_In_MUX.vhd ./HDL/INTCache_In_MUX.vhd}
#import_files -norecurse {./HDL/bcache_In_MUX.vhd ./HDL/INTCache_In_MUX.vhd}

add_files -norecurse -scan_for_includes {./HDL/MAJ_thread.vhd ./HDL/PSUM_thread.vhd ./HDL/ROT_thread.vhd ./HDL/XOR_thread.vhd}
#import_files -norecurse {./HDL/MAJ_thread.vhd ./HDL/PSUM_thread.vhd ./HDL/ROT_thread.vhd ./HDL/XOR_thread.vhd}

add_files -norecurse -scan_for_includes {./HDL/bcache_out_mux.vhd ./HDL/intcache_out_mux.vhd}
#import_files -norecurse {./HDL/bcache_out_mux.vhd ./HDL/intcache_out_mux.vhd}

add_files -norecurse -scan_for_includes {./HDL/ADD_1bit.vhd ./HDL/MAJ_1bit.vhd}
#import_files -norecurse {./HDL/ADD_1bit.vhd ./HDL/MAJ_1bit.vhd}

add_files -norecurse -scan_for_includes ./HDL/shift.vhd
#import_files -norecurse ./HDL/shift.vhd

add_files -norecurse -scan_for_includes ./HDL/axi_ctrl.vhd
#import_files -norecurse ./HDL/axi_ctrl.vhd

add_files -norecurse -scan_for_includes ./HDL/inst_cache.vhd
#import_files -norecurse ./HDL/inst_cache.vhd

create_bd_cell -type module -reference HDCA_top HDCA_top_0

#DMA HDCA

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
endgroup
set_property -dict [list \
  CONFIG.c_mm2s_burst_size {256} \
  CONFIG.c_s2mm_burst_size {256} \
  CONFIG.c_sg_include_stscntrl_strm {0} \
  CONFIG.c_sg_length_width {20} \
] [get_bd_cells axi_dma_0]
set_property CONFIG.Memory_Type {True_Dual_Port_RAM} [get_bd_cells blk_mem_gen_0]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
endgroup
set_property CONFIG.SINGLE_PORT_BRAM {1} [get_bd_cells axi_bram_ctrl_0]
copy_bd_objs /  [get_bd_cells {axi_bram_ctrl_0}]
set_property location {1 -96 152} [get_bd_cells axi_bram_ctrl_1]
connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
endgroup
set_property CONFIG.NUM_SI {1} [get_bd_cells smartconnect_0]
connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_dma_0/M_AXI_SG]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
endgroup
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
startgroup
set_property CONFIG.NUM_MI {3} [get_bd_cells axi_interconnect_0]
endgroup
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins HDCA_top_0/s_axi_ctrl]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
startgroup
set_property CONFIG.NUM_MI {3} [get_bd_cells axi_interconnect_0]
endgroup
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins HDCA_top_0/s_axi_ctrl]
connect_bd_intf_net [get_bd_intf_pins HDCA_top_0/s_axis_input] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
connect_bd_intf_net [get_bd_intf_pins HDCA_top_0/m_axis_output] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins smartconnect_0/aresetn]
connect_bd_net [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins HDCA_top_0/rst] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins HDCA_top_0/s_axi_ctrl_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins HDCA_top_0/s_axis_input_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins HDCA_top_0/m_axis_output_aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

#ADD PS

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

startgroup
set_property -dict [list \
  CONFIG.PCW_USE_S_AXI_GP0 {1} \
  CONFIG.PCW_USE_S_AXI_HP0 {1} \
] [get_bd_cells processing_system7_0]
endgroup
startgroup
set_property CONFIG.PCW_USE_S_AXI_GP0 {0} [get_bd_cells processing_system7_0]
endgroup

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_dma_0/m_axi_sg_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_dma_0/s_axi_lite_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_interconnect_0/ACLK]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_interconnect_0/M02_ACLK]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins HDCA_top_0/m_axis_output_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins HDCA_top_0/s_axi_ctrl_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins HDCA_top_0/s_axis_input_aclk]
endgroup
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI]
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_interconnect_0/S00_ACLK]
endgroup
startgroup
set_property -dict [list \
  CONFIG.PCW_USE_S_AXI_GP0 {1} \
  CONFIG.PCW_USE_S_AXI_HP1 {1} \
] [get_bd_cells processing_system7_0]
endgroup
startgroup
set_property CONFIG.PCW_USE_S_AXI_GP0 {0} [get_bd_cells processing_system7_0]
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_interconnect_0
endgroup
delete_bd_objs [get_bd_cells axis_interconnect_0]

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_0/M_AXI_MM2S} Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/axi_dma_0/M_AXI_S2MM} Slave {/processing_system7_0/S_AXI_HP1} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
endgroup
save_bd_design


#address
assign_bd_address


make_wrapper -files [get_files ./${proj_name}/${proj_name}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ./${proj_name}/${proj_name}.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1