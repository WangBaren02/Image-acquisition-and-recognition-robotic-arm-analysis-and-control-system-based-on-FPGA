`timescale 1ns/1ns

module tb_send_location();

reg				clk;
reg				rst_n;

reg		[19:0]	image_process_data;
reg				image_process_done;
reg				loop_done;

wire			en_rd;
wire 	[3:0]	address_rd;
wire			clk_rd;

wire	[1:0]	color;
wire	[1:0]	shape;
wire	[9:0]	X;
wire	[9:0]	Y;
wire			image_process_data_valid;

send_location send_location_inst
(
	.clk 						(clk),		//模块时钟：1MHz
	.rst_n 						(rst_n),	//模块复位

	.image_process_data			(image_process_data),
	.image_process_done			(image_process_done),
	.loop_done					(loop_done),

	.en_rd						(en_rd),
	.address_rd					(address_rd),
	.clk_rd						(clk_rd),

	.color						(color),
	.shape						(shape),
	.X							(X),
	.Y							(Y),
	.image_process_data_valid	(image_process_data_valid)
);

initial
	begin
		clk = 1'b0;
		rst_n <= 1'b0;

		image_process_data <= 19'b0;
		image_process_done <= 1'b0;
		loop_done <= 1'b0;

		#110
		rst_n <= 1'b1;

		#1000
		image_process_done <= 1'b1;
		#20
		image_process_done <= 1'b0;
		#20
		image_process_data <= 24'd16000012;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd14010404;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd12052143;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd15234789;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd14879865;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd15673567;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd13789456;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd12345645;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd15334956;
		#20
		image_process_data <= 24'b0;


		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd16334234;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd14923784;
		#20
		image_process_data <= 24'b0;

		#1000
		loop_done <= 1'b1;
		#20
		loop_done <= 1'b0;
		#20
		image_process_data <= 24'd15782567;
		#20
		image_process_data <= 24'b0;
	end

always #10 clk = ~ clk;

endmodule
