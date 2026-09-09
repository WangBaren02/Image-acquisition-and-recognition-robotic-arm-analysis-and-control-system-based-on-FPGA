//逆运动解算模块（时序逻辑赋值）
//每一个横纵坐标的比例对应一个舵机0的角度————通过( X_calulate / Y_calulate )的值确定servo0的角度
//每一个半径分别对应一个舵机1、2、3的角度————通过半径来计算servo1、2、3的角度
module inverse_kinematics_time
(
	input					clk,
	input					rst_n,

	input			[8:0]	X,					//0~265mm
	input			[7:0]	Y,					//0~175mm
	input					valid_axis_data,	//坐标信息有效信号

	output	reg		[6:0]	rom_address_servo0,		//0~109,共110个地址
	output	reg		[7:0]	rom_address_servo123,	//0~230,共231个地址
	output	reg				valid_rom_address		//抓数据的ROM地址有效信号
);
	localparam UP = 1'b1;				//上半区
	localparam DOWN = 1'b0;				//下半区

	localparam ORINGIN2WARE = 7'd85;	//机械臂原点到仓库的距离
/////////////////////////////////////////////////////////////////
	reg				valid_axis_data_reg;	//打一拍

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) valid_axis_data_reg <= 1'b0;
			else valid_axis_data_reg <= valid_axis_data;
		end

	reg				valid_axis_data_reg_1;	//打两拍

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) valid_axis_data_reg_1 <= 1'b0;
			else valid_axis_data_reg_1 <= valid_axis_data_reg;
		end

	reg				valid_axis_data_reg_2;	//打三拍

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) valid_axis_data_reg_2 <= 1'b0;
			else valid_axis_data_reg_2 <= valid_axis_data_reg_1;
		end
/////////////////////////////////////////////////////////////////
//将坐标转换成计算值
	reg				up_or_down;		//上半区还是下半区
	reg		[7:0]	X_calculate;	//X的计算值：0~180
	wire	[8:0]	Y_calculate;	//Y的计算值：85~260

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n)
				begin
					X_calculate <= 8'b0;
					up_or_down <= 1'b0;
				end
			else if(!valid_axis_data)
				begin
					X_calculate <= X_calculate;
					up_or_down <= up_or_down;
				end
			else if(X<=7'd85) //若X小于等于85，则判定为上半区
				begin
					X_calculate <= 7'd85 - X;
					up_or_down <= UP;
				end
			else if(X>7'd85) //若X大于85，则判定为下半区
				begin
					X_calculate <= X - 7'd85;
					up_or_down <= DOWN;
				end
			else
				begin
					X_calculate <= X_calculate;
					up_or_down <= up_or_down;
				end
		end

	assign Y_calculate = Y + ORINGIN2WARE;	//Y的计算值等于Y加机械臂原点到仓库的距离
//////////////////////////////////////////////////////////////////////////////////////
//求得半径的平方	X的一百倍（由于除完没有小数，分子乘一百倍，使商为原来的一百倍，方便计算）
	reg		[16:0]	R2;						//直径的平方:7225~100000
	reg		[14:0]	X_calculate_x_100;		//100倍X_calculate:0~18000

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n)
				begin
					R2 <= 17'b0;
					X_calculate_x_100 <= 15'b0;
				end
			else if(!valid_axis_data_reg)
				begin
					R2 <= R2;
					X_calculate_x_100 <= X_calculate_x_100;
				end
			else
				begin
					R2 <= X_calculate * X_calculate + Y_calculate * Y_calculate;	//半径的平方等于X方加Y方
					X_calculate_x_100 <= {1'b0,X_calculate[7:0],6'b0} + {2'b0,X_calculate[7:0],5'b0} + {5'b0,X_calculate[7:0],2'b0};	//100*X
				end
		end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	wire	[7:0]	tan_x_100;				//100倍tan:0~211
	wire	[7:0]	remainder_divide;
//除法器核例化
	divide_ip divide_ip_inst
	(
		.denom 		(Y_calculate),			//分母
		.numer 		(X_calculate_x_100),	//分子

		.quotient 	(tan_x_100),			//商
		.remain 	(remainder_divide)		//余数
	);
/////////////////////////////////////////////////////////////////////////
//通过( X_calulate*100 / Y_calulate )的值确定servo0的角度————查找表实现
//舵机0抓数据ROM地址赋值
//ROM_servo0中按角度大小顺序从0~109°(共110个）的delay_time
	reg		[8:0]	linear_fitting_arctan;

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) linear_fitting_arctan <= 8'b0;
			else if(!valid_axis_data_reg_1) linear_fitting_arctan <= linear_fitting_arctan;
			else if(tan_x_100 <= 6'd33) linear_fitting_arctan <= {1'b0,tan_x_100[7:1]} + {5'b0,tan_x_100[7:5]} + {6'b0,tan_x_100[7:6]} + {7'b0,tan_x_100[7]};															//0.1000111
			else if((tan_x_100 > 6'd33)&&(tan_x_100 <= 6'd58)) linear_fitting_arctan <= {2'b0,tan_x_100[7:2]} + {3'b0,tan_x_100[7:3]} + {4'b0,tan_x_100[7:4]} + {5'b0,tan_x_100[7:5]} + {6'b0,tan_x_100[7:6]} + 2'd2;	//0.0111110 +  2
			else if((tan_x_100 > 6'd58)&&(tan_x_100 <= 7'd75)) linear_fitting_arctan <= {2'b0,tan_x_100[7:2]} + {3'b0,tan_x_100[7:3]} + {6'b0,tan_x_100[7:6]} + {7'b0,tan_x_100[7]} + 3'd7;								//0.0110011 +  7
			else if((tan_x_100 > 7'd75)&&(tan_x_100 <= 7'd100)) linear_fitting_arctan <= {2'b0,tan_x_100[7:2]} + {4'b0,tan_x_100[7:4]} + {6'b0,tan_x_100[7:6]} + 4'd12;													//0.0101010 + 12
			else if((tan_x_100 > 7'd100)&&(tan_x_100 <= 8'd133)) linear_fitting_arctan <= {2'b0,tan_x_100[7:2]} + 5'd20;																								//0.01      + 20
			else if((tan_x_100 > 8'd133)&&(tan_x_100 <= 8'd158)) linear_fitting_arctan <= {3'b0,tan_x_100[7:3]} + {4'b0,tan_x_100[7:4]} + 5'd28;																		//0.0011    + 28
			else if((tan_x_100 > 8'd158)&&(tan_x_100 <= 8'd177)) linear_fitting_arctan <= {3'b0,tan_x_100[7:3]} + {6'b0,tan_x_100[7:6]} + {7'b0,tan_x_100[7]} + 6'd34;													//0.0010011 + 34
			else linear_fitting_arctan <= {3'b0,tan_x_100[7:3]} + 6'd38;																																				//0.001     + 38
		end

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) rom_address_servo0 <= 7'b0;
			else if(!valid_axis_data_reg_2) rom_address_servo0 <= rom_address_servo0;
			else if(up_or_down==UP) rom_address_servo0 <= 6'd45 - linear_fitting_arctan;
			else if(up_or_down==DOWN) rom_address_servo0 <= 6'd45 + linear_fitting_arctan;
			else rom_address_servo0 <= 7'b111_1111;	//最大地址对应delay_time=1500
		end
///////////////////////////////////////////////////////////////////////////////////////////
//通过半径来计算servo1、2、3的角度，分R<=178、R>178计算————查找表实现
	wire	[8:0]	R;					//半径：85~316
	wire	[8:0]	remainder_sqrt;		//开方的余数
//开方核例化
	sqrt_ip	sqrt_ip_inst
	(
		.radical 	(R2),

		.q 			(R),
		.remainder 	(remainder_sqrt)
	);
//舵机123抓数据ROM地址赋值
	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) rom_address_servo123 <= 8'b0;
			else if(!valid_axis_data_reg_2) rom_address_servo123 <= rom_address_servo123;
			else rom_address_servo123 <= R - 7'd85;
		end
////////////////////////////////////////////////////////
//抓数据有效
	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) valid_rom_address <= 1'b0;
			else valid_rom_address <= valid_axis_data_reg_2;
		end

endmodule
