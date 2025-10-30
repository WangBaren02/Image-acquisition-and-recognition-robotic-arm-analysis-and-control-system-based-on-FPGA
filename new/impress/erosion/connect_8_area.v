////连通域算法---八连通-----20k
//module	connect_8_area
//#(
//	parameter	IMG_WIDTH 	= 640,
//	parameter	IMG_HEIGHT 	= 480,
//	parameter	LABEL_BITS  = 4	 ,
//	parameter   BACK_NUM	= 1	
//)
//(
//	input	wire			clk			,
//	input	wire			rst_n		,
//	input	wire			href_in		,
//	input	wire			vsync_in	,
//	input	wire			de_in		,
//	input	wire			pixel_in	,
//	
//	output	wire			href_out	,
//	output	wire			vsync_out	,
//	output	wire			de_out		,
//	//output  reg 	[23:0]  rgb_out
//	output	reg				bin_out
//
//);
//
//reg			href_in_d0		;
//reg			href_in_d1		;
//reg			href_in_d2		;
//reg			vsync_in_d0		;
//reg			vsync_in_d1		;
//reg			vsync_in_d2		;
//reg			de_in_d0		;
//reg			de_in_d1		;
//reg			de_in_d2		;
//reg			pixel_in_d0		;
//reg			pixel_in_d1		;
//
//
//wire		hrefd1_neg_flag ;
//wire		vsyncd1_pos_flag;
//
//reg	[9:0]	x_cnt			;
//reg	[9:0]	y_cnt			;
//
////reg	[9:0]	x_cnt_r			;
////reg	[9:0]	y_cnt_r			;
//
////reg	[9:0]	back_cnt		;//背景计数器
////reg	[9:0]	back_cnt_reg	;//打牌
//
////reg	[LABEL_BITS - 1:0]	label_href_add	;//每一行的不同物体
//reg	[LABEL_BITS - 1:0]	label_href_max	;//每一行更新后的最大标签
//wire	[LABEL_BITS - 1:0]	current_label	;//当前的标签
//reg	[LABEL_BITS - 1:0]	global_label	;
//
//(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	current_line	[0 : IMG_WIDTH - 1];
//(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	pass_line		[0 : IMG_WIDTH - 1];
//
////reg			ram_fifo_rd_en	;
////reg			ram_wr_en		;
//wire			fifo_dout		;
//
//integer	i;	//遍历行循环变量
//integer	j;	//标签回溯次数变量
//
////reg	[23:0]	color_lut	[0:15];//LUT
//
////打拍取沿
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		begin
//		href_in_d0		    <=  1'b0;
//		href_in_d1		    <=  1'b0;
//		href_in_d2		    <=  1'b0;
//		vsync_in_d0		    <=  1'b0;
//		vsync_in_d1		    <=  1'b0;
//		vsync_in_d2		    <=  1'b0;
//		de_in_d0		    <=  1'b0;
//		de_in_d1		    <=  1'b0;
//		de_in_d2		    <=  1'b0;
//		pixel_in_d0			<=	1'b0;
//		pixel_in_d1         <=	1'b0;
//		end
//	else
//		begin
//		href_in_d0			<=	href_in		;
//		href_in_d1			<=	href_in_d0	;
//		href_in_d2			<=	href_in_d1	;
//		vsync_in_d0			<=	vsync_in	;
//		vsync_in_d1			<=	vsync_in_d0	;
//		vsync_in_d2			<=	vsync_in_d1	;
//		de_in_d0			<=	de_in		;
//		de_in_d1			<=	de_in_d0	;
//		de_in_d2			<=	de_in_d1	;
//		pixel_in_d0			<=	pixel_in	;
//		pixel_in_d1         <=	pixel_in_d0	;
//		end
//
//assign	hrefd1_neg_flag  = (~href_in_d0) &	href_in_d1;
//assign	vsyncd1_pos_flag = vsync_in_d0 & (~vsync_in_d1);
//
////行场计数器
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		begin
//			x_cnt <= 10'd0;
//			y_cnt <= 10'd0;
//		end
//	else	if(vsyncd1_pos_flag)
//		begin
//			x_cnt <= 10'd0;
//			y_cnt <= 10'd0;
//		end
//	else	if(hrefd1_neg_flag)
//		begin
//			x_cnt <= 10'd0;
//			y_cnt <= y_cnt + 10'd1;
//		end
//	else	if(de_in_d1)
//		begin
//			x_cnt <=  x_cnt + 10'd1;
//		end
//
////行场计数器打牌
////always@(posedge	clk or negedge	rst_n)
////	if(rst_n == 1'b0)
////		begin
////			x_cnt_r <= 10'd0;
////			y_cnt_r <= 10'd0;
////		end
////	else
////		begin
////			x_cnt_r <= x_cnt;
////			y_cnt_r <= y_cnt;
////		end
////背景计数器
////always@(posedge	clk or negedge	rst_n)
////	if(rst_n == 1'b0)
////		back_cnt	<=	10'd0;
////	else	if(vsyncd1_pos_flag )
////		back_cnt	<= 	10'd0;
////	else	if(hrefd1_neg_flag)
////		back_cnt	<= 	10'd0;
////	else	if(de_in_d0 && pixel_in_d0 == 1'b1)
////		back_cnt	<=	10'd0;
////	else	if(de_in_d0 && pixel_in_d0 == 1'b0)
////		back_cnt	<=	back_cnt + 10'd1;
////
//////背景计数器打牌
////always@(posedge	clk or negedge	rst_n)
////	if(rst_n == 1'b0)
////		back_cnt_reg  	<= 10'd0;
////	else
////		back_cnt_reg	<= back_cnt;
//
////每一行遇到新物体时，行新物体标签更新
////always@(posedge	clk or negedge	rst_n)
////	if(rst_n == 1'b0)
////		label_href_add	<= 4'd0;
////	else	if(vsyncd1_pos_flag)
////		label_href_add	<= 4'd0;
////	else	if(hrefd1_neg_flag)
////		label_href_add	<= 4'd0;
////	else	if(back_cnt_reg > back_cnt )
////		label_href_add	<= label_href_add + 4'd1;
//
////每一行更新后的最大标签
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)	
//		label_href_max	<= 4'd0;
//	else	if(vsyncd1_pos_flag)
//		label_href_max	<= 4'd0;
//	else	if(x_cnt == 10'd479)//提前一行归零
//		label_href_max	<= 4'd0;
//	else	if(hrefd1_neg_flag)
//		for	(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)
//			if(current_line[i] > label_href_max)
//				label_href_max <= current_line[i];
////全局最大变量
////assign	global_label = (rst_n == 0 || vsyncd1_pos_flag ) ? 1'b0 : ((global_label < label_href_max ) ? label_href_max : global_label);
//
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 0 || vsyncd1_pos_flag )
//		global_label	<= 1'b0;
//	else	if(global_label < label_href_max)
//		global_label	<= label_href_max;
//	else
//		global_label	<= global_label;
////当前标签
//assign	current_label = global_label + 1;
////当前行标签
////当前行标签
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
//			current_line[i] <= 4'd0;
//			pass_line[i]	<= 4'd0;
//			end
//	else	if(vsyncd1_pos_flag)
//		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
//			current_line[i] <= 4'd0;
//			pass_line[i]	<= 4'd0;
//			end
//	else	if(de_in_d0)begin
//		if(pixel_in_d0 == 1'b1)	begin
//			////左边没有的情况
//			//if	(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
//			//		current_line[x_cnt]	<= current_label;
//			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt];
//			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
//			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt];
//			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
//			//		begin
//			//			current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			//			for (j = 0 ; j <BACK_NUM ; j = j + 1)
//			//				if(pass_line[x_cnt + j] != 0)
//			//					pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
//			//		end
//			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			////左边有的情况
//			//else	if(current_line[x_cnt - 1'd1] != 0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
//			//		current_line[x_cnt]	<= current_line[x_cnt - 1'd1];
//			//else	if(current_line[x_cnt - 1'd1] != 0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
//			//		begin
//			//			current_line[x_cnt]	<= pass_line[x_cnt];
//			//			for(j = 0 ; j <BACK_NUM ; j = j + 1)
//			//				if(current_line[x_cnt - j] != 0)
//			//					current_line[x_cnt - j] <= pass_line[x_cnt];
//			//		end
//			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
//			//		begin
//			//			current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
//			//			for(j = 0 ; j <BACK_NUM ; j = j + 1)
//			//				if(current_line[x_cnt - j] != 0)
//			//					current_line[x_cnt - j] <= pass_line[x_cnt + 1'd1];
//			//		end
//			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
//			//		begin
//			//			current_line[x_cnt]	<= pass_line[x_cnt];
//			//			for(j = 0 ; j <BACK_NUM ; j = j + 1)
//			//				if(current_line[x_cnt - j] != 0)
//			//					current_line[x_cnt - j] <= pass_line[x_cnt];
//			//		end
//			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] ==0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
//			//		begin
//			//			current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			//			for (j = 0 ; j <BACK_NUM ; j = j + 1)
//			//				if(pass_line[x_cnt + j] != 0)
//			//					pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
//			//		end
//			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] !=0
//			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
//			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//			
//			
//			//左边没有
//			if(current_line[x_cnt - 1'd1] ==0)begin
//				if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	==0 
//				&& pass_line[x_cnt + 1'd1] == 0)
//					current_line[x_cnt]	<= current_label;
//				else	if(pass_line[x_cnt] !=0)
//					current_line[x_cnt]	<= pass_line[x_cnt];
//				else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	!=0 
//				&& pass_line[x_cnt + 1'd1] == 0)
//					current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//				else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	==0 
//				&& pass_line[x_cnt + 1'd1] != 0)
//					current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
//				else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	!=0 
//				&& pass_line[x_cnt + 1'd1] != 0)
//					begin
//						current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//						for( j = 0 ; j < BACK_NUM ; j = j + 1)
//							if(pass_line[x_cnt + j] != 0)
//								pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
//					end
//			end
//			//左边有
//			else
//				begin
//					if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	==0 
//					&& pass_line[x_cnt + 1'd1] == 0)
//						current_line[x_cnt]	<= current_line[x_cnt - 1'd1];
//					else	if(pass_line[x_cnt - 1'd1]	!=0 
//					&& pass_line[x_cnt + 1'd1] == 0)
//						current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//					else	if(pass_line[x_cnt - 1'd1]	==0 
//					&& pass_line[x_cnt + 1'd1] != 0)
//						begin
//							current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
//							for( j = 0 ; j <= BACK_NUM ; j = j + 1)
//								if(current_line[x_cnt - j] != 0)
//									current_line[x_cnt - j]	<= pass_line[x_cnt + 1'd1];
//						end
//					else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	!=0 
//					&& pass_line[x_cnt + 1'd1] != 0)
//						begin
//							current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//							for( j = 0 ; j < BACK_NUM ; j = j + 1)
//								if(pass_line[x_cnt + j] != 0)
//									pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
//						end
//					else	if(pass_line[x_cnt] !=0 &&	pass_line[x_cnt - 1'd1]	==0 
//					&& pass_line[x_cnt + 1'd1] == 0)
//						begin
//							current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//							for( j = 0 ; j <= BACK_NUM ; j = j + 1)
//								if(current_line[x_cnt - j] != 0)
//									current_line[x_cnt - j]	<= pass_line[x_cnt + 1'd1];
//						end
//					else	if(pass_line[x_cnt] !=0 &&	pass_line[x_cnt - 1'd1]	!=0 
//					&& pass_line[x_cnt + 1'd1] != 0)
//						current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
//				end
//		end else	if(pixel_in_d0 == 1'b0)
//			current_line[x_cnt]	<= 4'd0;
//		end
//	else	if(hrefd1_neg_flag)//每一行结束时更新行
//		for(i = 0 ; i < IMG_WIDTH - 1 ; i = i + 1)
//			pass_line[i] <= current_line[i];
//
////fifo进行行缓存
////scfifo_640x1	scfifo_640x1_inst (
////	.clock ( clk ),
////	.data ( pixel_in_d0 ),
////	.rdreq ( y_cnt >= 10'd1 && de_in_d0),//到第二行并且
////	.sclr ( ~rst_n ),
////	.wrreq (de_in_d0 ),
////	.empty (  ),
////	.q ( fifo_dout )
////	 
////	);
//fifo_640x1 fifo_640x1_inst (
//  .clk(clk),      // input wire clk
//  .srst(~rst_n||vsyncd1_pos_flag),    // input wire srst
//  .din(pixel_in_d0),      // input wire [0 : 0] din
//  .wr_en(de_in_d0),  // input wire wr_en
//  .rd_en(y_cnt >= 10'd1 && de_in_d0),  // input wire rd_en
//  .dout(fifo_dout),    // output wire [0 : 0] dout
//  .full(),    // output wire full
//  .empty()  // output wire empty
//);
//
//
//
//
//
//////预定义查找表
////always@(negedge rst_n)begin
////	if(rst_n == 1'b0)
////		begin
////		color_lut[0]  <= 24'h000000;//黑
////		color_lut[1]  <= 24'hFF0000;//红
////		color_lut[2]  <= 24'h00FF00;//绿
////		color_lut[3]  <= 24'h0000FF;//蓝
////		color_lut[4]  <= 24'hFFFF00;//黄
////		color_lut[5]  <= 24'hFF00FF;//品红
////		color_lut[6]  <= 24'h00FFFF;//青
////		color_lut[7]  <= 24'h800080;//紫
////		color_lut[8]  <= 24'h808000;//橄榄
////		color_lut[9]  <= 24'h008080;//蓝绿
////		color_lut[10] <= 24'h800000;//褐红
////		color_lut[11] <= 24'h008000;//深绿
////		color_lut[12] <= 24'h000080;//深蓝
////		color_lut[13] <= 24'h808080;//灰
////		color_lut[14] <= 24'hC0C0C0;//银
////		color_lut[15] <= 24'h40E0D0;//绿松石
////		end
////end
////
//////输出rgb颜色
////always@(posedge	clk or negedge	rst_n)
////	if(rst_n == 1'b0)
////		rgb_out	<= 24'h000000;
////	else	if(vsyncd1_pos_flag)
////		rgb_out	<= 24'h000000;
////	else	if(fifo_dout == 1'b0)
////		rgb_out	<= 24'h000000;
////	else	if(fifo_dout == 1'b1)
////		rgb_out <= color_lut[pass_line[x_cnt]];
//
//always@(posedge clk or negedge rst_n)
//	if(rst_n == 1'b0)
//		bin_out <= 1'b0;
//	else	if(vsyncd1_pos_flag)
//		bin_out <= 1'b0;
//	else	if(fifo_dout == 1'b0)
//		bin_out <= 1'b0;
//	else	if(fifo_dout == 1'b1 && pass_line[x_cnt] == 1)
//		bin_out <= 1'b1;
//	else
//		bin_out <= 1'b0;
//
//
//
//
////时序同步
//assign	href_out	= href_in_d2;
//assign	vsync_out	= vsync_in_d2;
//assign	de_out		= de_in_d2;
//
//
//		
//endmodule









//连通域算法---八连通-----20k
module	connect_8_area
#(
	parameter	IMG_WIDTH 	= 640,
	parameter	IMG_HEIGHT 	= 480,
	parameter	LABEL_BITS  = 4	 ,
	parameter   BACK_NUM	= 1	
)
(
	input	wire			clk			,
	input	wire			rst_n		,
	input	wire			href_in		,
	input	wire			vsync_in	,
	input	wire			de_in		,
	input	wire			pixel_in	,
	
	output	wire			href_out	,
	output	wire			vsync_out	,
	output	wire			de_out		,
	//output  reg 	[23:0]  rgb_out
	output	reg				bin_out

);

reg			href_in_d0		;
reg			href_in_d1		;
reg			href_in_d2		;

reg			href_in_d3		;

reg			vsync_in_d0		;
reg			vsync_in_d1		;
reg			vsync_in_d2		;

reg			vsync_in_d3		;

reg			de_in_d0		;
reg			de_in_d1		;
reg			de_in_d2		;

reg			de_in_d3		;

reg			pixel_in_d0		;
reg			pixel_in_d1		;

reg			pixel_in_d2		;



wire		hrefd1_neg_flag ;
wire		vsyncd1_pos_flag;

reg	[9:0]	x_cnt			;
reg	[9:0]	y_cnt			;

//reg	[LABEL_BITS - 1:0]	four_min;

//reg	[9:0]	x_cnt_r			;
//reg	[9:0]	y_cnt_r			;

//reg	[9:0]	back_cnt		;//背景计数器
//reg	[9:0]	back_cnt_reg	;//打牌

//reg	[LABEL_BITS - 1:0]	label_href_add	;//每一行的不同物体
reg	[LABEL_BITS - 1:0]	label_href_max	;//每一行更新后的最大标签
wire	[LABEL_BITS - 1:0]	current_label	;//当前的标签
reg	[LABEL_BITS - 1:0]	global_label	;


(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	current_line	[0 : IMG_WIDTH - 1];
(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	pass_line		[0 : IMG_WIDTH - 1];

//reg			ram_fifo_rd_en	;
//reg			ram_wr_en		;
wire			fifo_dout		;

integer	i;	//遍历行循环变量
integer	j;	//标签回溯次数变量
integer	n;	//四个区域便签的最小值
//reg	[23:0]	color_lut	[0:15];//LUT

//打拍取沿
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
		href_in_d0		    <=  1'b0;
		href_in_d1		    <=  1'b0;
		href_in_d2		    <=  1'b0;
		href_in_d3		    <=  1'b0;
		vsync_in_d0		    <=  1'b0;
		vsync_in_d1		    <=  1'b0;
		vsync_in_d2		    <=  1'b0;
		vsync_in_d3		    <=  1'b0;
		de_in_d0		    <=  1'b0;
		de_in_d1		    <=  1'b0;
		de_in_d2		    <=  1'b0;
		de_in_d3		    <=  1'b0;
		pixel_in_d0			<=	1'b0;
		pixel_in_d1         <=	1'b0;
		pixel_in_d2         <=	1'b0;
		end
	else
		begin
		href_in_d0			<=	href_in		;
		href_in_d1			<=	href_in_d0	;
		href_in_d2			<=	href_in_d1	;
		href_in_d3		    <=  href_in_d2	;
		vsync_in_d0			<=	vsync_in	;
		vsync_in_d1			<=	vsync_in_d0	;
		vsync_in_d2			<=	vsync_in_d1	;
		vsync_in_d3			<=	vsync_in_d2	;
		de_in_d0			<=	de_in		;
		de_in_d1			<=	de_in_d0	;
		de_in_d2			<=	de_in_d1	;
		de_in_d3			<=	de_in_d2	;
		pixel_in_d0			<=	pixel_in	;
		pixel_in_d1         <=	pixel_in_d0	;
		pixel_in_d2         <=	pixel_in_d1	;
		end

assign	hrefd1_neg_flag  = (~href_in_d0) &	href_in_d1;
assign	vsyncd1_pos_flag = vsync_in_d0 & (~vsync_in_d1);

//行场计数器
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
			x_cnt <= 10'd0;
			y_cnt <= 10'd0;
		end
	else	if(vsyncd1_pos_flag)
		begin
			x_cnt <= 10'd0;
			y_cnt <= 10'd0;
		end
	else	if(hrefd1_neg_flag)
		begin
			x_cnt <= 10'd0;
			y_cnt <= y_cnt + 10'd1;
		end
	else	if(de_in)
		begin
			x_cnt <=  x_cnt + 10'd1;
		end

//行场计数器打牌
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
			x_cnt_r <= 10'd0;
			y_cnt_r <= 10'd0;
		end
	else
		begin
			x_cnt_r <= x_cnt;
			y_cnt_r <= y_cnt;
		end
//背景计数器
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		back_cnt	<=	10'd0;
//	else	if(vsyncd1_pos_flag )
//		back_cnt	<= 	10'd0;
//	else	if(hrefd1_neg_flag)
//		back_cnt	<= 	10'd0;
//	else	if(de_in_d0 && pixel_in_d0 == 1'b1)
//		back_cnt	<=	10'd0;
//	else	if(de_in_d0 && pixel_in_d0 == 1'b0)
//		back_cnt	<=	back_cnt + 10'd1;
//
////背景计数器打牌
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		back_cnt_reg  	<= 10'd0;
//	else
//		back_cnt_reg	<= back_cnt;

//每一行遇到新物体时，行新物体标签更新
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		label_href_add	<= 4'd0;
//	else	if(vsyncd1_pos_flag)
//		label_href_add	<= 4'd0;
//	else	if(hrefd1_neg_flag)
//		label_href_add	<= 4'd0;
//	else	if(back_cnt_reg > back_cnt )
//		label_href_add	<= label_href_add + 4'd1;

//每一行更新后的最大标签
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)	
		label_href_max	<= 4'd0;
	else	if(vsyncd1_pos_flag)
		label_href_max	<= 4'd0;
	else	if(x_cnt == 10'd479)//提前一行归零
		label_href_max	<= 4'd0;
	else	if(hrefd1_neg_flag)
		for	(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)
			if(current_line[i] > label_href_max)
				label_href_max <= current_line[i];
//全局最大变量
//assign	global_label = (rst_n == 0 || vsyncd1_pos_flag ) ? 1'b0 : ((global_label < label_href_max ) ? label_href_max : global_label);

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 0 || vsyncd1_pos_flag )
		global_label	<= 1'b0;
	else	if(global_label < label_href_max)
		global_label	<= label_href_max;
	else
		global_label	<= global_label;
//当前标签
assign	current_label = global_label + 1;
//当前行标签
//当前行标签
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
		//four_min <= 4'd0;
		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
			current_line[i] <= 4'd0;
			pass_line[i]	<= 4'd0;
			end
		end
	else	if(vsyncd1_pos_flag)
		begin
		//four_min <= 4'd0;
		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
			current_line[i] <= 4'd0;
			pass_line[i]	<= 4'd0;
			end
		end
	else	if(de_in_d0)begin
		if(pixel_in_d0 == 1'b1)	begin
			////左边没有的情况
			//if	(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
			//		current_line[x_cnt]	<= current_label;
			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt];
			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt];
			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
			//		begin
			//			current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			//			for (j = 0 ; j <BACK_NUM ; j = j + 1)
			//				if(pass_line[x_cnt + j] != 0)
			//					pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
			//		end
			//else	if(current_line[x_cnt - 1'd1] ==0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			////左边有的情况
			//else	if(current_line[x_cnt - 1'd1] != 0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
			//		current_line[x_cnt]	<= current_line[x_cnt - 1'd1];
			//else	if(current_line[x_cnt - 1'd1] != 0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] == 0)
			//		begin
			//			current_line[x_cnt]	<= pass_line[x_cnt];
			//			for(j = 0 ; j <BACK_NUM ; j = j + 1)
			//				if(current_line[x_cnt - j] != 0)
			//					current_line[x_cnt - j] <= pass_line[x_cnt];
			//		end
			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
			//		begin
			//			current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
			//			for(j = 0 ; j <BACK_NUM ; j = j + 1)
			//				if(current_line[x_cnt - j] != 0)
			//					current_line[x_cnt - j] <= pass_line[x_cnt + 1'd1];
			//		end
			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] == 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	==0 && pass_line[x_cnt + 1'd1] != 0)
			//		begin
			//			current_line[x_cnt]	<= pass_line[x_cnt];
			//			for(j = 0 ; j <BACK_NUM ; j = j + 1)
			//				if(current_line[x_cnt - j] != 0)
			//					current_line[x_cnt - j] <= pass_line[x_cnt];
			//		end
			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] ==0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
			//		begin
			//			current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			//			for (j = 0 ; j <BACK_NUM ; j = j + 1)
			//				if(pass_line[x_cnt + j] != 0)
			//					pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
			//		end
			//else	if(current_line[x_cnt - 1'd1] !=0 && pass_line[x_cnt] !=0
			//	&&	pass_line[x_cnt - 1'd1]	!=0 && pass_line[x_cnt + 1'd1] != 0)
			//		current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
			
			
			//左边没有
			if(current_line[x_cnt - 1'd1] ==0)begin
				if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	==0 
				&& pass_line[x_cnt + 1'd1] == 0)
					current_line[x_cnt]	<= current_label;
				else	if(pass_line[x_cnt] !=0)
					current_line[x_cnt]	<= pass_line[x_cnt];
				else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	!=0 
				&& pass_line[x_cnt + 1'd1] == 0)
					current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
				else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	==0 
				&& pass_line[x_cnt + 1'd1] != 0)
					current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
				else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	!=0 
				&& pass_line[x_cnt + 1'd1] != 0)
					begin
						current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
						for( j = 0 ; j < BACK_NUM ; j = j + 1)
							if(pass_line[x_cnt + j] != 0)
								pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
					end
			end
			//左边有
			else	
				begin
					if(pass_line[x_cnt] == 0 &&	pass_line[x_cnt - 1'd1]	== 0 
					&& pass_line[x_cnt + 1'd1] == 0)
						current_line[x_cnt]	<= current_line[x_cnt - 1'd1];
						
						
						
						
					else	if(pass_line[x_cnt - 1'd1]	!=0 
					&& pass_line[x_cnt + 1'd1] == 0)
						//if(current_line[x_cnt - 1'd1] > pass_line[x_cnt - 1'd1])
							begin
							current_line[x_cnt]	<=  pass_line[x_cnt - 1'd1];//pass_line[x_cnt - 1'd1]
							current_line[x_cnt - 1'd1]	<= pass_line[x_cnt - 1'd1];
							end
						//else	if(current_line[x_cnt - 1'd1] <= pass_line[x_cnt - 1'd1])
						//	begin
						//	current_line[x_cnt]	<= current_line[x_cnt - 1'd1];
						//	pass_line[x_cnt - 1'd1]	<= current_line[x_cnt - 1'd1];
						//	end
						
						
						
						
					else	if(pass_line[x_cnt - 1'd1]	==0 
					&& pass_line[x_cnt + 1'd1] != 0)
						if(current_line[x_cnt - 1'd1] > pass_line[x_cnt + 1'd1])
							begin
								current_line[x_cnt]	<= pass_line[x_cnt + 1'd1];
								for( j = 0 ; j <= BACK_NUM ; j = j + 1)
									if(current_line[x_cnt - j] != 0)
										current_line[x_cnt - j]	<= pass_line[x_cnt + 1'd1];
							end
						else	if(current_line[x_cnt - 1'd1] <= pass_line[x_cnt + 1'd1])
							begin
								current_line[x_cnt]	<=	current_line[x_cnt - 1'd1];
								pass_line[x_cnt + 1'd1]	<= current_line[x_cnt - 1'd1];
							end
						
						
					else	if(pass_line[x_cnt] ==0 &&	pass_line[x_cnt - 1'd1]	!=0 
					&& pass_line[x_cnt + 1'd1] != 0)
						begin
							current_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
							for( j = 0 ; j < BACK_NUM ; j = j + 1)
								if(pass_line[x_cnt + j] != 0)
									pass_line[x_cnt + j] <= pass_line[x_cnt - 1'd1];
						end
						
						
						
						
					else	if(pass_line[x_cnt] !=0 &&	pass_line[x_cnt - 1'd1]	==0 
					&& pass_line[x_cnt + 1'd1] == 0)begin
						if(current_line[x_cnt - 1'd1] > pass_line[x_cnt])
							begin
								current_line[x_cnt]	<= pass_line[x_cnt];
								for( j = 0 ; j <= BACK_NUM ; j = j + 1)
									if(current_line[x_cnt - j] != 0)
										current_line[x_cnt - j]	<= pass_line[x_cnt];
							end
						else	if(current_line[x_cnt - 1'd1] <= pass_line[x_cnt])
							begin
								current_line[x_cnt]	<=  current_line[x_cnt - 1'd1];
								pass_line[x_cnt]	<= 	current_line[x_cnt - 1'd1];
							
							end
						end
						
						
						
					else	if(pass_line[x_cnt] !=0 &&	pass_line[x_cnt - 1'd1]	!=0 //细改
					&& pass_line[x_cnt + 1'd1] != 0)
					begin//current_line[x_cnt - 1'd1];
						//four_min	<= current_line[x_cnt - 1'd1];
						//for (n=0 ; n < 3 ; n = n + 1)
						//	begin
						//		if(four_min > pass_line[x_cnt + 1'd1 - n])
						//			four_min <= pass_line[x_cnt + 1'd1 - n];
						//	end
						if(pass_line[x_cnt - 1'd1] <= pass_line[x_cnt])
							if(pass_line[x_cnt - 1'd1] <= pass_line[x_cnt + 1'd1])begin
								current_line[x_cnt]	<=	pass_line[x_cnt - 1'd1];
								pass_line[x_cnt + 1'd1]	<= pass_line[x_cnt - 1'd1];
								pass_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
								end
							else	if(pass_line[x_cnt - 1'd1] > pass_line[x_cnt + 1'd1])begin
								current_line[x_cnt]	<=	pass_line[x_cnt + 1'd1];
								pass_line[x_cnt - 1'd1]	<= pass_line[x_cnt + 1'd1];
								pass_line[x_cnt]	<=	pass_line[x_cnt + 1'd1];
								end
						else	if(pass_line[x_cnt - 1'd1] <= pass_line[x_cnt + 1'd1])
							if(pass_line[x_cnt - 1'd1] <= pass_line[x_cnt])	begin
								current_line[x_cnt]	<=	pass_line[x_cnt - 1'd1];
								pass_line[x_cnt]	<= pass_line[x_cnt - 1'd1];
								pass_line[x_cnt + 1'd1]	<= pass_line[x_cnt - 1'd1];
							end
							else	if(pass_line[x_cnt - 1'd1] > pass_line[x_cnt])begin
								current_line[x_cnt]	<=	pass_line[x_cnt];
								pass_line[x_cnt - 1'd1]	<= pass_line[x_cnt];
								 pass_line[x_cnt + 1'd1]	<= pass_line[x_cnt];
							end
						else	if( pass_line[x_cnt]	<= pass_line[x_cnt + 1'd1] )
							if(pass_line[x_cnt]	<= pass_line[x_cnt - 1'd1])begin
								current_line[x_cnt]	<=	pass_line[x_cnt];
								pass_line[x_cnt - 1'd1]	<= pass_line[x_cnt];
							    pass_line[x_cnt + 1'd1]	<= pass_line[x_cnt];
							end	
							else	if((pass_line[x_cnt]	> pass_line[x_cnt - 1'd1])begin//current_line
								current_line[x_cnt]	<=	pass_line[x_cnt - 1'd1];
								pass_line[x_cnt + 1'd1]	<= pass_line[x_cnt - 1'd1];
								pass_line[x_cnt]	<=  pass_line[x_cnt - 1'd1];
							end
						else		
							current_line[x_cnt]	<= current_line[x_cnt - 1'd1];
						
						
						
					end
				end
		end else	if(pixel_in_d0 == 1'b0)
			current_line[x_cnt]	<= 4'd0;
		end
	else	if(hrefd1_neg_flag)//每一行结束时更新行
		for(i = 0 ; i < IMG_WIDTH - 1 ; i = i + 1)
			pass_line[i] <= current_line[i];

//fifo进行行缓存
//scfifo_640x1	scfifo_640x1_inst (
//	.clock ( clk ),
//	.data ( pixel_in_d0 ),
//	.rdreq ( y_cnt >= 10'd1 && de_in_d0),//到第二行并且
//	.sclr ( ~rst_n ),
//	.wrreq (de_in_d0 ),
//	.empty (  ),
//	.q ( fifo_dout )
//	 
//	);
fifo_640x1 fifo_640x1_inst (
  .clk(clk),      // input wire clk
  .srst(~rst_n||vsyncd1_pos_flag),    // input wire srst
  .din(pixel_in_d0),      // input wire [0 : 0] din
  .wr_en(de_in_d0),  // input wire wr_en
  .rd_en(y_cnt >= 10'd1 && de_in_d0),  // input wire rd_en
  .dout(fifo_dout),    // output wire [0 : 0] dout
  .full(),    // output wire full
  .empty()  // output wire empty
);





////预定义查找表
//always@(negedge rst_n)begin
//	if(rst_n == 1'b0)
//		begin
//		color_lut[0]  <= 24'h000000;//黑
//		color_lut[1]  <= 24'hFF0000;//红
//		color_lut[2]  <= 24'h00FF00;//绿
//		color_lut[3]  <= 24'h0000FF;//蓝
//		color_lut[4]  <= 24'hFFFF00;//黄
//		color_lut[5]  <= 24'hFF00FF;//品红
//		color_lut[6]  <= 24'h00FFFF;//青
//		color_lut[7]  <= 24'h800080;//紫
//		color_lut[8]  <= 24'h808000;//橄榄
//		color_lut[9]  <= 24'h008080;//蓝绿	
//		color_lut[10] <= 24'h800000;//褐红
//		color_lut[11] <= 24'h008000;//深绿
//		color_lut[12] <= 24'h000080;//深蓝
//		color_lut[13] <= 24'h808080;//灰
//		color_lut[14] <= 24'hC0C0C0;//银
//		color_lut[15] <= 24'h40E0D0;//绿松石
//		end
//end
//
////输出rgb颜色
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		rgb_out	<= 24'h000000;
//	else	if(vsyncd1_pos_flag)
//		rgb_out	<= 24'h000000;
//	else	if(fifo_dout == 1'b0)
//		rgb_out	<= 24'h000000;
//	else	if(fifo_dout == 1'b1)
//		rgb_out <= color_lut[pass_line[x_cnt]];

always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		bin_out <= 1'b0;
	else	if(vsyncd1_pos_flag)
		bin_out <= 1'b0;
	else	if(fifo_dout == 1'b0)
		bin_out <= 1'b0;
	else	if(fifo_dout == 1'b1 && pass_line[x_cnt_r] == 1 )
		bin_out <= 1'b1;
	else
		bin_out <= 1'b0;




//时序同步
assign	href_out	= href_in_d2;
assign	vsync_out	= vsync_in_d2;
assign	de_out		= de_in_d2;


		
endmodule







