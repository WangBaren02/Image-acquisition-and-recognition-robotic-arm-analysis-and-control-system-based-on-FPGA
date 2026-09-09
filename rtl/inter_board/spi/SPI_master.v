module SPI_master
#(
	parameter 				DNUM 			= 32,
	parameter 				FRE_DIV 		= 2,
	parameter 				FRE_DIV_INDEX	= 1
)
(
	input					clk,
	input					rst_n,

	input					spi_start,	//脉冲
	input		[DNUM-1:0]	spi_din,
	output	reg	[DNUM-1:0]	spi_dout,
	output	reg				spi_over,

	input					spi_miso,
	output	reg				spi_sck,
	output	reg				spi_mosi,
	output	reg				spi_cs
);

	reg						spi_conv;
	reg			[31:0]		spi_state_cnt;
	reg						spi_por;
	reg						shift_en;
	reg						shift_en_d;
	wire					send_en_flag;
	reg			[DNUM-1:0]	spi_data_to_be_sent;
	reg			[DNUM-1:0]	spi_data_to_be_recieved;

	assign send_en_flag = (shift_en_d & !shift_en & spi_conv);

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_conv <= 1'b0;
			else if(spi_start) spi_conv <= 1'b1;
			else if(spi_state_cnt == DNUM * FRE_DIV) spi_conv <= 1'b0;
			else spi_conv <= spi_conv;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_state_cnt <= 'h0;
			else if(spi_conv) spi_state_cnt <= spi_state_cnt + 1'b1;
			else spi_state_cnt <= 'h0;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_over <= 1'b0;
			else if(spi_state_cnt == DNUM * FRE_DIV) spi_over <= 1'b1;
			else spi_over <= 1'b0;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_cs <= 1'b1;
			else if(spi_over) spi_cs <= 1'b1;
			else if(spi_start) spi_cs <= 1'b0;
			else spi_cs <= spi_cs;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_por <= 1'b1;
			else spi_por <= spi_start||spi_state_cnt[FRE_DIV_INDEX-1];
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_sck <= 1'b0;
			else if(!spi_cs) spi_sck <= spi_por;
			else spi_sck <= 1'b0;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) shift_en <= 1'b0;
			else if(!spi_cs) shift_en <= spi_state_cnt[FRE_DIV_INDEX-1];
			else shift_en <= 1'b0;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) shift_en_d <= 1'b0;
			else shift_en_d <= shift_en;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_data_to_be_sent <= 'h0;
			else if(spi_start) spi_data_to_be_sent <= spi_din;
			else if(send_en_flag) spi_data_to_be_sent <= {spi_data_to_be_sent[DNUM-2:0],1'b0};
			else spi_data_to_be_sent <= spi_data_to_be_sent;
		end

	always@(negedge spi_sck or negedge rst_n)
		begin
			if(!rst_n) spi_mosi <= 1'b0;
			else if(spi_conv) spi_mosi <= spi_data_to_be_sent[DNUM-1];
			else spi_mosi <= 1'b0;
		end

	always@(posedge spi_sck or negedge rst_n)
			begin
			if(!rst_n) spi_data_to_be_recieved <= 'h0;
			else if(spi_conv) spi_data_to_be_recieved <= {spi_data_to_be_recieved[DNUM-2:0],spi_miso};
			else spi_data_to_be_recieved <= spi_data_to_be_recieved;
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) spi_dout <= 'h0;
			else if(spi_state_cnt == DNUM * FRE_DIV) spi_dout <= spi_data_to_be_recieved;
			else spi_dout <= spi_dout;
		end

endmodule
