// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue Apr  1 16:31:10 2025
// Host        : FranklinY9000P running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               F:/AD/Artix7-7103/01_demo_document/ad9280_ethernet/adc_ethernet.srcs/sources_1/ip/adc_pll/adc_pll_stub.v
// Design      : adc_pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module adc_pll(clk_out1, clk_50m, clk_100m, clk_25m, 
  clk_25m_deg, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,clk_50m,clk_100m,clk_25m,clk_25m_deg,reset,locked,clk_in1" */;
  output clk_out1;
  output clk_50m;
  output clk_100m;
  output clk_25m;
  output clk_25m_deg;
  input reset;
  output locked;
  input clk_in1;
endmodule
