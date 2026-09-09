//找颜色模?
module	color_bin
(
	input	wire			clk				,
	input	wire			rst_n			,
	input	wire			per_frame_vsync	,
    input	wire			per_frame_href 	,
    input	wire			per_frame_clken	,
    input	wire	[7:0]	per_img_Y  		,
    input	wire	[7:0]	per_img_Cb		,
    input	wire	[7:0]	per_img_Cr		,
	//input	wire			color_change	,
	input	wire			key_color		,//?个时钟周期高电平
	input	wire			key_mode		,
	input	wire			key_ycbcr		,
	input	wire			key_add_div		,

	output	reg		[19:0]	seg_data		,
    output	reg 			post_frame_vsync,
    output	reg 			post_frame_href ,
    output	reg 			post_frame_clken,
    output	reg 			post_img_Bit  	,
	output	reg		[2:0]	ycbcr_led		,	//绑定不同的led
	output	wire			mode_led
);

reg		[2:0]	color_cnt	;//颜色计数器切换目前颜? 0 - ? 1 - ? 2 - ? 3 - ?
//reg		[7:0]	y_left		;
//reg		[7:0]	y_right		;
//reg		[7:0]	cb_left		;
//reg		[7:0]	cb_right	;
//reg		[7:0]	cr_left		;
//reg		[7:0]	cr_right	;
reg		signed	[8:0]	y_num		;//key_color 为高电平时清?
reg		signed	[8:0]	cb_num		;
reg		signed	[8:0]	cr_num		;

//默认控制左边的加
reg				mode_flag	;//切换加减标志	 1 - ? 0 - ? 绑定led
//reg				lf_flag		;//1 - ? 0 - ?
reg		[1:0]	ycbcr_cnt		;
//reg		[2:0]	ycbcr_led		;
//模式flag
assign	mode_led = mode_flag;

//同步时序
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		begin
		post_frame_vsync	<= 1'b0;
		post_frame_href		<= 1'b0;
		post_frame_clken 	<= 1'b0;
		end
	else
		begin
		post_frame_vsync	<=	per_frame_vsync	;
		post_frame_href		<=	per_frame_href	;
		post_frame_clken 	<=	per_frame_clken	;
		end




always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		mode_flag <= 1'b1;
	else	if(key_mode == 1'b1)
		mode_flag <= ~mode_flag;
	else
		mode_flag <= mode_flag;

//切换ycbcr计数? 0 - y 1 - cb 2- cr
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		ycbcr_cnt <= 2'd0;
	else	if(ycbcr_cnt == 2'd3)//防止溢出
		ycbcr_cnt <= 2'd0;
	else	if(key_color == 1'b1)//从y??
		ycbcr_cnt <= 2'd0;//每次切换颜色都从y??
	else	if(key_ycbcr == 1'b1)
		ycbcr_cnt <= ycbcr_cnt + 1'd1;
	else
		ycbcr_cnt <= ycbcr_cnt;

//ycbcr_led
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		ycbcr_led <= 3'b0;
	else	case(ycbcr_cnt)
			2'd0 :ycbcr_led <= 3'b001;
			2'd1 :ycbcr_led <= 3'b010;
			2'd2 :ycbcr_led <= 3'b100;
			default : ycbcr_led <= 3'b0;
	endcase

//y_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		y_num	<= 9'd0;
	else	if(key_color == 1'b1)
		y_num	<= 9'd0;
	else	if(ycbcr_cnt == 2'd0 && key_add_div == 1'b1)
		if(mode_flag == 1'b1)
			y_num <= y_num + 1'd1;
		else
			y_num <= y_num - 1'd1;
	else
		y_num <= y_num;
//cb_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		cb_num <= 9'd0;
	else	if(key_color == 1'b1)
		cb_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd1 && key_add_div == 1'b1)
		if(mode_flag == 1'b1)
			cb_num <= cb_num + 1'd1;
		else
			cb_num <= cb_num - 1'd1;
	else
		cb_num <= cb_num;

//cr_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		cr_num <= 9'd0;
	else	if(key_color == 1'b1)
		cr_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd2 && key_add_div == 1'b1)
		if(mode_flag == 1'b1)
			cr_num <= cr_num + 1'd1;
		else
			cr_num <= cr_num - 1'd1;
	else
		cr_num <= cr_num;

//color_cnt 默认蓝色
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		color_cnt <= 9'd0;
	else	if(color_cnt == 3'd4)
		color_cnt <= 9'd0;
	else	if(key_color == 1'b1)
		color_cnt <= color_cnt + 3'd1;
	else
		color_cnt <= color_cnt;

//输出数码管的?
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		seg_data	<= 20'd0;
	else	case(ycbcr_cnt)
		2'd0	:	seg_data	<= {12'd0,8'd40 + y_num};
		2'd1	:	seg_data	<= {12'd0,8'd151 + cb_num};
		2'd2	:	seg_data	<= {12'd0,8'd148 + cr_num};
		default	:	seg_data	<=20'd0;
		endcase

//输出颜色
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		post_img_Bit <= 1'b0;
	else	if(per_frame_clken)// 0 - ? 1 - ? 2 - ? 3 - ?
			case(color_cnt)
			3'd0	:	if((per_img_Y < 8'd169 + y_num && per_img_Y > 8'd20)
							&& per_img_Cb > 8'd137+ cb_num)
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;


			3'd1	:	if((per_img_Y < 8'd238 + y_num) && (per_img_Cb < 8'd151 + cb_num)//红色
							&& (per_img_Cr < 8'd222 + cr_num  && per_img_Cr > 8'd155))
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;


			3'd2	:	if((per_img_Y < 8'd194+ y_num) && (per_img_Cb < 8'd84 + cb_num )//黄色206
							&& (per_img_Cr < 8'd140 + cr_num && per_img_Cr > 8'd8))
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;


			3'd3	:	if((per_img_Y < 8'd85 + y_num) && (per_img_Cb < 8'd151 + cb_num) //黑色
							&& (per_img_Cr < 8'd148 + cr_num))//(per_img_Y < 8'd74 + y_num) && (per_img_Cb < 8'd138 + cb_num) //黑色
							//&& (per_img_Cr < 8'd134 + cr_num)
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;
			default :	post_img_Bit <= 1'b0;
			endcase
endmodule