`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2018 20:21:24
// Design Name: 
// Module Name: rcsimple_sim
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


module rcsimple_sim();

reg clk;
reg reset_n;
reg [4:0] s_awaddr;
reg s_awvalid;
wire s_awready;
reg s_wvalid;
reg [63:0] s_wdata;
wire [31:0] icap_data;
wire icap_valid;
wire s_wready;
reg [7:0] s_wstrb;

reg m_arready;
reg m_rvalid;
wire m_arvalid;
reg [63:0] m_rdata;
reg m_rlast;

rcsimple rcsimple_inst(
 .AXI_aclk(clk), 
 .icape2_clk(clk),
 .AXI_aresetn(reset_n), 
 .s00_axi_awvalid(s_awvalid),
 .s00_axi_awready(s_awready),
 .s00_axi_wvalid(s_wvalid),
 .s00_axi_wready(s_wready),
 .s00_axi_awaddr(s_awaddr),
 .s00_axi_wdata(s_wdata),
 .s00_axi_wstrb(s_wstrb),
 .icape2_data_out(icap_data),
 .icape2_strb(icap_valid),
 .M_AXI_arready(m_arready),
 .M_AXI_rvalid(m_rvalid),
 .M_AXI_rdata(m_rdata),
 .M_AXI_arvalid(m_arvalid),
 .M_AXI_rlast(m_rlast)
);


initial begin 
    clk <= 0; 
    reset_n <= 0;
    s_awvalid <= 0;
    s_awaddr <= 8;
    s_wdata <= 64'd72;
    s_wstrb <= 255;
    m_arready <= 1;
    m_rvalid <= 0;
    m_rdata <= 0;    
    m_rlast <= 0;
    s_wvalid <= 0;
    # 10 reset_n <= 1; 
    # 10
        s_awvalid <= 1;
    # 10                  
    s_wvalid <= 1;    
    @(posedge m_arvalid);
    m_rdata <= {32'd45,32'd1};
    m_rvalid <= 1;
    repeat(16)begin  m_rdata <= m_rdata + 1; @(posedge clk); end
    m_rlast <= 1;
    @(posedge clk);
    m_rvalid <= 0;              
 end 
 
 always 
  #5  clk =  ! clk;
   

endmodule
