`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// 实验平台: 野火FPGA系列?发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  top_seg_dynamic
(
    input   wire            sys_clk     ,   //系统时钟，频?50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效
	input	wire	[19:0]	data		,

    output  wire    [5:0]   sel         ,   //数码管位选信?
    output  wire    [7:0]   seg             //数码管段选信?
);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//
//wire  define
//wire    [19:0]  data    ;   //数码管要显示的??
//wire    [5:0]   point   ;   //小数点显?,高电平有效top_seg_595
//wire            seg_en  ;   //数码管使能信号，高电平有?
//wire            sign    ;   //符号位，高电平显示负?

//********************************************************************//
//**************************** Main Code *****************************//
//********************************************************************//
//-------------data_gen_inst--------------
//data_gen    data_gen_inst
//(
//    .sys_clk     (sys_clk  ),   //系统时钟，频?50MHz
//    .sys_rst_n   (sys_rst_n),   //复位信号，低电平有效
//
//    .data        (data     ),   //数码管要显示的??
//    .point       (point    ),   //小数点显?,高电平有?
//    .seg_en      (seg_en   ),   //数码管使能信号，高电平有?
//    .sign        (sign     )    //符号位，高电平显示负?
//);

//-------------seg7_dynamic_inst--------------

seg_dynamic seg_dynamic_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频?50MHz
    .sys_rst_n   (sys_rst_n),   //复位信号，低有效
    .data        (data     ),   //数码管要显示的??
    .point       (6'b000_000    ),   //小数点显?,高电平有?
    .seg_en      (1'b1   ),   //数码管使能信号，高电平有?
    .sign        (1'b0     ),   //符号位，高电平显示负?

    .sel         (sel      ),   //数码管位选信?
    .seg         (seg      )    //数码管段选信?

);

endmodule
