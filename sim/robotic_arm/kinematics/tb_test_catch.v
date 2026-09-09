`timescale 1ns/1ns

module tb_test_catch();

reg	sys_clk;
reg	sys_rst_n;

reg		key1;
reg		key2;
reg		key3;
reg		key4;

wire	pwm0;
wire	pwm1;
wire	pwm2;
wire	pwm3;
wire	pwm4;

test_catch test_catch_inst
(
	.sys_clk	(sys_clk),
	.sys_rst_n	(sys_rst_n),

	.key1		(key1),
	.key2		(key2),
	.key3		(key3),
	.key4		(key4),

	.pwm0		(pwm0),
	.pwm1		(pwm1),
	.pwm2		(pwm2),
	.pwm3		(pwm3),
	.pwm4		(pwm4)
);

initial
	begin
		sys_clk = 1'b0;
		sys_rst_n <= 1'b0;

		key1 <= 1'b1;
		key2 <= 1'b1;
		key3 <= 1'b1;
		key4 <= 1'b1;
		#100
		sys_rst_n <= 1'b1;
		#1000
		key1 <= 1'b0;
		#1000000
		key1 <= 1'b1;
		#1000
		key2 <= 1'b0;
		#1000000
		key2 <= 1'b1;
		#1000
		key3 <= 1'b0;
		#1000000
		key3 <= 1'b1;
		#1000
		key4 <= 1'b0;
		#1000000
		key4 <= 1'b1;
	end

always #10 sys_clk = ~ sys_clk;

endmodule
