`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// 实验平台: 野火FPGA系列开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module par_to_ser
(
    input   wire            clk_5x      ,   //输入系统时钟
    input   wire    [9:0]   par_data    ,   //输入并行数据

    output  wire            ser_data_p  ,   //输出串行差分数据
    output  wire            ser_data_n      //输出串行差分数据
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire data;
wire    [4:0]   data_rise = {par_data[8],par_data[6],
                            par_data[4],par_data[2],par_data[0]};
wire    [4:0]   data_fall = {par_data[9],par_data[7],
                            par_data[5],par_data[3],par_data[1]};

//reg   define
reg     [4:0]   data_rise_s = 0;
reg     [4:0]   data_fall_s = 0;
reg     [2:0]   cnt = 0;


always @ (posedge clk_5x)
    begin
        cnt <= (cnt[2]) ? 3'd0 : cnt + 3'd1;
        data_rise_s  <= cnt[2] ? data_rise : data_rise_s[4:1];
        data_fall_s  <= cnt[2] ? data_fall : data_fall_s[4:1];

    end

//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
//ODDR2原语 
//将单边沿时钟信号转换为双边沿时钟信号
//5倍时钟双边沿输出数据等价为10倍时钟单边沿输出数据
ODDR2 #(
   .DDR_ALIGNMENT("NONE"), //设置输出对齐方式 "NONE", "C0" or "C1" 
   .INIT         (1'b0  ), // 设置初始化输出电平
   .SRTYPE       ("SYNC")  // 同步复位 "SYNC" or 异步复位"ASYNC" set/reset
) ODDR2_inst0 (
   .Q (data          ),   //输出ddr双边沿数据
   .C0(~clk_5x       ),   //上升沿时钟
   .C1(clk_5x        ),   // 下降沿时钟
   .CE(1'b1          ), // 使能输入
   .D0(data_rise_s[0]), // 上升沿数据
   .D1(data_fall_s[0]), // 上升沿数据
   .R (1'b0          ),   // 复位输入，不复位
   .S (1'b0          )    // 置位输入，不置位
);

//OBUFDS原语
//将单端信号转换为差分信号，约束为TMDS33电平
OBUFDS #(
   .IOSTANDARD("TMDS_33") //约束电平为TMDS33
) OBUFDS_inst (
   .O (ser_data_p), //差分信号正极性输出
   .OB(ser_data_n), //差分信号正极性输出
   .I (data      )  //单端信号输入 
);

endmodule
