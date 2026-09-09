//机械臂控制的顶层模块
module robotic_arm_low_clk
(
	input			clk,				//模块时钟:1MHz
	input			clk_100M,
	input			rst_n,				//模块复位

//	input			key_1,
//	input			key_2,
//	input			key_3,
//	input			key_4,

	input	[8:0]	X,					//X坐标
	input	[8:0]	Y,					//Y坐标
	input	[2:0]	des_X,				//目的地X
	input	[1:0]	des_Y,				//目的地Y
	input	[11:0]	catch_4_delay,		//抓取时servo4旋转角度
	input	[11:0]	release_4_change,
	input			VIP_data_valid,		//坐标信息有效

	input			lay_0_add_flag,
	input			lay_3_add_flag,

//	input	[6:0]	DUTY_STEP,			//线性插值模式下的步进
//	input	[19:0]	CNT_DELAY_DUTY,		//线性插值每步进的时间间隔

	output			pwm_0,				//PWM驱动舵机0
	output			pwm_1,				//PWM驱动舵机1
	output			pwm_2,				//PWM驱动舵机2
	output			pwm_3,				//PWM驱动舵机3
	output			pwm_4,				//PWM驱动舵机4
	output			air_pump,			//气泵使能

	output			loop_half_done,		//完成一半工作
	output			loop_done			//完成一个物体放置
);
//////////////////////////////////////////////////////////
//例化：抓模块
	wire			en_catch;				//抓使能

	wire	[11:0]	catch_0;				//舵机0的抓数据
	wire	[11:0]	catch_1;				//舵机1的抓数据
	wire	[11:0]	catch_2;				//舵机2的抓数据
	wire	[11:0]	catch_3;				//舵机3的抓数据
	wire	[11:0]	catch_4;				//舵机4的抓数据
	wire			valid_catch_rom_data;	//抓数据有效

	catch catch_inst
	(
		.clk 					(clk),
		.clk_100M 				(clk_100M),
		.rst_n 					(rst_n),

		.X						(X),
		.Y						(Y),
		.catch_4_delay			(catch_4_delay),
		.valid_axis_data		(en_catch),

		.catch_0				(catch_0),
		.catch_1				(catch_1),
		.catch_2				(catch_2),
		.catch_3				(catch_3),
		.catch_4				(catch_4),
		.valid_catch_rom_data	(valid_catch_rom_data)
	);
////////////////////////////////////////////////////////////
//例化：放模块
	wire	[11:0]	release_0;			//舵机0的放数据
	wire	[11:0]	release_1;			//舵机1的放数据
	wire	[11:0]	release_2;			//舵机2的放数据
	wire	[11:0]	release_3;			//舵机3的放数据
	wire	[11:0]	release_4;			//舵机4的放数据
	wire			valid_release_data;	//放数据有效
	wire			en_release;			//放使能

	laydown laydown_inst
	(
		.clk 				(clk),
		.rst_n 				(rst_n),

		.lay_0_add_flag		(lay_0_add_flag),
		.lay_3_add_flag		(lay_3_add_flag),

		.des_X				(des_X),
		.des_Y				(des_Y),
		.release_4_change	(release_4_change),
		.en_release			(en_release),
		.des_valid 			(VIP_data_valid),

		.release_0_change	(release_0),
		.release_1_change	(release_1),
		.release_2_change	(release_2),
		.release_3_change	(release_3),
		.release_4			(release_4),
		.valid_release_data	(valid_release_data)
	);
////////////////////////////////////////////////////////////
//例化：状态机模块
	wire	[11:0]	delay_0;			//舵机0期望数据
	wire	[11:0]	delay_1;			//舵机1期望数据
	wire	[11:0]	delay_2;			//舵机2期望数据
	wire	[11:0]	delay_3;			//舵机3期望数据
	wire	[11:0]	delay_4;			//舵机4期望数据

//	wire			loop_done;			//完成一个物体的抓取及放置（已回到复位状态）
	wire			interpolation_done_flag;	//线性插值完成信号
//	wire			en_catch;			//抓使能
	wire			first_or_last;
	wire	[3:0]	state_arm;

	state_ctrl state_ctrl_inst
	(
		.clk 				(clk),
		.rst_n 				(rst_n),

		.start 				(VIP_data_valid),
		.loop_half_done		(loop_half_done),
		.loop_done			(loop_done),
		.interpolation_done	(interpolation_done_flag),
		.en_interpolation 	(en_interpolation),
		.first_or_last		(first_or_last),
		.state_arm 			(state_arm),

		.catch_0			(catch_0),
		.catch_1			(catch_1),
		.catch_2			(catch_2),
		.catch_3			(catch_3),
		.catch_4			(catch_4),
		.valid_catch_data	(valid_catch_rom_data),
		.en_catch			(en_catch),

		.release_0			(release_0),
		.release_1			(release_1),
		.release_2			(release_2),
		.release_3			(release_3),
		.release_4			(release_4),
		.valid_release_data	(valid_release_data),
		.en_release			(en_release),

		.delay_0			(delay_0),
		.delay_1			(delay_1),
		.delay_2			(delay_2),
		.delay_3			(delay_3),
		.delay_4			(delay_4),
		.air_pump			(air_pump)
	);
/////////////////////////////////////////
//例化：模式选择模块
	wire	[11:0]	duty_processed_0;	//经过处理的舵机0数据（实时）
	wire	[11:0]	duty_processed_1;	//经过处理的舵机1数据（实时）
	wire	[11:0]	duty_processed_2;	//经过处理的舵机2数据（实时）
	wire	[11:0]	duty_processed_3;	//经过处理的舵机3数据（实时）
	wire	[11:0]	duty_processed_4;	//经过处理的舵机4数据（实时）

	mode_select mode_select_inst
	(
		.clk  						(clk),
		.rst_n 						(rst_n),

		.en_interpolation			(en_interpolation),
		.first_or_last				(first_or_last),
		.state_arm 					(state_arm),

		.delay_0					(delay_0),
		.delay_1					(delay_1),
		.delay_2					(delay_2),
		.delay_3					(delay_3),
		.delay_4 					(delay_4),

//		.DUTY_STEP					(DUTY_STEP),
//		.CNT_DELAY_DUTY				(CNT_DELAY_DUTY),

		.duty_processed_0			(duty_processed_0),
		.duty_processed_1			(duty_processed_1),
		.duty_processed_2			(duty_processed_2),
		.duty_processed_3			(duty_processed_3),
		.duty_processed_4			(duty_processed_4),

		.interpolation_done_flag	(interpolation_done_flag)
	);
///////////////////////////////////
//例化：PWM驱动舵机0
	pwm_servo_1M pwm_servo_1M_inst_0
	(
		.sys_clk	(clk),
		.sys_rst_n	(rst_n),

		.delay_us	(duty_processed_0),
		.work		(1'b1),

		.pwm 		(pwm_0)
	);
/////////////////////////////////////
//例化：PWM驱动舵机1
	pwm_servo_1M pwm_servo_1M_inst_1
	(
		.sys_clk	(clk),
		.sys_rst_n	(rst_n),

		.delay_us	(duty_processed_1),
		.work		(1'b1),

		.pwm 		(pwm_1)
	);
//////////////////////////////////////
//例化：PWM驱动舵机2
	pwm_servo_1M pwm_servo_1M_inst_2
	(
		.sys_clk	(clk),
		.sys_rst_n	(rst_n),

		.delay_us	(duty_processed_2),
		.work		(1'b1),

		.pwm 		(pwm_2)
	);
///////////////////////////////////////
//例化：PWM驱动舵机3
	pwm_servo_1M pwm_servo_1M_inst_3
	(
		.sys_clk	(clk),
		.sys_rst_n	(rst_n),

		.delay_us	(duty_processed_3),
		.work		(1'b1),

		.pwm 		(pwm_3)
	);
//////////////////////////////////////
//例化：PWM驱动舵机4
	pwm_servo_1M pwm_servo_1M_inst_4
	(
		.sys_clk	(clk),
		.sys_rst_n	(rst_n),

		.delay_us	(duty_processed_4),
		.work		(1'b1),

		.pwm 		(pwm_4)
	);

endmodule
