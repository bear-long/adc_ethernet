//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/7/19     meisq          1.0         Original
//  2019/10/11                   1.1  
//*******************************************************************************/
module top(
input                           sys_clk_p,                    //system clock positive
input                           sys_clk_n,                    //system clock negative 
input                           rst_n,                        //reset ,low active
//ad9280
input[7:0]                      ad9280_data,                  //ad9280 data
output                          ad9280_clk,                   //ad9280 clock input
output                          e1_reset,                     //phy reset
output                          e1_mdc,                       //phy emdio clock
inout                           e1_mdio,                      //phy emdio data
output[3:0]                     rgmii1_txd,                   //phy data send
output                          rgmii1_txctl,                 //phy data send control
output                          rgmii1_txc,                   //Clock for sending data
input[3:0]                      rgmii1_rxd,                   //recieve data
input                           rgmii1_rxctl,                 //Control signal for receiving data
input                           rgmii1_rxc,                   //Clock for recieving data	
output                          e2_reset,                     //phy reset
output                          e2_mdc,                       //phy emdio clock
inout                           e2_mdio,                      //phy emdio data
output[3:0]                     rgmii2_txd,                   //phy data send
output                          rgmii2_txctl,                 //phy data send control
output                          rgmii2_txc,                   //Clock for sending data
input[3:0]                      rgmii2_rxd,                   //recieve data
input                           rgmii2_rxctl,                 //Control signal for receiving data
input                           rgmii2_rxc,                   //Clock for recieving data   
//DDR3  
 inout [31:0]                   ddr3_dq,                      //ddr3 data
inout [3:0]                     ddr3_dqs_n,                   //ddr3 dqs negative
inout [3:0]                     ddr3_dqs_p,                   //ddr3 dqs positive
output [14:0]                   ddr3_addr,                    //ddr3 address
output [2:0]                    ddr3_ba,                      //ddr3 bank
output                          ddr3_ras_n,                   //ddr3 ras_n
output                          ddr3_cas_n,                   //ddr3 cas_n
output                          ddr3_we_n,                    //ddr3 write enable
output                          ddr3_reset_n,                 //ddr3 reset,
output [0:0]                    ddr3_ck_p,                    //ddr3 clock negative
output [0:0]                    ddr3_ck_n,                    //ddr3 clock positive
output [0:0]                    ddr3_cke,                     //ddr3_cke,
output [0:0]                    ddr3_cs_n,                    //ddr3 chip select,
output [3:0]                    ddr3_dm,                      //ddr3_dm
output [0:0]                    ddr3_odt                      //ddr3_odt
);
parameter MEM_DATA_BITS          = 64;             //external memory user interface data width
parameter ADDR_BITS              = 25;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width
wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[15:0]                      read_data;
wire                            write_en;
wire[15:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;

wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;

wire                            ui_clk;
wire                            ui_clk_sync_rst;
wire                            init_calib_complete;
// Master Write Address
wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;    // burst length: 0-255
wire [2:0]                      s00_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]                      s00_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire                            s00_axi_awlock;   // lock: fixed 2'b00
wire [3:0]                      s00_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]                      s00_axi_awprot;   // protect: fixed 2'b000
wire [3:0]                      s00_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]                      s00_axi_awuser;   // user: fixed 32'd0
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
// master write data
wire [63:0]                     s00_axi_wdata;
wire [7:0]                      s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
// master write response
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
// master read address
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
// master read data
wire [3:0]                      s00_axi_rid;
wire [63:0]                     s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;
wire                            sys_clk;          //single end clock 
wire                            clk_100m;
wire                            clk_50m;
wire                            clk_25m;
wire                            clk_25m_deg;
wire [1:0]                      speed_selection; // 1x gigabit, 01 100Mbps, 00 10mbps
wire                            duplex_mode;     // 1 full, 0 half

wire                            ad_data_req ;
wire                            ad_data_ack ;
wire                            ad_sample_req ;
wire                            ad_sample_ack ;
wire [31:0]                     sample_len  ;

wire                            adc_clk;
wire                            adc0_buf_wr;
wire [10:0]                     adc0_buf_addr;
wire [15:0]                     adc0_buf_data;

wire                            ad_data_valid;
wire signed[15:0]               ad_ch1;
wire signed[15:0]               ad_ch2;
wire signed[15:0]               ad_ch3;
wire signed[15:0]               ad_ch4;
wire signed[15:0]               ad_ch5;
wire signed[15:0]               ad_ch6;
wire signed[15:0]               ad_ch7;
wire signed[15:0]               ad_ch8;
                                
wire [11:0]                     fifo_data_count;
wire [7:0]                      fifo_data;
wire                            fifo_rd_en;                               
wire [15:0]                     read_usedw ;
wire                            write_finish ;

wire                           e1_reset_n ;
wire                           e2_reset_n ;   

wire                            reset_n;
wire   [ 7:0]                   gmii_txd;
wire                            gmii_tx_en;
wire                            gmii_tx_er;
wire                            gmii_tx_clk;
wire                            gmii_crs;
wire                            gmii_col;
wire   [ 7:0]                   gmii_rxd;
wire                            gmii_rx_dv;
wire                            gmii_rx_er;
wire                            gmii_rx_clk;
wire                            rgmii_rxcpll;

wire [31:0] s_axis_data_tdata;   //fft数据通道的输入数据
wire        s_axis_data_tvalid;	 //fft数据通道的输入数据有效使能
wire        s_axis_data_tready;  //fft数据通道准备完成信号
wire        s_axis_data_tlast;   //fft数据通道接收最后一个数据标志信号
wire        m_axis_data_tvalid;  //fft数据通道的输出数据有效使能
wire [31:0] m_axis_data_tdata;   //fft数据通道的输出数据
wire        m_axis_data_tlast;   //fft数据通道发送最后一个数据标志信号
wire [15:0] m_axis_data_tuser;   //fft数据通道输出数据的状态信息

assign s_axis_data_tdata = {24'b0,ad9280_data[7:0]};
//将采集后的adc输出数据有效使能赋给fft的输入数据有效使能
//assign  s_axis_data_tvalid =  ad_data_out_en; 
assign speed_selection          = 2'b10;
assign duplex_mode              = 1'b1;
assign ad9280_clk               = adc_clk;
/*************************************************************************
generate single end clock
**************************************************************************/
IBUFGDS sys_clk_ibufgds
(
.O                              (sys_clk                 ),
.I                              (sys_clk_p               ),
.IB                             (sys_clk_n               )
);
/*************************************************************************
 generate adc clock
**************************************************************************/
//adc_pll adc_pll_m0
//(
//.clk_in1                        (sys_clk                 ),
//.clk_out1                       (adc_clk                 ),
//.reset                          (1'b0                    ),
//.locked                         (                        )
//);
adc_pll adc_pll_m1
(
// Clock out ports
.clk_out1(adc_clk),     // output clk_out1
.clk_50m(clk_50m),     // output clk_50m
.clk_100m(clk_100m),     // output clk_100m
.clk_25m(clk_25m),     // output clk_25m
.clk_25m_deg(clk_25m_deg),     // output clk_25m_deg
// Status and control signals
.reset(~rst_n), // input reset
.locked(        ),       // output locked
// Clock in ports
.clk_in1(sys_clk));      // input clk_in1
/*************************************************************************
MDIO register configuration
****************************************************************************/  
smi_config  smi_config_inst0
(
.clk         (adc_clk),
.rst_n       (e1_reset_n    ),         
.mdc         (e1_mdc      ),
.mdio        (e1_mdio     )
);   

smi_config  smi_config_inst1
(
.clk         (adc_clk),
.rst_n       (e2_reset_n    ),         
.mdc         (e2_mdc      ),
.mdio        (e2_mdio     )
);   
/*************************************************************************
Generate PHY reset signal
****************************************************************************/
reset reset_m0
(
.clk                            (adc_clk                ),
.key1                           (rst_n                  ),
.rst_n                          (e1_reset               )
); 

reset reset_m1
(
.clk                            (adc_clk                ),
.key1                           (e1_reset                  ),
.rst_n                          (e1_reset_n               )
); 
/*************************************************************************
Generate PHY reset signal
****************************************************************************/
reset reset_m2
(
.clk                            (adc_clk                ),
.key1                           (rst_n                  ),
.rst_n                          (e2_reset               )
); 
reset reset_m3
(
.clk                            (adc_clk                ),
.key1                           (e2_reset                  ),
.rst_n                          (e2_reset_n               )
); 

(* IODELAY_GROUP = "rgmii_rx_delay" *) 
IDELAYCTRL  IDELAYCTRL_inst (
    .RDY(),                      // 1-bit output: Ready output
    .REFCLK(sys_clk),         // 1-bit input: Reference clock input
    .RST(1'b0)                   // 1-bit input: Active high reset input
);
/*************************************************************************
GMII and RGMII data conversion
****************************************************************************/
util_gmii_to_rgmii #(
   .IDELAY_VALUE(0)
)util_gmii_to_rgmii_m0 (
.reset                        (1'b0                   ),
.rgmii_td                     (rgmii1_txd             ),
.rgmii_tx_ctl                 (rgmii1_txctl           ),
.rgmii_txc                    (rgmii1_txc             ),
.rgmii_rd                     (rgmii1_rxd             ),
.rgmii_rx_ctl                 (rgmii1_rxctl           ),
.gmii_rx_clk                  (gmii_rx_clk            ),
.gmii_txd                     (gmii_txd               ),
.gmii_tx_en                   (gmii_tx_en             ),
.gmii_tx_er                   (1'b0                   ),
.gmii_tx_clk                  (gmii_tx_clk            ),
.gmii_crs                     (gmii_crs               ),
.gmii_col                     (gmii_col               ),
.gmii_rxd                     (gmii_rxd               ),
.rgmii_rxc                    (rgmii1_rxc             ),//add
.gmii_rx_dv                   (gmii_rx_dv             ),
.gmii_rx_er                   (gmii_rx_er             ),
.speed_selection              (speed_selection        ),
.duplex_mode                  (duplex_mode            )
);
/*************************************************************************
 Select only Network 1 to transmit AD data here. If you need other network ports to transmit, 
 rgmii1_txd，rgmii1_txc，rgmii1_rxd，rgmii1_rxd，rgmii1_rxctl should bereplaced accordingly in the util_gmii_to_rgmii_m0 mudule
**************************************************************************/
/*************************************************************************
Transmission of AD data through UDP protocol
**************************************************************************/
eth_top eth_top_inst
(
.rst_n                          (rst_n                    ),    

.fifo_data                      (read_data                ),           //read fifo data
.fifo_data_count                (read_usedw               ),           // Number of data in FIFO that can be read
.fifo_rd_en                     (read_en                  ),           //FIFO read enable

.read_req_ack                   (read_req_ack             ),
.read_req                       (read_req                 ),
.ad_sample_req                  (ad_sample_req            ),
.ad_sample_ack                  (ad_sample_ack            ),
.sample_len                     (sample_len               ),
.gmii_tx_clk                    (gmii_tx_clk              ),
.gmii_rx_clk                    (gmii_rx_clk              ) ,
.gmii_rx_dv                     (gmii_rx_dv               ),
.gmii_rxd                       (gmii_rxd                 ),
.gmii_tx_en                     (gmii_tx_en               ),
.gmii_txd                       (gmii_txd                 )
);
/*************************************************************************
AD data acquisition
**************************************************************************/
ad9280_sample ad9280_sample_m0
(
.adc_clk                        (adc_clk                ),
.rst                            (~rst_n                 ),
.adc_data                       (ad9280_data            ),  
.adc_buf_wr                     (write_en               ),
.adc_buf_data                   (write_data             ),
.sample_len                     (sample_len             ),
.ad_sample_req                  (ad_sample_req          ),
.ad_sample_ack                  (ad_sample_ack          ),
.write_req                      (write_req              ),
.write_req_ack                  (write_req_ack          )
);

/*************************************************************************
 frame data read-write control
**************************************************************************/
frame_read_write frame_read_write_m0
(
.rst                            (~rst_n                   ),
.mem_clk                        (ui_clk                   ),
.rd_burst_req                   (rd_burst_req             ),
.rd_burst_len                   (rd_burst_len             ),
.rd_burst_addr                  (rd_burst_addr            ),
.rd_burst_data_valid            (rd_burst_data_valid      ),
.rd_burst_data                  (rd_burst_data            ),
.rd_burst_finish                (rd_burst_finish          ),
.read_clk                       (gmii_tx_clk              ),
.read_req                       (read_req                 ),
.read_req_ack                   (read_req_ack             ),
.read_finish                    (                         ),
.read_addr_0                    (24'd0                    ), //The first frame address is 0
.read_addr_1                    (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
.read_addr_2                    (24'd4147200              ),
.read_addr_3                    (24'd6220800              ),
.read_addr_index                (2'd0                     ),
.read_len                       (sample_len/4             ),//frame size 
.read_en                        (read_en                  ),
.read_data                      (read_data                ),
.read_usedw                     (read_usedw               ),

.wr_burst_req                   (wr_burst_req             ),
.wr_burst_len                   (wr_burst_len             ),
.wr_burst_addr                  (wr_burst_addr            ),
.wr_burst_data_req              (wr_burst_data_req        ),
.wr_burst_data                  (wr_burst_data            ),
.wr_burst_finish                (wr_burst_finish          ),
.write_clk                      (adc_clk                  ),
.write_req                      (write_req                ),
.write_req_ack                  (write_req_ack            ),
.write_finish                   (                         ),
.write_addr_0                   (24'd0                    ),
.write_addr_1                   (24'd2073600              ),
.write_addr_2                   (24'd4147200              ),
.write_addr_3                   (24'd6220800              ),
.write_addr_index               (2'd0                     ),
.write_len                      (sample_len/4             ), //frame size  
.write_en                       (write_en                 ),
.write_data                     (write_data               )
);
/*************************************************************************
XILINX MIG IP with AXI bus
****************************************************************************/
ddr3 u_ddr3 
(
// Memory interface ports
.ddr3_addr                      (ddr3_addr                 ), 
.ddr3_ba                        (ddr3_ba                   ), 
.ddr3_cas_n                     (ddr3_cas_n                ), 
.ddr3_ck_n                      (ddr3_ck_n                 ), 
.ddr3_ck_p                      (ddr3_ck_p                 ),
.ddr3_cke                       (ddr3_cke                  ),  
.ddr3_ras_n                     (ddr3_ras_n                ), 
.ddr3_reset_n                   (ddr3_reset_n              ), 
.ddr3_we_n                      (ddr3_we_n                 ),  
.ddr3_dq                        (ddr3_dq                   ),  
.ddr3_dqs_n                     (ddr3_dqs_n                ),  
.ddr3_dqs_p                     (ddr3_dqs_p                ),  
.init_calib_complete            (init_calib_complete       ),  
 
.ddr3_cs_n                      (ddr3_cs_n                 ),  
.ddr3_dm                        (ddr3_dm                   ),  
.ddr3_odt                       (ddr3_odt                  ),  
// Application interface ports
.ui_clk                         (ui_clk                    ), 
.ui_clk_sync_rst                (ui_clk_sync_rst           ),  // output	   ui_clk_sync_rst
.mmcm_locked                    (                          ),  // output	    mmcm_locked
.aresetn                        (1'b1                      ),  // input			aresetn
.app_sr_req                     (1'b0                      ),  // input			app_sr_req
.app_ref_req                    (1'b0                      ),  // input			app_ref_req
.app_zq_req                     (1'b0                      ),  // input			app_zq_req
.app_sr_active                  (                          ),  // output	    app_sr_active
.app_ref_ack                    (                          ),  // output		app_ref_ack
.app_zq_ack                     (                          ),  // output		app_zq_ack
// Slave Interface Write Address Ports
.s_axi_awid                     (s00_axi_awid              ),  // input [0:0]	s_axi_awid
.s_axi_awaddr                   (s00_axi_awaddr            ),  // input [29:0]	s_axi_awaddr
.s_axi_awlen                    (s00_axi_awlen             ),  // input [7:0]	s_axi_awlen
.s_axi_awsize                   (s00_axi_awsize            ),  // input [2:0]	s_axi_awsize
.s_axi_awburst                  (s00_axi_awburst           ),  // input [1:0]	s_axi_awburst
.s_axi_awlock                   (s00_axi_awlock            ),  // input [0:0]	s_axi_awlock
.s_axi_awcache                  (s00_axi_awcache           ),  // input [3:0]	s_axi_awcache
.s_axi_awprot                   (s00_axi_awprot            ),  // input [2:0]	s_axi_awprot
.s_axi_awqos                    (s00_axi_awqos             ),  // input [3:0]	s_axi_awqos
.s_axi_awvalid                  (s00_axi_awvalid           ),  // input			s_axi_awvalid
.s_axi_awready                  (s00_axi_awready           ),  // output	    s_axi_awready
// Slave Interface Write Data Ports
.s_axi_wdata                    (s00_axi_wdata             ),  // input [63:0]	s_axi_wdata
.s_axi_wstrb                    (s00_axi_wstrb             ),  // input [7:0]	s_axi_wstrb
.s_axi_wlast                    (s00_axi_wlast             ),  // input			s_axi_wlast
.s_axi_wvalid                   (s00_axi_wvalid            ),  // input			s_axi_wvalid
.s_axi_wready                   (s00_axi_wready            ),  // output		s_axi_wready
// Slave Interface Write Response Ports
.s_axi_bid                      (s00_axi_bid               ),  // output [0:0]	s_axi_bid
.s_axi_bresp                    (s00_axi_bresp             ),  // output [1:0]	s_axi_bresp
.s_axi_bvalid                   (s00_axi_bvalid            ),  // output		s_axi_bvalid
.s_axi_bready                   (s00_axi_bready            ),  // input			s_axi_bready
// Slave Interface Read Address Ports
.s_axi_arid                     (s00_axi_arid              ),  // input [0:0]	s_axi_arid
.s_axi_araddr                   (s00_axi_araddr            ),  // input [29:0]	s_axi_araddr
.s_axi_arlen                    (s00_axi_arlen             ),  // input [7:0]	s_axi_arlen
.s_axi_arsize                   (s00_axi_arsize            ),  // input [2:0]	s_axi_arsize
.s_axi_arburst                  (s00_axi_arburst           ),  // input [1:0]	s_axi_arburst
.s_axi_arlock                   (s00_axi_arlock            ),  // input [0:0]	s_axi_arlock
.s_axi_arcache                  (s00_axi_arcache           ),  // input [3:0]	s_axi_arcache
.s_axi_arprot                   (s00_axi_arprot            ),  // input [2:0]	s_axi_arprot
.s_axi_arqos                    (s00_axi_arqos             ),  // input [3:0]	s_axi_arqos
.s_axi_arvalid                  (s00_axi_arvalid           ),  // input			s_axi_arvalid
.s_axi_arready                  (s00_axi_arready           ),  // output		s_axi_arready
// Slave Interface Read Data Ports
.s_axi_rid                      (s00_axi_rid               ),  // output [0:0]	s_axi_rid
.s_axi_rdata                    (s00_axi_rdata             ),  // output [63:0]	s_axi_rdata
.s_axi_rresp                    (s00_axi_rresp             ),  // output [1:0]	s_axi_rresp
.s_axi_rlast                    (s00_axi_rlast             ),  // output	    s_axi_rlast
.s_axi_rvalid                   (s00_axi_rvalid            ),  // output		s_axi_rvalid
.s_axi_rready                   (s00_axi_rready            ),  // input			s_axi_rready
// System Clock Ports
.sys_clk_i                      (sys_clk                   ),  //               MIG clock
.sys_rst                        (rst_n                     )   //              input sys_rst
);
/*************************************************************************
FFT例化模块
****************************************************************************/
fft_ls fft_ls (
  .aclk(clk_100m),                                                // input wire aclk
  .aresetn(rst_n),                                          // input wire aresetn
  .s_axis_config_tdata(8'b1),                  // input wire [15 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_config_tready(),                // output wire s_axis_config_tready
  
  .s_axis_data_tdata(s_axis_data_tdata),                      // input wire [127 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(s_axis_data_tvalid),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(s_axis_data_tready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(s_axis_data_tlast),                      // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(m_axis_data_tdata),                      // output wire [191 : 0] m_axis_data_tdata
  .m_axis_data_tvalid(m_axis_data_tvalid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast
  
  .m_axis_status_tdata(),                      //fft状态数据通道输出数据
  .m_axis_status_tvalid(),                     //fft状态数据通道输出数据有效使能
  .m_axis_status_tready(1'b1),                 //外部模块准备接收状态数据
  
  .event_frame_started(),                  // output wire event_frame_started
  .event_tlast_unexpected(),            // output wire event_tlast_unexpected
  .event_tlast_missing(),                  // output wire event_tlast_missing
  .event_status_channel_halt(),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt()  // output wire event_data_out_channel_halt
);
//例化数据取模模块
data_modulus  u_data_modulus(
    .clk					(clk_100m),
    .rst_n					(rst_n),
                     
    .source_real			(m_axis_data_tdata[8:0]),    //实部 有符号数
    .source_imag			(m_axis_data_tdata[24:16]),  //虚部 有符号数
    .source_eop				(m_axis_data_tlast),         //fft数据通道接收最后一个数据标志信号
    .source_valid			(m_axis_data_tvalid),        //输出有效信号，FFT变换完成后，此信号置高，开始输出数据
    //取模运算后的数据接口     
    .data_modulus			(write_data),                  //取模后的数据
    .data_eop				(fft_eop),                   //取模后输出的终止信号
    .data_valid				(fft_valid)                  //取模后的数据有效信号
);	
/*************************************************************************
AXI User Interface Conversion 
****************************************************************************/
aq_axi_master u_aq_axi_master
(
.ARESETN                        (~ui_clk_sync_rst         ),
.ACLK                           (ui_clk                   ),
.M_AXI_AWID                     (s00_axi_awid             ),
.M_AXI_AWADDR                   (s00_axi_awaddr           ),
.M_AXI_AWLEN                    (s00_axi_awlen            ),
.M_AXI_AWSIZE                   (s00_axi_awsize           ),
.M_AXI_AWBURST                  (s00_axi_awburst          ),
.M_AXI_AWLOCK                   (s00_axi_awlock           ),
.M_AXI_AWCACHE                  (s00_axi_awcache          ),
.M_AXI_AWPROT                   (s00_axi_awprot           ),
.M_AXI_AWQOS                    (s00_axi_awqos            ),
.M_AXI_AWUSER                   (s00_axi_awuser           ),
.M_AXI_AWVALID                  (s00_axi_awvalid          ),
.M_AXI_AWREADY                  (s00_axi_awready          ),
.M_AXI_WDATA                    (s00_axi_wdata            ),
.M_AXI_WSTRB                    (s00_axi_wstrb            ),
.M_AXI_WLAST                    (s00_axi_wlast            ),
.M_AXI_WUSER                    (s00_axi_wuser            ),
.M_AXI_WVALID                   (s00_axi_wvalid           ),
.M_AXI_WREADY                   (s00_axi_wready           ),
.M_AXI_BID                      (s00_axi_bid              ),
.M_AXI_BRESP                    (s00_axi_bresp            ),
.M_AXI_BUSER                    (s00_axi_buser            ),
.M_AXI_BVALID                   (s00_axi_bvalid           ),
.M_AXI_BREADY                   (s00_axi_bready           ),
.M_AXI_ARID                     (s00_axi_arid             ),
.M_AXI_ARADDR                   (s00_axi_araddr           ),
.M_AXI_ARLEN                    (s00_axi_arlen            ),
.M_AXI_ARSIZE                   (s00_axi_arsize           ),
.M_AXI_ARBURST                  (s00_axi_arburst          ),
.M_AXI_ARLOCK                   (s00_axi_arlock           ),
.M_AXI_ARCACHE                  (s00_axi_arcache          ),
.M_AXI_ARPROT                   (s00_axi_arprot           ),
.M_AXI_ARQOS                    (s00_axi_arqos            ),
.M_AXI_ARUSER                   (s00_axi_aruser           ),
.M_AXI_ARVALID                  (s00_axi_arvalid          ),
.M_AXI_ARREADY                  (s00_axi_arready          ),
.M_AXI_RID                      (s00_axi_rid              ),
.M_AXI_RDATA                    (s00_axi_rdata            ),
.M_AXI_RRESP                    (s00_axi_rresp            ),
.M_AXI_RLAST                    (s00_axi_rlast            ),
.M_AXI_RUSER                    (s00_axi_ruser            ),
.M_AXI_RVALID                   (s00_axi_rvalid           ),
.M_AXI_RREADY                   (s00_axi_rready           ),
.MASTER_RST                     (1'b0                     ),
.WR_START                       (wr_burst_req             ),
.WR_ADRS                        ({wr_burst_addr,3'd0}     ),
.WR_LEN                         ({wr_burst_len,3'd0}      ),
.WR_READY                       (                         ),
.WR_FIFO_RE                     (wr_burst_data_req        ),
.WR_FIFO_EMPTY                  (1'b0                     ),
.WR_FIFO_AEMPTY                 (1'b0                     ),
.WR_FIFO_DATA                   (wr_burst_data            ),
.WR_DONE                        (wr_burst_finish          ),
.RD_START                       (rd_burst_req             ),
.RD_ADRS                        ({rd_burst_addr,3'd0}     ),
.RD_LEN                         ({rd_burst_len,3'd0}      ),
.RD_READY                       (                         ),
.RD_FIFO_WE                     (rd_burst_data_valid      ),
.RD_FIFO_FULL                   (1'b0                     ),
.RD_FIFO_AFULL                  (1'b0                     ),
.RD_FIFO_DATA                   (rd_burst_data            ),
.RD_DONE                        (rd_burst_finish          ),
.DEBUG                          (                         )
);
endmodule