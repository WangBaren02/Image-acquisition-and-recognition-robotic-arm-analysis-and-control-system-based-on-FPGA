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
	input	wire	[2:0]	shape_infor		,
	input	wire			angle_gen_start	,
	input	wire			href_in			,
	input	wire			vsync_in		,//低电平有效

	output	reg		[9:0]	angle_data		,
	output	reg				angle_gen_flag

);


reg		[9:0]	x_gen_r					;//生成点坐标
reg		[9:0]	y_gen_r					;
reg				start_flag				;//角度开始计算标志信号
reg				calculation_flag		;//角度计算标志符号
reg				calculation_flag_reg	;
reg				arctan_flag				;//反正切结束信号
reg		[15:0]	x_denominator			;//分母
reg		[9:0]	y_molecule				;//分子
reg		[15:0]	y_molecule_100			;//扩大100倍分子
wire	[15:0]	tan_angle_100			;
reg		[9:0]	linear_fitting_arctan	;
wire			m_axis_dout_tvalid		;
//扩大100倍tan
//角度计算使能信号
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		start_flag <= 1'b0;
	else	if(angle_gen_flag)
		start_flag <= 1'b0;
	else	if(angle_gen_start && vsync_in == 1'b1)
		start_flag <= 1'b1;
	else	if(angle_data != 0)
		start_flag <= 1'b1;
	else
		start_flag	<= 1'b0;
//生成点坐标
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_gen_r	<= 10'd0;
	else	if(vsync_in == 1'b0)
		x_gen_r	<= 10'd0;
	else	if(start_flag)
		case	(shape_infor)
			3'd1	:	x_gen_r <= x_h_max;
			3'd2    :	x_gen_r <= x_h_max;
			3'd3    :	x_gen_r	<= 10'd0  ;
			3'd4    :	x_gen_r	<= x_h_max;
			default	:	x_gen_r	<= 10'd0  ;
		endcase

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_gen_r	<= 10'd0;
	else	if(vsync_in == 1'b0)
		y_gen_r	<= 10'd0;
	else	if(start_flag)
		case	(shape_infor)
			3'd1	:	y_gen_r	<=	y_cent;
			3'd2	:	y_gen_r	<=	y_cent;
			3'd3	:	y_gen_r	<=	10'd0  ;
			3'd4	:	y_gen_r	<=	y_cent;
			default	:	y_gen_r	<=	10'd0  ;
		endcase

//分子
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_molecule	<= 10'd0;
	else	if(vsync_in == 1'b0)
		y_molecule	<= 10'd0;
	else	if(start_flag)
		y_molecule	<=	(y_cent - y_h_max);//y_h_max - y_cent
//分母
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		x_denominator	<= 16'd0;
	else	if(vsync_in == 1'b0)
		x_denominator	<= 16'd0;
	else	if(start_flag)
		if(x_h_max >= x_cent)
			x_denominator	<= x_h_max - x_cent;
		else	if(x_h_max < x_cent)
			x_denominator	<= x_cent - x_h_max;

//分子扩大100倍
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		y_molecule_100 <= 16'd0;
	else	if(vsync_in == 1'b0)
		y_molecule_100 <= 16'd0;
	else	if(start_flag && y_molecule != 0)
		y_molecule_100 <= {y_molecule[9:0],6'b0} + {1'b0,y_molecule[9:0],5'b0} + {4'b0,y_molecule[9:0],2'b0};

//divide_angle	divide_angle_inst 
//(
//	.denom ( x_denominator ),
//	.numer ( y_molecule_100 ),
//	.quotient ( tan_angle_100 ),
//	.remain ( )
//);
//除法器ip核
divide_angle your_instance_name (
  .aclk(aclk),                                      // input wire aclk
  .s_axis_divisor_tvalid(1'b1),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(y_molecule_100),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(1'b1),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(x_denominator),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(tan_angle_100)            // output wire [31 : 0] m_axis_dout_tdata
);












//反tan角,β角
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		linear_fitting_arctan	<= 10'b0;
	else	if(vsync_in == 1'b0)
		linear_fitting_arctan	<= 10'b0;
	else	if(calculation_flag == 1)
		if(tan_angle_100 <= 6'd34 )
			linear_fitting_arctan <= {1'b0,tan_angle_100[9:1]} + {4'b0,tan_angle_100[9:4]};
		else	if(tan_angle_100 > 6'd34 && tan_angle_100 <= 6'd52)
			linear_fitting_arctan <= {1'b0,tan_angle_100[9:1]} + 2'd2;
		else	if(tan_angle_100 > 6'd52 && tan_angle_100 <= 7'd75)
			linear_fitting_arctan <= {2'b0,tan_angle_100[9:2]} + {3'b0,tan_angle_100[9:3]} + {5'b0,tan_angle_100[9:5]} + 3'd7;
		else
			linear_fitting_arctan <= {2'b0,tan_angle_100[9:2]} + {4'b0,tan_angle_100[9:4]} + 4'd14;

//要旋转的角度
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		angle_data	<= 10'd0;
	else	if(vsync_in == 1'b0)
		angle_data	<= 10'd0;
	else	if(calculation_flag_reg)
		case(shape_infor)
			3'd1	:	if(x_h_max >= x_cent)
							angle_data <= 27 + linear_fitting_arctan;
						else	if(x_h_max < x_cent)
							angle_data <= 207 - linear_fitting_arctan;
			3'd2    :	if(x_h_max - 4 >  x_cent)
							angle_data <=  linear_fitting_arctan - 45;
						else	if(x_h_max + 4 < x_cent)
							angle_data <= 135 - linear_fitting_arctan;
						else	if( x_h_max - 4 < x_cent < x_h_max + 4)
							angle_data <= 45;
			3'd3    :	angle_data	<= 0;
			3'd4    :	if(x_h_max - 4 > x_cent)
							angle_data <=  linear_fitting_arctan - 60;
						else	if(x_h_max + 4 < x_cent)
							angle_data <= 120 - linear_fitting_arctan;
						else	if( x_h_max - 4 < x_cent < x_h_max + 4)
							angle_data <=  60;
			default	:	angle_data	<= 0;
		endcase

//tan角度开始计算标志信号
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		calculation_flag <= 1'b0;
	else	if(vsync_in == 1'b0)
		calculation_flag <= 1'b0;
	else	if(start_flag == 1'b0)
		calculation_flag <= 1'b0;
	else	if(start_flag && y_molecule != 0)
		calculation_flag <=	1'b1;
//	else
//		calculation_flag <= 1'b0;
////tan角度开始计算标志信号寄存
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)	
		calculation_flag_reg	<= 1'b0;
	else	if(vsync_in == 1'b0)
		calculation_flag_reg	<= 1'b0;
	else
		calculation_flag_reg	<= calculation_flag;
//反tan角结束标志
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		arctan_flag <= 1'b0;
	else	if(vsync_in == 1'b0)
		arctan_flag <= 1'b0;
	else
		arctan_flag	<=	calculation_flag_reg;



//得到角度标志信号
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		angle_gen_flag <= 1'b0;
	else	if(vsync_in == 1'b0)
		angle_gen_flag <= 1'b0;
	else
		angle_gen_flag	<=	arctan_flag;





endmodule