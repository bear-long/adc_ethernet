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
//2017/8/28                   1.0          Original
//*******************************************************************************/
module ad9280_sample

       (
         input                       adc_clk,
         input                       rst,
         input      [7:0]            adc_data,
         input      [31:0]           sample_len,
         input                       ad_sample_req,
         input                       write_req_ack,//这是fifo发出的写请求标志
         
         output reg                  adc_buf_wr,//与fifo写使能标志位连接，表明写使能
         output     [15:0]           adc_buf_data,  
         output reg                  ad_sample_ack,   //ad采样完成标志位                               
         output reg                  write_req
       );
       
//`define TRIGGER

localparam       S_IDLE     = 0;
localparam       S_REQ      = 1;
localparam       S_ACK_WAIT = 2;
localparam       S_SAMPLE   = 3;
localparam       S_WAIT     = 4;


reg signed[15:0]     adc_data_wide;
reg signed[15:0]     adc_data_wide_d0;
reg [31:0]           sample_cnt;
reg [31:0]           wait_cnt;
reg signed[7:0]      adc_data_signed ;

reg        ad_sample_req_d0     ;
reg        ad_sample_req_d1     ;
reg        ad_sample_req_d2     ;

reg[2:0] state;

assign adc_buf_data = adc_data_wide_d0;

always@(posedge adc_clk or posedge rst)
  begin
    if(rst == 1'b1)
      adc_data_signed <= 8'd0;
    else
      adc_data_signed <= adc_data[7:0] - 8'd128 ;
  end
  
always@(posedge adc_clk or posedge rst)
  begin
    if(rst == 1'b1)
      adc_data_wide <= 16'd0;
    else
      adc_data_wide <= {{8{adc_data_signed[7]}}, adc_data_signed[7:0]};//16位有符号数，真正的16-bit有符号采样值
  end
  
always@(posedge adc_clk or posedge rst)
  begin
    if(rst == 1'b1)
      adc_data_wide_d0 <= 16'd0;
    else
      adc_data_wide_d0 <= adc_data_wide;//打一拍缓存，送到输出接口
  end
  
  
always @(posedge adc_clk or posedge rst)
  begin
    if (rst)
      begin
        ad_sample_req_d0 <= 1'b0 ;
        ad_sample_req_d1 <= 1'b0 ;
        ad_sample_req_d2 <= 1'b0 ;
      end
    else
      begin
        ad_sample_req_d0 <= ad_sample_req ;
        ad_sample_req_d1 <= ad_sample_req_d0 ;
        ad_sample_req_d2 <= ad_sample_req_d1 ;//ad_sample_reg_d2相当于请求采样开始，当ad_sample_reg_d2为1的时候说明开始准备采样
      end
  end
  
always@(posedge adc_clk or posedge rst)//状态机控制采样请求流程、数据写入 FIFO 过程、以及和上位模块通信的握手逻辑。
  begin
    if(rst == 1'b1)
      begin
        state <= S_IDLE;
        wait_cnt <= 32'd0;
        sample_cnt <= 32'd0;
        adc_buf_wr <= 1'b0;
        ad_sample_ack <= 1'b0 ;
      end
    else
      case(state)
        S_IDLE:
          begin
            if (ad_sample_req_d2)//req_d2为高代表以太网接口触发，可以接收数据，此时ad开始采集数据
              begin
                write_req <= 1'b1 ;
                state <= S_REQ;
              end
            else
              state <= S_IDLE ;
          end
        S_REQ :
          begin
            if (write_req_ack)//fifo同意写标志，这里是收到fifo写请求，以后撤销握手，将write_reg置0；
              begin
                write_req <= 1'b0 ;
                state <= S_ACK_WAIT ;
              end
            else
              state <= S_REQ ;
          end
        S_ACK_WAIT:
          begin
            if (wait_cnt == 32'd40)//这个是等待四十个周期
              begin
                state <= S_SAMPLE ;
                wait_cnt <= 32'd0 ;
              end
            else
              begin
                wait_cnt <= wait_cnt + 1'b1 ;//提出问题，为什么要等待硬件处理延迟？？
                state <= S_ACK_WAIT ;
              end
          end
        S_SAMPLE:
          begin
            ad_sample_ack <= 1'b1 ;
            if(sample_cnt == sample_len)
              begin
                sample_cnt <= 11'd0;
                adc_buf_wr <= 1'b0;
                state <= S_WAIT;
              end
            else
              begin
                sample_cnt <= sample_cnt + 11'd1;//计数
                adc_buf_wr <= 1'b1;//fifo写使能
              end
          end
        S_WAIT:
          begin
            ad_sample_ack <= 1'b0 ;
            state <= S_IDLE;
          end
        default:
          state <= S_IDLE;
      endcase
  end
  
endmodule
