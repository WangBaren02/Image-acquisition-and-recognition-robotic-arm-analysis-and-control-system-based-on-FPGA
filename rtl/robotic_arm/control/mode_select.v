//模式选择模块
//当复位时，希望舵机尽快到达——>用模式0：delay突变至1500
//当抓或取时，希望舵机速度相对稳定——>用模式1：线性插值，delay从1500步进至目标
module mode_select
(
	input					clk,					//系统时钟：1MHz
	input					rst_n,					//模块复位

	input					en_interpolation,		//线性插值模式使能
	input					first_or_last,			//1号舵机最先或最后动：1'b1最先、1'b0最后
	input 			[3:0]	state_arm,

	input			[11:0]	delay_0,				//比赛模式下舵机0的PWM数据
	input			[11:0]	delay_1,				//比赛模式下舵机1的PWM数据
	input			[11:0]	delay_2,				//比赛模式下舵机2的PWM数据
	input			[11:0]	delay_3,				//比赛模式下舵机3的PWM数据
	input			[11:0]  delay_4,				//比赛模式下舵机4的PWM数据

//	input			[6:0]	DUTY_STEP,				//步进delay_time
//	input			[19:0]	CNT_DELAY_DUTY,			//分频计数器最大值

	output	reg 	[11:0]	duty_processed_0,		//经过处理的舵机0数据
	output	reg 	[11:0]	duty_processed_1,		//经过处理的舵机1数据
	output	reg 	[11:0]	duty_processed_2,		//经过处理的舵机2数据
	output	reg 	[11:0]	duty_processed_3,		//经过处理的舵机3数据
	output	reg 	[11:0]	duty_processed_4,		//经过处理的舵机4数据

	output	wire			interpolation_done_flag	//完成线性插值标志信号
);
//////////////////////////////////////////////////////////////

	localparam 	DUTY_STEP = 4'd10;
	localparam 	CNT_DELAY_DUTY = 19'd10000;	//分频计数器最大值

	localparam	MID = 12'd1500;					//舵机复位（竖直）值

	localparam	RESET_0 = 12'd1500;				//舵机0复位值
	localparam	RESET_1 = 12'd2000;				//舵机1复位值
	localparam	RESET_2 = 12'd2100;				//舵机2复位值
	localparam	RESET_3 = 12'd800;				//舵机3复位值
	localparam	RESET_4 = 12'd1500;				//舵机4复位值

	localparam  RESET_0_cangku = 12'd800;		//舵机0在仓库的复位值
	localparam  RESET_1_cangku = 12'd2000;		//舵机1在仓库的复位值
	localparam  RESET_2_cangku = 12'd2100;		//舵机2在仓库的复位值
	localparam  RESET_3_cangku = 12'd800;		//舵机3在仓库的复位值

	localparam  RESET_0_mudidi = 12'd2200;		//舵机0在目的地的复位值
	localparam  RESET_1_mudidi = 12'd2000;		//舵机1在目的地的复位值
	localparam  RESET_2_mudidi = 12'd2100;		//舵机2在目的地的复位值
	localparam  RESET_3_mudidi = 12'd800;		//舵机3在目的地的复位值

	localparam	SERVO1_DELAY = 21'd1200000;	//舵机1先运动的时间	//21'd1200000
//注意！！！！！！：SERVO1_DELAY必须小于等于state_ctrl里的RESET_TIME
//否则后果不堪设想
///////////////////////////////////////////////////////
//当舵机0、1、2、3都完成插值后，插值完成信号拉高
	wire	duty_done_0;		//舵机0线性插值完成
	wire	duty_done_1;		//舵机1线性插值完成
	wire	duty_done_2;		//舵机2线性插值完成
	wire	duty_done_3;		//舵机3线性插值完成

	wire	interpolation_half;	//舵机0、2、3线性插值完成
	wire	interpolation_done;	//所有线性插值完成信号

	assign interpolation_half = duty_done_0 && duty_done_2 && duty_done_3;
	assign interpolation_done = duty_done_0 && duty_done_1 && duty_done_2 && duty_done_3;

	reg 	interpolation_done_reg;

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) interpolation_done_reg <= 1'b0;
			else interpolation_done_reg <= interpolation_done;
		end

	assign interpolation_done_flag = ((!interpolation_done_reg) && interpolation_done);
////////////////////////////////////////////////////////
	reg 	[11:0]	duty_start_0;

	always@(*)
		begin
			if(state_arm==4'd2) duty_start_0 <= RESET_0_cangku;
			else if(state_arm==4'd6) duty_start_0 <= RESET_0_mudidi;
			else duty_start_0 <= RESET_0;
		end

	wire	[11:0]	duty_0;			//舵机0的实时数据
//	wire			duty_done_0;	//舵机0线性插值完成
//舵机0线性插值模块的例化
	linear_interpolation linear_interpolation_inst_0
	(
		.clk				(clk),
		.rst_n				(en_interpolation),

		.en_interpolation 	(en_interpolation),
		.duty_start			(duty_start_0),
		.duty_target		(delay_0),
		.DUTY_STEP			(DUTY_STEP),
		.CNT_DELAY_DUTY		(CNT_DELAY_DUTY),

		.duty 				(duty_0),
		.duty_done			(duty_done_0)
	);
////////////////////////////////////////////////////////
	wire	[11:0]	duty_1;			//舵机1的实时数据
//	wire			duty_done_1;	//舵机1线性插值完成
//舵机1线性插值模块的例化
	linear_interpolation linear_interpolation_inst_1
	(
		.clk				(clk),
		.rst_n				(interpolation_half),

		.en_interpolation 	(interpolation_half),
		.duty_start			(RESET_1),	//去往抓位置和放位置的开始皆是复位
		.duty_target		(delay_1),
		.DUTY_STEP			(DUTY_STEP),
		.CNT_DELAY_DUTY		(CNT_DELAY_DUTY),

		.duty 				(duty_1),
		.duty_done			(duty_done_1)
	);
////////////////////////////////////////////////////////
	wire	[11:0]	duty_2;			//舵机2的实时数据
//	wire			duty_done_2;	//舵机2线性插值完成
//舵机2线性插值模块的例化
	linear_interpolation linear_interpolation_inst_2
	(
		.clk				(clk),
		.rst_n				(en_interpolation),

		.en_interpolation 	(en_interpolation),
		.duty_start			(RESET_2),
		.duty_target		(delay_2),
		.DUTY_STEP			(DUTY_STEP),
		.CNT_DELAY_DUTY		(CNT_DELAY_DUTY),

		.duty 				(duty_2),
		.duty_done			(duty_done_2)
	);
/////////////////////////////////////////////////////////
	wire	[11:0]	duty_3;			//舵机3的实时数据
//	wire			duty_done_3;	//舵机3线性插值完成
//舵机3线性插值模块的例化
	linear_interpolation linear_interpolation_inst_3
	(
		.clk				(clk),
		.rst_n				(en_interpolation),

		.en_interpolation 	(en_interpolation),
		.duty_start			(RESET_3),
		.duty_target		(delay_3),
		.DUTY_STEP			(DUTY_STEP),
		.CNT_DELAY_DUTY		(CNT_DELAY_DUTY),

		.duty 				(duty_3),
		.duty_done			(duty_done_3)
	);
///////////////////////////////////////////////////////
	reg  	[20:0]	delay;
	reg 			delay_done;

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) delay <= 21'b0;
			else if(delay == SERVO1_DELAY) delay <= 21'b0;
			else if(first_or_last) delay <= delay + 1'b1;
			else delay <= 21'b0;
		end

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) delay_done <= 1'b0;
			else if(!first_or_last) delay_done <= 1'b0;
			else if(delay == SERVO1_DELAY) delay_done <= 1'b1;
			else delay_done <= delay_done;
		end
///////////////////////////////////////////////////////
//模式确定：
//mode==1'b0时使用全速模式；
//mode==1'b1时使用线性插值模式；
	wire	mode;

	assign mode = en_interpolation;
//////////////////////////////////////////////////////////////////////////////////////////
	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n)
				begin
					duty_processed_0 <= duty_start_0;
					duty_processed_1 <= RESET_1;
					duty_processed_2 <= RESET_2;
					duty_processed_3 <= RESET_3;
					duty_processed_4 <= RESET_4;
				end
			else
				case(mode)
				1'b0://全速模式
					begin
						duty_processed_1 <= delay_1;

						if(first_or_last && delay_done)
							begin
								duty_processed_0 <= delay_0;
								duty_processed_2 <= delay_2;
								duty_processed_3 <= delay_3;
								duty_processed_4 <= delay_4;
							end
						else if(!first_or_last)
							begin
								duty_processed_0 <= delay_0;
								duty_processed_2 <= delay_2;
								duty_processed_3 <= delay_3;
								duty_processed_4 <= delay_4;
							end
						else
							begin
								duty_processed_0 <= duty_processed_0;
								duty_processed_2 <= duty_processed_2;
								duty_processed_3 <= duty_processed_3;
								duty_processed_4 <= duty_processed_4;
							end
					end
				1'b1://线性插值模式
					begin
						duty_processed_0 <= duty_0;
						duty_processed_2 <= duty_2;
						duty_processed_3 <= duty_3;
						duty_processed_4 <= delay_4;

						if(interpolation_half)
							begin
								duty_processed_1 <= duty_1;
							end
						else
							begin
								duty_processed_1 <= RESET_1;
							end
					end
				default:
					begin
						duty_processed_0 <= duty_start_0;
						duty_processed_1 <= RESET_1;
						duty_processed_2 <= RESET_2;
						duty_processed_3 <= RESET_3;
						duty_processed_4 <= RESET_4;
					end
				endcase
		end

endmodule
