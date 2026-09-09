`timescale 1ns/1ns

module tb_test_SPI();

	reg 	sys_clk;
	reg		sys_rst_n;

	 test_SPI test_SPI_inst
	(
		.sys_clk 	(sys_clk),
		.sys_rst_n 	(sys_rst_n)
	);

	initial
		begin
			sys_clk = 1'b1;
			sys_rst_n = 1'b0;

			#100
			sys_rst_n = 1'b1;
		end

	always #1 sys_clk =~sys_clk;

endmodule
