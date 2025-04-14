-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Tue Apr  1 16:31:10 2025
-- Host        : FranklinY9000P running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               F:/AD/Artix7-7103/01_demo_document/ad9280_ethernet/adc_ethernet.srcs/sources_1/ip/adc_pll/adc_pll_stub.vhdl
-- Design      : adc_pll
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tfgg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adc_pll is
  Port ( 
    clk_out1 : out STD_LOGIC;
    clk_50m : out STD_LOGIC;
    clk_100m : out STD_LOGIC;
    clk_25m : out STD_LOGIC;
    clk_25m_deg : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end adc_pll;

architecture stub of adc_pll is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,clk_50m,clk_100m,clk_25m,clk_25m_deg,reset,locked,clk_in1";
begin
end;
