//状态机控制模块
//舵机	复位——>抓——>复位——>放——>复位
//气泵			 吸         放
//使机械臂按照顺序执行
module state_ctrl
//#(
//	parameter 	CATCH_TIME 	 = 21'd100,	//机械臂从抓姿态到复位姿态所需时间
//	parameter	RELEASE_TIME = 21'd100,	//机械臂从放姿态到复位姿态所需时间
//	parameter	LAYDOWN_TIME = 21'd100	//气泵吸或放所需时间
//)
(
	input	wire			clk,				//时钟：1MHz
	input	wire			rst_n,				//模块复位

	input	wire			start,				//图像识别信息有效为高电平时，机械臂开始工作
	output	reg 			loop_half_done,		//完成一半工作
	output	reg 			loop_done,			//完成放置一个物体
	input	wire			interpolation_done,	//线性插值模块完成
	output	reg				en_interpolation,	//线性插值模式使能
	output	reg 			first_or_last,		//1号舵机最先或最后动：1'b1最先、1'b0最后
	output	reg  	[3:0]	state_arm,

	input	wire	[11:0]	catch_0,			//舵机0的抓数据
	input	wire	[11:0]	catch_1,			//舵机1的抓数据
	input	wire	[11:0]	catch_2,			//舵机2的抓数据
	input	wire	[11:0]	catch_3,			//舵机3的抓数据
	input	wire	[11:0]	catch_4,			//舵机4的抓数据
	input	wire			valid_catch_data,	//抓数据有效信号
	output	reg				en_catch,			//读取抓数据模块的使能

	input	wire	[11:0]	release_0,			//舵机0的放数据
	input	wire	[11:0]	release_1,			//舵机1的放数据
	input	wire	[11:0]	release_2,			//舵机2的放数据
	input	wire	[11:0]	release_3,			//舵机3的放数据
	input	wire	[11:0]	release_4,			//舵机4的放数据
	input	wire			valid_release_data,	//放数据有效信号
	output	reg				en_release,			//读取放数据模块的使能

	output	reg		[11:0]	delay_0,			//舵机0的PWM数据
	output	reg		[11:0]	delay_1,			//舵机1的PWM数据
	output	reg		[11:0]	delay_2,			//舵机2的PWM数据
	output	reg		[11:0]	delay_3,			//舵机3的PWM数据
	output	reg		[11:0]	delay_4,			//舵机4的PWM数据
	output	reg				air_pump			//气泵
);
//////////////////////////////////////////////////////////////////////
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

	localparam	STABILIZE_TIME = 26'd800000;	//机械臂从线性插值完成到舵机到达抓或放的稳定状态所需时间	//26'd800000
	localparam	RESET_TIME = 26'd1500000;		//机械臂从抓或姿态到复位姿态所需时间					//26'd1500000
	localparam	AIR_PUMP_TIME = 26'd800000;		//气泵吸或放所需时间									//26'd800000
	localparam	STATE_47_TIME = AIR_PUMP_TIME + RESET_TIME;	//状态3所需时间
	localparam 	PREPARE_TIME = 26'd800000;		//机械臂从复位状态到预备状态的所需时间
//////////////////////////////////////////////////////////////////////////////////////
	// reg	[3:0]	state_arm;		//状态机变量
	reg	[3:0]	state_arm_reg;	//状态机变量寄存

	always@(posedge clk or negedge rst_n)	//给状态信号打一拍
		begin
			if(!rst_n)	state_arm_reg <= 4'b0;
			else state_arm_reg <= state_arm;
		end

	wire		state_arm_change_flag;//状态转变信号

	assign state_arm_change_flag = (state_arm != state_arm_reg) ? 1'b1 : 1'b0;	//当状态机变量和状态机变量寄存不一样时，状态改变
////////////////////////////////////////////////////
//延时计数器
	reg	[25:0]	delay;			//延时计数器

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) delay <= 26'b0;
			else if(state_arm_change_flag) delay <= 26'b0;
			else if(state_arm!=0) delay <= delay + 1'b1;
			else delay <= 26'b0;
		end
////////////////////////////////////////////
//状态机
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					state_arm <= 4'd0;
					delay_0 <= RESET_0;
					delay_1 <= RESET_1;
					delay_2 <= RESET_2;
					delay_3 <= RESET_3;
					delay_4 <= RESET_4;

					loop_half_done <= 1'b0;
					loop_done <= 1'b0;
					en_interpolation <= 1'b0;
					en_catch <= 1'b0;
					first_or_last <= 1'b0;
					en_release <= 1'b0;

					air_pump <= 1'b0;
				end
			else
				begin
					case(state_arm)
					4'd0://复位
						begin
							loop_done <= 1'b0;

							delay_0 <= RESET_0;
							delay_1 <= RESET_1;
							delay_2 <= RESET_2;
							delay_3 <= RESET_3;
							delay_4 <= RESET_4;

							air_pump <= 1'b0;

							if(start)
								state_arm <= 4'd1;
						end
					4'd1://到抓取预备姿态
						begin
							delay_0 <= RESET_0_cangku;
							delay_1 <= RESET_1_cangku;
							delay_2 <= RESET_2_cangku;
							delay_3 <= RESET_3_cangku;
							delay_4 <= RESET_4;

							if(delay == PREPARE_TIME)
								begin
									state_arm <= 4'd2;
								end
						end
					4'd2://到抓取姿态
						begin
							en_catch <= 1'b1;
							first_or_last <= 1'b0;

							if(valid_catch_data)
								begin
									delay_0 <= catch_0;
									delay_1 <= catch_1;
									delay_2 <= catch_2;
									delay_3 <= catch_3;
									delay_4 <= catch_4;

									en_interpolation <= 1'b1;
								end

							if(interpolation_done)
								begin
									state_arm <= 4'd3;
									en_interpolation <= 1'b0;
								end
						end
					4'd3://气泵抓起薄片
						begin
							if(delay == STABILIZE_TIME)
								begin
									air_pump <= 1'b1;

									state_arm <= 4'd4;
									en_catch <= 1'b0;
								end
						end
					4'd4://复位
						begin
							if(delay == AIR_PUMP_TIME)
								begin
									first_or_last <= 1'b1;

									delay_0 <= RESET_0;
									delay_1 <= RESET_1;
									delay_2 <= RESET_2;
									delay_3 <= RESET_3;
									delay_4 <= RESET_4;
								end

							if(delay == STATE_47_TIME)
								begin
									state_arm <= 4'd5;
								end
						end
					4'd5://到放置预备姿态
						begin
							delay_0 <= RESET_0_mudidi;
							delay_1 <= RESET_1_mudidi;
							delay_2 <= RESET_2_mudidi;
							delay_3 <= RESET_3_mudidi;
							delay_4 <= RESET_4;

							if(delay == PREPARE_TIME)
								begin
									state_arm <= 4'd6;
									en_interpolation <= 1'b0;
								end
						end
					4'd6://到放置姿态
						begin
							en_release <= 1'b1;
							first_or_last <= 1'b0;
							loop_half_done <= 1'b1;

							if(valid_release_data)
								begin
									delay_0 <= release_0;
									delay_1 <= release_1;
									delay_2 <= release_2;
									delay_3 <= release_3;
									delay_4 <= release_4;

									en_interpolation <= 1'b1;
								end

							if(interpolation_done)
								begin
									state_arm <= 4'd7;
									en_interpolation <= 1'b0;
									loop_half_done <= 1'b0;
								end
						end
					4'd7://气泵放下薄片
						begin
							if(delay == STABILIZE_TIME)
								begin
									air_pump <= 1'b0;

									state_arm <= 4'd8;
									en_release <= 1'b0;
								end
						end
					4'd8://复位
						begin
							if(delay == AIR_PUMP_TIME)
								begin
									first_or_last <= 1'b1;

									delay_0 <= RESET_0;
									delay_1 <= RESET_1;
									delay_2 <= RESET_2;
									delay_3 <= RESET_3;
									delay_4 <= RESET_4;
								end

							if(delay == STATE_47_TIME)
								begin
									state_arm <= 4'd0;
									loop_done <= 1'b1;
								end
						end
					default:;
					endcase
				end
		end

endmodule
