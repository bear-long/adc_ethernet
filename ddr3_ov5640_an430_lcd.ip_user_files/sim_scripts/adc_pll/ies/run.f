-makelib ies_lib/xil_defaultlib -sv \
  "E:/xilinx_SDK/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "E:/xilinx_SDK/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "E:/xilinx_SDK/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../adc_ethernet.srcs/sources_1/ip/adc_pll/adc_pll_clk_wiz.v" \
  "../../../../adc_ethernet.srcs/sources_1/ip/adc_pll/adc_pll.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

