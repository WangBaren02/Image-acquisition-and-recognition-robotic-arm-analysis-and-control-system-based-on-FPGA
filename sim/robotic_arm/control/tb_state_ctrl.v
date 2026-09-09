`timescale 1ns/1ns

module tb_state_ctrl();

reg		clk;
reg		rst_n;

reg		start;
reg		interpolation_done;

state_ctrl
//#(
//	parameter 	CATCH_TIME 	 = 26'd100,	//机械臂从抓姿态到复位姿态所需时间
//	parameter	RELEASE_TIME = 26'd100,	//机械臂从放姿态到复位姿态所需时间
//	parameter	LAYDOWN_TIME = 26'd100	//气泵吸或放所需时间
//)
(
	input	wire			clk,				//时钟：12MHz
	input	wire			rst_n,				//模块复位

	input	wire			start,				//图像识别信息有效为高电平时，机械臂开始工作
	input	wire			interpolation_done,	//线性插值模块完成
	output	reg				mode,				//舵机模式：1'b1为速度可调模式、1'b0为全速模式

	input	wire	[11:0]	catch_0,			//舵机0的抓数据
	input	wire	[11:0]	catch_1,			//舵机1的抓数据
	input	wire	[11:0]	catch_2,			//舵机2的抓数据
	input	wire	[11:0]	catch_3,			//舵机3的抓数据
//	input	wire	[11:0]	catch_4,			//舵机4的抓数据
	input	wire			valid_catch_data,	//抓数据有效信号
	output	reg				en_catch,			//读取抓数据模块的使能

	input	wire	[11:0]	release_0,			//舵机0的放数据
	input	wire	[11:0]	release_1,			//舵机1的放数据
	input	wire	[11:0]	release_2,			//舵机2的放数据
	input	wire	[11:0]	release_3,			//舵机3的放数据
//	input	wire	[11:0]	release_4,			//舵机4的放数据
	input	wire			valid_release_data,	//放数据有效信号
	output	reg				en_release,			//读取放数据模块的使能

	output	reg		[11:0]	delay_0,			//舵机0的PWM数据
	output	reg		[11:0]	delay_1,			//舵机1的PWM数据
	output	reg		[11:0]	delay_2,			//舵机2的PWM数据
	output	reg		[11:0]	delay_3,			//舵机3的PWM数据
//	output	reg		[11:0]	delay_4,			//舵机4的PWM数据
	output	reg				air_pump			//气泵
);
