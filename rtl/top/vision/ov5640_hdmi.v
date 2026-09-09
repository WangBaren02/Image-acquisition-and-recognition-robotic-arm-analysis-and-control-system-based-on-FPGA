`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// 实验平台: 野火FPGA系列弿发?
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  ov5640_hdmi
(
    input   wire            sys_clk     	,  //系统时钟
    input   wire            sys_rst_n   	,  //系统复位，低电平有效
//摄像头接?
    input   wire            cam1_pclk 		,  //摄像头数据像素时?
    input   wire            cam1_vsync		,  //摄像头场同步信号
    input   wire            cam1_href 		,  //摄像头行同步信号
    input   wire    [7:0]   cam1_data 		,  //摄像头数?
    output  wire            cam_rst_n		,  //摄像头复位信号，低电平有?
    output  wire            cam_pwdn 		,  //摄像头时钟鿉择信?
    output  wire            sccb1_scl    	,  //摄像头SCCB_SCL?
    inout   wire            sccb1_sda    	,  //摄像头SCCB_SDA?

//DDR3接口
    inout [31:0]       ddr3_dq		,
    inout [3:0]        ddr3_dqs_n	,
    inout [3:0]        ddr3_dqs_p	,
    output [14:0]      ddr3_addr	,
    output [2:0]       ddr3_ba		,
    output             ddr3_ras_n	,
    output             ddr3_cas_n	,
    output             ddr3_we_n	,
    output             ddr3_reset_n	,
    output [0:0]       ddr3_ck_p	,
    output [0:0]       ddr3_ck_n	,
    output [0:0]       ddr3_cke		,
    output [0:0]       ddr3_cs_n	,
    output [3:0]       ddr3_dm		,
    output [0:0]       ddr3_odt		,


    output  wire            ddc_scl     ,
    output  wire            ddc_sda     ,
    output  wire            tmds_clk_p  ,
    output  wire            tmds_clk_n  ,   //HDMI时钟差分信号
    output  wire    [2:0]   tmds_data_p ,
    output  wire    [2:0]   tmds_data_n ,   //HDMI图像差分信号

//spi
    input    wire         spi_scl         ,
    input    wire         spi_mosi        ,
    output   wire         spi_miso        ,
    input    wire         spi_sel         ,

	input	wire			color_in		,
	input	wire			mode_in			,
	input	wire			ycbcr_in		,
	input	wire			add_div_in		,

	output	wire		[5:0]	sel		,
	output	wire		[7:0]	seg		,

	output	wire	[2:0]	ycbcr_led		,
	output	wire			mode_led		,
    input   wire          change_in       ,
    output  wire  [1:0]   color           ,
    output  wire  [1:0]   shape
    //output  wire          ram_wr_en
);
////////////////////////////////////////
    wire            spi_done	;
    wire            spi_start	;
	wire	[28:0]	ram_wr_data	;
    wire    [31:0]  Din			;
	wire          ram_wr_en 	;
	wire	[19:0]	seg_data	;

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//


//wire	key_color	;
//wire    key_mode	;
//wire    key_ycbcr	;
//wire    key_add_div	;


//parameter define
parameter   H_PIXEL     =   24'd640 ;   //水平方向像素个数
parameter   V_PIXEL     =   24'd480 ;   //垂直方向像素个数

//wire  define

wire            clk_25m         ;   //24mhz时钟,提供给摄像头驱动时钟
wire            clk_125m        ;
wire            rst_n           ;   //复位信号
wire            cfg_done        ;   //摄像头初始化完成
wire            wr_en           ;   //sdram写使?
wire   [15:0]   wr_data         ;   //sdram写数?
wire            rd_en           ;   //sdram读使?
wire   [15:0]   rd_data         ;   //sdram读数?
//wire      rd_data         ;   //sdram读数?

wire            sys_init_done   ;   //系统初始化完?
wire            c3_calib_done  	;   //DDR3初始化完?
wire            c3_clk0			;
wire            c3_rst0			;
wire    [15:0]  rgb				;

wire [15:0]cam_out	;                 //摄像头输出数?
wire [7:0] Red		;                     //分解的RGB
wire [7:0] Green	;
wire [7:0] Blue		;

wire [7:0]ycbcr_y	;                  //转换后的YCC色域数据
wire [7:0]ycbcr_cb	;
wire [7:0]ycbcr_cr	;

//
wire	ov5640_af_vsync	;
wire	ov5640_af_href	;

wire	ycbcr_vsync		;
wire	ycbcr_href		;
wire	ycbcr_de		;
wire	[7:0]	img_y	;
wire	[7:0]	img_cb	;
wire	[7:0]	img_cr	;

wire		vsync_out	;
wire		href_out	;
wire		de_out		;
wire		bin_out		;
//wire	[19:0]	seg_data;
//数据输出
//wire	[1:0]	color		;	//颜色 红色 0 黄色1 蓝色2 黑色3
//wire	[1:0]	shape_infor	;	//三角?0 正方?1 圆形2 六边?3
//wire			ram_wr_en	;	//读取标志信号
	//前十位是x 中间十位y 后九位角?

//wire	key_color;

wire	locked2	;
wire	clk_120m	;





wire			key_color	;
wire			key_mode	;
wire			key_ycbcr	;
wire			key_add_div	;
//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//系统初始化完?
assign sys_init_done =c3_calib_done & cfg_done & locked1&locked2;
//rst_n:复位信号(sys_rst_n & locked)
assign  rst_n = sys_rst_n & c3_calib_done & locked;

//ov5640_rst_n:摄像头复?,固定高电?
assign  cam_rst_n = 1'b1;

//ov5640_pwdn
assign  cam_pwdn = 1'b0;


 SPI_slave
   #(
       .width                      (32)
   )
   SPI_slave_inst
   (
       .clk                        (clk_120m)   ,   //120M
       .rst_n                      (rst_n) ,

       .spi_scl                    (spi_scl),
       .spi_sdi                    (spi_mosi),
       .spi_sdo                    (spi_miso),
       .spi_sel                    (spi_sel),

       .Din                        (Din),
       .Dout                       (Dout),
       .Data_begin                 (spi_start),
       .Data_end                   (spi_done)
   );

    assign Din = {ram_wr_data,3'b0};





clk_wiz_0 clk_wiz_0_inst
(
    // Clock out ports
    .clk_out1   (clk_320m   ),
    // Status and control signals
    .reset      (~sys_rst_n ),
    .locked     (locked     ),
    // Clock in ports
    .clk_in1    (sys_clk    )
);

clk_wiz_1 clk_wiz_1_inst
(
    // Clock out ports
    .clk_out1   (clk_125m   ),
    .clk_out2   (clk_25m    ),
    // Status and control signals
    .reset      (~sys_rst_n ),
    .locked     (locked1    ),
    // Clock in ports
    .clk_in1    (sys_clk    )
);
//pll 120MHZ
 clk_wiz_2 clk_wiz_2_inst
  (
   // Clock out ports
   .clk_120M(clk_120m),     // output clk_120M
   // Status and control signals
   .reset(~sys_rst_n), // input reset
   .locked(locked2),       // output locked
  // Clock in ports
   .clk_50M(sys_clk)
	);




//------------- ov5640_top_inst -------------
ov5640_top  ov5640_top_inst(

    .sys_clk         (clk_25m       ),   //系统时钟
    .sys_rst_n       (sys_rst_n     ),   //复位信号
    .sys_init_done   (sys_init_done ),   //系统初始化完?

    .ov5640_pclk     (cam1_pclk   ),   //摄像头像素时?
    .ov5640_href     (cam1_href   ),   //摄像头行同步信号
    .ov5640_vsync    (cam1_vsync  ),   //摄像头场同步信号
    .ov5640_data     (cam1_data   ),   //摄像头图像数?

    .cfg_done        (cfg_done      ),   //寄存器配置完?
    .sccb_scl        (sccb1_scl      ),   //SCL
    .sccb_sda        (sccb1_sda      ),   //SDA
    .ov5640_wr_en    (wr_en         ),   //图像数据有效使能信号
    .ov5640_data_out (cam_out       ),    //图像数据
	.ov5640_af_vsync	(ov5640_af_vsync),
	.ov5640_af_href	    (ov5640_af_href)
);

//------------- 图像二忼? -------------
assign Red={cam_out[15:11],3'd0};       //提取RGB三原?
assign Green={cam_out[10:5],2'd0};
assign Blue={cam_out[4:0],3'd0};

//rgb2yuv rgb2yuv_inst(                   //色域转换
//    .Red     (Red       ),
//    .Green   (Green     ),
//    .Blue    (Blue      ),
//
//    .ycbcr_y (ycbcr_y   ),
//    .ycbcr_cb(ycbcr_cb  ),
//    .ycbcr_cr(ycbcr_cr  )
//);

//按键消抖总模? 不接像素时钟
//key_filiter_top key_filiter_top_inst
//(
//	.clk			(sys_clk	),//系统时钟
//	.rst_n			(sys_rst_n	),//系统复位
//	.change_in		(change_in	),
//
//
//    .key_change		(key_color	)
//);

key_filiter_top	key_filiter_top_inst
(
	.clk			(sys_clk),
	.rst_n			(sys_rst_n),
	.color_in		(color_in	),
	.mode_in		(mode_in	),
	.ycbcr_in		(ycbcr_in	),
	.add_div_in		(add_div_in	),


    .key_color		(key_color	),
	.key_mode		(key_mode	),
	.key_ycbcr		(key_ycbcr	),
	.key_add_div	(key_add_div)

);








rgb2ycbcr	rgb2ycbcr_inst
(
    //module clock
    .clk             	(cam1_pclk		),   // 模块驱动时钟
    .rst_n           	(rst_n			),   // 复位信号

    //图像处理前的数据接口
   .pre_frame_vsync 	(ov5640_af_vsync),   // vsync信号
   .pre_frame_hsync 	(ov5640_af_href	),   // hsync信号
   .pre_frame_de    	(wr_en),   // data enable信号
   .img_red         	(cam_out[15:11]	),   // 输入图像数据R
   .img_green       	(cam_out[10:5]	),   // 输入图像数据G
   .img_blue        	(cam_out[4:0]	),   // 输入图像数据B

    //图像处理后的数据接口
    .post_frame_vsync	(ycbcr_vsync	),   // vsync信号
    .post_frame_hsync	(ycbcr_href		),   // hsync信号
    .post_frame_de   	(ycbcr_de		),   // data enable信号
    .img_y           	(img_y 			),   // 输出图像Y数据
    .img_cb          	(img_cb			),   // 输出图像Cb数据
    .img_cr             (img_cr			) // 输出图像Cr数据
);





//connect_component_top	connect_component_top_inst//用于仿真版顶层代?
//(
//	.clk				(cam1_pclk		),
//	.rst_n				(rst_n			),
//	.per_frame_vsync	(ycbcr_vsync	),
//	.per_frame_href		(ycbcr_href		),
//	.per_frame_clken	(ycbcr_de		),
//	.per_img_Y			(img_y			),
//	.per_img_Cb			(img_cb			),
//	.per_img_Cr			(img_cr			),
//	.key_color			(change_in		),
//
//	.color				(color			),
//	.shape_infor		(shape	        ),
//	.ram_wr_en			(ram_wr_en		),
//	.ram_wr_data		(ram_wr_data	),
//	.vsync_out			(vsync_out		),
//	.href_out			(href_out		),
//	.de_out				(de_out			),
//	.bin_out			(bin_out		)
//
//);
connect_component_top	connect_component_top_inst//用于仿真版顶层代?
(
	.clk				(cam1_pclk		),
	.rst_n				(rst_n			),
	.per_frame_vsync	(ycbcr_vsync	),
	.per_frame_href		(ycbcr_href		),
	.per_frame_clken	(ycbcr_de		),
	.per_img_Y			(img_y			),
	.per_img_Cb			(img_cb			),
	.per_img_Cr			(img_cr			),
	.change_in			(change_in		),
	.key_color			(key_color		),
	.key_mode			(key_mode		),
	.key_ycbcr			(key_ycbcr		),
	.key_add_div		(key_add_div	),

	.ycbcr_led			(ycbcr_led	),
	.mode_led			(mode_led	),
	.seg_data			(seg_data	),
	.color				(color		),
	.shape_infor		(shape   ),

	.ram_wr_en			(ram_wr_en	),
	.ram_wr_data		(ram_wr_data),
	.vsync_out			(vsync_out	),
	.href_out			(href_out	),
	.de_out				(de_out		),
	.bin_out			(bin_out	)

);

top_seg_dynamic		top_seg_dynamic_inst
(
    .sys_clk     	(sys_clk	),   //系统时钟，频?50MHz
    .sys_rst_n   	(sys_rst_n	),   //复位信号，低电平有效
	.data			(seg_data),

    .sel         	(sel),   //数码管位选信?
    .seg            (seg) //数码管段选信?
);









assign wr_data={ycbcr_y[7:3],ycbcr_y[7:2],ycbcr_y[7:3]};    //取亮度忿



//------------- ddr_rw_inst -------------
//DDR读写控制部分
axi_ddr_top
#(
.DDR_WR_LEN(64),//写突发长? 朿夿128?64bit
.DDR_RD_LEN(64)//读突发长? 朿夿128?64bit
)
ddr_rw_inst(
  .ddr3_clk     (clk_320m       ),
  .sys_rst_n    (sys_rst_n&locked),
  .pingpang     (0              ),
   //写用户接?
  .user_wr_clk  (cam1_pclk      ), //写时?
  .data_wren    (de_out          ), //写使能，高电平有?
  .data_wr      ({16{bin_out}}       ), //写数?16位wr_data
  .wr_b_addr    (30'd0          ), //写起始地?
  .wr_e_addr    (H_PIXEL*V_PIXEL*2  ), //写结束地?,8位一字节对应丿个地坿?16位x2
  .wr_rst       (1'b0           ), //写地坿复? wr_rst
  //读用户接?
  .user_rd_clk  (clk_25m        ), //读时?
  .data_rden    (rd_en          ), //读使能，高电平有?
  .data_rd      (rd_data        ), //读数?16?
  .rd_b_addr    (30'd0          ), //读起始地?
  .rd_e_addr    (H_PIXEL*V_PIXEL*2  ), //写结束地?,8位一字节对应丿个地坿,16位x2
  .rd_rst       (1'b0           ), //读地坿复? rd_rst
  .read_enable  (1'b1           ),

  .ui_rst       (c3_rst0        ), //ddr产生的复位信?
  .ui_clk       (c3_clk0        ), //ddr操作时钟125m
  .calib_done   (c3_calib_done  ), //代表ddr初始化完?

  //物理接口
  .ddr3_dq      (ddr3_dq        ),
  .ddr3_dqs_n   (ddr3_dqs_n     ),
  .ddr3_dqs_p   (ddr3_dqs_p     ),
  .ddr3_addr    (ddr3_addr      ),
  .ddr3_ba      (ddr3_ba        ),
  .ddr3_ras_n   (ddr3_ras_n     ),
  .ddr3_cas_n   (ddr3_cas_n     ),
  .ddr3_we_n    (ddr3_we_n      ),
  .ddr3_reset_n (ddr3_reset_n   ),
  .ddr3_ck_p    (ddr3_ck_p      ),
  .ddr3_ck_n    (ddr3_ck_n      ),
  .ddr3_cke     (ddr3_cke       ),
  .ddr3_cs_n    (ddr3_cs_n      ),
  .ddr3_dm      (ddr3_dm        ),
  .ddr3_odt     (ddr3_odt       )

);

//------------- vga_ctrl_inst -------------
vga_ctrl  vga_ctrl_inst
(
    .vga_clk    (clk_25m    ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n      ) ,  //输入复位信号,低电平有?,1bit
    .pix_data   (rd_data     ),  //输入像素点色彩信?,16bit

    .pix_x      (           ),  //输出VGA有效显示区域像素点X轴坐?,10bit
    .pix_y      (           ),  //输出VGA有效显示区域像素点Y轴坐?,10bit
    .hsync      (hsync      ),  //输出行同步信?,1bit
    .vsync      (vsync      ),  //输出场同步信?,1bit
    .rgb_valid  (rd_en      ),
    .rgb        (rgb        )   //输出像素点色彩信?,16bit
);

//------------- hdmi_ctrl_inst -------------
hdmi_ctrl   hdmi_ctrl_inst
(
    .clk_1x      (clk_25m           ),   //输入系统时钟
    .clk_5x      (clk_125m          ),   //输入5倍系统时?
    .sys_rst_n   (rst_n             ),   //复位信号,低有?
    .rgb_blue    ({8{rgb[0]}}    	),   //蓝色分量./
    .rgb_green   ({8{rgb[0]}}   	),   //绿色分量  ./
    .rgb_red     ({8{rgb[0]}} 		),   //红色分量   ./
    .hsync       (hsync             ),   //行同步信?
    .vsync       (vsync             ),   //场同步信?
    .de          (rd_en             ),   //使能信号
    .hdmi_clk_p  (tmds_clk_p        ),
    .hdmi_clk_n  (tmds_clk_n        ),   //时钟差分信号
    .hdmi_r_p    (tmds_data_p[2]    ),
    .hdmi_r_n    (tmds_data_n[2]    ),   //红色分量差分信号
    .hdmi_g_p    (tmds_data_p[1]    ),
    .hdmi_g_n    (tmds_data_n[1]    ),   //绿色分量差分信号
    .hdmi_b_p    (tmds_data_p[0]    ),
    .hdmi_b_n    (tmds_data_n[0]    )    //蓝色分量差分信号
);

endmodule