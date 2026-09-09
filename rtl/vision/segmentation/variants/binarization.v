//module binarization(
//    input               clk             ,   // 时钟信号
//    input               rst_n           ,   // 复位信号（低有效）
//
//	input				per_frame_vsync ,
//	input				per_frame_href  ,
//	input				per_frame_clken ,
//	input		[7:0]	per_img_Y  		,
//	input		[7:0]	per_img_Cb		,
//	input		[7:0]	per_img_Cr		,
//	input				key_color		,//改变颜色
//	input				key_y			,
//	input				key_cb			,
//	input				key_cr			,
//	input				key_change		,//改变加减操作
//	input				key_area		,
//
//	output	reg 		post_frame_vsync,
//	output	reg 		post_frame_href ,
//	output	reg 		post_frame_clken,
//	output	reg 		post_img_Bit    ,
//
//	input		[7:0]	Binary_Threshold
//);
//
////二值化
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n)
//        post_img_Bit <= 1'b0;
//    else begin
//		if((per_img_Y < 8'd255 && per_img_Y > 0) &&
//			//(per_img_Cb > 8'd100 && per_img_Cb < 8'd150) &&
//			(per_img_Cr < 8'd255))
//			post_img_Bit <= 1'b1;
//		else
//			post_img_Bit <= 1'b0;
//	end
//end
//
//
//always@(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        post_frame_vsync <= 1'd0;
//        post_frame_href  <= 1'd0;
//        post_frame_clken <= 1'd0;
//    end
//    else begin
//        post_frame_vsync <= per_frame_vsync;
//        post_frame_href  <= per_frame_href ;
//        post_frame_clken <= per_frame_clken;
//    end
//end
//
//endmodule

module binarization(
    input               clk            	,   // 时钟信号
    input               rst_n          	,   // 复位信号（低有效）

	input				per_frame_vsync	,
	input				per_frame_href 	,
	input				per_frame_clken	,
	input		[7:0]	per_img_Y  		,
	input		[7:0]	per_img_Cb		,
	input		[7:0]	per_img_Cr		,

	output	reg 		post_frame_vsync,
	output	reg 		post_frame_href ,
	output	reg 		post_frame_clken,
	output	reg 		post_img_Bit  	,

	input		[7:0]	Binary_Threshold
);
//
//二值化
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        post_img_Bit <= 1'b0;
    else begin//per_img_Y < 8'H45 && per_img_Y < 8'H9C
		if(per_img_Y < 8'd120 && per_img_Y > 8'd20&& per_img_Cb > 8'H97)//per_img_Y > 8'd150
		//(per_img_Cb > 8'd70) && (per_img_Cb < 8'd130) && (per_img_Cr > 8'd130) && (per_img_Cr < 8'd175)
			post_img_Bit <= 1'b1;
		else
			post_img_Bit <= 1'b0;
	end
end

//(per_img_Y < 8'd255 && per_img_Y > 0) &&
			//(per_img_Cb > 8'd100 && per_img_Cb < 8'd150) &&
			//(per_img_Cr < 8'd255)


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
