set proj_dir ./$proj_name
set bd_tcl_dir ./scripts
set board vision_som
set device k26
set rev None
set output {xsa}
#set xdc_list {./xdc/pin.xdc}


set proj_board [get_board_parts "*:kv260_som:*" -latest_file_version]
create_project -name $proj_name -force -dir $proj_dir -part [get_property PART_NAME [get_board_parts $proj_board]]
set_property board_part $proj_board [current_project]

#import_files -fileset constrs_1 $xdc_list

set_property board_connections {som240_1_connector xilinx.com:kv260_carrier:som240_1_connector:1.3}  [current_project]


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


#simulation

startgroup
create_bd_port -dir I -type rst aresetn
connect_bd_net [get_bd_pins /smartconnect_0/aresetn] [get_bd_ports aresetn]
endgroup
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/ACLK] -boundary_type upper
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] -boundary_type upper
connect_bd_net [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] -boundary_type upper
connect_bd_net [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] -boundary_type upper
connect_bd_net [get_bd_pins smartconnect_0/aclk] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk]
connect_bd_net [get_bd_pins axi_dma_0/m_axi_sg_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
connect_bd_net [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
connect_bd_net [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
connect_bd_net [get_bd_pins HDCA_top_0/clk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
connect_bd_net [get_bd_pins HDCA_top_0/s_axi_ctrl_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
connect_bd_net [get_bd_pins HDCA_top_0/s_axis_input_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]
connect_bd_net [get_bd_pins HDCA_top_0/m_axis_output_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk]

startgroup
create_bd_port -dir I -type clk -freq_hz 100000000 aclk
set_property -dict [list CONFIG.CLK_DOMAIN [get_property CONFIG.CLK_DOMAIN [get_bd_pins smartconnect_0/aclk]]] [get_bd_ports aclk]
connect_bd_net [get_bd_pins /smartconnect_0/aclk] [get_bd_ports aclk]
endgroup

open_bd_design {F:/HDCA_TCL/HDC_Sim_proj/HDC_Sim_proj.srcs/sources_1/bd/design_1/design_1.bd}
startgroup
create_bd_port -dir O -type intr mm2s_introut
connect_bd_net [get_bd_pins /axi_dma_0/mm2s_introut] [get_bd_ports mm2s_introut]
endgroup

startgroup
create_bd_port -dir O -type intr s2mm_introut
connect_bd_net [get_bd_pins /axi_dma_0/s2mm_introut] [get_bd_ports s2mm_introut]
endgroup


startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_vip_0
endgroup
set_property location {0.5 -479 32} [get_bd_cells axi_vip_0]
connect_bd_intf_net [get_bd_intf_pins axi_vip_0/M_AXI] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI]

startgroup
set_property CONFIG.INTERFACE_MODE {MASTER} [get_bd_cells axi_vip_0]
endgroup
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_vip_0/aclk]
connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi_vip_0/aresetn]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_vip_1
endgroup

set_property CONFIG.INTERFACE_MODE {SLAVE} [get_bd_cells axi_vip_1]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1
endgroup
set_property -dict [list \
  CONFIG.NUM_MI {1} \
  CONFIG.NUM_SI {2} \
] [get_bd_cells axi_interconnect_1]
connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S01_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins axi_vip_1/S_AXI]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_vip_1/aclk]
connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi_vip_1/aresetn]

connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi_interconnect_1/S01_ARESETN]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_interconnect_1/S01_ACLK]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_interconnect_1/M00_ACLK]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_interconnect_1/S00_ACLK]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_interconnect_1/ACLK]
connect_bd_net [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] -boundary_type upper
connect_bd_net [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] -boundary_type upper
connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi_interconnect_1/M00_ARESETN]
save_bd_design

startgroup
set_property -dict [list \
  CONFIG.NUM_MI {1} \
  CONFIG.NUM_SI {3} \
] [get_bd_cells axi_interconnect_1]
endgroup

startgroup
set_property CONFIG.NUM_MI {4} [get_bd_cells axi_interconnect_0]
endgroup

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_pins axi_interconnect_1/S02_AXI]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_interconnect_1/S02_ACLK]
connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi_interconnect_1/S02_ARESETN]
connect_bd_net [get_bd_ports aresetn] [get_bd_pins axi_interconnect_0/M03_ARESETN]
connect_bd_net [get_bd_ports aclk] [get_bd_pins axi_interconnect_0/M03_ACLK]


#address
delete_bd_objs [get_bd_addr_segs] [get_bd_addr_segs -excluded]

delete_bd_objs [get_bd_addr_segs] [get_bd_addr_segs -excluded]
save_bd_design
assign_bd_address -target_address_space /axi_vip_0/Master_AXI [get_bd_addr_segs axi_vip_1/S_AXI/Reg] -force
set_property offset 0x40000000 [get_bd_addr_segs {axi_vip_0/Master_AXI/SEG_axi_vip_1_Reg}]
set_property range 512M [get_bd_addr_segs {axi_vip_0/Master_AXI/SEG_axi_vip_1_Reg}]


assign_bd_address
set_property offset 0xA0000000 [get_bd_addr_segs {axi_vip_0/Master_AXI/SEG_HDCA_top_0_reg0}]
save_bd_design
#add simulation file
add_files -norecurse -scan_for_includes ./SV/HDC_simulator.sv


make_wrapper -files [get_files ./${proj_name}/${proj_name}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ./${proj_name}/${proj_name}.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v

set_property top HDC_simulator [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]