
// Verilog only wrapper for sv-code to use in Xilinx IP

module rcsimple #(
    parameter integer C_S00_AXI_DATA_WIDTH = 64,
    parameter integer C_S00_AXI_ADDR_WIDTH = 5,
        
    parameter integer C_M_AXI_BURST_LEN = 16,
    parameter integer C_M_AXI_ID_WIDTH = 1,
    parameter integer BS_LENGTH_BITS = 24
)(
    input wire  AXI_aclk,
    input wire  AXI_aresetn,
    
    input wire [23:0] tmp_bs_length_strobe,
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
    output wire  M_AXI_arvalid,
    input wire  M_AXI_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_rid,
    input wire [63 : 0] M_AXI_rdata,
    input wire [1 : 0] M_AXI_rresp,
    input wire  M_AXI_rlast,
    input wire [0 : 0] M_AXI_ruser,
    input wire  M_AXI_rvalid,
    output wire  M_AXI_rready,
    
    // unused write ports
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
    //input wire s00_axi_aclk,
    //input wire s00_axi_aresetn,
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

    rcsimple_sv # (.C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
        .C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
        .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
        .BS_LENGTH_BITS(BS_LENGTH_BITS)
    ) rcsimple_inst (
        .tmp_bs_length_strobe(tmp_bs_length_strobe),
        .s00_axi_aclk(AXI_aclk),
        .s00_axi_aresetn(AXI_aresetn), 
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awprot(s00_axi_awprot),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_awready(s00_axi_awready),
        .s00_axi_wdata(s00_axi_wdata),
        .s00_axi_wstrb(s00_axi_wstrb),
        .s00_axi_wvalid(s00_axi_wvalid),
        .s00_axi_wready(s00_axi_wready),
        .s00_axi_bresp(s00_axi_bresp),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_arprot(s00_axi_arprot),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_arready(s00_axi_arready),
        .s00_axi_rdata(s00_axi_rdata),
        .s00_axi_rresp(s00_axi_rresp),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_rready(s00_axi_rready),
        
        .decouple(decouple),
        
        .icape2_clk(icape2_clk),
        .icape2_data_out(icape2_data_out),
        .icape2_strb(icape2_strb),

        .M_AXI_aclk(AXI_aclk),
        .M_AXI_aresetn(AXI_aresetn),
        .M_AXI_bid(M_AXI_bid),
        .M_AXI_bresp(M_AXI_bresp),
        .M_AXI_buser(M_AXI_buser),
        .M_AXI_bvalid(M_AXI_bvalid),
        .M_AXI_bready(M_AXI_bready),
        .M_AXI_arid(M_AXI_arid),
        .M_AXI_araddr(M_AXI_araddr),
        .M_AXI_arlen(M_AXI_arlen),
        .M_AXI_arsize(M_AXI_arsize),
        .M_AXI_arburst(M_AXI_arburst),
        .M_AXI_arlock(M_AXI_arlock),
        .M_AXI_arcache(M_AXI_arcache),
        .M_AXI_arprot(M_AXI_arprot),
        .M_AXI_arqos(M_AXI_arqos),
        .M_AXI_aruser(M_AXI_aruser),
        .M_AXI_arvalid(M_AXI_arvalid),
        .M_AXI_arready(M_AXI_arready),
        .M_AXI_rid(M_AXI_rid),
        .M_AXI_rdata(M_AXI_rdata),
        .M_AXI_rresp(M_AXI_rresp),
        .M_AXI_rlast(M_AXI_rlast),
        .M_AXI_ruser(M_AXI_ruser),
        .M_AXI_rvalid(M_AXI_rvalid),
        .M_AXI_rready(M_AXI_rready),
        
        .M_AXI_awid(M_AXI_awid),
        .M_AXI_awaddr(M_AXI_awaddr),
        .M_AXI_awlen(M_AXI_awlen),
        .M_AXI_awsize(M_AXI_awsize),
        .M_AXI_awburst(M_AXI_awburst),
        .M_AXI_awlock(M_AXI_awlock),
        .M_AXI_awcache(M_AXI_awcache),
        .M_AXI_awprot(M_AXI_awprot),
        .M_AXI_awqos(M_AXI_awqos),
        .M_AXI_awuser(M_AXI_awuser),
        .M_AXI_awvalid(M_AXI_awvalid),
        .M_AXI_awready(M_AXI_awready),
        .M_AXI_wdata(M_AXI_wdata),
        .M_AXI_wstrb(M_AXI_wstrb),
        .M_AXI_wlast(M_AXI_wlast),
        .M_AXI_wuser(M_AXI_wuser),
        .M_AXI_wvalid(M_AXI_wvalid),
        .M_AXI_wready(M_AXI_wready)
    );

endmodule