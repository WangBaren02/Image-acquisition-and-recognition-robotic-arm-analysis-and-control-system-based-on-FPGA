module test_laydown_1
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
	wire			locked;

	pll_ip	pll_ip_inst
	(
		.areset ( ~sys_rst_n ),
		.inclk0 ( sys_clk ),
		.c0 	( clk_1M ),
		.locked ( locked )
	);

	wire			rst_n;

	assign rst_n = sys_rst_n & locked;

	wire	[3:0]	key;

	assign key = {key4,key3,key2,key1};

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
		.release_4_change 	(12'd0),

		.release_0			(release_0),
		.release_1			(release_1),
		.release_2			(release_2),
		.release_3			(release_3),
		.release_4			(release_4),
		.valid_release_data	(valid_release_data)
	);
/////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_0
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(release_0),
		.work		(valid_release_data),

		.pwm 		(pwm_0)
	);
/////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_1
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(release_1),
		.work		(valid_release_data),

		.pwm 		(pwm_1)
	);
//////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_2
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(release_2),
		.work		(valid_release_data),

		.pwm 		(pwm_2)
	);
//////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_3
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(release_3),
		.work		(valid_release_data),

		.pwm 		(pwm_3)
	);
///////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_4
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(release_4),
		.work		(valid_release_data),

		.pwm 		(pwm_4)
	);

endmodule
