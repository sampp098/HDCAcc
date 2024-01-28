`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2023 06:33:40 PM
// Design Name: 
// Module Name: HDC_simulator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;
import design_1_axi_vip_1_0_pkg::*;

//////////////////////////////////////////////////////////////////////////////////
// Test Bench Signals
//////////////////////////////////////////////////////////////////////////////////
// Clock and Reset
bit aclk = 0, aresetn = 1;
//Simulation output
bit led_1, switch_1;
//AXI4-Lite signals
xil_axi_resp_t 	resp;
bit[31:0]  addr, data, switch_state;

bit[31:0]  XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR = 32'hC000_0000;
bit[31:0]  XPAR_AXI_DMA_0_BASEADDR = 32'h6000_0000;
bit[31:0]  XPAR_HDCA_0_BASEADDR    = 32'hA000_0000;
bit[31:0]  DDR_BASEADDR            = 32'h4000_0000;

logic mm2s_introut;
logic s2mm_introut;
module HDC_simulator( );

design_1_wrapper DUT
(
    .aclk               (aclk),
    .aresetn            (aresetn),
    .mm2s_introut       (mm2s_introut),
    .s2mm_introut       (s2mm_introut)
);

// Generate the clock : 50 MHz    
always #10ns aclk = ~aclk;


localparam 
	inst_NOP     = 4'b0000,
	inst_BLD     = 4'b0001,
	inst_BSRT    = 4'b0010,
	inst_ILD     = 4'b0011,
	inst_ISRT    = 4'b0100,
	inst_XORLDA  = 4'b0101,
	inst_XORLDB  = 4'b0110,
	inst_XORSTR  = 4'b0111,
	inst_ROTLDB  = 4'b1000,
	inst_ROTLDS  = 4'b1001,
	inst_ROTSTR  = 4'b1010,
	inst_PSUMLDS = 4'b1011, 
	inst_PSUMSTR = 4'b1100,
    inst_MAJLDL  = 4'b1101,
    inst_MAJLDS  = 4'b1110,
    inst_MAJSTR  = 4'b1111;

//////////////////////////////////////////////////////////////////////////////////
// Main Process
//////////////////////////////////////////////////////////////////////////////////
//
initial begin
    reset();
    initDMA();
    Bload();
end
//
//////////////////////////////////////////////////////////////////////////////////
// The following part controls the AXI VIP. 
//It follows the "Usefull Coding Guidelines and Examples" section from PG267
//////////////////////////////////////////////////////////////////////////////////
//
// Step 3 - Declare the agent for the master VIP
design_1_axi_vip_0_0_mst_t      master_agent;
design_1_axi_vip_1_0_slv_mem_t  slv_agent;
//
initial begin    

    // Step 4 - Create a new agent
    master_agent = new("master vip agent",DUT.design_1_i.axi_vip_0.inst.IF);
    slv_agent    = new("master vip agent",DUT.design_1_i.axi_vip_1.inst.IF);
    slv_agent.set_verbosity(400);
    
    // Step 5 - Start the agent
    master_agent.start_master();
    slv_agent.start_slave();
    
    //Wait for the reset to be released
end
task reset();
    //Assert the reset
    aresetn = 0;
    
    #340ns
    // Release the reset
    aresetn = 1;
    HDCA_reset();
endtask;
task axi_write(input bit[31:0] address,data);
	master_agent.AXI4LITE_WRITE_BURST(address,0,data,resp);
endtask;

task axi_read(input bit[31:0] address, output logic[31:0] data);
	master_agent.AXI4LITE_READ_BURST(address,0,data,resp);
endtask;

task initDMA();
	$display("\ninitDMA\n");

	// reset MM2S
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h00, 32'h0101dfe6);
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h00, 32'h0101dfe2);

	//# configure S2MM
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h30, 32'h0101dfe6);
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h30, 32'h0101dfe2);

endtask;

task startS2MM(input bit[31:0] descAddr);
	$display("\nstartS2MM\n");
	axi_write(descAddr+32'h1c, 32'h00000000); //reset transfered value from Desc
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h3c, 32'h00000000);
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h38, descAddr);//Descriptor address

	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h30, 32'h0101dfe3);

	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h44, 32'h00000000);
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h40, descAddr);
endtask;

task startMM2S(input bit[31:0] descAddr);
	$display("\nstartMM2S\n");
	axi_write(descAddr+32'h1c, 32'h00000000); //reset transfered value from Desc
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h0c, 32'h00000000);
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h08, descAddr);//Descriptor address

	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h00, 32'h0101dfe3);

	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h14, 32'h00000000);
	axi_write(XPAR_AXI_DMA_0_BASEADDR+32'h10, descAddr);
endtask;

task sendDescriptors(input bit[31:0] SG_BRAM_ADDR, input int byteSize, input bit[31:0] data_addr, output bit[31:0] return_addr);

	$display("\nwrite Descriptors\n");

	axi_write(SG_BRAM_ADDR + 32'h0000, SG_BRAM_ADDR);//next Descriptor (LSB)
	axi_write(SG_BRAM_ADDR + 32'h0004, 32'h00000000);// MSB
	axi_write(SG_BRAM_ADDR + 32'h0008, data_addr);//Buffer Address (LSB)
	axi_write(SG_BRAM_ADDR + 32'h000c, 32'h00000000);//Buffer Address (MSB
	axi_write(SG_BRAM_ADDR + 32'h0010, 32'h00000000);//Reserved
	axi_write(SG_BRAM_ADDR + 32'h0014, 32'h00000000);//Reserved

	axi_write(SG_BRAM_ADDR + 32'h0018, 32'h0c000000+byteSize); //[expr 0x0c000000+$transferSize]

	axi_write(SG_BRAM_ADDR + 32'h001c, 32'h00000000);//DMA Status, for check after transfer
	axi_write(SG_BRAM_ADDR + 32'h0020, 32'h00000000);//User App Fields
	axi_write(SG_BRAM_ADDR + 32'h0024, 32'h00000000);//User App Fields
	axi_write(SG_BRAM_ADDR + 32'h0028, 32'h00000000);//User App Fields
	axi_write(SG_BRAM_ADDR + 32'h002c, 32'h00000000);//User App Fields
	axi_write(SG_BRAM_ADDR + 32'h0030, 32'h00000000);//User App Fields

	return_addr = SG_BRAM_ADDR + 32'h0040;
endtask;


task automatic clearDMAInterupt();
    int tmpValue;
    axi_read ( XPAR_AXI_DMA_0_BASEADDR + 32'h34, tmpValue);
	tmpValue = tmpValue | 32'h1000;
	axi_write( XPAR_AXI_DMA_0_BASEADDR + 32'h34 , tmpValue );

endtask;

task automatic Bload();
    int byteSize = 32*4;
//    u8 data_toMM[32][4];
//    u8 data_fromSlave[32][4];
    //initial data
    int count = 0;
    int row = 0;
    int col =0;
    
    int MM2S_base_addr;
    int next_disc_addr;
    int next_disc_addr2;
    //u32 data_toMM_addr =  (u32)&data_toMM[0];
    //u32 data_fromSlave_addr  =  (u32)&data_fromSlave [0];
    int inst_toMM_addr      = DDR_BASEADDR + 32'h00009000;
    int data_toMM_addr      = DDR_BASEADDR + 32'h0000a000;
    int data_fromSlave_addr = DDR_BASEADDR + 32'h0000b000;
    
    axi_write(inst_toMM_addr+0, {inst_BLD,6'D0,22'D0} );
    axi_write(inst_toMM_addr+4, {inst_XORLDA,6'D0,22'D0} );
    axi_write(inst_toMM_addr+8, {inst_XORLDB,6'D0,22'D1} );
    axi_write(inst_toMM_addr+12, {inst_XORSTR,6'D1,22'D0} );
    axi_write(inst_toMM_addr+16, {inst_ROTLDB,6'D0,22'D3} );
    axi_write(inst_toMM_addr+20, {inst_ROTLDS,6'D0,22'D1} );
    axi_write(inst_toMM_addr+24, {inst_ROTLDS,6'D0,22'D1} );
    axi_write(inst_toMM_addr+28, {inst_ROTSTR,6'D1,22'D1} );
    axi_write(inst_toMM_addr+32, {inst_PSUMLDS,6'D0,22'D31} );
    axi_write(inst_toMM_addr+36, {inst_PSUMLDS,6'D0,22'D31} );
    axi_write(inst_toMM_addr+40, {inst_PSUMLDS,6'D0,22'D31} );
    axi_write(inst_toMM_addr+44, {inst_PSUMLDS,6'D0,22'D31} );
    axi_write(inst_toMM_addr+48, {inst_PSUMLDS,6'D0,22'D31} );
    axi_write(inst_toMM_addr+52, {inst_PSUMLDS,6'D0,22'D31} );
    axi_write(inst_toMM_addr+56, {inst_PSUMSTR,6'D0,22'D0} );
    axi_write(inst_toMM_addr+60, {inst_PSUMLDS,6'D0,22'D31} );
    axi_write(inst_toMM_addr+64, {inst_PSUMSTR,6'D0,22'D1} );
    axi_write(inst_toMM_addr+68, {inst_MAJLDL,6'D0,22'D3} );
    axi_write(inst_toMM_addr+72, {inst_MAJLDS,6'D0,22'D0} );
    axi_write(inst_toMM_addr+76, {inst_MAJSTR,6'D1,22'D3} );
    for(row =20; row <32; row++) begin
        axi_write(inst_toMM_addr+(row*4), {inst_NOP,14'b00000000000000,14'b00000000000000} );
    end
    
    for(row =0; row <32; row++) begin
        axi_write(data_toMM_addr+(row*4), 32'h0000b000+row);
    end
    
    initDMA();
    //Xil_DCacheFlush();
    MM2S_base_addr =  XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR;
    
    sendDescriptors( .SG_BRAM_ADDR(MM2S_base_addr),
                     .byteSize(128), 
                     .data_addr(inst_toMM_addr) ,
                     .return_addr(next_disc_addr));
                     
    sendDescriptors( .SG_BRAM_ADDR(next_disc_addr),
                     .byteSize(128), 
                     .data_addr(data_toMM_addr) ,
                     .return_addr(next_disc_addr2));         
    
    startMM2S(MM2S_base_addr);
    //startS2MM(S2MM_base_addr);
    HDCA_start();
    @(posedge mm2s_introut);
    clearDMAInterupt();
    initDMA();
    repeat(5) @(posedge aclk);
    startMM2S(next_disc_addr);
    
endtask;




//
//////////////////////////////////////////////////////////////////////////////////
// HDCA tasks
//////////////////////////////////////////////////////////////////////////////////
//
task HDCA_reset();
    axi_write(XPAR_HDCA_0_BASEADDR + 0, 32'h00000001);
    repeat(5) @(posedge aclk);
    axi_write(XPAR_HDCA_0_BASEADDR + 0, 32'h00000000);
endtask;
task HDCA_start();
    axi_write(XPAR_HDCA_0_BASEADDR + 0, 32'h00000000);
    axi_write(XPAR_HDCA_0_BASEADDR + 0, 32'h00000002);
endtask;
endmodule