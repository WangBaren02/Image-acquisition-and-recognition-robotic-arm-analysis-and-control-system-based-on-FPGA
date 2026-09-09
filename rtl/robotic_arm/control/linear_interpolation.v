//线性插值模块：若令delay突变，则舵机速度过快，
//使用线性插值，每过一段时间步进一个step以使速度降低
//同时，可随时改变step的值
module linear_interpolation
(
	input				clk,				//时钟：1MHz
	input				rst_n,				//模块复位

	input				en_interpolation,	//线性插值使能信号
	input		[11:0]	duty_start,			//初始delay_time
	input		[11:0]	duty_target,		//目标delay_time
	input		[6:0]	DUTY_STEP,			//步进delay_time:0~127,127接近最高速(数值加大，速度越快)
	input		[19:0]	CNT_DELAY_DUTY,		//分频计数器最大值（数值加大，速度越慢）

	output	reg [11:0]	duty,				//实时delay_time
	output	reg			duty_done			//duty已完成从初始到目标delay_time信号
);
/////////////////////////////////////////////////////////////
	reg 	[19:0]	cnt;
	reg     		clk_div;

	always @(posedge clk or negedge rst_n)	//分频计数器
		begin
			if(!rst_n) cnt <= 20'b0;
			else if(cnt==CNT_DELAY_DUTY) cnt <= 20'b0;
			else cnt <= cnt + 1'b1;
		end

	always @(posedge clk or negedge rst_n)	//分频时钟,f=clk/(2*CNT_DELAY_DUTY)
		begin
			if(!rst_n) clk_div <= 1'b0;
			else if(cnt==CNT_DELAY_DUTY) clk_div <= ~ clk_div;
			else clk_div <= clk_div;
		end
//////////////////////////////////////////////////////////////
	reg 			en_interpolation_reg;

	wire			interpolation_start_flag;

	always @(posedge clk or negedge rst_n)	//给valid_interpolation打一拍
		begin
			if(!rst_n) en_interpolation_reg <= 1'b0;
			else en_interpolation_reg <= en_interpolation;
		end

	assign interpolation_start_flag = (en_interpolation) && (~en_interpolation_reg);	//提取en_interpolation的上升沿
////////////////////////////////////////////////////////////////////////////////////////////////
	wire	add_or_subtract;	//判断开始delay_time到目标是加还是减

	assign  add_or_subtract = ( duty >= duty_target ) ? 1'b1 : 1'b0 ;	//目前>结束为1，目前<结束为0		1则减，0则加
////////////////////////////////////////////////////////////////////////////////////////
	always @(posedge clk_div or negedge rst_n or posedge interpolation_start_flag)
		begin
			if(!rst_n) duty <= 12'b0;
			else if(interpolation_start_flag) duty <= duty_start;
			else if(duty==duty_target) duty <= duty_target;
			else
				case(add_or_subtract)
				1'b1:
					begin
						if(duty-DUTY_STEP<duty_target) duty <= duty_target;
						else if(duty>duty_target) duty <= duty - DUTY_STEP;
						else duty <= duty;
					end
				1'b0:
					begin
						if(duty+DUTY_STEP>duty_target) duty <= duty_target;
						else if(duty<duty_target) duty <= duty + DUTY_STEP;
						else duty <= duty;
					end
				default:;
				endcase
		end
/////////////////////////////////////////////////////////////////////////////
	always @(posedge clk or negedge rst_n) 	//duty是否步进到duty_target
		begin
			if(!rst_n) duty_done <= 1'b0;
			else if(duty == duty_target) duty_done <= 1'b1;
			else duty_done <= 1'b0;
		end

endmodule
