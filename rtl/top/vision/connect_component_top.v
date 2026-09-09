module	connect_component_top//用于仿真版顶层代?
(
	input	wire			clk				,
	input	wire			rst_n			,
	input	wire			per_frame_vsync	,
	input	wire			per_frame_href	,
	input	wire			per_frame_clken	,
	input	wire	[7:0]	per_img_Y		,
	input	wire	[7:0]	per_img_Cb		,
	input	wire	[7:0]	per_img_Cr		,
	input	wire			change_in		,
	input	wire			key_color		,
	input	wire			key_mode		,
	input	wire			key_ycbcr		,
	input	wire			key_add_div		,

	output	wire	[2:0]	ycbcr_led		,
	output	wire			mode_led		,
	output	wire	[19:0]	seg_data		,
	output	wire	[1:0]	color			,
	output	wire	[1:0]	shape_infor		,

	output	wire			ram_wr_en		,
	output	wire	[28:0]	ram_wr_data		,
	output	wire			vsync_out		,
	output	wire			href_out		,
	output	wire			de_out			,
	output	wire			bin_out

);

wire			bin_vsync	;
wire			bin_href	;
wire			bin_clken	;
wire			bin_bit		;

wire			ero_vsync	;
wire			ero_href	;
wire			ero_clken	;
wire			ero_bit		;

wire			ero1_vsync	;
wire			ero1_href	;
wire			ero1_clken	;
wire			ero1_bit	;

wire			ero2_vsync	;
wire			ero2_href	;
wire			ero2_clken	;
wire			ero2_bit	;

wire			ero3_vsync	;
wire			ero3_href	;
wire			ero3_clken	;
wire			ero3_bit	;







wire			dil_vsync	;
wire			dil_href	;
wire			dil_clken	;
wire			dil_bit		;

wire			dil2_vsync	;
wire			dil2_href	;
wire			dil2_clken	;
wire			dil2_bit	;

wire			dil3_vsync	;
wire			dil3_href	;
wire			dil3_clken	;
wire			dil3_bit	;

wire			dil4_vsync	;
wire			dil4_href	;
wire			dil4_clken	;
wire			dil4_bit	;

//连通域算法后的后处理
//				腐蚀					//
wire			ero4_vsync	;
wire			ero4_href	;
wire			ero4_clken	;
wire			ero4_bit	;


//				膨胀					//
wire			dil5_vsync	;
wire			dil5_href	;
wire			dil5_clken	;
wire			dil5_bit	;







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
//wire	[2:0]	shape_infor	;
wire			angle_gen_start;
wire			coor_href	;
wire			coor_vsync	;
wire			ram_wr_addr	;
wire			color_change;
wire	[19:0]	pixel_area_out;

wire	[8:0]	angle_data	;
wire			angle_gen_flag;
wire			color_mode	;


reg		[1:0]	xyd_num_cnt	;


wire	connect_href_out	;
wire	connect_vsync_out	;
wire	connect_de_out		;
wire	connect_bin_out     ;


//color_bin	color_bin_inst
//(
//	.clk				(clk),
//	.rst_n				(rst_n),
//	.per_frame_vsync	(per_frame_vsync),
//    .per_frame_href 	(per_frame_href	),
//    .per_frame_clken	(per_frame_clken),
//    .per_img_Y  		(per_img_Y		),
//    .per_img_Cb			(per_img_Cb		),
//    .per_img_Cr			(per_img_Cr		),
//
//    .post_frame_vsync	(bin_vsync	),
//    .post_frame_href 	(bin_href	),
//    .post_frame_clken	(bin_clken	),
//    .post_img_Bit  	(bin_bit	)
//
//);
//color_bin	color_bin_inst
//(
//    .clk            	(clk	),   // 时钟信号
//    .rst_n          	(rst_n	),   // 复位信号（低有效?
//
//	.per_frame_vsync	(per_frame_vsync),
//	.per_frame_href 	(per_frame_href ),
//	.per_frame_clken	(per_frame_clken),
//	.per_img_Y  		(per_img_Y  	),
//	.per_img_Cb			(per_img_Cb		),
//	.per_img_Cr			(per_img_Cr		),
//	.key_color			(key_color		),
//
//	.post_frame_vsync	(bin_vsync	),
//	.post_frame_href 	(bin_href	),
//	.post_frame_clken	(bin_clken	),
//	.post_img_Bit  		(bin_bit	),
//	.color		        (color		        )
//
//);

//color_bin	color_bin(
//    .clk            	(clk	),   // 时钟信号
//    .rst_n          	(rst_n	),   // 复位信号（低有效?
//
//	.per_frame_vsync	(per_frame_vsync),
//	.per_frame_href 	(per_frame_href ),
//	.per_frame_clken	(per_frame_clken),
//	.per_img_Y  		(per_img_Y  ),
//	.per_img_Cb			(per_img_Cb	),
//	.per_img_Cr			(per_img_Cr	),
//	.key_color			(key_color),
//	.color_mode			(color_mode),
//
//	.post_frame_vsync	(bin_vsync	),
//	.post_frame_href 	(bin_href	),
//	.post_frame_clken	(bin_clken	),
//	.post_img_Bit  		(bin_bit	),
//	.color		        (color		)
//
//);
color_bin	color_bin_inst
(
	.clk				(clk		),
	.rst_n				(rst_n		),
	.per_frame_vsync	(per_frame_vsync),
    .per_frame_href 	(per_frame_href ),
    .per_frame_clken	(per_frame_clken),
    .per_img_Y  		(per_img_Y  ),
    .per_img_Cb			(per_img_Cb	),
    .per_img_Cr			(per_img_Cr	),
	//input	wire			color_change	,
	.key_color			(key_color	),//娑�?娑擃亝妞傞柦鐔锋噯閺堢喖鐝悽闈涢挬
	.key_mode			(key_mode	),
	.key_ycbcr			(key_ycbcr	),
	.key_add_div		(key_add_div),
	.change_in			(change_in	),
	.color_mode			(color_mode	),

	.color				(color		),
	.seg_data			(seg_data	),
    .post_frame_vsync	(bin_vsync	),
    .post_frame_href 	(bin_href	),
    .post_frame_clken	(bin_clken	),
    .post_img_Bit  		(bin_bit	),
	.ycbcr_led			(ycbcr_led	),	//缂佹垵鐣炬稉宥呮倱閻ㄥ埐ed
	.mode_led		    (mode_led	)
);

erosion_7x7
#(
	.IMG_HDISP (10'd640) ,	//640*480
	.IMG_VDISP (10'd480)
)erosion_inst
(
	//global clock
	.clk				(clk				),  				//cmos video pixel clock
	.rst_n				(rst_n				),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync	(bin_vsync			),	//Prepared Image data vsync valid signal
	.per_frame_href		(bin_href			),		//Prepared Image data href vaild  signal
	.per_frame_clken	(bin_clken			),	//Prepared Image data output/capture enable clock
	.per_img_Bit		(bin_bit			),		//Prepared Image Bit flag outout(1: Value, 0:inValid)

	//Image data has been processd
	.post_frame_vsync	(ero_vsync			),	//Processed Image data vsync valid signal
	.post_frame_href	(ero_href			),	//Processed Image data href vaild  signal
	.post_frame_clken	(ero_clken			),	//Processed Image data output/capture enable clock
	.post_img_Bit		(ero_bit			)	//Processed Image Bit flag outout(1: Value, 0:inValid)
);

erosion_7x7
#(
	.IMG_HDISP (10'd640) ,	//640*480
	.IMG_VDISP (10'd480)
)erosion_inst_1
(
	//global clock
	.clk				(clk				),  				//cmos video pixel clock
	.rst_n				(rst_n				),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync	(ero_vsync	),	//Prepared Image data vsync valid signal
	.per_frame_href		(ero_href	),		//Prepared Image data href vaild  signal
	.per_frame_clken	(ero_clken	),	//Prepared Image data output/capture enable clock
	.per_img_Bit		(ero_bit	),		//Prepared Image Bit flag outout(1: Value, 0:inValid)

	//Image data has been processd
	.post_frame_vsync	(ero1_vsync	),	//Processed Image data vsync valid signal
	.post_frame_href	(ero1_href	),	//Processed Image data href vaild  signal
	.post_frame_clken	(ero1_clken	),	//Processed Image data output/capture enable clock
	.post_img_Bit		(ero1_bit	)	//Processed Image Bit flag outout(1: Value, 0:inValid)
);

erosion
#(
	.IMG_HDISP (10'd640) ,	//640*480
	.IMG_VDISP (10'd480)
)erosion_inst_2
(
	//global clock
	.clk				(clk				),  				//cmos video pixel clock
	.rst_n				(rst_n				),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync	(ero1_vsync	),	//Prepared Image data vsync valid signal
	.per_frame_href		(ero1_href	),		//Prepared Image data href vaild  signal
	.per_frame_clken	(ero1_clken	),	//Prepared Image data output/capture enable clock
	.per_img_Bit		(ero1_bit	),		//Prepared Image Bit flag outout(1: Value, 0:inValid)

	//Image data has been processd
	.post_frame_vsync	(ero2_vsync	),	//Processed Image data vsync valid signal
	.post_frame_href	(ero2_href	),	//Processed Image data href vaild  signal
	.post_frame_clken	(ero2_clken	),	//Processed Image data output/capture enable clock
	.post_img_Bit		(ero2_bit	)	//Processed Image Bit flag outout(1: Value, 0:inValid)
);

dilation
#(
	.IMG_HDISP (10'd640) ,	//640*480
	.IMG_VDISP (10'd480)
)dilation_inst
(
	//global clock
	.clk				(clk				),  				//cmos video pixel clock
	.rst_n				(rst_n				),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync	(ero2_vsync			),	//Prepared Image data vsync valid signal
	.per_frame_href		(ero2_href			),		//Prepared Image data href vaild  signal
	.per_frame_clken	(ero2_clken			),	//Prepared Image data output/capture enable clock
	.per_img_Bit		(ero2_bit			),		//Prepared Image Bit flag outout(1: Value, 0:inValid)

	//Image data has been processd
	.post_frame_vsync	(dil_vsync		),	//Processed Image data vsync valid signal//////腐蚀 --------->二级膨胀
	.post_frame_href	(dil_href			),	//Processed Image data href vaild  signal//dilation
	.post_frame_clken	(dil_clken			),	//Processed Image data output/capture enable clock//#(
	.post_img_Bit		(dil_bit			)	//Processed Image Bit flag outout(1: Value, 0:inValid)//	.IMG_HDISP (10'd640) ,	//640*480//////腐蚀 --------->二级膨胀
);//	.IMG_VDISP (10'd480) //dilation
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)dilation_inst
//(
//	//global clock
//	.clk				(clk				),  				//cmos video pixel clock
//	.rst_n				(rst_n				),				//global reset
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(ero_vsync			),	//Prepared Image data vsync valid signal
//	.per_frame_href		(ero_href			),		//Prepared Image data href vaild  signal
//	.per_frame_clken	(ero_clken			),	//Prepared Image data output/capture enable clock
//	.per_img_Bit		(ero_bit			),		//Prepared Image Bit flag outout(1: Value, 0:inValid)
//
//	//Image data has been processd
//	.post_frame_vsync	(	dil_vsync		),	//Processed Image data vsync valid signal
//	.post_frame_href	(dil_href			),	//Processed Image data href vaild  signal
//	.post_frame_clken	(dil_clken			),	//Processed Image data output/capture enable clock
//	.post_img_Bit		(dil_bit			)	//Processed Image Bit flag outout(1: Value, 0:inValid)
//);
//
//////闭运?
//////二忼? ------->丿级腐蚿
//erosion
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)erosion_inst
//(
//	//global clock
//	.clk				(clk				),  				//cmos video pixel clock
//	.rst_n				(rst_n				),				//global reset
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(bin_vsync			),	//Prepared Image data vsync valid signal
//	.per_frame_href		(bin_href			),		//Prepared Image data href vaild  signal
//	.per_frame_clken	(bin_clken			),	//Prepared Image data output/capture enable clock
//	.per_img_Bit		(bin_bit			),		//Prepared Image Bit flag outout(1: Value, 0:inValid)
//
//	//Image data has been processd
//	.post_frame_vsync	(ero_vsync			),	//Processed Image data vsync valid signal
//	.post_frame_href	(ero_href			),	//Processed Image data href vaild  signal
//	.post_frame_clken	(ero_clken			),	//Processed Image data output/capture enable clock
//	.post_img_Bit		(ero_bit			)	//Processed Image Bit flag outout(1: Value, 0:inValid)
//);
////
////
//
////第二层腐?//
//erosion
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)erosion_inst_2
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(dil_vsync			),
//	.per_frame_href		(dil_href			),
//	.per_frame_clken	(dil_clken			),
//	.per_img_Bit		(dil_bit			),
//
//	//Image data has been processd//
//	.post_frame_vsync	(ero1_vsync			),	////dilation
//	.post_frame_href	(ero1_href			),	////#(
//	.post_frame_clken	(ero1_clken			),	////	.IMG_HDISP (10'd320) ,	//640*480
//	.post_img_Bit		(ero1_bit			)	////	.IMG_VDISP (10'd240)
//);
//
////第二层膨?
//
//
//dilation
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)dilation_inst_1
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(ero1_vsync			),
//	.per_frame_href		(ero1_href			),
//	.per_frame_clken	(ero1_clken			),
//	.per_img_Bit		(ero1_bit			),
//
//	//Image data has been processd
//	.post_frame_vsync	(dil2_vsync			),
//	.post_frame_href	(dil2_href			),
//	.post_frame_clken	(dil2_clken			),
//	.post_img_Bit		(dil2_bit			)
//);
//
////第三层腐?//
//erosion
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)erosion_inst_3
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(dil2_vsync			),
//	.per_frame_href		(dil2_href			),
//	.per_frame_clken	(dil2_clken			),
//	.per_img_Bit		(dil2_bit			),
//
//	//Image data has been processd//
//	.post_frame_vsync	(ero2_vsync			),	////dilation
//	.post_frame_href	(ero2_href			),	////#(
//	.post_frame_clken	(ero2_clken			),	////	.IMG_HDISP (10'd320) ,	//640*480
//	.post_img_Bit		(ero2_bit			)	////	.IMG_VDISP (10'd240)
//);
//
////第三层膨?//
//dilation
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)dilation_inst_2
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(ero2_vsync			),
//	.per_frame_href		(ero2_href			),
//	.per_frame_clken	(ero2_clken			),
//	.per_img_Bit		(ero2_bit			),
//
//	//Image data has been processd
//	.post_frame_vsync	(dil3_vsync			),
//	.post_frame_href	(dil3_href			),
//	.post_frame_clken	(dil3_clken			),
//	.post_img_Bit		(dil3_bit			)
//);
//
////第四层腐?//
//erosion
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)erosion_inst_4
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(dil3_vsync			),
//	.per_frame_href		(dil3_href			),
//	.per_frame_clken	(dil3_clken			),
//	.per_img_Bit		(dil3_bit			),
//
//	//Image data has been processd//
//	.post_frame_vsync	(ero3_vsync			),	////dilation
//	.post_frame_href	(ero3_href			),	////#(
//	.post_frame_clken	(ero3_clken			),	////	.IMG_HDISP (10'd320) ,	//640*480
//	.post_img_Bit		(ero3_bit			)	////	.IMG_VDISP (10'd240)
//);
//
////第四层膨?//
//dilation
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)dilation_inst_3
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(ero3_vsync			),
//	.per_frame_href		(ero3_href			),
//	.per_frame_clken	(ero3_clken			),
//	.per_img_Bit		(ero3_bit			),
//
//	//Image data has been processd
//	.post_frame_vsync	(dil4_vsync			),
//	.post_frame_href	(dil4_href			),
//	.post_frame_clken	(dil4_clken			),
//	.post_img_Bit		(dil4_bit			)
//);
















connect_8_area
#(
	.IMG_WIDTH 		(640) ,
	.IMG_HEIGHT 	(480) ,
	.LABEL_BITS  	(4	) ,
	.BACK_NUM		(1)
)connect_8_area_inst
(
	.clk			(clk				),
	.rst_n			(rst_n				),
	.href_in		(dil_href			),
	.vsync_in		(dil_vsync			),
	.de_in			(dil_clken			),
	.pixel_in		(dil_bit			),

	.href_out		(href_out			),
	.vsync_out		(vsync_out			),
	.de_out			(de_out				),
	.bin_out        (bin_out	 		)

);

////后处理-------腐蚀
//erosion
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)erosion_inst_5
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(connect_vsync_out			),
//	.per_frame_href		(connect_href_out			),
//	.per_frame_clken	(connect_de_out				),
//	.per_img_Bit		(connect_bin_out     		),
//
//	//Image data has been processd//
//	.post_frame_vsync	(ero4_vsync			),	////dilation
//	.post_frame_href	(ero4_href			),	////#(
//	.post_frame_clken	(ero4_clken			),	////	.IMG_HDISP (10'd320) ,	//640*480
//	.post_img_Bit		(ero4_bit			)	////	.IMG_VDISP (10'd240)
//);
//
////后处理膨胀
//dilation
//#(
//	.IMG_HDISP (10'd640) ,	//640*480
//	.IMG_VDISP (10'd480)
//)dilation_inst_5
//(
//	//global clock
//	.clk				(clk				),
//	.rst_n				(rst_n				),
//
//	//Image data prepred to be processd
//	.per_frame_vsync	(ero4_vsync			),
//	.per_frame_href		(ero4_href			),
//	.per_frame_clken	(ero4_clken			),
//	.per_img_Bit		(ero4_bit			),
//
//	//Image data has been processd
//	.post_frame_vsync	(vsync_out			),
//	.post_frame_href	(href_out			),
//	.post_frame_clken	(de_out				),
//	.post_img_Bit		(bin_out			)
//);








//
//质心坐标计算模块
//coordinate_centroid//质心坐标计算模块
//#(
//	.IMG_HDISP (10'd640) ,
//	.IMG_VDISP (10'd480)
//)coordinate_centroid_inst11
//(
//	.clk				(clk			),
//	.rst_n				(rst_n			),
//	.href_in			(href_out		),
//	.vsync_in			(vsync_out		),//取反输入
//	.de_in				(de_out			),
//	.din_in				(bin_out		),
//	.angle_data			(angle_data		),
//	.angle_gen_flag		(angle_gen_flag	),
//
//	.x_cent				(x_cent			),//质心坐标
//	.y_cent				(y_cent	    	),
//	.x_h_max			(x_h_max     	),//?高点坐标
//	.y_h_max			(y_h_max     	),
//	.x_h_min			(x_h_min     	),//?低点坐标
//	.y_h_min			(y_h_min     	),
//	.shape_infor		(shape_infor	),	//四种形状信息
//	.ram_wr_en			(ram_wr_en		),
//	.ram_wr_addr		(ram_wr_addr	),
//	.ram_wr_data		(ram_wr_data	),
//	.color_change		(color_change	),	//颜色标志信号
//	.angle_gen_start	(angle_gen_start),//角度?始计算标志信?
//	.href_out			(coor_href		),
//	.vsync_out		    (coor_vsync		),
//	.pixel_area_out		(pixel_area_out	)
//);


coordinate_centroid//质心坐标计算模块
#(
	.IMG_HDISP (10'd640) ,
	.IMG_VDISP (10'd480)
)coordinate_centroid_inst11
(
	.clk				(clk		),
	.rst_n				(rst_n		),
	.href_in			(href_out	),
	.vsync_in			(vsync_out	),//取反输入
	.de_in				(de_out		),
	.din_in				(bin_out	),

	.angle_data			(angle_data		),
	.angle_gen_flag		(angle_gen_flag	),


	.x_cent				(x_cent			),//质心坐标
	.y_cent				(y_cent	    	),
	.x_h_max			(x_h_max     	),//朿高点坐?
	.y_h_max			(y_h_max     	),
	.x_h_min			(x_h_min     	),//朿低点坐?
	.y_h_min			(y_h_min     	),
	//output	reg				ram_rd_en	,
	.shape_infor		(shape_infor	),	//四种形状信息
	.ram_wr_en			(ram_wr_en		),
	.ram_wr_addr		(ram_wr_addr	),
	.ram_wr_data		(ram_wr_data	),
	.color_mode			(color_mode		),
	//output	reg				color_change	,	//颜色标志信号
	.angle_gen_start	(angle_gen_start),//角度弿始计算标志信叿
	.href_out			(coor_href		),
	.vsync_out			(coor_vsync		),
	.pixel_area_out	    (pixel_area_out	)
);



















angle_find	angle_find_inst		//坐标角度转换模块
(
	.clk				(clk			),
	.rst_n				(rst_n			),
	.x_cent				(x_cent			),
	.y_cent				(y_cent			),
	.x_h_max			(x_h_max		),
	.y_h_max			(y_h_max		),
	.x_h_min			(x_h_min		),
	.y_h_min			(y_h_min		),
	.shape_infor		(shape_infor	),
	.angle_gen_start	(angle_gen_start),
	.href_in			(coor_href		),
	.vsync_in			(coor_vsync		),//低电平有?

	.angle_data			(angle_data		),
	.angle_gen_flag     (angle_gen_flag	)
);




endmodule