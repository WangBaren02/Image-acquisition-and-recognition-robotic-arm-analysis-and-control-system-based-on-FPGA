module test_robotic_arm
(
	input	sys_clk,
	input	sys_rst_n,

	input	key1,
	input	key2,
	input	key3,
	input	key4,

	output	pwm0,
	output	pwm1,
	output	pwm2,
	output	pwm3
//	output	pwm4
);
/////////////////////////////////////
	wire	clk_1M;

	wire	locked;

	pll_test	pll_test_inst
	(
		.areset (~sys_rst_n),
		.inclk0 (sys_clk),

		.c0 	(clk_1M),
		.locked (locked)
	);

	wire	rst_n;

	assign rst_n = sys_rst_n & locked;
///////////////////////////////////////
	wire	[3:0]	key;

	assign key = {key4,key3,key2,key1};
//////////////////////////////////////////
	reg		[7:0]	X;	//-82~82
	reg		[7:0]	Y;	//85~196
	reg		[1:0]	shape;
	reg		[1:0]	color;
	reg				valid_image_process_data;

	always@( posedge clk_1M or negedge rst_n )
		begin
			if(!rst_n)
				begin
					X <= 8'b0;
					Y <= 8'b0;
					shape <= 2'b0;
					color <= 2'b0;
					valid_image_process_data <= 1'b0;
				end
			else
				begin
					case(key)
					4'b1110:
						begin
							X <= 97;
							Y <= 20;
							shape <= 2'b00;
							color <= 2'b00;
							valid_image_process_data <= 1'b1;
						end
					4'b1101:
						begin
							X <= 97;
							Y <= 60;
							shape <= 2'b01;
							color <= 2'b01;
							valid_image_process_data <= 1'b1;
						end
					4'b1011:
						begin
							X <= 150;
							Y <= 20;
							shape <= 2'b11;
							color <= 2'b01;
							valid_image_process_data <= 1'b1;
						end
					4'b0111:
						begin
							X <= 50;
							Y <= 20;
							shape <= 2'b10;
							color <= 2'b10;
							valid_image_process_data <= 1'b1;
						end
					default:
						begin
							X <= 8'b0;
							Y <= 8'b0;
							shape <= 2'b11;
							color <= 2'b11;
							valid_image_process_data <= 1'b0;
						end
					endcase
				end
		end

	wire	loop_done;

	robotic_arm_low_clk robotic_arm_low_clk_inst
    (
        .sys_clk                    (clk_1M),       //模块时钟:1MHz
        .sys_rst_n                  (rst_n),    	//模块复位

        .X                          (X),
        .Y                          (Y),
        .shape                      (shape),        //形状��?2'b00—��?>圆��?2'b01—��?>方��?2'b10—��?>��?
        .color                      (color),        //颜色��?2'b00—��?>纀�?2'b01—��?>黄��?2'b10—��?>蓝��?2'b11—��?>��?
        .valid_image_process_data   (valid_image_process_data), //图像识别信息有效

        .DUTY_STEP                  (7'd10),        //7'd10
        .CNT_DELAY_DUTY             (20'd10000),    //20'd10000

//        .mode                       (mode),
//
//        .duty_processed_0           (duty_0),
//        .duty_processed_1           (duty_1),
//        .duty_processed_2           (duty_2),
//        .duty_processed_3           (duty_3),

        .pwm_0                      (pwm_0),        //PWM驱动舵机0
        .pwm_1                      (pwm_1),        //PWM驱动舵机1
        .pwm_2                      (pwm_2),        //PWM驱动舵机2
        .pwm_3                      (pwm_3),        //PWM驱动舵机3
//        .pwm_4                      (pwm_4),        //PWM驱动舵机4
        .air_pump                   (air_pump),     //气泵使能

        .loop_done                  (loop_done) 	//完成一个物体放��?
    );

endmodule
