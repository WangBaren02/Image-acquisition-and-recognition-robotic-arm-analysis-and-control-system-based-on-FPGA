module	connect_8_area //八连通算法与两遍扫描法
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

	output	reg				bin_out

);
//时序同步的中间变量
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



wire		hrefd1_neg_flag ;//行同步信号下降沿
wire		vsyncd1_pos_flag;//场同步信号上升沿
//行场计数器
reg	[9:0]	x_cnt			;
reg	[9:0]	y_cnt			;


//行场计数器延迟一个时钟周期
reg	[9:0]	x_cnt_r			;
reg	[9:0]	y_cnt_r			;



reg	[LABEL_BITS - 1:0]	label_href_max	;//取一行标签的最大值
wire	[LABEL_BITS - 1:0]	current_label	;//给新物体打的标签
reg	[LABEL_BITS - 1:0]	global_label	;//全局最大标签
reg	[LABEL_BITS - 1:0]	three_min		;//当前像素上方三个像素非零最小值

(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	current_line	[0 : IMG_WIDTH - 1];//当前行标签
(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	pass_line		[0 : IMG_WIDTH - 1];//上一行标签




wire			fifo_dout		;//读fifo
//循环变量
integer	i;	
integer	j;	



//行场信号时序同步
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
//取行信号下降沿和场信号上升沿
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
//行场计数器打拍
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

//找到当前行的最大值
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)	
		label_href_max	<= 4'd0;
	else	if(vsyncd1_pos_flag)
		label_href_max	<= 4'd0;
	else	if(x_cnt == 10'd479)
		label_href_max	<= 4'd0;
	else	if(hrefd1_neg_flag)
		for	(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)
			if(current_line[i] > label_href_max)
				label_href_max <= current_line[i];

//找到给物体打的最大标签
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 0 || vsyncd1_pos_flag )
		global_label	<= 1'b0;
	else	if(global_label < label_href_max)
		global_label	<= label_href_max;
	else
		global_label	<= global_label;




//给新物体打的标签
assign	current_label = global_label + 1;

//提前一个时钟周期找到当前像素对应的最小值//上面三个像素的标签永远小于等于左边的标签
always@(posedge	clk or negedge	rst_n)//three_min要与de_in_0同步，这样抓取的x_cnt与three_min才同步
	if(rst_n == 1'b0)
		three_min <= 4'd1;
	else	if(de_in && pixel_in)begin//此时x_cnt是前一个像素的坐标
		if(pass_line[x_cnt + 2'd2] !=0)begin
			three_min <=pass_line[x_cnt + 2'd2];
			for(j = 0; j <2 ; j = j+1)begin
				if(pass_line[x_cnt + j]!=0)begin
					if(three_min >  pass_line[x_cnt + j])
						three_min	<= pass_line[x_cnt + j];
				end
			
			end
		end
		else	if(pass_line[x_cnt + 2'd1] !=0)begin
			three_min <= pass_line[x_cnt + 2'd1];
			for(j = 0; j <1 ; j = j+1)begin
				if(pass_line[x_cnt + j] != 0)begin
					if(three_min > pass_line[x_cnt])
						three_min <=  pass_line[x_cnt];
				end
			end	
		end
		else	if(pass_line[x_cnt] !=0)
			three_min <= pass_line[x_cnt];
	end			
	else
		three_min	<= three_min;
	



//标签更新逻辑
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)//复位
		begin

		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
			current_line[i] <= 4'd0;
			pass_line[i]	<= 4'd0;
			end
		end
	else	if(vsyncd1_pos_flag)//帧复位
		begin

		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
			current_line[i] <= 4'd0;
			pass_line[i]	<= 4'd0;
			end
		end
	else	if(de_in_d0)begin
		
		if(pixel_in_d0 == 1'b1)	begin
			if(pass_line[x_cnt - 1'd1] == 1'd0 && pass_line[x_cnt] == 1'd0 && pass_line[x_cnt  + 1'd1] == 1'd0 && current_line[x_cnt - 1'd1] == 1'd0)
				current_line[x_cnt]	<= current_label;//遇到新物体给最大值+1
			else	if(pass_line[x_cnt - 1'd1] == 1'd0 && pass_line[x_cnt] == 1'd0 && pass_line[x_cnt  + 1'd1] == 1'd0 && current_line[x_cnt - 1'd1] != 1'd0)begin
				current_line[x_cnt]	<= current_line[x_cnt - 1'd1];//头上三个没标签则给左边
			end
			else begin//把头上三个最小的非零标签赋值给当前像素
				current_line[x_cnt]	<= three_min;
				if(current_line[x_cnt - 1'd1] != 0)
					current_line[x_cnt - 1'd1] <= three_min;//往左回溯1次
				if(current_line[x_cnt - 2'd2] != 0)
					current_line[x_cnt - 2'd2]	<= three_min;
				if(current_line[x_cnt - 2'd3] != 0)
					current_line[x_cnt - 2'd3]	<= three_min;//往左回溯三次	
			end
		end else	if(pixel_in_d0 == 1'b0)//黑色后景标签给0
			current_line[x_cnt]	<= 4'd0;
		end
	else	if(hrefd1_neg_flag)
		for(i = 0 ; i < IMG_WIDTH - 1 ; i = i + 1)
			pass_line[i] <= current_line[i];


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





//输出标签为1的二值化图像
always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		bin_out <= 1'b0;
	else	if(vsyncd1_pos_flag)
		bin_out <= 1'b0;
	else	if(fifo_dout == 1'b0)
		bin_out <= 1'b0;
	else	if(fifo_dout == 1'b1 && (pass_line[x_cnt_r] == 1) )//pass_line[x_cnt_r] == 1
		bin_out <= 1'b1;
	else
		bin_out <= 1'b0;





assign	href_out	= href_in_d2;
assign	vsync_out	= vsync_in_d2;
assign	de_out		= de_in_d2;


		
endmodule







