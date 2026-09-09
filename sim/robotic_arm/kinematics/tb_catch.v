`timescale 1ns/1ns

module tb_catch();

reg				clk;
reg				rst_n;
reg		[7:0]	X;
reg		[7:0]	Y;
reg				valid_axis_data;

wire	[11:0]	catch_0;
wire	[11:0]	catch_1;
wire	[11:0]	catch_2;
wire	[11:0]	catch_3;
wire	[11:0]	catch_4;
wire			valid_catch_rom_data;

catch catch_inst
(
	.clk					(clk),
	.rst_n					(rst_n),

	.X						(X),
	.Y						(Y),
	.valid_axis_data		(valid_axis_data),

	.catch_0				(catch_0),
	.catch_1				(catch_1),
	.catch_2				(catch_2),
	.catch_3				(catch_3),
	.catch_4				(catch_4),
	.valid_catch_rom_data	(valid_catch_rom_data)
);

initial
	begin
		clk = 1'b0;
		rst_n <= 1'b0;
		X <= 8'b0;
		Y <= 8'b0;
		valid_axis_data <= 1'b0;
		#100
		rst_n <= 1'b1;
		#990
		X <= 8'd97;
		Y <= 8'd30;
		valid_axis_data <= 1'b1;
		#10000
		valid_axis_data <= 1'b0;

		#1000
		X <= 8'd50;
		Y <= 8'd20;
		valid_axis_data <= 1'b1;
		#10000
		valid_axis_data <= 1'b0;
	end

always #10 clk = ~ clk;

endmodule
