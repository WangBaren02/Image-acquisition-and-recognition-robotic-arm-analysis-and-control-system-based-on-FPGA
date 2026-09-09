//module color_bin(
//    input               clk            	,   // 时钟信号
//    input               rst_n          	,   // 复位信号（低有效?
//
//	input				per_frame_vsync	,
//	input				per_frame_href 	,
//	input				per_frame_clken	,
//	input		[7:0]	per_img_Y  		,
//	input		[7:0]	per_img_Cb		,
//	input		[7:0]	per_img_Cr		,
//	input				key_color		,
//	input	wire		color_mode		,
//
//	output	reg 		post_frame_vsync,
//	output	reg 		post_frame_href ,
//	output	reg 		post_frame_clken,
//	output	reg 		post_img_Bit  	,
//	output	wire	[1:0]	color
//
//);
//
//reg		[1:0]		color_cnt;
//reg					key_color_r;
//wire				color_pos;
//
//
//
//
//
//
////打拍取沿
//always@(posedge clk or negedge rst_n)
//	if(rst_n == 1'b0)
//		key_color_r <= 1'b0;
//	else
//		key_color_r <= key_color;
//
//assign	color_pos = key_color & (~key_color_r);
//
//
//always@(posedge clk or negedge rst_n)
//	if(rst_n == 1'b0)
//		color_cnt <= 2'd0;
//	else	if(color_pos && color_mode)
//		color_cnt	<= color_cnt + 1'd1;
//	else
//		color_cnt	<= color_cnt;
//
//
//
//
//
//
////always@(posedge	clk or negedge rst_n)
////	if(rst_n == 1'b0)
////		color_cnt <= 4'd0;
////	else	if(color_pos == 1'b1)
////		color_cnt <= color_cnt + 4'd1;
////	else
////		color_cnt <= color_cnt;
//
//
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n)
//        post_img_Bit <= 1'b0;
//	else
//		case (color_cnt)
//			2'd2	:	if((per_img_Y < 8'd206 && per_img_Y > 8'd20)//蓝色
//							&& per_img_Cb > 8'd145)
//							post_img_Bit <= 1'b1;
//					else
//						post_img_Bit <= 1'b0;
//
//
//			2'd0	:if((per_img_Y < 8'd238) && (per_img_Cb < 8'd151 )//红色
//							&& (per_img_Cr < 8'd222  && per_img_Cr > 8'd140))
//								post_img_Bit <= 1'b1;
//						else
//							post_img_Bit <= 1'b0;
//
//
//
//			2'd1	:if((per_img_Y < 8'd194) && (per_img_Cb < 8'd84 )//黄色
//							&& (per_img_Cr < 8'd140 && per_img_Cr > 8'd8))
//								post_img_Bit <= 1'b1;
//						else
//							post_img_Bit <= 1'b0;
//
//
//
//			2'd3	:if((per_img_Y < 8'd85) && (per_img_Cb < 8'd136) //黑色
//							&& (per_img_Cr < 8'd133))
//								post_img_Bit <= 1'b1;
//						else
//							post_img_Bit <= 1'b0;
//
//
//
//			default	:	post_img_Bit <= 1'b0;
//			endcase
//end
//
//assign	color = color_cnt;
//
//
//
//
//always@(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        post_frame_vsync <= 1'd0;
//        post_frame_href  <= 1'd0;
//        post_frame_clken <= 1'd0;
//    end
//    else begin
//        post_frame_vsync <= per_frame_vsync;
//        post_frame_href  <= per_frame_href ;
//        post_frame_clken <= per_frame_clken;
//    end
//end
//
//endmodule
//閹甸箖顤?懝鍙壞侀??
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
	input	wire			key_color		,//娑�?娑擃亝妞傞柦鐔锋噯閺堢喖鐝悽闈涢挬
	input	wire			key_mode		,
	input	wire			key_ycbcr		,
	input	wire			key_add_div		,
	input	wire			change_in		,
	input	wire			color_mode		,

	output	wire	[1:0]	color			,
	output	reg		[19:0]	seg_data		,
    output	reg 			post_frame_vsync,
    output	reg 			post_frame_href ,
    output	reg 			post_frame_clken,
    output	reg 			post_img_Bit  	,
	output	reg		[2:0]	ycbcr_led		,	//缂佹垵鐣炬稉宥呮倱閻ㄥ埐ed
	output	wire			mode_led
);

reg		[1:0]	color_cnt	;//妫版粏澹婄拋鈩冩殶閸ｃ劌鍨忛幑銏㈡窗閸撳秹顤??? 0 - 閽�? 1 - 缁�? 2 - 姒�? 3 - 姒�?
//reg		[7:0]	y_left		;
//reg		[7:0]	y_right		;
//reg		[7:0]	cb_left		;
//reg		[7:0]	cb_right	;
//reg		[7:0]	cr_left		;
//reg		[7:0]	cr_right	;
reg		signed	[8:0]	blue_y_num		;//key_color 娑撴椽鐝?悽闈涢挬閺冭埖绔婚梿?
reg		signed	[8:0]	blue_cb_num		;
reg		signed	[8:0]	blue_cr_num		;

reg		signed	[8:0]	red_y_num		;
reg		signed	[8:0]	red_cb_num		;
reg		signed	[8:0]	red_cr_num		;

reg		signed	[8:0]	yellow_y_num	;
reg		signed	[8:0]	yellow_cb_num	;
reg		signed	[8:0]	yellow_cr_num	;

reg		signed	[8:0]	black_y_num	;
reg		signed	[8:0]	black_cb_num	;
reg		signed	[8:0]	black_cr_num	;



//姒涙顓婚幒褍鍩?锕佺珶閻ㄥ嫬濮?
reg				mode_flag	;//閸掑洦宕查崝鐘插櫤閺嶅洤绻�	 1 - 閸�? 0 - 閸�? 缂佹垵鐣緇ed
//reg				lf_flag		;//1 - 瀹�? 0 - 閸�?
reg		[1:0]	ycbcr_cnt		;
//reg		[2:0]	ycbcr_led		;
//濡�崇?flag
assign	mode_led = mode_flag;
reg				change_in_r;
wire			color_pos	;
//打拍
always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		change_in_r	<= 1'b0;
	else
		change_in_r	<= change_in;

//去上升沿

assign	color_pos = change_in & (~change_in_r);

//color_cnt 姒涙顓婚拑婵婂?
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		color_cnt <= 9'd0;
	//else	if(color_cnt == 2'd3)
	//	color_cnt <= 9'd0;
	else	if(key_color == 1'b1)
		color_cnt <= color_cnt + 2'd1;
	else	if(color_pos && color_mode)
		color_cnt	<= color_cnt + 2'd1;
	else
		color_cnt <= color_cnt;



//閸氬本顒為弮璺虹?
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

//閸掑洦宕瞴cbcr鐠佲剝鏆熼崳? 0 - y 1 - cb 2- cr
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		ycbcr_cnt <= 2'd0;
	else	if(ycbcr_cnt == 2'd3)//闂冨弶顒涘┃銏犲?
		ycbcr_cnt <= 2'd0;
	else	if(key_color == 1'b1)//娴犲窢?�?婵�?
		ycbcr_cnt <= 2'd0;//濮ｅ繑顐奸崚鍥ㄥ床妫版粏澹婇柈鎴掔矤y瀵�?婵�?
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
//钃濊壊璋冨姩
//blue_y_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		blue_y_num	<= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_y_num	<= 9'd0;
	else	if(ycbcr_cnt == 2'd0 && key_add_div == 1'b1 && color_cnt == 2'd2 )
		if(mode_flag == 1'b1)
			blue_y_num <= blue_y_num + 1'd1;
		else
			blue_y_num <= blue_y_num - 1'd1;
	else
		blue_y_num <= blue_y_num;
//blue_cb_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		blue_cb_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cb_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd1 && key_add_div == 1'b1 && color_cnt == 2'd2)
		if(mode_flag == 1'b1)
			blue_cb_num <= blue_cb_num + 1'd1;
		else
			blue_cb_num <= blue_cb_num - 1'd1;
	else
		blue_cb_num <= blue_cb_num;

//blue_cr_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		blue_cr_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cr_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd2 && key_add_div == 1'b1 && color_cnt == 2'd2)
		if(mode_flag == 1'b1)
			blue_cr_num <= blue_cr_num + 1'd1;
		else
			blue_cr_num <= blue_cr_num - 1'd1;
	else
		blue_cr_num <= blue_cr_num;

//绾㈣壊璋冨姩
//red_y_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		red_y_num	<= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_y_num	<= 9'd0;
	else	if(ycbcr_cnt == 2'd0 && key_add_div == 1'b1 && color_cnt == 2'd0 )
		if(mode_flag == 1'b1)
			red_y_num <= red_y_num + 1'd1;
		else
			red_y_num <= red_y_num - 1'd1;
	else
		red_y_num <= red_y_num;
//red_cb_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		red_cb_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cb_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd1 && key_add_div == 1'b1 && color_cnt == 2'd0)
		if(mode_flag == 1'b1)
			red_cb_num <= red_cb_num + 1'd1;
		else
			red_cb_num <= red_cb_num - 1'd1;
	else
		red_cb_num <=red_cb_num;
//red_cr_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		red_cr_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cr_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd2 && key_add_div == 1'b1 && color_cnt == 2'd0)
		if(mode_flag == 1'b1)
			red_cr_num <= red_cr_num + 1'd1;
		else
			red_cr_num <= red_cr_num - 1'd1;
	else
		red_cr_num <= red_cr_num;
//榛勮壊璋冨姩
//yellow_y_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		yellow_y_num	<= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_y_num	<= 9'd0;
	else	if(ycbcr_cnt == 2'd0 && key_add_div == 1'b1 && color_cnt == 2'd1 )
		if(mode_flag == 1'b1)
			yellow_y_num <= yellow_y_num + 1'd1;
		else
			yellow_y_num <= yellow_y_num - 1'd1;
	else
		yellow_y_num <= yellow_y_num;
//yellow_cb_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		yellow_cb_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cb_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd1 && key_add_div == 1'b1 && color_cnt == 2'd1)
		if(mode_flag == 1'b1)
			yellow_cb_num <= yellow_cb_num + 1'd1;
		else
			yellow_cb_num <=yellow_cb_num - 1'd1;
	else
		yellow_cb_num <= yellow_cb_num;
//yellow_cr_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		yellow_cr_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cr_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd2 && key_add_div == 1'b1 && color_cnt == 2'd1)
		if(mode_flag == 1'b1)
			yellow_cr_num <= yellow_cr_num + 1'd1;
		else
			yellow_cr_num <= yellow_cr_num - 1'd1;
	else
		yellow_cr_num <= yellow_cr_num;
//榛戣壊璋冨姩
//black_y_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		black_y_num	<= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_y_num	<= 9'd0;
	else	if(ycbcr_cnt == 2'd0 && key_add_div == 1'b1 && color_cnt == 2'd3 )
		if(mode_flag == 1'b1)
			black_y_num <= black_y_num + 1'd1;
		else
			black_y_num <= black_y_num - 1'd1;
	else
		black_y_num <= black_y_num;
//black_cb_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		black_cb_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cb_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd1 && key_add_div == 1'b1 && color_cnt == 2'd3)
		if(mode_flag == 1'b1)
			black_cb_num <= black_cb_num + 1'd1;
		else
			black_cb_num <= black_cb_num - 1'd1;
	else
		black_cb_num <= black_cb_num;
//black_cr_num
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		black_cr_num <= 9'd0;
	//else	if(key_color == 1'b1)
	//	blue_cr_num <= 9'd0;
	else	if(ycbcr_cnt == 2'd2 && key_add_div == 1'b1 && color_cnt == 2'd3)
		if(mode_flag == 1'b1)
			black_cr_num <= black_cr_num + 1'd1;
		else
			black_cr_num <= black_cr_num - 1'd1;
	else
		black_cr_num <= black_cr_num;




assign	color = color_cnt;



//鏉堟挸鍤弫鎵垳缁狅紕娈戦??
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		seg_data	<= 20'd0;
	else	case(ycbcr_cnt)
		2'd0	:	if(color_cnt == 2'd2)
						seg_data	<= {12'd0,8'd203 + blue_y_num};
					else	if(color_cnt == 2'd0)
						seg_data	<= {12'd0,8'd238 + red_y_num};
					else	if(color_cnt == 2'd1)
						seg_data	<= {12'd0,8'd215 + yellow_y_num};
					else	if(color_cnt == 2'd3)
						seg_data	<= {12'd0,8'd85 + black_y_num};
		2'd1	:	if(color_cnt == 2'd2)
						seg_data	<= {12'd0, 8'd134 + blue_cb_num};
					else	if(color_cnt == 2'd0)
						seg_data	<= {12'd0,8'd151 + red_cb_num};
					else	if(color_cnt == 2'd1)
						seg_data	<= {12'd0,8'd100 + yellow_cb_num};
					else	if(color_cnt == 2'd3)
						seg_data	<= {12'd0,8'd151 + black_cb_num};

		2'd2	:	if(color_cnt == 2'd2)
						seg_data	<= {12'd0,8'd0 + blue_cr_num};
					else	if(color_cnt == 2'd0)
						seg_data	<= {12'd0, 8'd130 + red_cr_num};
					else	if(color_cnt == 2'd1)
						seg_data	<= {12'd0,8'd150 + yellow_cr_num};
					else	if(color_cnt == 2'd3)
						seg_data	<= {12'd0,8'd148+ black_cr_num};
		default	:	seg_data	<=20'd0;
		endcase











//鏉堟挸鍤０婊嗗?
always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		post_img_Bit <= 1'b0;
	else	if(per_frame_clken)// 0 - 閽�? 1 - 缁�? 2 - 姒�? 3 - 姒�?
			case(color_cnt)
			2'd2	:	if((per_img_Y < 8'd203 + blue_y_num  && per_img_Y > 8'd20)//+ blue_y_num
							&& per_img_Cb > 8'd134 + blue_cb_num) //
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;


			2'd0	:	if((per_img_Y < 8'd238 + red_y_num) && (per_img_Cb < 8'd151 + red_cb_num)//缁俱垼澹?
							&& (per_img_Cr < 8'd222  && per_img_Cr > 8'd130  + red_cr_num))
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;


			2'd1	:	if((per_img_Y < 8'd215+ yellow_y_num) && (per_img_Cb < 8'd100 + yellow_cb_num )//姒涘嫯澹?206
							&& (per_img_Cr < 8'd150 + yellow_cr_num && per_img_Cr > 8'd8))
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;


			2'd3	:	if((per_img_Y < 8'd85 + black_y_num) && (per_img_Cb < 8'd151 + black_cb_num) //姒涙垼澹?
							&& (per_img_Cr < 8'd148 + black_cr_num))//(per_img_Y < 8'd74 + y_num) && (per_img_Cb < 8'd138 + cb_num) //姒涙垼澹?
							//&& (per_img_Cr < 8'd134 + cr_num)
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;
			default :	post_img_Bit <= 1'b0;
			endcase
endmodule
