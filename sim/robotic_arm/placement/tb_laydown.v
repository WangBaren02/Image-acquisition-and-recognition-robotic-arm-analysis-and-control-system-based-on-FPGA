`timescale 1ns/1ns

module tb_laydown();

reg				clk;
reg 			rst_n;
reg		[1:0]	color;
reg		[1:0]	shape;
reg				en_release;

wire	[11:0]	release_0;
wire	[11:0]	release_1;
wire	[11:0]	release_2;
wire	[11:0]	release_3;
wire	[11:0]	release_4;
wire			valid_release_data;

laydown laydown_inst
(
	.clk				(clk),
	.rst_n				(rst_n),

	.color				(color),
	.shape				(shape),
	.en_release			(en_release),

	.release_0			(release_0),
	.release_1			(release_1),
	.release_2			(release_2),
	.release_3			(release_3),
	.release_4			(release_4),
	.valid_release_data	(valid_release_data)
);

initial
	begin
		clk = 1'b0;
		rst_n <= 1'b0;
		color <= 2'b00;
		shape <= 2'b00;
		en_release <= 1'b0;
		#100
		rst_n <= 1'b1;
		#1000
		color <= 2'b00;
		shape <= 2'b00;
		en_release <= 1'b1;
		#1000
		color <= 2'b01;
		shape <= 2'b00;
		en_release <= 1'b1;
		#1000
		color <= 2'b10;
		shape <= 2'b00;
		en_release <= 1'b1;
		#1000
		color <= 2'b11;
		shape <= 2'b00;
		en_release <= 1'b1;
		#1000
		color <= 2'b00;
		shape <= 2'b01;
		en_release <= 1'b1;
		#1000
		color <= 2'b01;
		shape <= 2'b01;
		en_release <= 1'b1;
		#1000
		color <= 2'b10;
		shape <= 2'b01;
		en_release <= 1'b1;
		#1000
		color <= 2'b11;
		shape <= 2'b01;
		en_release <= 1'b1;
		#1000
		color <= 2'b00;
		shape <= 2'b10;
		en_release <= 1'b1;
		#1000
		color <= 2'b01;
		shape <= 2'b10;
		en_release <= 1'b1;
		#1000
		color <= 2'b10;
		shape <= 2'b10;
		en_release <= 1'b1;
		#1000
		color <= 2'b11;
		shape <= 2'b10;
		en_release <= 1'b1;
	end

always #10 clk = ~ clk;

endmodule
