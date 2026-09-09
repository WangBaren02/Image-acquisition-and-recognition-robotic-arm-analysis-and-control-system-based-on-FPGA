`timescale 1ns/1ns

module tb_linear_interpolation();

reg  			clk;
reg  			rst_n;
reg  			valid_interpolation;
reg  	[11:0]	duty_start;
reg 	[11:0]	duty_target;
reg 	[6:0]  	duty_step;

wire	[11:0]	duty;
wire			duty_done;

linear_interpolation linear_interpolation_inst
(
	.clk 				(clk),
	.rst_n 				(rst_n),

	.valid_interpolation(valid_interpolation),
	.duty_start 		(duty_start),
	.duty_target 		(duty_target),
	.duty_step 			(duty_step),

	.duty 				(duty),
	.duty_done 			(duty_done)
);

initial
	begin
		clk = 1'b0;
		rst_n <= 1'b0;
		valid_interpolation <= 1'b0;
		duty_start <= 12'd1500;
		duty_target <= 12'b0;
		duty_step <= 7'd100;
		#100
		rst_n <= 1'b1;
		#1000
		valid_interpolation <= 1'b1;
		duty_target <= 12'd2500;
		#20000000
		duty_target <= 12'd1500;
		#20000000
		duty_target <= 12'd500;
		#20000000
		duty_target <= 12'd1500;
	end

always #1 clk = ~ clk;

endmodule
