//抓模块的顶层
module catch
(
	input			clk,					//时钟：1Mhz
	input			clk_100M,
	input			rst_n,					//模块复位

	input	[8:0]	X,						//X坐标
	input	[8:0]	Y,						//Y坐标
	input	[11:0]	catch_4_delay,
	input			valid_axis_data,		//坐标信号有效

	output	[11:0]	catch_0,				//舵机0的delay_time
	output	[11:0]	catch_1,				//舵机1的delay_time
	output	[11:0]	catch_2,				//舵机2的delay_time
	output	[11:0]	catch_3,				//舵机3的delay_time
	output	[11:0]	catch_4,				//舵机4的delay_time
	output			valid_catch_rom_data	//抓数据有效
);
///////////////////////////////////////////////////////////////
	wire	[6:0]	rom_address_servo0;		//舵机0数据的ROM地址
	wire	[7:0]	rom_address_servo123;	//舵机123数据的ROM地址
	wire			valid_rom_address;		//抓数据有效
//逆运动解算模块例化
	inverse_kinematics_cordic inverse_kinematics_cordic_inst
	(
		.clk					(clk),
		.clk_100M 				(clk_100M),
		.rst_n					(rst_n),

		.X						(X),
		.Y						(Y),
		.valid_axis_data		(valid_axis_data),

		.rom_address_servo0		(rom_address_servo0),
		.rom_address_servo123	(rom_address_servo123),
		.valid_rom_address		(valid_rom_address)
	);
////////////////////////////////////////////////////////
//读抓数据ROM模块例化
	rom_catch_data rom_catch_data_inst
	(
		.clk					(clk),
		.rst_n					(rst_n),

		.rom_address_servo0		(rom_address_servo0),
		.rom_address_servo123	(rom_address_servo123),
		.catch_4_delay			(catch_4_delay),
		.valid_rom_address		(valid_rom_address),

		.catch_0				(catch_0),
		.catch_1				(catch_1),
		.catch_2				(catch_2),
		.catch_3				(catch_3),
		.catch_4				(catch_4),
		.valid_catch_rom_data	(valid_catch_rom_data)
	);

endmodule
