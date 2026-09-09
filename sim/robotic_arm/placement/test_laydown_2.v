module test_laydown_2
(
	input	sys_clk,
	input	sys_rst_n,

	input	key1,
	input	key2,
	input	key3,
	input	key4,

	output	pwm_0,
	output	pwm_1,
	output	pwm_2,
	output	pwm_3,
	output	pwm_4
);

	wire			clk_1M;

	pll_ip	pll_ip_inst
	(
		.areset ( ~sys_rst_n ),
		.inclk0 ( sys_clk ),
		.c0 	( clk_1M ),
		.locked ( locked )
	);

	wire			rst_n;

	assign rst_n = sys_rst_n & locked;

	localparam DUTY_STEP = 7'd100;
	localparam CNT_MAX   = 24'd1000000;

	wire	[3:0]	key;
	wire			key_pushed;

	assign key = {key4,key3,key2,key1};

	assign key_pushed = ~ (key1&key2&key3&key4);

	reg		[2:0]	X_des;
	reg		[1:0]	Y_des;
	reg				en_release;

	always @(posedge clk_1M or negedge sys_rst_n)
			begin
				if(!sys_rst_n)
					begin
						X_des <= 3'b0;
						Y_des <= 2'b0;
						en_release <= 1'b0;
					end
				else
					begin
						case(key)
						4'b1110:
							begin
								X_des <= 3'b000;
								Y_des <= 2'b10;
								en_release <= 1'b1;
							end
						4'b1101:
							begin
								X_des <= 3'b001;
								Y_des <= 2'b10;
								en_release <= 1'b1;
							end
						4'b1011:
							begin
								X_des <= 3'b010;
								Y_des <= 2'b10;
								en_release <= 1'b1;
							end
						4'b0111:
							begin
								X_des <= 3'b011;
								Y_des <= 2'b10;
								en_release <= 1'b1;
							end
						default:
							begin
								X_des <= 3'b011;
								Y_des <= 2'b11;
								en_release <= 1'b1;
							end
						endcase
					end
			end

	wire	[11:0]	release_0;
	wire	[11:0]	release_1;
	wire	[11:0]	release_2;
	wire	[11:0]	release_3;
	wire	[11:0]	release_4;
	wire			valid_release_data;

	laydown laydown_inst
	(
		.clk				(clk_1M),
		.rst_n				(sys_rst_n),

		.des_X				(X_des),
		.des_Y				(Y_des),
		.en_release			(en_release),

		.release_0			(release_0),
		.release_1			(release_1),
		.release_2			(release_2),
		.release_3			(release_3),
//		.release_4			(release_4),
		.valid_release_data	(valid_release_data)
	);
/////////////////////////////////////////////////////
	wire 	[11:0]	duty_0;
	wire			duty_done_0;
	wire	[11:0]	delay_0;

	linear_interpolation linear_interpolation_inst_0
	(
		.clk 				(clk_1M),
		.rst_n 				(sys_rst_n),

		.en_interpolation(valid_release_data),
		.duty_start			(12'd1500),
		.duty_target 		(release_0),
		.duty_step 			(DUTY_STEP),
		.CNT_MAX			(CNT_MAX),

		.duty 				(duty_0),
		.duty_done			(duty_done_0)
	);

	assign delay_0 = (key_pushed) ? duty_0 : 12'd1500;

	pwm_servo_1M pwm_servo_1M_inst_0
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(delay_0),
		.work		(valid_release_data),

		.pwm 		(pwm0)
	);
/////////////////////////////////////////////////////////
	wire 	[11:0]	duty_1;
	wire			duty_done_1;
	wire	[11:0]	delay_1;

	linear_interpolation linear_interpolation_inst_1
	(
		.clk 				(clk_1M),
		.rst_n 				(sys_rst_n),

		.en_interpolation(valid_release_data),
		.duty_start			(12'd1500),
		.duty_target 		(release_1),
		.duty_step 			(DUTY_STEP),
		.CNT_MAX			(CNT_MAX),

		.duty 				(duty_1),
		.duty_done			(duty_done_1)
	);

	assign delay_1 = (key_pushed) ? duty_1 : 12'd1500;

	pwm_servo_1M pwm_servo_1M_inst_1
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(delay_1),
		.work		(valid_release_data),

		.pwm 		(pwm1)
	);
//////////////////////////////////////////////////////////
	wire 	[11:0]	duty_2;
	wire			duty_done_2;
	wire	[11:0]	delay_2;

	linear_interpolation linear_interpolation_inst_2
	(
		.clk 				(clk_1M),
		.rst_n 				(sys_rst_n),

		.en_interpolation(valid_release_data),
		.duty_start			(12'd1500),
		.duty_target 		(release_2),
		.duty_step 			(DUTY_STEP),
		.CNT_MAX			(CNT_MAX),

		.duty 				(duty_2),
		.duty_done			(duty_done_2)
	);

	assign delay_2 = (key_pushed) ? duty_2 : 12'd1500;

	pwm_servo_1M pwm_servo_1M_inst_2
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(delay_2),
		.work		(valid_release_data),

		.pwm 		(pwm2)
	);
//////////////////////////////////////////////////////////
	wire 	[11:0]	duty_3;
	wire			duty_done_3;
	wire	[11:0]	delay_3;

	linear_interpolation linear_interpolation_inst_3
	(
		.clk 				(clk_1M),
		.rst_n 				(sys_rst_n),

		.en_interpolation(valid_release_data),
		.duty_start			(12'd1500),
		.duty_target 		(release_3),
		.duty_step 			(DUTY_STEP),
		.CNT_MAX			(CNT_MAX),

		.duty 				(clk_1M),
		.duty_done			(duty_done_3)
	);

	assign delay_3 = (key_pushed) ? duty_3 : 12'd1500;

	pwm_servo_1M pwm_servo_1M_inst_3
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(delay_3),
		.work		(valid_release_data),

		.pwm 		(pwm3)
	);
///////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_4
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(12'd1500),
		.work		(valid_release_data),

		.pwm 		(pwm4)
	);

endmodule
