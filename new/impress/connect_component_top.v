module	connect_component_top//图像处理顶层模块
(
	input	wire			clk				,
	input	wire			rst_n			,
	input	wire			per_frame_vsync	,
	input	wire			per_frame_href	,
	input	wire			per_frame_clken	,
	input	wire	[7:0]	per_img_Y		,
	input	wire	[7:0]	per_img_Cb		,
	input	wire	[7:0]	per_img_Cr		,

	
	output	wire			vsync_out		,
	output	wire			href_out		,
	output	wire			de_out			,
	output	wire			bin_out			,
	output	wire	[29:0]	ram_wr_data
	
);



wire			bin_vsync	;
wire			bin_href	;
wire			bin_clken	;
wire			bin_bit		;

wire			ero_vsync	;
wire			ero_href	;
wire			ero_clken	;
wire			ero_bit		;

wire			dil_vsync	;
wire			dil_href	;
wire			dil_clken	;
wire			dil_bit		;

wire			dil2_vsync	;
wire			dil2_href	;
wire			dil2_clken	;
wire			dil2_bit	;

wire			con_vsync	;
wire			con_href	;
wire			con_clken	;
wire	[23:0]	con_rgb		;

wire			rgb_vsync	;
wire			rgb_href	;
wire			rgb_clk_en	;
wire			rgb_bin		;

wire	[9:0]	x_cent		;
wire	[9:0]	y_cent	    ;
wire	[9:0]	x_h_max     ;
wire	[9:0]	y_h_max     ;
wire	[9:0]	x_h_min     ;
wire	[9:0]	y_h_min     ;
wire	[2:0]	shape_infor	;
wire			angle_gen_start;
wire			coor_href	;
wire			coor_vsync	;
wire			ram_wr_en	;
wire			ram_wr_addr	;
wire	[29:0]	ram_wr_data	;
wire			color_change;

wire	[9:0]	angle_data	;
wire			angle_gen_flag;



binarization	binarization_inst
(
    .clk            	(clk   ),   // 时钟信号
    .rst_n          	(rst_n ),   // 复位信号（低有效）

	.per_frame_vsync	(per_frame_vsync	),
	.per_frame_href 	(per_frame_href		),	
	.per_frame_clken	(per_frame_clken	),
	.per_img_Y  		(per_img_Y			),
	.per_img_Cb			(per_img_Cb			),
	.per_img_Cr			(per_img_Cr			),
	.key_color			(color_change),//传入的切换颜色数据

	.post_frame_vsync	(bin_vsync	),	
	.post_frame_href 	(bin_href	),	
	.post_frame_clken	(bin_clken	),	
	.post_img_Bit  		(bin_bit	)		


);

















////腐蚀 --------->二级膨胀
dilation
#(
	.IMG_HDISP (10'd640) ,	//640*480
	.IMG_VDISP (10'd480) 
)dilation_inst
(
	//global clock
	.clk				(clk),  				//cmos video pixel clock
	.rst_n				(rst_n),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync	(ero_vsync		),	//Prepared Image data vsync valid signal                     //bin_vsync	
	.per_frame_href		(ero_href		),		//Prepared Image data href vaild  signal                 //bin_href	
	.per_frame_clken	(ero_clken		),	//Prepared Image data output/capture enable clock            //bin_clken	
	.per_img_Bit		(ero_bit		),		//Prepared Image Bit flag outout(1: Value, 0:inValid)	 //bin_bit	
	
	//Image data has been processd
	.post_frame_vsync	(	dil_vsync	),	//Processed Image data vsync valid signal                   //dil_vsync	
	.post_frame_href	(	dil_href	),	//Processed Image data href vaild  signal                   //dil_href	
	.post_frame_clken	(	dil_clken	),	//Processed Image data output/capture enable clock          //dil_clken	
	.post_img_Bit		(	dil_bit		)//Processed Image Bit flag outout(1: Value, 0:inValid)		//dil_bit	
);
//
////闭运箿
////二忼化 ------->丿级腐蚿
erosion
#(
	.IMG_HDISP (10'd640) ,	//640*480
	.IMG_VDISP (10'd480) 
)erosion_inst
(
	//global clock
	.clk				(clk),  				//cmos video pixel clock
	.rst_n				(rst_n),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync	(bin_vsync		),	//Prepared Image data vsync valid signal                    //dil_vsync	
	.per_frame_href		(bin_href		),		//Prepared Image data href vaild  signal                //dil_href	
	.per_frame_clken	(bin_clken		),	//Prepared Image data output/capture enable clock           //dil_clken	
	.per_img_Bit		(bin_bit		),		//Prepared Image Bit flag outout(1: Value, 0:inValid)	//dil_bit	
	
	//Image data has been processd
	.post_frame_vsync	(	ero_vsync		),	//Processed Image data vsync valid signal                   //ero_vsync	
	.post_frame_href	(	ero_href		),	//Processed Image data href vaild  signal                   //ero_href	
	.post_frame_clken	(	ero_clken		),	//Processed Image data output/capture enable clock          //ero_clken	
	.post_img_Bit		(	ero_bit				)//Processed Image Bit flag outout(1: Value, 0:inValid)	//ero_bit	
);
//
//











//连通域算法输出标签为1的物体
connect_8_area
#(
	.IMG_WIDTH 		(640) ,
	.IMG_HEIGHT 	(480) ,
	.LABEL_BITS  	(4	) ,
	.BACK_NUM		(1) 	
)connect_8_area_inst
(
	.clk			(clk			),
	.rst_n			(rst_n			),
	.href_in		(dil_href	),//腐蚀后的图像数据
	.vsync_in		(dil_vsync	),
	.de_in			(dil_clken		),
	.pixel_in		(dil_bit		),

	.href_out		(href_out),
	.vsync_out		(vsync_out),
	.de_out			(de_out),
	.bin_out        (bin_out)

);
//
//质心坐标计算模块
coordinate_centroid//质心坐标计算模块
#(
	.IMG_HDISP (10'd640) ,
	.IMG_VDISP (10'd480) 
)coordinate_centroid_inst
(
	.clk				(clk),
	.rst_n				(rst_n),
	.href_in			(href_out),
	.vsync_in			(vsync_out),//取反输入
	.de_in				(de_out),
	.din_in				(bin_out),
	.angle_data			(angle_data),
	.angle_gen_flag		(angle_gen_flag),

	.x_cent				(x_cent		),//质心坐标
	.y_cent				(y_cent	    ),
	.x_h_max			(x_h_max     ),//最高点坐标
	.y_h_max			(y_h_max     ),
	.x_h_min			(x_h_min     ),//最低点坐标
	.y_h_min			(y_h_min     ),
	.shape_infor		(shape_infor),	//四种形状信息
	.ram_wr_en			(ram_wr_en),
	.ram_wr_addr		(ram_wr_addr),
	.ram_wr_data		(ram_wr_data),
	.color_change		(color_change),	//颜色标志信号
	.angle_gen_start	(angle_gen_start),//角度开始计算标志信号
	.href_out			(coor_href	),
	.vsync_out		    (coor_vsync	)
);

angle_find	angle_find_inst		//坐标角度转换模块
(
	.clk				(clk),
	.rst_n				(rst_n),
	.x_cent				(x_cent),//质心
	.y_cent				(y_cent),
	.x_h_max			(x_h_max),//最高点
	.y_h_max			(y_h_max),
	.x_h_min			(x_h_min),//最低点
	.y_h_min			(y_h_min),
	.shape_infor		(shape_infor),
	.angle_gen_start	(angle_gen_start),//角度开始计算标志信号
	.href_in			(coor_href),
	.vsync_in			(coor_vsync),

	.angle_data			(angle_data),//角度数据
	.angle_gen_flag     (angle_gen_flag)

);




endmodule