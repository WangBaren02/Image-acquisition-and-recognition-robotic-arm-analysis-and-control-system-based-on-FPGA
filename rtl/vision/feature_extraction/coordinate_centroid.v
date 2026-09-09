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
	input	wire	[8:0]	angle_data		,
	input	wire			angle_gen_flag	,


	output	reg		[9:0]	x_cent			,//质心坐标
	output	reg		[9:0]	y_cent			,
	output	reg		[9:0]	x_h_max			,//朿高点坐?
	output	reg		[9:0]	y_h_max			,
	output	reg		[9:0]	x_h_min			,//朿低点坐?
	output	reg		[9:0]	y_h_min			,
	//output	reg				ram_rd_en	,
	output	reg		[1:0]	shape_infor		,	//四种形状信息
	output	reg				ram_wr_en		,
	output	reg				ram_wr_addr		,
	output	reg		[28:0]	ram_wr_data		,
	output	reg				color_mode		,
	//output	reg				color_change	,	//颜色标志信号
	output	reg				angle_gen_start	,//角度弿始计算标志信叿
	output	wire			href_out		,
	output	wire			vsync_out		,
	output	reg		[19:0]	pixel_area_out
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

reg			hrefd1_neg_flag_r	;////////////////////////////////////////
reg			squre_de			;////////////////////////////////////////
reg			squre_de_r			;



wire		squre_ok			;
wire		squre_ok_2			;
wire		squre_ok_3			;
wire		squre_ok_4			;


reg			[9:0]	x_left_cnt	;//朿左边的像素，两迅一起赋?,用于求解三角形抓取点
reg			[9:0]	y_left_cnt	;

reg			[9:0]	x_right_cnt	;//朿右边的像素，用于求解三角形抓取?
reg			[9:0]	y_right_cnt	;



reg			[9:0]	x_cnt		;//行场计数?
reg			[9:0]	y_cnt		;
reg			[9:0]	x_pixel_cnt	;//寄存有效像素坐标
reg			[9:0]	y_pixel_cnt	;
reg			[19:0]	cnt_pixel	;//统计像素个数


reg			[27:0]	x_num_cnt	;//x坐标相加
reg			[27:0]	y_num_cnt	;//y坐标相加

//两条?
reg		[15:0]	squre_1		;
reg		[15:0]	squre_2		;
reg		[15:0]	squre_3		;
reg		[15:0]	squre_4		;


wire		[15:0]	squre_out_1	;
wire		[15:0]	squre_out_2	;
wire		[15:0]	squre_out_3	;
wire		[15:0]	squre_out_4	;

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

assign	hrefd1_neg_flag  = (~href_in_d1) &	href_in_d2;//取输入场信号上升?
assign	vsyncd1_pos_flag = vsync_in_d1 & (~vsync_in_d2);//取输入行信号下降?
//行场计数?
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
//有效像素计数?
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

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_cent <= 10'd0;
	//else	if(vsyncd1_pos_flag)
	//	x_cent <= 10'd0;
	else	if(squre_ok)	begin
		if(shape_infor == 2'd3)
			begin
				if((x_h_max >= x_right_cnt - 4'd9)&&(x_h_max <= x_right_cnt + 4'd9)
					&&(y_h_max >= y_right_cnt - 3'd5)&&(y_h_max <= y_right_cnt + 3'd5))	begin//朿上与朿右重?
						if(squre_out_4 >= squre_out_1)
							x_cent <= (x_h_max + x_h_min) >> 1 ;
						else
							x_cent <= (x_h_max + x_left_cnt) >> 1;
				end
				else	if((x_h_max >= x_left_cnt - 4'd9) && (x_h_max <= x_left_cnt + 4'd9)
					&& (y_h_max >= y_left_cnt - 3'd5) && (y_h_max <= y_left_cnt + 3'd5)) begin//朿上与朿左重?
						if(squre_out_4 >= squre_out_3)
							x_cent <= (x_h_max + x_h_min) >> 1;
						else
							x_cent <= (x_h_max + x_right_cnt) >> 1;
				end
				else	begin
					if((squre_out_1 <= squre_out_2) && (squre_out_3 <= squre_out_2))
						x_cent <= (x_left_cnt + x_right_cnt) >> 1;
					else	if((squre_out_1 > squre_out_2) && (squre_out_1 > squre_out_3))
						x_cent <= (x_left_cnt + x_h_max) >> 1;
					else	if((squre_out_1 < squre_out_3) && (squre_out_3 > squre_out_2))
						x_cent <= (x_h_max + x_right_cnt) >> 1;
				end
			end
		else	if(shape_infor == 2'd2)	begin
			x_cent <= x_num_cnt/cnt_pixel + 4'd5;
		end
		else	begin
			x_cent <= x_num_cnt/cnt_pixel;
		end
	end










always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_cent <= 10'd0;
	//else	if(vsyncd1_pos_flag)
	//	y_cent <= 10'd0;
	else	if(squre_ok)	begin
		if(shape_infor == 2'd3)
			begin
				if((x_h_max >= x_right_cnt - 4'd9)&&(x_h_max <= x_right_cnt + 4'd9)
					&&(y_h_max >= y_right_cnt - 3'd5)&&(y_h_max <= y_right_cnt + 3'd5))	begin
						if(squre_out_4 >= squre_out_1)
							y_cent <= (y_h_max + y_h_min) >> 1;
						else
							y_cent <= (y_h_max + y_left_cnt) >> 1;
					end
				else	if((x_h_max >= x_left_cnt - 4'd9) && (x_h_max <= x_left_cnt + 4'd9)
					&& (y_h_max >= y_left_cnt - 3'd5) && (y_h_max <= y_left_cnt + 3'd5))	begin
						if(squre_out_4 >= squre_out_3)
							y_cent <= (y_h_max + y_h_min) >> 1;
						else
							y_cent <= (y_h_max + y_right_cnt) >> 1;

					end
				else	begin
					if((squre_out_1 <= squre_out_2) && (squre_out_3 <= squre_out_2))
						y_cent <= (y_left_cnt + y_right_cnt ) >> 1;
					else	if((squre_out_1 > squre_out_2) && (squre_out_1 > squre_out_3))
						y_cent <= (y_left_cnt + y_h_max) >> 1;
					else	if((squre_out_1 < squre_out_3) && (squre_out_3 > squre_out_2))
						y_cent <= (y_h_max + y_right_cnt) >> 1;
					else
						y_cent <= y_num_cnt/cnt_pixel;
				end
			end
		else	begin
			y_cent <= y_num_cnt/cnt_pixel;
		end
	end

//输出朿高坐栿
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_h_max <= 10'd0;
	//else	if(vsyncd1_pos_flag)
	//	x_h_max <= 10'd0;
	else	if(cnt_pixel == 0 && din_in_d1)
		x_h_max <= x_cnt;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_h_max <= 10'd0;
	//else	if(vsyncd1_pos_flag)
	//	y_h_max <= 10'd0;
	else	if(cnt_pixel == 0 && din_in_d1)
		y_h_max <= y_cnt;

//输出朿低坐栿
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_h_min <= 10'd0;
	//else	if(vsyncd1_pos_flag)
	//	x_h_min <= 10'd0;/
	else	if(y_cnt == IMG_VDISP - 1 && x_cnt == IMG_HDISP)////////////////////////////////
		x_h_min <= x_pixel_cnt;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_h_min <= 10'd0;
	//else	if(vsyncd1_pos_flag)
	//	y_h_min <= 10'd0;
	else	if(y_cnt == IMG_VDISP - 1 && x_cnt == IMG_HDISP)///////////////////////////////
		y_h_min <= y_pixel_cnt;

//输出形状数据
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		shape_infor <= 2'd0;
	//else	if(vsyncd1_pos_flag)
	//	shape_infor <= 3'd0;
	else	if(y_cnt == IMG_VDISP - 1 && x_cnt == IMG_HDISP)////////////////////////////////
		begin
		if(cnt_pixel >= 15'd300&& cnt_pixel < 15'd1500)//三角?
			shape_infor <=2'd3 ;
		else	if(cnt_pixel >= 15'd3200 && cnt_pixel < 15'd5000)//正方?
			shape_infor <= 2'd1;
		else	if(cnt_pixel >= 15'd2550&& cnt_pixel <15'd3200)//圆形
			shape_infor <= 2'd0;
		else	if(cnt_pixel >= 15'd1500 && cnt_pixel < 15'd2550)//六边?
			shape_infor <= 2'd2;
		else
			shape_infor <=2'd0;// shape_infor;//////////////////////////////////////////11111111111222222222333333333333333444444444
		end

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		color_mode <= 1'b0;
	else	if(y_cnt == IMG_VDISP)
		if(cnt_pixel < 15'd300)
			color_mode <= 1'b1;
		else	if(cnt_pixel >=  15'd300)
			color_mode	<= 1'b0;
	else
		color_mode	<= color_mode;

always@(posedge clk or negedge rst_n)//求每丿帧图像朿左边的像素点（要求规整?
	if(rst_n == 1'b0)
		begin
			x_left_cnt <= 10'd639;
			y_left_cnt <= 10'd479;
		end
	else	if(vsyncd1_pos_flag)
		begin
			x_left_cnt <= 10'd639;
		    y_left_cnt <= 10'd479;
		end
	else	if(din_in_d1 && de_in_d1)
		begin
			if(x_cnt <= x_left_cnt)
				begin
					x_left_cnt <= x_cnt;
				    y_left_cnt <= y_cnt;
				end
		end
	else
		begin
			x_left_cnt <= x_left_cnt;
		    y_left_cnt <= y_left_cnt;

		end

always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		begin
			x_right_cnt <= 10'd0;
			y_right_cnt <= 10'd0;
		end
	else	if(vsyncd1_pos_flag)
		begin
			x_right_cnt <= 10'd0;
		    y_right_cnt <= 10'd0;
		end
	else	if(din_in_d1 && de_in_d1)
		begin
			if(x_cnt >= x_right_cnt)
				begin
					x_right_cnt	<= x_cnt;
					y_right_cnt <= y_cnt;
				end
		end
	else
		begin
			x_right_cnt	<=	x_right_cnt;
		    y_right_cnt <=  y_right_cnt;
		end
always@(posedge clk or negedge rst_n)
	if(rst_n == 1'd0)
		hrefd1_neg_flag_r <= 1'b0;
	else
		hrefd1_neg_flag_r	<= hrefd1_neg_flag;




always@(posedge clk or negedge rst_n)//朿上面与?左边的点
	if(rst_n == 1'b0)
		squre_1 <= 1'd0;
	else	if(squre_de)
		squre_1 <= ((x_h_max - x_left_cnt) * (x_h_max - x_left_cnt) + (y_left_cnt - y_h_max) * (y_left_cnt - y_h_max));
	else
		squre_1 <=	squre_1;

always@(posedge clk or negedge rst_n)//朿左边的点和?右边的点
	if(rst_n == 1'b0)
		squre_2 <= 1'd0;
	else	if(squre_de)	begin
		if(y_right_cnt >= y_left_cnt)
			squre_2	<= ((x_right_cnt - x_left_cnt) * (x_right_cnt - x_left_cnt) + (y_right_cnt - y_left_cnt) * (y_right_cnt - y_left_cnt));
		else
			squre_2	<= ((x_right_cnt - x_left_cnt) * (x_right_cnt - x_left_cnt) + (y_left_cnt - y_right_cnt) * (y_left_cnt - y_right_cnt));
	end
	else
		squre_2	<=	squre_2;
always@(posedge clk or negedge rst_n)//朿上面与?右边
	if(rst_n == 1'b0)
		squre_3 <= 1'd0;
	else	if(squre_de)	begin
			squre_3 <= ((x_right_cnt - x_h_max) * (x_right_cnt - x_h_max) + (y_h_max - y_right_cnt) * (y_h_max - y_right_cnt));
	end
	else
		squre_3 <= squre_3;

always@(posedge	clk or negedge rst_n)//朿上面朿下面
	if(rst_n == 1'b0)
		squre_4 <= 1'd0;
	else	if(squre_de)	begin
		if(x_h_max >= x_h_min)
			squre_4	<= ((x_h_max - x_h_min) * (x_h_max - x_h_min) + (y_h_min - y_h_max) * (y_h_min - y_h_max));
		else
			squre_4	<= ((x_h_min - x_h_max) * (x_h_min - x_h_max) + (y_h_min - y_h_max) * (y_h_min - y_h_max));
	end
	else
		squre_4 <= squre_4;



cordic_1 cordic_1_inst_1 (
  .aclk(clk),                                        // input wire aclk
  .aresetn(rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(squre_de_r),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(squre_1),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(squre_ok		),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(squre_out_1)              // output wire [15 : 0] m_axis_dout_tdata
);
cordic_1 cordic_1_inst_2 (
  .aclk(clk),                                        // input wire aclk
  .aresetn(rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(squre_de_r),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(squre_2),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(squre_ok_2),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(squre_out_2)              // output wire [15 : 0] m_axis_dout_tdata
);
cordic_1 cordic_1_inst_3 (
  .aclk(clk),                                        // input wire aclk
  .aresetn(rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(squre_de_r),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(squre_3),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(squre_ok_3),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(squre_out_3)              // output wire [15 : 0] m_axis_dout_tdata
);

cordic_1 cordic_1_inst_4 (
  .aclk(clk),                                        // input wire aclk
  .aresetn(rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(squre_de_r),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(squre_4),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(squre_ok_4),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(squre_out_4)              // output wire [15 : 0] m_axis_dout_tdata
);











//弿平方标志信?
always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		squre_de_r <= 1'b0;
	else
		squre_de_r <= squre_de;



//输出ramip核写使能信号

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		angle_gen_start <= 1'b0;
	else
		angle_gen_start	<= squre_ok;
//角度计算弿始标志信叿------拉高丿个时钟周朿
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		squre_de <= 1'b0;
	else	if(vsyncd1_pos_flag)
		squre_de <= 1'b0;
	//else	if(angle_gen_flag)
	//	angle_gen_start <= 1'b0;
	else	if(y_cnt == IMG_VDISP - 1 && x_cnt == IMG_HDISP)
		squre_de <= 1'b1;
	else
		squre_de <= 1'b0;

//写使?
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		ram_wr_en	<= 1'b0;
	//else	if(vsyncd1_pos_flag)
	//	ram_wr_en	<= 1'b0;
	else	if(angle_gen_flag)
		ram_wr_en	<= angle_gen_flag;

//写数?
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		ram_wr_data	<= 29'd0;
	//else	if(vsyncd1_pos_flag)
	//	ram_wr_data	<= 29'd0;
	else	if(angle_gen_flag)
		ram_wr_data	<= {(x_cent - 5'd16),(y_cent - 5'd5),angle_data};

//写地?
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		ram_wr_addr	<= 1'b0;
	else	if(vsyncd1_pos_flag)
		ram_wr_addr	<= 1'b0;
	else	if(angle_gen_flag)
		ram_wr_addr	<= 1'b1;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		pixel_area_out	<= 20'd0;
	else	if(x_cnt == IMG_HDISP - 1'd1 && y_cnt == IMG_VDISP-1'd1)
		pixel_area_out	<= cnt_pixel;
	else
		pixel_area_out	<=	pixel_area_out;




endmodule