`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// 实验平台: 野火FPGA系列开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////


module rgb2yuv(
input wire [7:0] Red,
input wire [7:0] Green,
input wire [7:0] Blue,

output wire [7:0]ycbcr_y,
output wire [7:0]ycbcr_cb,
output wire [7:0]ycbcr_cr

    );

parameter KYR=306;
parameter KYG=601;
parameter KYB=116;
parameter OFFSET_Y=0;

parameter KCBR=-173;
parameter KCBG=-339;
parameter KCBB=512;
parameter OFFSET_CB=131000;

parameter KCRR=512;
parameter KCRG=-428;
parameter KCRB=-83;
parameter OFFSET_CR=131000;

wire [17:0]ycbcr_y_tmp;
wire [17:0]ycbcr_cb_tmp;
wire [17:0]ycbcr_cr_tmp;

assign ycbcr_y_tmp=KYR*Red+KYG*Green+KYB*Blue+OFFSET_Y;
assign ycbcr_cb_tmp=KCBR*Red+KCBG*Green+KCBB*Blue+OFFSET_CB;
assign ycbcr_cr_tmp=KCRR*Red+KCRG*Green+KCRB*Blue+OFFSET_CR;

assign ycbcr_y=ycbcr_y_tmp[17:10];
assign ycbcr_cb=ycbcr_cb_tmp[17:10];
assign ycbcr_cr=ycbcr_cr_tmp[17:10];


endmodule
