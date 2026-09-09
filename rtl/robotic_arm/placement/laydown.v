//放下模块：利用ROM把各个舵机相应的位置
//通过图像识别信息来确定ROM地址
module laydown
(
	input				clk,
	input				rst_n,

	input				lay_0_add_flag,
	input				lay_3_add_flag,

	input		[2:0]	des_X,	//0~5
	input		[1:0]	des_Y,	//0~3
	input		[11:0]	release_4_change,
	input				en_release,	//放下使能
	input				des_valid,

	output	reg	[11:0]	release_0_change,
	output	reg	[11:0]	release_1_change,
	output	reg	[11:0]	release_2_change,
	output	reg	[11:0]	release_3_change,
	output		[11:0]	release_4,
	output	reg			valid_release_data	//放下数据有效
);
////////////////////////////////////////////////////
	reg  	[4:0]	rom_address;	//共24组数据

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) rom_address <= 5'd0;
			else if(des_valid) rom_address = des_X + {des_Y,2'b0} + {des_Y,1'b0};
			else rom_address <= rom_address;
		 end
//////////////////////////////////////
	reg				rd_request;
	reg				rd_request_reg;
	wire	[59:0]	data_angle;		//共5*12bit数据

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) rd_request <= 1'b0;
			else if(en_release) rd_request <= 1'b1;
			else rd_request <= 1'b0;
		end

	always@(posedge clk or negedge rst_n)//给rd_request打一拍，把时序对上
		begin
			if(!rst_n) rd_request_reg <= 1'b0;
			else rd_request_reg <= rd_request;
		end

	//ROM的存储方式：24（地址）* 60（bit）
	laydown_location_rom	laydown_location_rom_inst
	(
		.address 	(rom_address),
		.clock 		(clk 		),
		.rden 		(rd_request ),

		.q 			(data_angle )
	);

	wire	[11:0] 	release_0;
	wire	[11:0] 	release_1;
	wire	[11:0] 	release_2;
	wire	[11:0] 	release_3;

	assign release_0 = data_angle[11: 0];	//11~ 0位为舵机0
	assign release_1 = data_angle[23:12];	//23~12位为舵机1
	assign release_2 = data_angle[35:24];	//35~24位为舵机2
	assign release_3 = data_angle[47:36];	//47~36位为舵机3
	assign release_4 = data_angle[59:48] + release_4_change;	//59~48位为舵机4

	reg 	[11:0]	add_servo0_delay;

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) add_servo0_delay <= 12'd0;
			else if(lay_0_add_flag) add_servo0_delay <= add_servo0_delay + 4'd10;
			else add_servo0_delay <= add_servo0_delay;
		end

	reg 	[11:0]	add_servo3_delay;

	always@( posedge clk or negedge rst_n )
		begin
			if(!rst_n) add_servo3_delay <= 12'd0;
			else if(lay_3_add_flag) add_servo3_delay <= add_servo3_delay + 4'd10;
			else add_servo3_delay <= add_servo3_delay;
		end

	always@(*)
		begin
			case(rom_address)
			5'd0://
				begin
					release_0_change <= release_0 + 6'd45 + add_servo0_delay;
					release_1_change <= release_1 + 5'd30;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd0 + add_servo3_delay;
				end
			5'd1:
				begin
					release_0_change <= release_0 + 8'd85 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 - 5'd10 + add_servo3_delay;
				end
			5'd2://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 - 5'd20 + add_servo3_delay;
				end
			5'd3://
				begin
					release_0_change <= release_0 + 5'd10 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 - 5'd10 + add_servo3_delay;
				end
			5'd4://
				begin
					release_0_change <= release_0 + 5'd15 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd0 + add_servo3_delay;
				end
			5'd5://
				begin
					release_0_change <= release_0 + 5'd15 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd0 + add_servo3_delay;
				end
			5'd6://
				begin
					release_0_change <= release_0 + 5'd30 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd10 + add_servo3_delay;
				end
			5'd7://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd5 + add_servo3_delay;
				end
			5'd8://
				begin
					release_0_change <= release_0 + 5'd15 + add_servo0_delay;
					release_1_change <= release_1 + 5'd10;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd0 + add_servo3_delay;
				end
			5'd9://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd10 + add_servo3_delay;
				end
			5'd10://
				begin
					release_0_change <= release_0 + 5'd5 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd15 + add_servo3_delay;
				end
			5'd11://
				begin
					release_0_change <= release_0 + 5'd15 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd10 + add_servo3_delay;
				end
			5'd12://
				begin
					release_0_change <= release_0 + 5'd25 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd20 + add_servo3_delay;
				end
			5'd13://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd20 + add_servo3_delay;
				end
			5'd14://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd20 + add_servo3_delay;
				end
			5'd15://
				begin
					release_0_change <= release_0 + 5'd25 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd20 + add_servo3_delay;
				end
			5'd16://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd25 + add_servo3_delay;
				end
			5'd17://
				begin
					release_0_change <= release_0 - 5'd15 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd10 + add_servo3_delay;
				end
			5'd18://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd20 + add_servo3_delay;
				end
			5'd19://
				begin
					release_0_change <= release_0 + 5'd25 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd25 + add_servo3_delay;
				end
			5'd20://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd25 + add_servo3_delay;
				end
			5'd21://
				begin
					release_0_change <= release_0 + 5'd25 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd20 + add_servo3_delay;
				end
			5'd22://
				begin
					release_0_change <= release_0 - 5'd35 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 + 5'd20 + add_servo3_delay;
				end
			5'd23://
				begin
					release_0_change <= release_0 + 5'd20 + add_servo0_delay;
					release_1_change <= release_1 + 5'd0;
					release_2_change <= release_2 + 5'd0;
					release_3_change <= release_3 - 5'd5 + add_servo3_delay;
				end
			default:
				begin
					release_0_change <= release_0;
					release_1_change <= release_1;
					release_2_change <= release_2;
					release_3_change <= release_3;
				end
			endcase
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n) valid_release_data <= 1'b0;
			else if(rd_request_reg)	valid_release_data <= 1'b1;
			else valid_release_data <= 1'b0;
		end

endmodule
