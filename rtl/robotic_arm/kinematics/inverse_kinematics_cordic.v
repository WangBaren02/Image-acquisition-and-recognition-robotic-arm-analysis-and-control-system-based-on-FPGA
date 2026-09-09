//逆运动解算模块（cordic）
//每一个横纵坐标的比例对应一个舵机0的角度————通过arctan确定servo0的角度
//每一个半径分别对应一个舵机1、2、3的角度————通过半径来计算servo1、2、3的角度
module inverse_kinematics_cordic
(
	input					clk,
	input					clk_100M,
	input					rst_n,

	input			[8:0]	X,					//0~265mm
	input			[8:0]	Y,					//0~175mm
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
//求得半径的平方
	reg		[16:0]	R2;						//直径的平方:7225~100000

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) R2 <= 17'b0;
			else if(!valid_axis_data_reg) R2 <= R2;
			else R2 <= X_calculate * X_calculate + Y_calculate * Y_calculate;	//半径的平方等于X方加Y方
		end
/////////////////////////////////////////////////////////////////////////
//通过ATAN2确定servo0的角度————查找表实现
//舵机0抓数据ROM地址赋值
//ROM_servo0中按角度大小顺序从0~109°(共110个）的delay_time
	wire	[8:0]	arctan_res;

	cordic_ATAN2 cordic_ATAN2_inst
	(
		.clk_100M 	(clk_100M),
		.rst_n 		(rst_n),

		.X			(Y_calculate),
		.Y			(X_calculate),

		.res 		(arctan_res)
	);

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) rom_address_servo0 <= 7'b0;
			else if(!valid_axis_data_reg_2) rom_address_servo0 <= rom_address_servo0;
			else if(up_or_down==UP) rom_address_servo0 <= 6'd45 - arctan_res;
			else if(up_or_down==DOWN) rom_address_servo0 <= 6'd45 + arctan_res;
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
