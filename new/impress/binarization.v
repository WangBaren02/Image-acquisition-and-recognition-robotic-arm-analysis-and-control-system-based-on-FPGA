module binarization(
    input               clk            	,   // 时钟信号
    input               rst_n          	,   // 复位信号（低有效）

	input				per_frame_vsync	,
	input				per_frame_href 	,	
	input				per_frame_clken	,
	input		[7:0]	per_img_Y  		,
	input		[7:0]	per_img_Cb		,
	input		[7:0]	per_img_Cr		,
	input				key_color		,

	output	reg 		post_frame_vsync,	
	output	reg 		post_frame_href ,	
	output	reg 		post_frame_clken,	
	output	reg 		post_img_Bit  			

);

reg		[3:0]		color_cnt;
reg					key_color_r;
wire				color_pos;






//打拍取沿
always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		key_color_r <= 1'b0;
	else
		key_color_r <= key_color;
		
assign	color_pos = key_color & (~key_color_r);



always@(posedge	clk or negedge rst_n)
	if(rst_n == 1'b0)
		color_cnt <= 4'd0;
	else	if(color_pos == 1'b1)
		color_cnt <= color_cnt + 4'd1;
	else
		color_cnt <= color_cnt;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        post_img_Bit <= 1'b0;
	else
		case (color_cnt)
			4'd2	:	if((per_img_Y < 8'd206 && per_img_Y > 8'd20)//蓝色
							&& per_img_Cb > 8'd145) 
							post_img_Bit <= 1'b1;
					else
						post_img_Bit <= 1'b0;
											
			
			4'd0	:if((per_img_Y < 8'd238) && (per_img_Cb < 8'd151 )//红色
							&& (per_img_Cr < 8'd222  && per_img_Cr > 8'd140))
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;
			
			
			
			4'd1	:if((per_img_Y < 8'd194) && (per_img_Cb < 8'd84 )//黄色
							&& (per_img_Cr < 8'd140 && per_img_Cr > 8'd8))
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;
			
			
			
			4'd3	:if((per_img_Y < 8'd85) && (per_img_Cb < 8'd136) //黑色
							&& (per_img_Cr < 8'd133))
								post_img_Bit <= 1'b1;
						else
							post_img_Bit <= 1'b0;
			
			
			
			default	:	post_img_Bit <= 1'b0;
			endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        post_frame_vsync <= 1'd0;
        post_frame_href  <= 1'd0;
        post_frame_clken <= 1'd0;
    end
    else begin
        post_frame_vsync <= per_frame_vsync;
        post_frame_href  <= per_frame_href ;
        post_frame_clken <= per_frame_clken;
    end
end

endmodule







