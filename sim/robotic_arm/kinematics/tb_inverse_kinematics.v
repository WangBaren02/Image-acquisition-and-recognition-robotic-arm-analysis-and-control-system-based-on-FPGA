`timescale 1ns/1ns

module tb_inverse_kinematics();

reg		[7:0]	X;
reg		[7:0]	Y;
reg				valid_axis_data;

wire	[6:0]	rom_address_servo0;
wire	[7:0]	rom_address_servo123;
wire			valid_rom_address;

inverse_kinematics inverse_kinematics_inst
(
	.clk					(clk),
	.rst_n					(rst_n),

	.X						(X),
	.Y						(Y),
	.valid_axis_data		(valid_axis_data),

	.rom_address_servo0		(rom_address_servo0),
	.rom_address_servo123	(rom_address_servo123),
	.valid_rom_address		(valid_rom_address)
);

initial
	begin
		X <= 8'b0;
		Y <= 8'b0;
		valid_axis_data <= 1'b0;

		#1000
		X <= 8'd0;
		Y <= 8'd0;
		valid_axis_data <= 1'b1;
		#20
		valid_axis_data <= 1'b0;

		#1000
		X <= 8'd195;
		Y <= 8'd126;
		valid_axis_data <= 1'b1;
		#20
		valid_axis_data <= 1'b0;


		#1000
		X <= 8'd120;
		Y <= 8'd100;
		valid_axis_data <= 1'b1;
		#20
		valid_axis_data <= 1'b0;

	end

endmodule
