

module rcsimple_sv #(
    parameter integer C_S00_AXI_DATA_WIDTH = 64,
    parameter integer C_S00_AXI_ADDR_WIDTH = 5,
        
    parameter integer C_M_AXI_BURST_LEN = 16,
    parameter integer C_M_AXI_ID_WIDTH = 1,
    
    parameter integer BS_LENGTH_BITS = 24 
)(    
    input wire [23:0] tmp_bs_length_strobe,
    input wire  M_AXI_aclk,
    input wire  M_AXI_aresetn,    
    input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_bid,
    input wire [1 : 0] M_AXI_bresp,
    input wire [0 : 0] M_AXI_buser,
    input wire  M_AXI_bvalid,
    output wire  M_AXI_bready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_arid,
    output wire [31 : 0] M_AXI_araddr,
    output wire [7 : 0] M_AXI_arlen,
    output wire [2 : 0] M_AXI_arsize,
    output wire [1 : 0] M_AXI_arburst,
    output wire  M_AXI_arlock,
    output wire [3 : 0] M_AXI_arcache,
    output wire [2 : 0] M_AXI_arprot,
    output wire [3 : 0] M_AXI_arqos,
    output wire [0 : 0] M_AXI_aruser,
    output reg  M_AXI_arvalid,
    input wire  M_AXI_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_rid,
    input wire [63 : 0] M_AXI_rdata,
    input wire [1 : 0] M_AXI_rresp,
    input wire  M_AXI_rlast,
    input wire [0 : 0] M_AXI_ruser,
    input wire  M_AXI_rvalid,
    output reg  M_AXI_rready,
    
    // unused AXI Master write ports
    output wire [0 : 0] M_AXI_awid,
    output wire [31 : 0] M_AXI_awaddr,
    output wire [7 : 0] M_AXI_awlen,
    output wire [2 : 0] M_AXI_awsize,
    output wire [1 : 0] M_AXI_awburst,
    output wire  M_AXI_awlock,
    output wire [3 : 0] M_AXI_awcache,
    output wire [2 : 0] M_AXI_awprot,
    output wire [3 : 0] M_AXI_awqos,
    output wire [0 : 0] M_AXI_awuser,
    output wire M_AXI_awvalid,
    input wire  M_AXI_awready,
    output wire [63 : 0] M_AXI_wdata,
    output wire [7 : 0] M_AXI_wstrb,
    output wire  M_AXI_wlast,
    output wire [0 : 0] M_AXI_wuser,
    output wire  M_AXI_wvalid,
    input wire  M_AXI_wready,
    
    // Ports of Axi Slave Bus Interface S00_AXI    
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready,
    
    input wire icape2_clk,
    output wire [31:0] icape2_data_out,
    output wire icape2_strb,
    
    output wire decouple
);

    // default values for unused axi master read ports    
    assign M_AXI_arid = 0;
    assign M_AXI_arlock = 0;
    assign M_AXI_arprot = 0;
    assign M_AXI_arqos = 0;
    
    // unused AXI master write ports
    assign M_AXI_awid = 0;
    assign M_AXI_awaddr = 0;
    assign M_AXI_awlen = 0;
    assign M_AXI_awsize = 0;
    assign M_AXI_awburst = 0;
    assign M_AXI_awlock = 0;
    assign M_AXI_awcache = 0;
    assign M_AXI_awprot = 0;
    assign M_AXI_awqos = 0;
    assign M_AXI_awuser = 0;
    assign M_AXI_awvalid = 0;
    assign M_AXI_wdata = 0;
    assign M_AXI_wstrb = 0;
    assign M_AXI_wlast = 0;
    assign M_AXI_wuser = 0;
    assign M_AXI_wvalid = 0;
    
    // Handling of AXI master port
    
    assign M_AXI_araddr = cur_addr;
    assign M_AXI_arlen = cur_arlen;
    assign M_AXI_arsize = 'b011; // 64bits = 8 bytes in transfer
    assign M_AXI_arprot = 0;
    assign M_AXI_arburst = 'b01; // burst type = INCR
                       
    localparam BURST_WIDTH = 8; //64 bits = 8 bytes
    
    // 2 different ARLEN values for transfering data if remaining bytes < BURST_WIDTH*BURST_LEN    
    localparam ARLEN_BIG = C_M_AXI_BURST_LEN-1;
    localparam ARLEN_1 = 0;
    
    reg [7:0] cur_arlen; // holds the current length data
    
    reg [31:0] cur_addr; // current fetch address, is incremented after
        
    // configuration data from AXI Lite slave port
    reg [BS_LENGTH_BITS-1:0] bs_length;    
    wire [31:0] bs_addr;    
    
    reg [1:0] status_bits;
    wire [31:0] status_bits_full;
    assign status_bits_full = {30'd0,status_bits}; // STATUS register value, read from AXI lite slave port
    
    // counter for reconfig time, readable from AXI lite slave port
    reg [31:0] reconfig_counter;
        
        
    wire M_AXI_fifo_write_en;
    assign M_AXI_fifo_write_en = M_AXI_rvalid & M_AXI_rready; // write to fifo automatically when AXI data valid and we are reading data
    
    wire M_AXI_fifo_full;    
    assign M_AXI_rready = !M_AXI_fifo_full;
        
    wire ICAP_fifo_empty;    
    wire ICAP_fifo_read_en; 
    
    wire M_AXI_fifo_empty; 
    
    // ICAP counter
    // every 6 cycles: set CSIB high
    // why? don't know, the PRC from Xilinx does that
    /*
    reg [3:0] icap_cnt;
    always @(posedge M_AXI_aclk)
    begin
        if (icap_cnt == 5)
            icap_cnt <= 0;
        else
            icap_cnt <= icap_cnt + 1;            
    end;*/
    
    wire ICAP_fifo_valid;
    
              
    // instantiate the asynchronous fifo
    `ifdef VERILATOR
        
    fifo64to32 #(    
        .AFIFO_SIZE(3)
    ) fifo_inst (
        .RST_X(M_AXI_aresetn),
    
        .WCLK(M_AXI_aclk),
        .data_in(M_AXI_rdata),
        .full(M_AXI_fifo_full),
        .enq(M_AXI_fifo_write_en),
        
        .RCLK(icape2_clk),
        .data_out(icape2_data_out),
        .deq(ICAP_fifo_read_en),
        .empty(ICAP_fifo_empty)
    );
        
    `else
    
   wire [63:0] data_in_reversed;
   assign data_in_reversed = {M_AXI_rdata[31:0],M_AXI_rdata[63:32]};   
   fifo_generator_0 fifo_inst (
        // read        
        .dout(icape2_data_out),
        .rd_clk(icape2_clk),
        .rd_en(ICAP_fifo_read_en),
        .empty(ICAP_fifo_empty),
        .valid(ICAP_fifo_valid),
                
        // write
        .wr_en(M_AXI_fifo_write_en),
        .wr_clk(M_AXI_aclk),        
        .din(data_in_reversed),
        .full(M_AXI_fifo_full)        
    );
    `endif
    
    // synchronise ICAP_fifo_empty into M_AXI clock domain
    cdc_sync #(
        .C_CDC_TYPE(1), // level sync
        .C_RESET_STATE(0), // no reset
        .C_SINGLE_BIT(1),
        .C_MTBF_STAGES(2)
    ) cdc_fifo_empty (
        .prmry_aclk(icape2_clk),
        .prmry_in(ICAP_fifo_empty),
        .scndry_aclk(M_AXI_aclk),
        .scndry_out(M_AXI_fifo_empty)        
    );
                                             
    wire [BS_LENGTH_BITS-1:0] bs_length_strobe;
                     
    assign icape2_strb = !ICAP_fifo_valid; // we always read as long there is data    
    // icap_csib is active low
    
    //assign ICAP_fifo_read_en = (icap_cnt != 0);
    assign ICAP_fifo_read_en = 1;        
            
    wire [31:0] remaining_words;
    wire [31:0] bs_length_32;
    assign bs_length_32 = {{(32-BS_LENGTH_BITS){1'b0}},bs_length};
    assign remaining_words = (bs_addr + bs_length_32 - cur_addr) >> 3; // 8 bytes per word
    
    wire [BS_LENGTH_BITS-3:0] remaining_words_small;
    assign remaining_words_small = remaining_words[BS_LENGTH_BITS-3:0];
    
    wire large_burst_allow;
    assign large_burst_allow = remaining_words >= C_M_AXI_BURST_LEN;
    
    wire still_stuff_to_fetch;
    assign still_stuff_to_fetch = remaining_words > 0;
    
    
    // state machine for axi transfers
    typedef enum {
        STATE_IDLE,
        STATE_START_TRANSACTION,
        STATE_WAIT_TRANSACTION        
    } axi_state_t;    
    
    axi_state_t state_ff;
    
    assign decouple = (state_ff != STATE_IDLE)|(!M_AXI_fifo_empty);
        
    // State machine for AXI master -> ICAP fifo transfer
    always @(posedge M_AXI_aclk)
    begin : axi     
        if (M_AXI_aresetn == 0)   
        begin
            state_ff <= STATE_IDLE;
            M_AXI_arvalid <= 0;            
            bs_length <= 0;
            cur_arlen <= ARLEN_BIG[7:0];
            status_bits <= 0;
            reconfig_counter <= 0;            
        end else
        begin
            
            begin
                unique case (state_ff)
                    STATE_IDLE:
                        // wait for the bitstream length to become non-zero
                        // we then latch the bitstream address and start the transfer
                        if (bs_length_strobe > 0) 
                        begin
                            cur_addr <= bs_addr;
                            bs_length <= bs_length_strobe;                            
                            state_ff <= STATE_START_TRANSACTION;
                            reconfig_counter <= 0;
                        end
                    STATE_START_TRANSACTION:
                    begin                        
                        // determine if we have stuff to fetch                        
                        status_bits <= 2;
                        if (still_stuff_to_fetch)
                        begin
                            // initiate a new transaction
                            reconfig_counter <= reconfig_counter + 1;
                            
                            // determine burst
                            if (!large_burst_allow)
                                cur_arlen <= ARLEN_1;
                            else
                                cur_arlen <= ARLEN_BIG[7:0];
                                
                            state_ff <= STATE_WAIT_TRANSACTION;
                            M_AXI_arvalid <= 1;                            
                        end else
                        begin
                            // nothing to fetch anymore, return to IDLE
                            status_bits <= 1;
                            state_ff <= STATE_IDLE;                            
                        end
                    end
                    
                    STATE_WAIT_TRANSACTION:
                    begin
                        reconfig_counter <= reconfig_counter + 1;
                        if (M_AXI_arready) 
                        begin
                            state_ff <= STATE_START_TRANSACTION;                                                        
                            M_AXI_arvalid <= 0;
                            // increment our addr for the next transaction
                            if (cur_arlen == ARLEN_BIG[7:0])
                            begin
                                cur_addr <= cur_addr + (BURST_WIDTH*C_M_AXI_BURST_LEN);                                    
                            end else
                            begin
                                cur_addr <= cur_addr + BURST_WIDTH;                                    
                            end                            
                        end 
                    end
                endcase
            end
        end
    end

    wire [23:0] bs_length_strobe_from_axi;
    
    assign bs_length_strobe = bs_length_strobe_from_axi | tmp_bs_length_strobe;
    
    rc_axi_slave_S00_AXI # ( 
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
        .BS_LENGTH_BITS(BS_LENGTH_BITS)
    ) rc_simple_axi_slave_v1_0_S00_AXI_inst (
        .bitstream_length(bs_length_strobe_from_axi),       
        .bitstream_addr(bs_addr),
        .status_bits(status_bits_full),
        .reconfig_counter(reconfig_counter),
        .S_AXI_ACLK(s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR(s00_axi_awaddr),
        .S_AXI_AWPROT(s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA(s00_axi_wdata),
        .S_AXI_WSTRB(s00_axi_wstrb),
        .S_AXI_WVALID(s00_axi_wvalid),
        .S_AXI_WREADY(s00_axi_wready),
        .S_AXI_BRESP(s00_axi_bresp),
        .S_AXI_BVALID(s00_axi_bvalid),
        .S_AXI_BREADY(s00_axi_bready),
        .S_AXI_ARADDR(s00_axi_araddr),
        .S_AXI_ARPROT(s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA(s00_axi_rdata),
        .S_AXI_RRESP(s00_axi_rresp),
        .S_AXI_RVALID(s00_axi_rvalid),
        .S_AXI_RREADY(s00_axi_rready)
    );

endmodule
