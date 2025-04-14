// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module adc_pll(clk_out1, clk_50m, clk_100m, clk_25m, 
  clk_25m_deg, reset, locked, clk_in1);
  output clk_out1;
  output clk_50m;
  output clk_100m;
  output clk_25m;
  output clk_25m_deg;
  input reset;
  output locked;
  input clk_in1;
endmodule
