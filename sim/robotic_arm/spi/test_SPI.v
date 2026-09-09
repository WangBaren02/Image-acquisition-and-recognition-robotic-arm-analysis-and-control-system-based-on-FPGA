module test_SPI
(
	input	sys_clk,
	input	sys_rst_n
);
/////////////////////////////////
	wire            clk_120M;
	wire            clk_20M;

    pll_100M_ip  pll_100M__ip_inst
    (
        .areset (~sys_rst_n),
        .inclk0 (sys_clk),
        .c0     (clk_120M),
        .c1     (clk_20M),
        .locked (locked)
    );

    wire    rst_n;

    assign rst_n = locked & sys_rst_n;
////////////////////////////////////////
	reg				master_start;
	reg		[31:0]	master_din;
	wire	[31:0]	master_dout;
	wire			master_over;

	wire			spi_miso;
	wire			spi_mosi;
	wire			spi_sck;
	wire			spi_cs;

	SPI_master
	#(
		.DNUM 			(32),
		.FRE_DIV 		(2),
		.FRE_DIV_INDEX	(1)
	)
	SPI_master_inst
	(
		.clk 		(clk_20M),
		.rst_n 		(rst_n),

		.spi_start 	(master_start),	//脉冲
		.spi_din 	(master_din),
		.spi_dout	(master_dout),
		.spi_over	(master_over),

		.spi_miso 	(spi_miso),
		.spi_sck 	(spi_sck),
		.spi_mosi 	(spi_mosi),
		.spi_cs 	(spi_cs)
	);
//////////////////////////////////////
	wire			slave_start;
	reg		[31:0]	slave_din;
	wire	[31:0]	slave_dout;
	wire			slave_over;

	SPI_slave
	#(
	    .width      (32)
	)
	SPI_slave_inst
	(
	    .clk        (clk_120M),
	    .rst_n      (rst_n),

	    .spi_scl    (spi_sck),
	    .spi_sdi    (spi_mosi),
	    .spi_sdo    (spi_miso),
	    .spi_sel    (spi_cs),

	    .Din        (slave_din),
	    .Dout       (slave_dout),
	    .Data_begin (slave_start),
	    .Data_end   (slave_over)
	);
///////////////////////////////////////
	reg		[9:0]	cnt;

	always@(posedge clk_20M or negedge rst_n)
		begin
			if(!rst_n) cnt <= 'b0;
			else if(cnt==10'd100) cnt <= 'b0;
			else cnt <= cnt + 1'b1;
		end

	always@(posedge clk_20M or negedge rst_n)
		begin
			if(!rst_n)
				begin
					master_start <= 1'b0;
					master_din   <= 32'b0;
					slave_din 	 <= 32'b0;
				end
			else if(cnt==10'd100)
				begin
					master_start <= 1'b1;
					master_din   <= 32'hABCDEF89;
					slave_din 	 <= 32'h12344567;
				end
			else
				begin
					master_start <= 1'b0;
					master_din   <= master_din;
					slave_din 	 <= slave_din;
				end
		end

endmodule
