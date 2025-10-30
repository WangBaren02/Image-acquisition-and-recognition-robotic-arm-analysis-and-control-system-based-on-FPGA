module	coordinate_centroid//质心坐标计算模块
#(
	parameter 	[9:0]	IMG_HDISP = 10'd640,
	parameter	[9:0]	IMG_VDISP = 10'd480
)
(
	input	wire			clk				,
	input	wire			rst_n			,
	input	wire			href_in			,
	input	wire			vsync_in		,//取反输入
	input	wire			de_in			,
	input	wire			din_in			,
	//input	wire			shape_girth		,
	input	wire	[9:0]	angle_data		,
	input	wire			angle_gen_flag	,
	
	
	output	reg		[9:0]	x_cent			,//质心坐标
	output	reg		[9:0]	y_cent			,
	output	reg		[9:0]	x_h_max			,//最高点坐标
	output	reg		[9:0]	y_h_max			,
	output	reg		[9:0]	x_h_min			,//最低点坐标
	output	reg		[9:0]	y_h_min			,
	//output	reg				ram_rd_en	,
	output	reg		[2:0]	shape_infor		,	//四种形状信息
	output	reg				ram_wr_en		,
	output	reg				ram_wr_addr		,
	output	reg		[29:0]	ram_wr_data		,
	output	reg				color_change	,	//颜色标志信号
	output	reg				angle_gen_start	,//角度开始计算标志信号
	output	wire			href_out		,
	output	wire			vsync_out		
);
reg			vsync_in_d1			;
reg			href_in_d1			;
reg			de_in_d1			;
reg			din_in_d1			;

reg			vsync_in_d2			;
reg			href_in_d2			;
reg			de_in_d2			;
reg			din_in_d2			;

wire		hrefd1_neg_flag		;//d1同步,提取行下降沿
wire		vsyncd1_pos_flag	;//提取场上升沿

reg			[9:0]	x_cnt		;//行场计数器
reg			[9:0]	y_cnt		;
reg			[9:0]	x_pixel_cnt	;//寄存有效像素坐标
reg			[9:0]	y_pixel_cnt	;
reg			[19:0]	cnt_pixel	;//统计像素个数


reg			[27:0]	x_num_cnt	;//x坐标相加
reg			[27:0]	y_num_cnt	;//y坐标相加

//时序同步
assign	href_out  = href_in_d2	;
assign	vsync_out = vsync_in_d2	;



//打拍取沿
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
		vsync_in_d1		<= 1'b0;	
		href_in_d1		<= 1'b0;	
		de_in_d1		<= 1'b0;	
		din_in_d1		<= 1'b0;	
		end
	else
		begin
		vsync_in_d1		<= vsync_in	;
		href_in_d1		<= href_in	;
		de_in_d1		<= de_in	;
		din_in_d1		<= din_in	;
		end

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
		vsync_in_d2		<= 	1'b0;	
		href_in_d2		<= 	1'b0;	
		de_in_d2		<= 	1'b0;	
		din_in_d2		<= 	1'b0;	
		end
	else
		begin
		vsync_in_d2		<= 	vsync_in_d1	;
		href_in_d2		<= 	href_in_d1	;
		de_in_d2		<= 	de_in_d1	;
		din_in_d2		<= 	din_in_d1	;
		end

assign	hrefd1_neg_flag  = (~href_in_d1) &	href_in_d2;//取输入场信号上升沿
assign	vsyncd1_pos_flag = vsync_in_d1 & (~vsync_in_d2);//取输入行信号下降沿
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
	else	if(de_in_d1)
		begin
			x_cnt <=  x_cnt + 10'd1;
		end
//有效像素计数器
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		cnt_pixel <= 1'b0;
	else	if(vsyncd1_pos_flag)
		cnt_pixel <= 1'b0;
	else	if(din_in_d1)
		cnt_pixel <= cnt_pixel + 1'd1;
//有效像素x坐标相加
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_num_cnt <= 19'd0;
	else	if(vsyncd1_pos_flag)
		x_num_cnt <= 19'd0;
	else	if(din_in_d1)
		x_num_cnt <=  x_num_cnt + x_cnt;
//有效像素y坐标相加
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_num_cnt <= 19'd0;
	else	if(vsyncd1_pos_flag)
		y_num_cnt <= 19'd0;
	else	if(din_in_d1)
		y_num_cnt <= y_num_cnt + y_cnt;
//寄存有效像素坐标，找到最后一个点
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_pixel_cnt <=	10'd0;
	else	if(vsyncd1_pos_flag)
		x_pixel_cnt <=	10'd0;
	else	if(din_in_d1)
		x_pixel_cnt <= x_cnt;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_pixel_cnt <= 10'd0;
	else	if(vsyncd1_pos_flag)
		y_pixel_cnt <= 10'd0;
	else	if(din_in_d1)
		y_pixel_cnt <= y_cnt;
//输出质心坐标
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_cent <= 10'd0;
	else	if(vsyncd1_pos_flag)
		x_cent <= 10'd0;
	else	if(y_cnt == IMG_VDISP )
		x_cent <= x_num_cnt/cnt_pixel;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_cent <= 10'd0;
	else	if(vsyncd1_pos_flag)
		y_cent <= 10'd0;
	else	if(y_cnt == IMG_VDISP)
		y_cent <= y_num_cnt/cnt_pixel;

//输出最高坐标
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_h_max <= 10'd0;
	else	if(vsyncd1_pos_flag)
		x_h_max <= 10'd0;
	else	if(cnt_pixel == 0 && din_in_d1)
		x_h_max <= x_cnt;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_h_max <= 10'd0;
	else	if(vsyncd1_pos_flag)
		y_h_max <= 10'd0;
	else	if(cnt_pixel == 0 && din_in_d1)
		y_h_max <= y_cnt;

//输出最低坐标
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_h_min <= 10'd0;
	else	if(vsyncd1_pos_flag)
		x_h_min <= 10'd0;
	else	if(y_cnt == IMG_VDISP)
		x_h_min <= x_pixel_cnt;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_h_min <= 10'd0;
	else	if(vsyncd1_pos_flag)
		y_h_min <= 10'd0;
	else	if(y_cnt == IMG_VDISP)
		y_h_min <= y_pixel_cnt;

//输出形状数据
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		shape_infor <= 3'd0;
	else	if(vsyncd1_pos_flag)
		shape_infor <= 3'd0;
	else	if(y_cnt == IMG_VDISP)
		begin
		if(cnt_pixel >= 10'd50 && cnt_pixel < 10'd100)//三角形
			shape_infor <= 3'd1;
		if(cnt_pixel >= 20'd15000 && cnt_pixel < 20'd23000)//正方形
			shape_infor <= 3'd2;
		if(cnt_pixel >= 10'd300 && cnt_pixel <10'd400)//圆形
			shape_infor <= 3'd3;
		if(cnt_pixel >= 20'd6000 && cnt_pixel < 20'd7000)//六边形
			shape_infor <= 3'd4;
		end

//输出ramip核写使能信号

//always@(posedge	clk or negedge	rst_n)

//角度计算开始标志信号------拉高一个时钟周期
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		angle_gen_start <= 1'b0;
	else	if(vsyncd1_pos_flag)
		angle_gen_start <= 1'b0;
	//else	if(angle_gen_flag)
	//	angle_gen_start <= 1'b0;
	else	if(y_cnt == IMG_VDISP)
		angle_gen_start <= 1'b1;
	else
		angle_gen_start <= 1'b0;

//颜色切换信号 (拉高一个时钟周期)
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		color_change <= 1'b0;
	else	if(vsyncd1_pos_flag)
		color_change <= 1'b0;
	else	if(y_cnt == IMG_VDISP - 1'd1 && hrefd1_neg_flag)
		if(cnt_pixel < 20'd25)
			color_change <= 1'b1;
		else
			color_change <= 1'b0;
	else
		color_change <= 1'b0;

//写使能
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		ram_wr_en	<= 1'b0;
	else	if(vsyncd1_pos_flag)
		ram_wr_en	<= 1'b0;
	else	if(angle_gen_flag)
		ram_wr_en	<= 1'b1;

//写数据
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		ram_wr_data	<= 30'd0;
	else	if(vsyncd1_pos_flag)
		ram_wr_data	<= 30'd0;
	else	if(angle_gen_flag&& color_change != 1)
		ram_wr_data	<= {x_cent,y_cent,angle_data};
	else	if(angle_gen_flag&& color_change == 1)
		ram_wr_data	<= 30'd0;

//写地址
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		ram_wr_addr	<= 1'b0;
	else	if(vsyncd1_pos_flag)
		ram_wr_addr	<= 1'b0;
	else	if(angle_gen_flag)
		ram_wr_addr	<= 1'b1;






endmodule