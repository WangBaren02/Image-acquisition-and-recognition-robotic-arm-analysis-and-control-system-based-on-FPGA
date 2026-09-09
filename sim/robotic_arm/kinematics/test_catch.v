module test_catch
(
	input	sys_clk,
	input	sys_rst_n,

	// input	key1,
	// input	key2,
	// input	key3,
	// input	key4,

	input	[7:0]	sw,

	input			confirm,

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

	// wire	[3:0]	key;

	// assign key = {key4,key3,key2,key1};

	// reg		[8:0]	X;	//物块在仓库中的X坐标(mm):0~265
	// reg		[7:0]	Y;	//物块在仓库中的Y坐标(mm):0~175
	// reg				valid_axis_data;

	// always @(posedge clk_1M or negedge sys_rst_n)
	// 		begin
	// 			if(!sys_rst_n)
	// 				begin
	// 					X <= 8'b0;
	// 					Y <= 8'b0;
	// 					valid_axis_data <= 1'b0;
	// 				end
	// 			else
	// 				begin
	// 					case(key)
	// 					4'b1110:
	// 						begin
	// 							X <= 20;
	// 							Y <= 20;
	// 							valid_axis_data <= 1'b1;
	// 						end
	// 					4'b1101:
	// 						begin
	// 							X <= 40;
	// 							Y <= 40;
	// 							valid_axis_data <= 1'b1;
	// 						end
	// 					4'b1011:
	// 						begin
	// 							X <= 150;
	// 							Y <= 20;
	// 							valid_axis_data <= 1'b1;
	// 						end
	// 					4'b0111:
	// 						begin
	// 							X <= 50;
	// 							Y <= 20;
	// 							valid_axis_data <= 1'b1;
	// 						end
	// 					default:
	// 						begin
	// 							X <= 8'b0;
	// 							Y <= 8'b0;
	// 							valid_axis_data <= 1'b0;
	// 						end
	// 					endcase
	// 				end
	// 		end
/////////////////////////////////////////
	reg				confirm_reg;

	always@( posedge clk_1M or negedge sys_rst_n )
		begin
			if(!sys_rst_n) confirm_reg <= 1'b0;
			else confirm_reg <= confirm;
		end

	wire	work_flag;

	assign work_flag = confirm_reg & (~confirm);

	reg 	work_flag_reg;

	always@( posedge clk_1M or negedge sys_rst_n )
		begin
			if(!sys_rst_n) work_flag_reg <= 1'b0;
			else work_flag_reg <= work_flag;
		end
///////////////////////////////////////////////////
	wire	[8:0]	X_cal;
//	wire	[7:0]	Y_cal;

	assign X_cal = sw;
//	assign Y_cal = sw;
///////////////////////////////////////////////////////
	reg		[8:0]	X;	//物块在仓库中的X坐标(mm):0~265
	reg		[7:0]	Y;	//物块在仓库中的Y坐标(mm):0~175

	always@( posedge clk_1M or negedge sys_rst_n )
		begin
			if(!sys_rst_n)
				begin
					X <= 9'b0;
					Y <= 9'b0;
				end
			else if((work_flag)&&(X_cal<=265))
				begin
					X <= X_cal;	//物块在仓库中的X坐标(mm):0~265
					Y <= 9'd50;
				end
			else
				begin
					X <= X;
					Y <= Y;
				end
		end
//////////////////////////////////
	wire	[11:0]	catch_0;
	wire	[11:0]	catch_1;
	wire	[11:0]	catch_2;
	wire	[11:0]	catch_3;
//	wire	[11:0]	catch_4;
	wire			valid_catch_rom_data;

	catch catch_inst
	(
		.clk 					(clk_1M),
		.rst_n 					(rst_n),

		.X						(X),
		.Y						(Y),
		.valid_axis_data		(confirm),

		.catch_0				(catch_0),
		.catch_1				(catch_1),
		.catch_2				(catch_2),
		.catch_3				(catch_3),
//		.catch_4				(catch_4),
		.valid_catch_rom_data	(valid_catch_rom_data)
	);
/////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_0
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(catch_0),
		.work		(1'b1),

		.pwm 		(pwm_0)
	);
/////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_1
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(catch_1),
		.work		(1'b1),

		.pwm 		(pwm_1)
	);
//////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_2
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(catch_2),
		.work		(1'b1),

		.pwm 		(pwm_2)
	);
//////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_3
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(catch_3),
		.work		(1'b1),

		.pwm 		(pwm_3)
	);
///////////////////////////////////////////////////////////
	pwm_servo_1M pwm_servo_1M_inst_4
	(
		.sys_clk	(clk_1M),
		.sys_rst_n	(sys_rst_n),

		.delay_us	(12'd1500),
		.work		(1'b1),

		.pwm 		(pwm_4)
	);

endmodule
