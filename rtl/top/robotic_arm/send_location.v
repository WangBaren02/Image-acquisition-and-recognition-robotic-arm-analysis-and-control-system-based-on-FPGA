//坐标发送模块
//将图像采集及识别模块中的坐标转换为实际以mm为单位的坐标数据
//将转换好的仓库坐标和目的地坐标发送给机械臂分析及控制模块
module send_location
(
	input				clk_20M,			//模块时钟:1MHz
	input				rst_n,				//模块复位

	input				key_start,			//开始按键——脉冲
    output	reg 		spi_start,         	//spi开始发送
    input				des_X_add_flag,
    input				des_Y_add_flag,

	input		[9:0]	VIP_X,				//图像坐标系下的X坐标:0-640
	input		[9:0]	VIP_Y,				//图像坐标系下的Y坐标:0-480
	input		[1:0]	shape,				//形状信息:2'b00圆,2'b01方,2'b10六,2'b11三
	input		[1:0]	color,				//颜色信息:2'b00红,2'b01黄,2'b10蓝,2'b11黑
	input		[8:0]	catch_4_angle,		//抓取物块的偏移角度
	input				VIP_done,			//完成一个物块图像处理的标志信号

	output	reg	[8:0]	X,					//机械臂坐标系下的X坐标:0-265
	output	reg	[8:0]	Y,					//机械臂坐标系下的Y坐标:0-175
	output	reg [2:0]	des_X,				//物块在目的地的X坐标
	output	reg [1:0]	des_Y,				//物块在目的地的Y坐标
	output	reg	[11:0]	catch_4_delay,		//抓取物块的偏移delay
	output	reg	[11:0]	release_4_change,	//放置三角形的偏移delay
	output	reg			VIP_data_valid,		//图像信息有效信号

	input				loop_done,			//机械臂完成一个物块循环的标志信号
	output	reg 		all_done			//机械臂完成所有任务的标志信号
);
////////////////////////////////////////////////////////////////////////////
	reg 	loop_done_reg;

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) loop_done_reg <= 1'b0;
			else loop_done_reg <= loop_done;
		end

	wire	loop_done_flag;

	assign loop_done_flag = ((!loop_done_reg) & (loop_done));
////////////////////////////////////////////////////////////////////
	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) spi_start <= 1'b0;
			else if(key_start||loop_done_flag) spi_start <= 1'b1;
			else spi_start <= 1'b0;
		end
///////////////////////////////////////////////////////////////////
	localparam NUMBER = 15;	///////////////////////////////////////////////////////////////////////////////////////////////////

	reg 	[4:0]	cnt_number;				//目的地摆放物块数量

	always@( posedge clk_20M or negedge rst_n)
		begin
			if(!rst_n) cnt_number <= 5'b0;
			else if(cnt_number==NUMBER-1'b1) cnt_number <= cnt_number;
			else if(loop_done_flag) cnt_number <= cnt_number + 1'b1;
			else cnt_number <= cnt_number;
		end

	always@( posedge clk_20M or negedge rst_n)	//机械臂完成所有任务的标志信号赋值
		begin
			if(!rst_n) all_done <= 1'b0;
			else if(cnt_number==NUMBER-1'b1) all_done <= 1'b1;
			else all_done <= all_done;
		end
/////////////////////////////////////////////////////////////
	reg				VIP_done_reg;			//给VIP_done打一拍

	always@( posedge clk_20M or negedge rst_n)
		begin
			if(!rst_n) VIP_done_reg <= 1'b0;
			else VIP_done_reg <= VIP_done;
		end
/////////////////////////////////////////////////////////////////////////////////
//物块个数计数器:用到哪几个就写哪几个

//红色
	reg 	[4:0]	cnt_red_round;		//红圆

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_red_round <= 5'd0;
			else if((shape==2'b00)&&(color==2'b00)&&(VIP_done)) cnt_red_round <= cnt_red_round + 1'b1;
			else cnt_red_round <= cnt_red_round;
		end

	reg 	[4:0]	cnt_red_square;		//红方

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_red_square <= 5'd0;
			else if((shape==2'b01)&&(color==2'b00)&&(VIP_done)) cnt_red_square <= cnt_red_square + 1'b1;
			else cnt_red_square <= cnt_red_square;
		end

	reg 	[4:0]	cnt_red_six;		//红六

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_red_six <= 5'd0;
			else if((shape==2'b10)&&(color==2'b00)&&(VIP_done)) cnt_red_six <= cnt_red_six + 1'b1;
			else cnt_red_six <= cnt_red_six;
		end

	reg 	[4:0]	cnt_red_tri;		//红三

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_red_tri <= 5'd0;
			else if((shape==2'b11)&&(color==2'b00)&&(VIP_done)) cnt_red_tri <= cnt_red_tri + 1'b1;
			else cnt_red_tri <= cnt_red_tri;
		end

// //黄色
	reg 	[4:0]	cnt_yellow_round;	//黄圆

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_yellow_round <= 5'd0;
			else if((shape==2'b00)&&(color==2'b01)&&(VIP_done)) cnt_yellow_round <= cnt_yellow_round + 1'b1;
			else cnt_yellow_round <= cnt_yellow_round;
		end

	reg 	[4:0]	cnt_yellow_square;	//黄方

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_yellow_square <= 5'd0;
			else if((shape==2'b01)&&(color==2'b01)&&(VIP_done)) cnt_yellow_square <= cnt_yellow_square + 1'b1;
			else cnt_yellow_square <= cnt_yellow_square;
		end

	reg 	[4:0]	cnt_yellow_six;		//黄六

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_yellow_six <= 5'd0;
			else if((shape==2'b10)&&(color==2'b01)&&(VIP_done)) cnt_yellow_six <= cnt_yellow_six + 1'b1;
			else cnt_yellow_six <= cnt_yellow_six;
		end

	reg 	[4:0]	cnt_yellow_tri;		//黄三

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_yellow_tri <= 5'd0;
			else if((shape==2'b11)&&(color==2'b01)&&(VIP_done)) cnt_yellow_tri <= cnt_yellow_tri + 1'b1;
			else cnt_yellow_tri <= cnt_yellow_tri;
		end

// //蓝色
	reg 	[4:0]	cnt_blue_round;		//蓝圆

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_blue_round <= 5'd0;
			else if((shape==2'b00)&&(color==2'b10)&&(VIP_done)) cnt_blue_round <= cnt_blue_round + 1'b1;
			else cnt_blue_round <= cnt_blue_round;
		end

	reg 	[4:0]	cnt_blue_square;	//蓝方

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_blue_square <= 5'd0;
			else if((shape==2'b01)&&(color==2'b10)&&(VIP_done)) cnt_blue_square <= cnt_blue_square + 1'b1;
			else cnt_blue_square <= cnt_blue_square;
		end

	reg 	[4:0]	cnt_blue_six;		//蓝六

	always@( posedge clk_20M or negedge rst_n )
		begin
		if(!rst_n) cnt_blue_six <= 5'd0;
			else if((shape==2'b10)&&(color==2'b10)&&(VIP_done)) cnt_blue_six <= cnt_blue_six + 1'b1;
			else cnt_blue_six <= cnt_blue_six;
		end

	reg 	[4:0]	cnt_blue_tri;		//蓝三

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_blue_tri <= 5'd0;
			else if((shape==2'b11)&&(color==2'b10)&&(VIP_done)) cnt_blue_tri <= cnt_blue_tri + 1'b1;
			else cnt_blue_tri <= cnt_blue_tri;
		end

//黑色
	reg 	[4:0]	cnt_black_round;	//黑圆

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_black_round <= 5'd0;
			else if((shape==2'b00)&&(color==2'b11)&&(VIP_done)) cnt_black_round <= cnt_black_round + 1'b1;
			else cnt_black_round <= cnt_black_round;
		end

	reg 	[4:0]	cnt_black_square;	//黑方

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_black_square <= 5'd0;
			else if((shape==2'b01)&&(color==2'b11)&&(VIP_done)) cnt_black_square <= cnt_black_square + 1'b1;
			else cnt_black_square <= cnt_black_square;
		end

	reg 	[4:0]	cnt_black_six;		//黑六

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_black_six <= 5'd0;
			else if((shape==2'b10)&&(color==2'b11)&&(VIP_done)) cnt_black_six <= cnt_black_six + 1'b1;
			else cnt_black_six <= cnt_black_six;
		end

	reg 	[4:0]	cnt_black_tri;		//黑三

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_black_tri <= 5'd0;
			else if((shape==2'b11)&&(color==2'b11)&&(VIP_done)) cnt_black_tri <= cnt_black_tri + 1'b1;
			else cnt_black_tri <= cnt_black_tri;
		end
//////////////////////////////////////////////////////
	reg 	[1:0]	release_tri_pos;	//放置三角形的姿态

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) release_tri_pos <= 2'b0;
			else if(shape==2'b11)
				begin
					if(cnt_black_tri==1) release_tri_pos <= 2'd2;
					else if(cnt_blue_tri==1) release_tri_pos <= 2'd3;
					else if(cnt_yellow_tri==1) release_tri_pos <= 2'd2;
					else if(cnt_red_tri==1) release_tri_pos <= 2'd1;
					else release_tri_pos <= 2'b0;
				end
			else release_tri_pos <= 2'b0;
		end

	//有几个三角形就有几个else if
//////////////////////////////////////////////////////
	wire	[3:0]	situation;

	assign situation = {color[1:0],shape[1:0]};
//物体目的地坐标:用到哪几个就写哪几个
	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) begin des_X <= 3'd0; des_Y <= 2'd0; end
			else if(VIP_done_reg)
			//初赛目的地
				begin
					case(situation)
					4'b10_00:
						if(cnt_blue_round==5'd1) begin des_X <= 3'd0; des_Y <= 2'd0; end 	//目的地地址 0
					4'b01_01:
						if(cnt_yellow_square==5'd1) begin des_X <= 3'd1; des_Y <= 2'd0; end 	//目的地地址 1
					// 4'b:
					// 	if() begin des_X <= 3'd2; des_Y <= 2'd0; end 	//目的地地址 2
					// 4'b:
					// 	if() begin des_X <= 3'd3; des_Y <= 2'd0; end 	//目的地地址 3
					4'b10_11:
						if(cnt_blue_tri==5'd1) begin des_X <= 3'd4; des_Y <= 2'd0; end 	//目的地地址 4
					// 4'b:
					// 	if() begin des_X <= 3'd5; des_Y <= 2'd0; end  	//目的地地址 5

					// 4'b:
					// 	if() begin des_X <= 3'd0; des_Y <= 2'd1; end 	//目的地地址 6
					4'b11_01:
						if(cnt_black_square==5'd1) begin des_X <= 3'd1; des_Y <= 2'd1; end 	//目的地地址 7
					4'b00_11:
						if(cnt_red_tri==5'd1) begin des_X <= 3'd2; des_Y <= 2'd1; end  	//目的地地址 8
					4'b11_11:
						if(cnt_black_tri==5'd1) begin des_X <= 3'd3; des_Y <= 2'd1; end  	//目的地地址 9
						else if(cnt_black_tri==5'd2) begin des_X <= 3'd4; des_Y <= 2'd3; end 	//目的地地址22
					4'b01_11:
						if(cnt_yellow_tri==5'd1) begin des_X <= 3'd4; des_Y <= 2'd1; end 	//目的地地址10
					// 4'b:
					// 	if() begin des_X <= 3'd5; des_Y <= 2'd1; end 	//目的地地址11

					4'b10_01:
						if(cnt_blue_square==5'd1) begin des_X <= 3'd0; des_Y <= 2'd2; end 	//目的地地址12
					// 4'b:
					// 	if() begin des_X <= 3'd1; des_Y <= 2'd2; end 	//目的地地址13
					4'b00_00:
						if(cnt_red_round==5'd1) begin des_X <= 3'd2; des_Y <= 2'd2; end  	//目的地地址14
					4'b01_10:
						if(cnt_yellow_six==5'd1) begin des_X <= 3'd3; des_Y <= 2'd2; end  	//目的地地址15
					// 4'b:
					// 	if() begin des_X <= 3'd4; des_Y <= 2'd2; end 	//目的地地址16
					4'b11_00:
						if(cnt_black_round==5'd1) begin des_X <= 3'd5; des_Y <= 2'd2; end 	//目的地地址17

					// 4'b:
					// 	if() begin des_X <= 3'd0; des_Y <= 2'd3; end 	//目的地地址18
					4'b01_00:
						if(cnt_yellow_round==5'd1) begin des_X <= 3'd1; des_Y <= 2'd3; end 	//目的地地址19
					4'b11_10:
						if(cnt_black_six==5'd1) begin des_X <= 3'd2; des_Y <= 2'd3; end
					// 4'b:
					// 	if() begin des_X <= 3'd3; des_Y<=2'd3; end 	//目的地地址20
					// 4'b:
					//	if() begin des_X <= 3'd3; des_Y <= 2'd3; end 	//目的地地址21
					// 4'b:
					//	if() begin des_X <= 3'd4; des_Y <= 2'd3; end 	//目的地地址22
					4'b00_01:
						if(cnt_red_square==5'd1) begin des_X <= cnt_des_X; des_Y <= cnt_des_Y; end 	//目的地地址23
					default: begin des_X <= des_X; des_Y <= des_Y; end
					endcase
				end
			else begin des_X <= des_X; des_Y <= des_Y; end
		end

	reg 	[2:0]	cnt_des_X;

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_des_X <= 3'd0;
			else if(des_X_add_flag) cnt_des_X <= cnt_des_X + 1'b1;
			else cnt_des_X <= cnt_des_X;
		end

	reg 	[1:0]	cnt_des_Y;

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_des_Y <= 2'd0;
			else if(des_Y_add_flag) cnt_des_Y <= cnt_des_Y + 1'b1;
			else cnt_des_Y <= cnt_des_Y;
		end
///////////////////////////////////////////////////////
//坐标转换:像素点个数转换为mm
	wire	[8:0]	arm_X;
	wire	[8:0]	arm_Y;

	assign arm_X = {VIP_X[9:1]} + {6'b0,VIP_X[9:7]} + 4'd10;	//arm_X = VIP_X * 325 / 640
	assign arm_Y = {VIP_Y[9:1]} + {6'b0,VIP_X[9:7]} + 4'd10;	//arm_Y = VIP_Y * 325 / 640
//////////////////////////////////////////////////////////////////////////////////////////////////////
// //按实际情况加偏置
// 	reg		[8:0]	arm_compensatex_X;
// 	reg 	[7:0]	arm_compensatex_Y;

// 	always@(*)
// 		begin
// 			if(arm_X>8'd198 && arm_Y>8'd117)
// 				begin
// 					arm_compensatex_X <= arm_X + 5'd18;
// 					arm_compensatex_Y <= arm_Y - 4'd7;
// 				end
// 			else if(arm_X>8'd198 && arm_Y>8'd58)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd11;
// 					arm_compensatex_Y <= arm_Y - 4'd4;
// 				end
// 			else if(arm_X>8'd198)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd7;
// 					arm_compensatex_Y <= arm_Y - 1'b1;
// 				end
// 			else if(arm_X>8'd132 && arm_Y>8'd117)
// 				begin
// 					arm_compensatex_X <= arm_X + 5'd23;
// 					arm_compensatex_Y <= arm_Y - 4'd5;
// 				end
// 			else if(arm_X>8'd132 && arm_Y>8'd58)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd13;
// 					arm_compensatex_Y <= arm_Y - 4'd5;
// 				end
// 			else if(arm_X>8'd132)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd6;
// 					arm_compensatex_Y <= arm_Y + 4'd0;
// 				end
// 			else if(arm_X>8'd66 && arm_Y>8'd117)
// 				begin
// 					arm_compensatex_X <= arm_X + 5'd20;
// 					arm_compensatex_Y <= arm_Y + 4'd3;
// 				end
// 			else if(arm_X>8'd66 && arm_Y>8'd58)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd10;
// 					arm_compensatex_Y <= arm_Y + 4'd2;
// 				end
// 			else if(arm_X>8'd66)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd7;
// 					arm_compensatex_Y <= arm_Y - 4'd4;
// 				end
// 			else if(arm_Y>8'd117)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd11;
// 					arm_compensatex_Y <= arm_Y + 4'd7;
// 				end
// 			else if(arm_Y>8'd58)
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd6;
// 					arm_compensatex_Y <= arm_Y + 4'd3;
// 				end
// 			else
// 				begin
// 					arm_compensatex_X <= arm_X + 4'd6;
// 					arm_compensatex_Y <= arm_Y - 4'd2;
// 				end
// 		end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//用于与1MHz时钟信号同步
	reg 	[5:0] 	cnt_VIP_done_reg;

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) cnt_VIP_done_reg <= 6'd0;
			else if(VIP_done_reg) cnt_VIP_done_reg <= 6'd39;
			else if(cnt_VIP_done_reg!=6'd0) cnt_VIP_done_reg <= cnt_VIP_done_reg - 1'b1;
			else cnt_VIP_done_reg <= cnt_VIP_done_reg;
		end

	reg 			VIP_done_reg_1MHz;

	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n) VIP_done_reg_1MHz <= 1'b0;
			else if(cnt_VIP_done_reg!=6'd0) VIP_done_reg_1MHz <= 1'b1;
			else VIP_done_reg_1MHz <= 1'b0;
		end
//信息输出
	always@( posedge clk_20M or negedge rst_n )
		begin
			if(!rst_n)
				begin
					X <= 9'b0;
					Y <= 9'b0;
					catch_4_delay <= 12'b0;
					release_4_change <= 12'b0;

					VIP_data_valid <= 1'b0;
				end
			else if(VIP_done_reg_1MHz)
				begin
					X <= arm_X;//arm_compensatex_X;	//
					Y <= arm_Y;//arm_compensatex_Y;	//
					catch_4_delay <= {1'b0,catch_4_angle,2'b0} + {2'b0,catch_4_angle,1'b0} + {3'b0,catch_4_angle} + {5'b0,catch_4_angle[8:2]} + {6'b0,catch_4_angle[8:3]} + {8'b0,catch_4_angle[8:5]};
					release_4_change <= release_tri_pos * 10'd666;

					VIP_data_valid <= 1'b1;
				end
			else
				begin
					X <= X;
					Y <= Y;
					catch_4_delay <= catch_4_delay;
					release_4_change <= release_4_change;

					VIP_data_valid <= 1'b0;
				end
		end

endmodule
