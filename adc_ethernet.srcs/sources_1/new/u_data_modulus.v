`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/10 14:46:31
// Design Name: 
// Module Name: u_data_modulus
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


module data_modulus(
    input           clk,
    input           rst_n,
    input[8:0]      source_real,
    input[8:0]      source_imag,
    input           source_eop,         //fft数据通道接收最后一个数据标志信号
    input           source_valid,       //输出有效信号，FFT变换完成后，此信号置高，开始输出数据
    
    output [15:0]   data_modulus,       //取模后的数据
    output          data_eop,           //取模后输出的终止信号
    output          data_valid          //取模后的数据有效信号
    );
    
reg [15:0]          source_data;        //原码平方和
reg [7:0]           data_real;          //实部原码
reg [7:0]           data_imag;          //虚部原码
reg [7:0]           source_valid_d;
reg [7:0]           source_eop_d;

assign data_eop=source_eop_d[7];

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        source_data<=18'd0;
        data_real<=16'd0;
        data_imag<=16'd0;
    end
    else begin
        if(source_real[8]==1'b0)//确定是否为正数
            data_real<=source_real[7:0];
        else
            data_real<=~source_real[7:0]+1'b1;//求补码，取反后再加一，负数转正数
        
        if(source_imag[8]==1'b0)
            data_imag<=source_imag[7:0];
        else
            data_imag<=~source_imag[7:0]+1'b1;
        source_data<=(data_real*data_real)+(data_imag*data_imag);
    end
end

//对信号进行打拍处理
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        source_eop_d   <= 8'd0;
        source_valid_d <= 8'd0;
    end
    else begin
        source_valid_d <= {source_valid_d[6:0],source_valid};
        source_eop_d   <= {source_eop_d[6:0],source_eop};
    end
end

my_cordic_1 u_my_cordic_1 (
  .aclk(clk),                                        // input wire aclk
  .s_axis_cartesian_tvalid(source_valid_d[1]),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(source_data),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(data_valid),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(data_modulus)              // output wire [15 : 0] m_axis_dout_tdata
);

    
endmodule
