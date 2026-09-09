//读抓数据ROM模块
//ROM里存储了通过实验得到的关于舵机0、1、2、3的delay_time
module rom_catch_data
(
	input					clk,					//时钟：1MHz
	input					rst_n,					//模块复位

	input	wire	[6:0]	rom_address_servo0,		//舵机0抓数据的ROM地址：0~109,分别代表舵机真实角度0~109共110个地址
	input	wire	[7:0]	rom_address_servo123,	//舵机1、2、3抓数据的ROM地址：0~111,分别代表R从100~211,共112个地址
	input	wire	[11:0]	catch_4_delay,
	input					valid_rom_address,		//抓数据的ROM地址有效信号

	output	wire	[11:0]	catch_0,				//舵机0的抓数据
	output	wire	[11:0]	catch_1,				//舵机1的抓数据
	output	wire	[11:0]	catch_2,				//舵机2的抓数据
	output	wire	[11:0]	catch_3,				//舵机3的抓数据
	output	wire	[11:0]	catch_4,				//舵机4的抓数据
	output	wire			valid_catch_rom_data	//读取的ROM抓数据有效
);
////////////////////////////////////////////////////////////打两拍把时序对上
	reg		valid_rom_address_reg;

	always@(posedge clk or negedge rst_n)	//打一拍
		begin
			if(!rst_n) valid_rom_address_reg <= 1'b0;
			else valid_rom_address_reg <= valid_rom_address;
		end

	reg		valid_rom_address_reg_1;

	always@(posedge clk or negedge rst_n)	//打两拍
		begin
			if(!rst_n) valid_rom_address_reg_1 <= 1'b0;
			else valid_rom_address_reg_1 <= valid_rom_address_reg;
		end
//////////////////////////////////////////////////////////////
	wire	[11:0]	servo0_data;
//舵机0抓数据ROM核例化
	catch_servo0_rom_data catch_servo0_rom_data_inst
	(
		.address 	(rom_address_servo0),
		.clock 		(clk),
		.rden 		(valid_rom_address),

		.q 			(servo0_data)
	);
//ROM中按角度大小顺序从8~84°(共77个）的delay_time
///////////////////////////////////////////////////////////////
	wire	[35:0]	servo123_data;	//其中[11:0]为舵机1的数据，[23:12]为舵机2的数据，[35:24]为舵机3的数据
//舵机123抓数据ROM核例化
	catch_servo123_rom_data catch_servo123_rom_data_inst
	(
		.address 	(rom_address_servo123),
		.clock 		(clk),
		.rden 		(valid_rom_address),

		.q 			(servo123_data)
	);
//////////////////////////////////////////////////////////////////////////////////
	assign catch_0 = (valid_rom_address_reg_1) ? servo0_data          : 12'd1500;	//舵机0抓数据赋值
	assign catch_1 = (valid_rom_address_reg_1) ? servo123_data[11: 0] : 12'd1500;	//舵机1抓数据赋值
	assign catch_2 = (valid_rom_address_reg_1) ? servo123_data[23:12] : 12'd1500;	//舵机2抓数据赋值
	assign catch_3 = (valid_rom_address_reg_1) ? servo123_data[35:24] : 12'd1500;	//舵机3抓数据赋值
	assign catch_4 = (valid_rom_address_reg_1) ? servo0_data + 10'd666 + catch_4_delay : 12'd1500;	//舵机4抓数据赋值
	assign valid_catch_rom_data = (valid_rom_address_reg_1) ? 1'b1 : 1'b0;

endmodule
