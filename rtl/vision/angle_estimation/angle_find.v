module	angle_find//坐标角度转换模块
(
	input	wire			clk				,
	input	wire			rst_n			,
	input	wire	[9:0]	x_cent			,
	input	wire	[9:0]	y_cent			,
	input	wire	[9:0]	x_h_max			,
	input	wire	[9:0]	y_h_max			,
	input	wire	[9:0]	x_h_min			,
	input	wire	[9:0]	y_h_min			,
	input	wire	[1:0]	shape_infor		,
	input	wire			angle_gen_start	,
	input	wire			href_in			,
	input	wire			vsync_in		,//低电平有?

	output	reg		[8:0]	angle_data		,
	output	reg				angle_gen_flag

);


reg		[9:0]	x_gen_r					;//生成点坐?
reg		[9:0]	y_gen_r					;
reg				start_flag				;//角度弿始计算标志信叿
//reg				calculation_flag		;//角度计算标志符号
//reg				calculation_flag_reg	;
//reg				arctan_flag				;//反正切结束信?
reg		[15:0]	x_denominator			;//分母
//reg		[15:0]	x_denominator_100		;
reg		[15:0]	y_molecule				;//分子
reg		[15:0]	y_molecule_100			;//扩大100倍分?
wire	[31:0]	tan_angle_100			;
wire	[15:0]	linear_fitting_arctan	;
wire			m_axis_dout_tvalid		;
reg		[9:0]	angle_data_bf			;
reg				m_axis_dout_tvalid_r	;
reg				m_axis_dout_tvalid_r2	;
reg				m_axis_dout_tvalid_r3	;
reg				divide_ip_en			;


wire	[15:0]	sqare_data;
wire			sqare_ok	;
wire	[15:0]	sqare_out	;
wire	[15:0]	z_data		;
wire			divide_en_1	;
wire			divide_en_2	;
wire	[31:0]	sin_data	;
wire	[31:0]	cos_data	;

wire	[15:0]	sin_data_q	;
wire	[15:0]	sin_data_r	;

wire	[15:0]	cos_data_q	;
wire	[15:0]	cos_data_r	;

wire	[15:0]	cordic_out	;
wire	[9:0]	arc_tan		;









//扩大100倍tan
//角度计算使能信号
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		start_flag <= 1'b0;
	else	if(angle_gen_flag)
		start_flag <= 1'b0;
	else	if(angle_gen_start)
		start_flag <= 1'b1;
	//else	if(angle_data != 0)
	//	start_flag <= 1'b1;
	else
		start_flag	<= 1'b0;
//生成点坐?
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_gen_r	<= 10'd0;
	else	if(vsync_in == 1'b0)
		x_gen_r	<= 10'd0;
	else	if(start_flag)
		case	(shape_infor)
			2'd2	:	x_gen_r <= x_h_max;
			2'd1    :	x_gen_r <= x_h_max;
			2'd0    :	x_gen_r	<= 10'd0  ;
			2'd3    :	x_gen_r	<= x_h_max;
			default	:	x_gen_r	<= 10'd0  ;
		endcase

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_gen_r	<= 10'd0;
	else	if(vsync_in == 1'b0)
		y_gen_r	<= 10'd0;
	else	if(start_flag)
		case	(shape_infor)
			2'd2		:	y_gen_r	<=	y_cent;
			2'd1    	:	y_gen_r	<=	y_cent;
			2'd0    	:	y_gen_r	<=	10'd0  ;
			2'd3    	:	y_gen_r	<=	y_cent;
			default	:	y_gen_r	<=	10'd0  ;
		endcase

//分子
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_molecule	<= 16'd0;
	//else	if(vsync_in == 1'b0)
	//	y_molecule	<= 16'd0;
	else	if(start_flag)
		y_molecule	<=	(y_cent - y_h_max);//y_h_max - y_cent
//分母
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_denominator	<= 16'd0;
	//else	if(vsync_in == 1'b0)
	//	x_denominator	<= 16'd0;
	else	if(start_flag)
		if(x_h_max >= x_cent)
			x_denominator	<= {6'd0,(x_h_max - x_cent)};
		else	if(x_h_max < x_cent)
			x_denominator	<= {6'd0,(x_cent - x_h_max)};

//分子扩大100?
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_molecule_100 <= 16'd0;
	//else	if(vsync_in == 1'b0)
	//	y_molecule_100 <= 16'd0;
	else	if(y_molecule != 0)
		y_molecule_100 <= {y_molecule[9:0],6'b0} + {1'b0,y_molecule[9:0],5'b0} + {4'b0,y_molecule[9:0],2'b0};


//divide_angle divide_angle_inst (
//  .aclk(clk),                                      // input wire aclk
//  .s_axis_divisor_tvalid(divide_ip_en),    // input wire s_axis_divisor_tvalid
//  .s_axis_divisor_tdata(x_denominator),      // input wire [15 : 0] s_axis_divisor_tdata
//  .s_axis_dividend_tvalid(divide_ip_en),  // input wire s_axis_dividend_tvalid
//  .s_axis_dividend_tdata(y_molecule_100),    // input wire [15 : 0] s_axis_dividend_tdata
//  .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
//  .m_axis_dout_tdata(tan_angle_100)            // output wire [31 : 0] m_axis_dout_tdata
//);
//wire	[15:0]	redmin;
//wire	[15:0]	rel;
//
//assign	redmin	= tan_angle_100[15:0];
//assign	rel		= tan_angle_100[31:16];
//
//
//always@(posedge	clk or negedge	rst_n)
//	if(rst_n == 1'b0)
//		linear_fitting_arctan	<= 10'b0;
//	else	if(vsync_in == 1'b0)
//		linear_fitting_arctan	<= 10'b0;
//	else	if(m_axis_dout_tvalid_r2)	begin
//		if(tan_angle_100[31:16] <= 6'd34 )
//			linear_fitting_arctan <= {1'b0,tan_angle_100[25:17]} + {4'b0,tan_angle_100[25:20]};
//		else	if(tan_angle_100[31:16] > 6'd34 && tan_angle_100[31:16] <= 6'd52)
//			linear_fitting_arctan <= {1'b0,tan_angle_100[25:17]} + 2'd2;
//		else	if(tan_angle_100[31:16] > 6'd52 && tan_angle_100[31:16] <= 7'd75)
//			linear_fitting_arctan <= {2'b0,tan_angle_100[25:18]} + {3'b0,tan_angle_100[25:19]} + {5'b0,tan_angle_100[25:21]} + 3'd7;
//		else	if(tan_angle_100[31:16] > 7'd75 && tan_angle_100[31:16] <= 7'd108)
//			linear_fitting_arctan <= {2'b0,tan_angle_100[25:18]} + {4'b0,tan_angle_100[25:20]} + 5'd16;
//		else	if(tan_angle_100[31:16] > 7'd108 && tan_angle_100[31:16] <= 8'd129)
//			linear_fitting_arctan <= {2'b0,tan_angle_100[25:18]} + {4'b0,tan_angle_100[25:20]} + 4'd12;
//		else	if(tan_angle_100[31:16] > 8'd129 && tan_angle_100[31:16] <= 8'd169)
//			linear_fitting_arctan <= {2'b0,tan_angle_100[25:18]} + {4'b0,tan_angle_100[25:20]} + 4'd13;
//		else	if(tan_angle_100[31:16] > 8'd169 && tan_angle_100[31:16] <= 8'd210)
//			linear_fitting_arctan <= {2'b0,tan_angle_100[25:18]} + {4'b0,tan_angle_100[25:20]} + {6'b0,tan_angle_100[25:22]};
//		else	if(tan_angle_100[31:16] > 8'd210 && tan_angle_100[31:16] <= 9'd261)
//			linear_fitting_arctan <= tan_angle_100[25:18] + tan_angle_100[25:23] + tan_angle_100[25:22] + 3'd5;//{2'b0,tan_angle_100[25:18]} + {5'b0,tan_angle_100[25:21]};
//		else	if(tan_angle_100[31:16] > 9'd261&& tan_angle_100[31:16] <= 9'd351)
//			linear_fitting_arctan <= tan_angle_100[25:19] + tan_angle_100[25:20] + tan_angle_100[25:21]+4'd5;// tan_angle_100[25:22] + {3'b0,tan_angle_100[25:19]} + {4'b0,tan_angle_100[25:20]} + {5'b0,tan_angle_100[25:21]} + 5'd5+ {6'b0,tan_angle_100[25:22]};
//		else	if(tan_angle_100[31:16] > 9'd351&& tan_angle_100[31:16] < 10'd526)
//			linear_fitting_arctan <= {3'b0,tan_angle_100[25:19]}+ {5'b0,tan_angle_100[25:21]} + {6'b0,tan_angle_100[25:22]}+ {6'b0,tan_angle_100[25:23]} + 2'd1;//+ {4'b0,tan_angle_100[25:20]};//+ {4'b0,tan_angle_100[25:20]} + {8'b0,tan_angle_100[25:24]} + 3'd4;
//		else	if(tan_angle_100[31:16] > 10'd526 && tan_angle_100[31:16] < 10'd930)
//			linear_fitting_arctan <= {5'b0,tan_angle_100[25:21]} + {4'b0,tan_angle_100[25:20]} + {6'b0,tan_angle_100[25:22]} + {7'b0,tan_angle_100[25:23]}+{8'b0,tan_angle_100[25:24]}; //{5'b0,tan_angle_100[25:21]} + {3'b0,tan_angle_100[25:19]};//{4'b0,tan_angle_100[25:20]} //+ {5'b0,tan_angle_100[25:21]} + {6'b0,tan_angle_100[25:22]} + {7'b0,tan_angle_100[25:23]}+{8'b0,tan_angle_100[25:24]};
//		else
//			linear_fitting_arctan <={5'b0,tan_angle_100[25:21]} + {4'b0,tan_angle_100[25:20]};
//	end
//
//
//wire	[9:0]	rel25_18;
//wire	[9:0]	rel25_17;
//wire	[9:0]	rel25_16;
//wire	[9:0]	rel25_19;
//wire	[9:0]	rel25_20;
//wire	[9:0]	rel25_21;
//wire	[9:0]	rel25_22;
//wire	[9:0]	rel25_23;
//wire	[9:0]	rel25_24;
//
//assign	rel25_18	=	tan_angle_100[25:18];
//assign	rel25_17    =	tan_angle_100[25:17];
//assign	rel25_16    =	tan_angle_100[25:16];
//assign	rel25_19    =	tan_angle_100[25:19];
//assign	rel25_20    =	tan_angle_100[25:20];
//assign	rel25_21    =	tan_angle_100[25:21];
//assign	rel25_22    =	tan_angle_100[25:22];
//assign	rel25_23    =	tan_angle_100[25:23];
//assign	rel25_24    =	tan_angle_100[25:24];



assign	cos_data_r = cos_data[15:0];//cos_data[15:0]
assign	cos_data_q = cos_data[31:16];
assign	sin_data_r = sin_data[15:0];//sin_data[15:0]
assign	sin_data_q = sin_data[31:16];
assign	sqare_data = x_denominator*x_denominator + y_molecule*y_molecule;
assign	z_data = sqare_out;
//求出斜边
cordic_1 cordic_1 (
  .aclk(clk),                                        // input wire aclk
  .aresetn(rst_n),                                  // input wire aresetn
  .s_axis_cartesian_tvalid(divide_ip_en),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(sqare_data),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(sqare_ok),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(sqare_out)              // output wire [15 : 0] m_axis_dout_tdata
);

//cordic_0 CORDIC (
//  .aclk(clk),                                        // input wire aclk
//  .s_axis_cartesian_tvalid(divide_en_1),  // input wire s_axis_cartesian_tvalid
//  .s_axis_cartesian_tdata({sin_data_r[0:6],cos_data_r}),    // input wire [31 : 0] s_axis_cartesian_tdata
//  .m_axis_dout_tvalid(m_axis_dout_tvalid),            // output wire m_axis_dout_tvalid
//  .m_axis_dout_tdata(linear_fitting_arctan)              // output wire [15 : 0] m_axis_dout_tdata
//);
//divide_angle your_instance_name (
//  .aclk(aclk),                                      // input wire aclk
//  .s_axis_divisor_tvalid(s_axis_divisor_tvalid),    // input wire s_axis_divisor_tvalid
//  .s_axis_divisor_tdata(s_axis_divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
//  .s_axis_dividend_tvalid(s_axis_dividend_tvalid),  // input wire s_axis_dividend_tvalid
//  .s_axis_dividend_tdata(s_axis_dividend_tdata),    // input wire [15 : 0] s_axis_dividend_tdata
//  .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
//  .m_axis_dout_tdata(m_axis_dout_tdata)            // output wire [31 : 0] m_axis_dout_tdata
//);

cordic_0 CORDIC (
  .aclk(clk),                                        // input wire aclk
  .s_axis_cartesian_tvalid(divide_en_1),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata({5'd0,sin_data_q[0],sin_data_r[9:0],5'd0,cos_data_q[0],cos_data_r[9:0]}),//1位符号位1位整数位剩下小数?    // input wire [31 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(m_axis_dout_tvalid),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(cordic_out)              // output wire [15 : 0] m_axis_dout_tdata
);

//归一化结果到2?7次方才很稳定?

//{8'd0,sin_data_r[7:0],8'd0,cos_data_r[7:0]}






//对y坐标归一化处?
divide_angle divide_angle_inst_1 (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(sqare_ok),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(sqare_out),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(sqare_ok),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(y_molecule),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(divide_en_1),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(sin_data)            // output wire [31 : 0] m_axis_dout_tdata
);

//对x坐标归一化处?
divide_angle divide_angle_inst_2 (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(sqare_ok),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(sqare_out),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(sqare_ok),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(x_denominator),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(divide_en_2),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(cos_data)            // output wire [31 : 0] m_axis_dout_tdata
);


assign	linear_fitting_arctan = cordic_out[12:6] * 180;//利用乘法器，较为耗资源㿂调，用移位笿
assign	arc_tan	= (linear_fitting_arctan >>7);





//wire	[2:0]	cordic_3bit;
//wire	[12:0]	cordic_13bit;
//
//assign	cordic_3bit = linear_fitting_arctan[15:13];
//assign	cordic_13bit = 	linear_fitting_arctan[12:0];




//要旋转的角度
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		angle_data	<= 10'd0;
	else	if(m_axis_dout_tvalid_r3)
		case(shape_infor)
			2'd3	:	if((x_h_max - 1 < x_cent) && ( x_cent < x_h_max + 1))
							angle_data <= 45;
						else	if(x_h_max - 1 >= x_cent)
							angle_data <= 51 + arc_tan;//135 - arc_tan
						else	if(x_h_max + 1 < x_cent)
							angle_data <= arc_tan - 43;//45 - arc_tan


			2'd1    :	if(((x_cent < x_h_max + 2) && (x_h_max - 2 < x_cent)))//||(y_molecule/x_denominator >= 5'd10)
							angle_data <= 45;
						//else	if(y_molecule/x_denominator <= 1'd1)
						//	angle_data <= 0;
						else	if((x_h_max - 2>  x_cent))
							angle_data <=  135 - arc_tan ;// arc_tan - 45
						else	if(x_h_max + 2 < x_cent)
							angle_data <= arc_tan - 44;//135 - arc_tan

			2'd0    :	angle_data	<= 0;
			2'd2    :	if(( x_h_max - 1 < x_cent ) && ( x_cent < x_h_max + 1))
							angle_data <=  30;
						else	if(x_h_max - 1 > x_cent)
							angle_data <=  123 - arc_tan;//arc_tan - 60
						else	if(x_h_max +	1 < x_cent)
							angle_data <= 151 - arc_tan ;//120 - arc_tan

			default	:	angle_data	<= angle_data;
		endcase




//求角度使能信?
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		m_axis_dout_tvalid_r	<= 1'b0;
	else
		m_axis_dout_tvalid_r	<= m_axis_dout_tvalid;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		m_axis_dout_tvalid_r	<= 1'b0;
	else
		m_axis_dout_tvalid_r	<= m_axis_dout_tvalid;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		m_axis_dout_tvalid_r2	<= 1'b0;
	else
		m_axis_dout_tvalid_r2	<= m_axis_dout_tvalid_r;

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		m_axis_dout_tvalid_r3	<= 1'b0;
	else
		m_axis_dout_tvalid_r3	<= m_axis_dout_tvalid_r2;






//除法器ip使能信号
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		divide_ip_en	<= 1'b0;
	else
		divide_ip_en	<= start_flag;



//得到角度标志信号
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		angle_gen_flag <= 1'b0;

	else
		angle_gen_flag	<=	m_axis_dout_tvalid_r3;





endmodule