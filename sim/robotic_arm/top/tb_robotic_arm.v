`timescale	1ns/1ns

module tb_robotic_arm();

reg				sys_clk;
reg				sys_rst_n;

//reg				key_1;
//reg				key_2;
//reg				key_3;
//reg				key_4;

reg		[7:0]	X;
reg		[7:0]	Y;
reg		[1:0]	shape;
reg		[1:0]	color;
reg				valid_image_process_data;

reg		[6:0]	DUTY_STEP;
reg		[23:0]	CNT_DELAY_DUTY;

wire			pwm_0;
wire			pwm_1;
wire			pwm_2;
wire			pwm_3;
wire			pwm_4;
wire			air_pump;

robotic_arm	robotic_arm_inst
(
	.sys_clk					(sys_clk),	//系统时钟
	.sys_rst_n					(sys_rst_n),//系统复位

//	.key_1						(key_1),
//	.key_2						(key_2),
//	.key_3						(key_3),
//	.key_4						(key_4),

	.X							(X),
	.Y							(Y),
	.shape						(shape),					//形状：2'b00——>圆、2'b01——>方、2'b10——>六
	.color						(color),					//颜色：2'b00——>红、2'b01——>黄、2'b10——>蓝、2'b11——>黑
	.valid_image_process_data	(valid_image_process_data),	//图像识别信息有效

	.DUTY_STEP					(DUTY_STEP),
	.CNT_DELAY_DUTY				(CNT_DELAY_DUTY),

	.pwm_0						(pwm_0),	//PWM驱动舵机0
	.pwm_1						(pwm_1),	//PWM驱动舵机1
	.pwm_2						(pwm_2),	//PWM驱动舵机2
	.pwm_3						(pwm_3),	//PWM驱动舵机3
	.pwm_4						(pwm_4),	//PWM驱动舵机4
	.air_pump					(air_pump)	//气泵使能
);

initial
	begin
		sys_clk = 1'b0;
		sys_rst_n <= 1'b0;
//		key_1 <= 1'b0;
//		key_2 <= 1'b0;
//		key_3 <= 1'b0;
//		key_4 <= 1'b0;
		X <= 8'b0;
		Y <= 8'b0;
		shape <= 2'b0;
		color <= 2'b0;
		valid_image_process_data <= 1'b0;

		DUTY_STEP <= 7'd0;
		CNT_DELAY_DUTY <= 24'd0;
		#1000
		sys_rst_n <= 1'b1;
		#1000
		X <= 8'd50;
		Y <= 8'd50;
		shape <= 2'b10;
		color <= 2'b10;
		valid_image_process_data <= 1'b1;

		DUTY_STEP <= 7'd100;
		CNT_DELAY_DUTY <= 24'd500;
	end

always #1 sys_clk = ~ sys_clk;

endmodule
