`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2023 01:12:21 PM
// Design Name: 
// Module Name: test_HDCA
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

//import axi4stream_vip_pkg::*;
//import design_1_axi4stream_vip_0_0_pkg::*;

module test_HDCA(
    );
    // Clock signal
    bit                                     clock;
    // Reset signal
    bit                                     reset;
    wire    mm2s_introut_0;
    bit [31:0] data;
    bit[31:0] read_addr;
  
    initial begin 
      reset <= 1'b1;
      repeat (20) @(negedge clock);  
      reset <= 1'b0;
    end
    
    always #10 clock <= ~clock;
    
    design_1_axi_vip_0_0_mst_t                               mst_agent;
    design_1_axi_vip_1_0_slv_mem_t                           slv_agent;
    //design_1_axi4stream_vip_0_0_slv_t                        str_slv_agent0;
         
    /***************************************************************************************************
    * Verbosity level which specifies how much debug information to be printed out
    * 0         - No information will be printed out
    * 400       - All information will be printed out
    ***************************************************************************************************/
    //xil_axi4stream_uint                           str_slv_agent_verbosity = 0;

    initial begin
      /***********************************************************************************************
      * Before agent is newed, user has to run simulation with an empty testbench to find the hierarchy
      * path of the AXI VIP's instance.Message like
      * "Xilinx AXI VIP Found at Path: my_ip_exdes_tb.DUT.ex_design.axi_vip_mst.inst" will be printed 
      * out. Pass this path to the new function. 
      ***********************************************************************************************/

      mst_agent = new("master vip agent",tb.DUT.design_1_i.axi_vip_0.inst.IF);
      mst_agent.start_master();               // agent start to run
      slv_agent = new("slave vip mem agent",tb.DUT.design_1_i.axi_vip_1.inst.IF); // agent is newed
      slv_agent.start_slave();                                                  //  agent starts to run

      //str_slv_agent0 = new("slave vip agent",tb.DUT.design_1_i.axi4stream_vip_0.inst.IF);
    
      // Set up stream slave agents
      //str_slv_agent0.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
      //str_slv_agent0.set_agent_tag("Slave VIP");
      //str_slv_agent0.set_verbosity(str_slv_agent_verbosity);
      //str_slv_agent0.start_slave();
    
      // Wait for reset
      repeat (20) @(negedge clock);
      
      // Populate AXI VIP memory slave with Buffer Descriptors
      // Use backdoor memory writes
      //backdoor_mem_write_from_file("bufferDesc.mem",32'h40000000,32'h40000200);
      // Read back data
      //for(read_addr = 32'h40000000; read_addr < 32'h40000200; read_addr += 16) begin
      //  data = slv_agent.mem_model.backdoor_memory_read(read_addr);
      //  $display("Address: 0x%08X Data: 0x%X", read_addr, data);
      //end
        master_reg_write(32'h40000000,32'h40000000);
        master_reg_write(32'h40000004,32'h00000000);
        master_reg_write(32'h40000000,32'h40000000);
        master_reg_write(32'h40000008,32'h00a00000);
        master_reg_write(32'h4000000c,32'h00000000);
        master_reg_write(32'h40000010,32'h00000000);
        master_reg_write(32'h40000014,32'h00000000);
        master_reg_write(32'h40000018,32'h0c000080);
        master_reg_write(32'h4000001c,32'h00000000);
        master_reg_write(32'h40000020,32'h00000000);
        master_reg_write(32'h40000024,32'h00000000);
        master_reg_write(32'h40000028,32'h00000000);
        master_reg_write(32'h4000002c,32'h00000000);
        master_reg_write(32'h40000030,32'h00000000);
      
      // Set up readys on slave VIPs
      gen_wready();
      slv0_gen_tready();

      //master_reg_write(32'h40000018,32'h0c000080);//ichanged the discriptor
      // Register writes to initialize AXI DMA 0
      // current descriptor, R/S, interrupts, tail descriptor
      master_reg_write(32'h00000008, 32'h40000000);         // current descriptor
      master_reg_write(32'h00000000, 32'h00047001);         // enable interrupts, run
      
 //read
      master_reg_read(32'h00000008, data);
      $display("read data1 Address: 0x00000008 Data: 0x%X", data); 
      master_reg_read(32'h00000000, data);
   $display("read data 2 Address: 0x00000000 Data: 0x%X", data);
 
      // Start DMA by writing tail descriptor
      master_reg_write(32'h00000010, 32'h400000C0);
//      master_reg_write(32'h00010010, 32'h400001C0);
      
	  //read status register_DMA0
	  master_reg_read(32'h00000004, data);
	  $display("MM2S status register");
	  $display("Address: 0x00000004 Data: 0x%X", data);
	  	  
      // wait for axi dma 0 to finish
      wait(mm2s_introut_0 == 1'b1);
      $display("AXI DMA0 finished");
	  master_reg_read(32'h00000004, data);
	  $display("MM2S status register");
	  $display("Address: 0x00000004 Data: 0x%X", data);

      $finish;
      
   end
   
   design_1_wrapper DUT
     (.aclk (clock),
      //.mm2s_introut_0 (mm2s_introut_0),
      .aresetn (reset));
   
   // Task to generate single beat, 32-bit register write transactions
  task master_reg_write;
    input   [design_1_axi_vip_0_0_VIP_ADDR_WIDTH - 1:0]  address;
    input   [design_1_axi_vip_0_0_VIP_DATA_WIDTH - 1:0]  data;
    axi_transaction              wr_transaction;     //Declare an object handle of write transaction
    xil_axi_uint                 mtestID;            // Declare ID  
    xil_axi_ulong                mtestADDR;          // Declare ADDR  
    xil_axi_len_t                mtestBurstLength;   // Declare Burst Length   
    xil_axi_size_t               mtestDataSize;      // Declare SIZE  
    xil_axi_burst_t              mtestBurstType;     // Declare Burst Type  
    xil_axi_data_beat [255:0]    mtestWUSER;         // Declare Wuser  
    xil_axi_data_beat            mtestAWUSER;        // Declare Awuser  
    xil_axi_resp_t               mtestBresp;
    /***********************************************************************************************
    * A burst can not cross 4KB address boundry for AXI4
    * Maximum data bits = 4*1024*8 =32768
    * Write Data Value for WRITE_BURST transaction
    * Read Data Value for READ_BURST transaction
    ***********************************************************************************************/
    bit [32767:0]                 mtestWData;         // Declare Write Data 

    mtestID = 0;
    mtestADDR = address;
    mtestBurstLength = 'h0;
    mtestDataSize = XIL_AXI_SIZE_4BYTE; 
    mtestBurstType = XIL_AXI_BURST_TYPE_INCR; 
    mtestAWUSER =0;
    mtestWData[design_1_axi_vip_0_0_VIP_DATA_WIDTH - 1:0] = data;
    
    
    wr_transaction = mst_agent.wr_driver.create_transaction("write transaction in API");
    wr_transaction.set_write_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize);
    wr_transaction.set_data_block(mtestWData);
    wr_transaction.set_awuser(mtestAWUSER);
    for (xil_axi_uint beat = 0; beat < wr_transaction.get_len()+1;beat++) begin
    wr_transaction.set_wuser(beat, mtestWUSER[beat]);
    end  
    wr_transaction.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
    mst_agent.wr_driver.send(wr_transaction);
    mst_agent.wr_driver.wait_rsp(wr_transaction);
    mtestBresp = wr_transaction.get_bresp();
    
    $display("Write response: 0x%H",mtestBresp); 
  endtask :master_reg_write

  // Task to generate single beat, 32-bit register read transactions
  task master_reg_read;
    input   [design_1_axi_vip_0_0_VIP_ADDR_WIDTH - 1:0]  address;
    output  [design_1_axi_vip_0_0_VIP_DATA_WIDTH - 1:0]  data;
    
    axi_transaction              rd_transaction;     //Declare an object handle of read transaction
    xil_axi_uint                 mtestID;            // Declare ID  
    xil_axi_ulong                mtestADDR;          // Declare ADDR  
    xil_axi_len_t                mtestBurstLength;   // Declare Burst Length   
    xil_axi_size_t               mtestDataSize;      // Declare SIZE  
    xil_axi_burst_t              mtestBurstType;     // Declare Burst Type    

    /***********************************************************************************************
    * A burst can not cross 4KB address boundry for AXI4
    * Maximum data bits = 4*1024*8 =32768
    * Write Data Value for WRITE_BURST transaction
    * Read Data Value for READ_BURST transaction
    ***********************************************************************************************/
//    bit [32767:0]                 mtestRData;         // Declare Read Data 
    
    mtestID = 0;
    mtestADDR = address;
    mtestBurstLength = 'h0;
    mtestDataSize = XIL_AXI_SIZE_4BYTE;
    mtestBurstType = XIL_AXI_BURST_TYPE_INCR; 

    rd_transaction = mst_agent.rd_driver.create_transaction("read transaction");
    rd_transaction.set_read_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize);
    rd_transaction.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
    mst_agent.rd_driver.send(rd_transaction);
    mst_agent.rd_driver.wait_rsp(rd_transaction);
    data = rd_transaction.get_data_beat(0);

  endtask  :master_reg_read

 /*************************************************************************************************  
  * Task backdoor_mem_write shows how user can do backdoor write to memory model
  * Fills range beginning at start_addr and ending at stop_addr with random data. 
  * Declare default fill in value  mem_fill_payload according to DATA WIDTH
  * Declare backdoor memory write payload according to DATA WIDTH
  * Declare backdoor memory write strobe
  * Set default memory fill policy to random
  * Fill data payload with random data
  * 
  * Task assumes the start/stop address are aligned to data width.
  * Write data to memory model  
  *************************************************************************************************/
/*  task backdoor_mem_write(
    input xil_axi_ulong     start_addr,
    input xil_axi_ulong     stop_addr
  );
    bit[design_1_axi_vip_1_0_VIP_ADDR_WIDTH-1:0]              mem_wr_addr;
    bit[design_1_axi_vip_1_0_VIP_DATA_WIDTH-1:0]              write_data;
    bit[(design_1_axi_vip_1_0_VIP_DATA_WIDTH/8)-1:0]          write_strb;
    xil_axi_ulong             addr_offset;

    slv_agent.mem_model.set_memory_fill_policy(XIL_AXI_MEMORY_FILL_RANDOM);        // Determines what policy to use when memory model encounters an empty entry
    write_strb = ($pow(2,(design_1_axi_vip_1_0_VIP_DATA_WIDTH/8)) - 1);            // All strobe bits asserted
    for(mem_wr_addr = start_addr; mem_wr_addr < stop_addr; mem_wr_addr += 16) begin
        WRITE_DATA_FAIL: assert(std::randomize(write_data)); 
        slv_agent.mem_model.backdoor_memory_write(mem_wr_addr, write_data, write_strb);
     end
  endtask :backdoor_mem_write
*/

  task backdoor_mem_write_from_file;
     input [(128*8)-1:0] file_name;             // max file name length is 128 chars
     input xil_axi_ulong    start_addr;
     input xil_axi_ulong    stop_addr;
     
      reg [31:0] mem [0:127];
      bit[31:0] mem_wr_addr;
      bit[(design_1_axi_vip_1_0_VIP_DATA_WIDTH/8)-1:0]          write_strb;
      $readmemh(file_name,mem);
      // populate AXI VIP
      for(mem_wr_addr = start_addr; mem_wr_addr < stop_addr; mem_wr_addr += 4) begin
        write_strb = 4'hF << mem_wr_addr[3:0];
        //slv_agent.mem_model.backdoor_memory_write(mem_wr_addr, mem[(mem_wr_addr & 32'h000001FF) >> 2], write_strb);
        slv_agent.mem_model.backdoor_memory_write_4byte(mem_wr_addr, mem[(mem_wr_addr & 32'h000001FF) >> 2], 4'hF);
        $display("Addr: 0x%08X Data: 0x%08X Strobe: 0x%X",mem_wr_addr, mem[(mem_wr_addr & 32'h000001FF) >> 2], write_strb);
      end
  endtask  :backdoor_mem_write_from_file

  // task to set slave AXI VIP wready policy to always asserted
  task gen_wready();
    axi_ready_gen       wready_gen;
    wready_gen = slv_agent.wr_driver.create_ready("wready");
    wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    slv_agent.wr_driver.send_wready(wready_gen);
  endtask :gen_wready

  /*****************************************************************************************************************
  * Task slv_gen_tready shows how slave VIP agent generates one customerized tready signal. 
  * Declare axi4stream_ready_gen  ready_gen
  * Call create_ready from agent's driver to create a new class of axi4stream_ready_gen 
  * Set the poicy of ready generation in this example, it select XIL_AXI4STREAM_READY_GEN_OSC 
  * Set low time 
  * Set high time
  * Agent's driver send_tready out
  * Ready generation policy are listed below:
  *  XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE     - Ready stays asserted and will not change. The driver
                                                 will still check for policy changes.
  *   XIL_AXI4STREAM_READY_GEN_SINGLE             - Ready stays low for low_time,goes high and stay high till one 
  *                                         ready/valid handshake occurs, it then goes to low repeats this pattern. 
  *   XIL_AXI4STREAM_READY_GEN_EVENTS             - Ready stays low for low_time,goes high and stay high till one
  *                                          a certain amount of ready/valid handshake occurs, it then goes to 
  *                                          low and repeats this pattern.  
  *   XIL_AXI4STREAM_READY_GEN_OSC                - Ready stays low for low_time and then goes to high and stays 
  *                                          high for high_time, it then goes to low and repeat the same pattern
  *   XIL_AXI4STREAM_READY_GEN_RANDOM             - Ready generates randomly 
  *   XIL_AXI4STREAM_READY_GEN_AFTER_VALID_SINGLE - Ready stays low, once valid goes high, ready stays low for
  *                                          low_time, then it goes high and stay high till one ready/valid handshake 
  *                                          occurs. it then goes low and repeate the same pattern.
  *   XIL_AXI4STREAM_READY_GEN_AFTER_VALID_EVENTS - Ready stays low, once valid goes high, ready stays low for low_time,
  *                                          then it goes high and stay high till some amount of ready/valid handshake
  *                                          event occurs. it then goes low and repeate the same pattern.
  *   XIL_AXI4STREAM_READY_GEN_AFTER_VALID_OSC    - Ready stays low, once valid goes high, ready stays low for low_time, 
  *                                          then it goes high and stay high for high_time. it then goes low 
  *                                          and repeate the same pattern.
  *****************************************************************************************************************/
  task slv0_gen_tready();
    $display("--------------------------------My ready cache slv0_gen_tready");
    @(posedge clock);
    master_reg_write(32'h00010004, 32'h00010001);
    @(posedge clock);
    @(posedge clock);
    master_reg_write(32'h00010004, 32'h00010000);
    //axi4stream_ready_gen                           ready_gen;
    //ready_gen = str_slv_agent0.driver.create_ready("ready_gen");
    //ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
//    ready_gen.set_low_time(2);
//    ready_gen.set_high_time(6);
    //str_slv_agent0.driver.send_tready(ready_gen);
  endtask :slv0_gen_tready



endmodule
