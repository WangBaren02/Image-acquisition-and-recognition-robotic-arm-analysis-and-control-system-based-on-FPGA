module	connect_8_area
#(
	parameter	IMG_WIDTH 	= 640,
	parameter	IMG_HEIGHT 	= 480,
	parameter	LABEL_BITS  = 5	 ,
	parameter   BACK_NUM	= 1
)
(
	input	wire			clk			,
	input	wire			rst_n		,
	input	wire			href_in		,
	input	wire			vsync_in	,
	input	wire			de_in		,
	input	wire			pixel_in	,

	output	wire			href_out	,
	output	wire			vsync_out	,
	output	wire			de_out		,

	output	reg				bin_out

);

reg			href_in_d0		;
reg			href_in_d1		;
reg			href_in_d2		;

reg			href_in_d3		;

reg			vsync_in_d0		;
reg			vsync_in_d1		;
reg			vsync_in_d2		;

reg			vsync_in_d3		;

reg			de_in_d0		;
reg			de_in_d1		;
reg			de_in_d2		;

reg			de_in_d3		;

reg			pixel_in_d0		;
reg			pixel_in_d1		;

reg			pixel_in_d2		;
//鍍忕礌璁℃暟鍣�
reg		[19:0]	cnt_pixel	;


wire		hrefd1_neg_flag ;
wire		vsyncd1_pos_flag;

reg	[9:0]	x_cnt			;
reg	[9:0]	y_cnt			;

reg	[9:0]	back_cnt		;
reg	[9:0]	back_cnt_r		;

reg	[3:0]	href_obbject	;

reg	[9:0]	x_cnt_r			;
reg	[9:0]	y_cnt_r			;



reg	[LABEL_BITS - 1:0]	label_href_max	;
wire	[LABEL_BITS - 1:0]	current_label	;
reg	[LABEL_BITS - 1:0]	global_label	;
reg	[LABEL_BITS - 1:0]	three_min		;

(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	current_line	[0 : IMG_WIDTH - 1];
(* ramstyle = "M9K" *) reg	[LABEL_BITS - 1:0]	pass_line		[0 : IMG_WIDTH - 1];




wire			fifo_dout		;

integer	i;
integer	j;
integer	n;



always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
		href_in_d0		    <=  1'b0;
		href_in_d1		    <=  1'b0;
		href_in_d2		    <=  1'b0;
		href_in_d3		    <=  1'b0;
		vsync_in_d0		    <=  1'b0;
		vsync_in_d1		    <=  1'b0;
		vsync_in_d2		    <=  1'b0;
		vsync_in_d3		    <=  1'b0;
		de_in_d0		    <=  1'b0;
		de_in_d1		    <=  1'b0;
		de_in_d2		    <=  1'b0;
		de_in_d3		    <=  1'b0;
		pixel_in_d0			<=	1'b0;
		pixel_in_d1         <=	1'b0;
		pixel_in_d2         <=	1'b0;
		end
	else
		begin
		href_in_d0			<=	href_in		;
		href_in_d1			<=	href_in_d0	;
		href_in_d2			<=	href_in_d1	;
		href_in_d3		    <=  href_in_d2	;
		vsync_in_d0			<=	vsync_in	;
		vsync_in_d1			<=	vsync_in_d0	;
		vsync_in_d2			<=	vsync_in_d1	;
		vsync_in_d3			<=	vsync_in_d2	;
		de_in_d0			<=	de_in		;
		de_in_d1			<=	de_in_d0	;
		de_in_d2			<=	de_in_d1	;
		de_in_d3			<=	de_in_d2	;
		pixel_in_d0			<=	pixel_in	;
		pixel_in_d1         <=	pixel_in_d0	;
		pixel_in_d2         <=	pixel_in_d1	;
		end

assign	hrefd1_neg_flag  = (~href_in_d0) &	href_in_d1;
assign	vsyncd1_pos_flag = vsync_in_d0 & (~vsync_in_d1);


always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
			x_cnt <= 10'd0;
			y_cnt <= 10'd0;
		end
	else	if(vsyncd1_pos_flag)
		begin
			x_cnt <= 10'd0;
			y_cnt <= 10'd0;
		end
	else	if(hrefd1_neg_flag)
		begin
			x_cnt <= 10'd0;
			y_cnt <= y_cnt + 10'd1;
		end
	else	if(de_in)
		begin
			x_cnt <=  x_cnt + 10'd1;
		end

always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin
			x_cnt_r <= 10'd0;
			y_cnt_r <= 10'd0;
		end
	else
		begin
			x_cnt_r <= x_cnt;
			y_cnt_r <= y_cnt;
		end

//鍍忕礌璁℃暟鍣�
always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		cnt_pixel <= 1'd0;
	else	if(vsyncd1_pos_flag)
		cnt_pixel <= 1'd0;
	else	if(de_in && pixel_in)
		cnt_pixel <= cnt_pixel + 1'd1;



//琛屽悗鏅鏁板櫿
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 0 || vsyncd1_pos_flag)
		back_cnt <= 9'd0;
	else	if(hrefd1_neg_flag)
		back_cnt <= 9'd0;
	else	if(de_in && pixel_in)
		back_cnt <= 9'd0;
	else	if(de_in && pixel_in == 1'd0)
		back_cnt	<= back_cnt + 1'd1;

//琛屽悗鏅鏁板櫒鎵撴媿
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 0)
		back_cnt_r <= 9'd0;
	else
		back_cnt_r	<= back_cnt;

//鍗曡鐗╿綋href_obbject	;(宸甦e0涓夸釜鏃堕挓鍛ㄦ溿)
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 0 || vsyncd1_pos_flag)
		href_obbject	<= 4'd0;
	else	if(hrefd1_neg_flag)
		href_obbject	<= 4'd0;
	else	if(back_cnt_r > back_cnt)
		href_obbject	<= href_obbject + 1'd1;





always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		label_href_max	<= 4'd0;
	else	if(vsyncd1_pos_flag)
		label_href_max	<= 4'd0;
	else	if(x_cnt == 10'd637)
		label_href_max	<= 4'd0;
	else	if(hrefd1_neg_flag)
		for	(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)
			if(current_line[i] > label_href_max)
				label_href_max <= current_line[i];


always@(posedge	clk or negedge	rst_n)
	if(rst_n == 0 || vsyncd1_pos_flag )
		global_label	<= 1'b0;
	else   if(global_label < 4'd4)    begin
	   if(global_label < label_href_max)
		global_label	<= label_href_max;
	end
	else   if(global_label  >= 4'd4)
		global_label	<= 4'd6;
	else
	   global_label    <= global_label;





//assign	current_label = global_label + 1;
assign	current_label = ((cnt_pixel <= 12'd640) && (href_obbject == 1'd1) && (global_label == 2'd0))? 1'd1 : global_label + 2;

//鎻愬墠涓夸釜鏃堕挓鍛ㄦ湡鎵惧埌褰撳墠鍍忕礌翵瑰簲鐨勬溈灏忓靿//涓婇潰涓変釜鍍忕礌鐨勬爣绛炬案杩滃皬浜庣瓑浜庡乏杈圭殑鏍囩
always@(posedge	clk or negedge	rst_n)//three_min瑕佷笌de_in_0鍚屾锛岃繖鏍锋姄鍙栫殑x_cnt涓巘hree_min鎵嶅悓姝￿
	if(rst_n == 1'b0)
		three_min <= 4'd1;
	else	if(de_in && pixel_in)begin//姝ゆ椂x_cnt鏄墠涓夸釜鍍忕礌鐨勫潗鏍�
		if(pass_line[x_cnt + 2'd2] != 0)begin
			if(pass_line[x_cnt + 3'd5] == 1'b1)
				//three_min <=pass_line[x_cnt];
				three_min	<= pass_line[x_cnt +3'd5];
			else	if(pass_line[x_cnt - 3'd5] == 1'b1)
				three_min	<= pass_line[x_cnt - 3'd5];
			else	begin
				three_min <= pass_line[x_cnt + 2'd2];
				for(j = 0; j <2 ; j = j+1)begin
					if(pass_line[x_cnt + j]!=0)begin
						if(three_min >  pass_line[x_cnt + j])
							three_min	<= pass_line[x_cnt + j];
				end
			end
		end
	end
		else	if(pass_line[x_cnt + 2'd1] !=0)begin
				if(pass_line[x_cnt + 3'd5] == 1'b1)
					three_min <= pass_line[x_cnt + 3'd5];
				else
					three_min <= pass_line[x_cnt + 2'd1];
					if(pass_line[x_cnt] != 0)begin
						if(three_min > pass_line[x_cnt])
							three_min <=  pass_line[x_cnt];
					end
				end
		else	if(pass_line[x_cnt] !=0)
			//if(pass_line[x_cnt + 2'd3] == 1'd1)
				three_min <= pass_line[x_cnt];
		else
			three_min <= 4'd0;
	end
	else
		three_min	<= 4'd0;

//瑕佷箞涓嶅姞鍥炴函锛岃涔堬紝璁╅偅涓鍓嶄竴涓�
always@(posedge	clk or negedge	rst_n)
	if(rst_n == 1'b0)
		begin

		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
			current_line[i] <= 4'd0;
			pass_line[i]	<= 4'd0;
			end
		end
	else	if(vsyncd1_pos_flag)
		begin

		for(i = 0 ; i < IMG_WIDTH - 1 ;i = i + 1)begin
			current_line[i] <= 4'd0;
			pass_line[i]	<= 4'd0;
			end
		end
	else	if(de_in_d0)begin

		if(pixel_in_d0 == 1'b1)	begin
			if(pass_line[x_cnt - 1'd1] == 1'd0 && pass_line[x_cnt] == 1'd0 && pass_line[x_cnt  + 1'd1] == 1'd0 && current_line[x_cnt - 1'd1] == 1'd0)
				current_line[x_cnt]	<= current_label;
			else	if(pass_line[x_cnt - 1'd1] == 1'd0 && pass_line[x_cnt] == 1'd0 && pass_line[x_cnt  + 1'd1] == 1'd0 && current_line[x_cnt - 1'd1] != 1'd0)begin
				current_line[x_cnt]	<= current_line[x_cnt - 1'd1];
				//if(current_line[x_cnt - 1'd1] != 0)
				//	current_line[x_cnt - 1'd1] <= three_min;
			end
			else begin
				current_line[x_cnt]	<= three_min;

				if(pass_line[x_cnt - 1'd1] != 0)
					pass_line[x_cnt - 1'd1] <= three_min;
				if(pass_line[x_cnt] != 0)
					pass_line[x_cnt] <= three_min;
				//if(pass_line[x_cnt - 2'd2] != 0)
				//	pass_line[x_cnt - 2'd2] <= three_min;
				//if(pass_line[x_cnt - 2'd3] != 0)
				//	pass_line[x_cnt - 2'd3] <= three_min;
				//if(three_min == 1'd1)
				//	begin
				if(current_line[x_cnt - 1'd1] != 0)
					current_line[x_cnt - 1'd1] <= three_min;
				if(current_line[x_cnt - 2'd2] != 0)
					current_line[x_cnt - 2'd2]	<= three_min;
				if(current_line[x_cnt - 2'd3] != 0)
					current_line[x_cnt - 2'd3]	<= three_min;
				if(current_line[x_cnt - 3'd4] != 0)
					current_line[x_cnt - 3'd4]	<= three_min;
				if(current_line[x_cnt - 3'd5] != 0)
					current_line[x_cnt - 3'd5]	<= three_min;
				//if(pass_line[x_cnt+2'd1] != 0)
				//	pass_line[x_cnt+2'd1] <= three_min;
					//end
				//if(pass_line[x_cnt - 3'd4] != 0)
				//	pass_line[x_cnt - 3'd4] <= three_min;

				//if(pass_line[x_cnt+2'd2] != 0)
				//	pass_line[x_cnt+2'd2] <= three_min;


			end
		end else	if(pixel_in_d0 == 1'b0)
			current_line[x_cnt]	<= 4'd0;
		end
	else	if(hrefd1_neg_flag)	begin
		for(i = 0 ; i < IMG_WIDTH - 1 ; i = i + 1)	begin
			pass_line[i] <= current_line[i];
			end
		end

fifo_640x1 fifo_640x1_inst (
  .clk(clk),      // input wire clk
  .srst(~rst_n||vsyncd1_pos_flag),    // input wire srst
  .din(pixel_in_d0),      // input wire [0 : 0] din
  .wr_en(de_in_d0),  // input wire wr_en
  .rd_en(y_cnt >= 10'd1 && de_in_d0),  // input wire rd_en
  .dout(fifo_dout),    // output wire [0 : 0] dout
  .full(),    // output wire full
  .empty()  // output wire empty
);






always@(posedge clk or negedge rst_n)
	if(rst_n == 1'b0)
		bin_out <= 1'b0;
	else	if(vsyncd1_pos_flag)
		bin_out <= 1'b0;
	else	if(fifo_dout == 1'b0)
		bin_out <= 1'b0;
	else	if(fifo_dout == 1'b1 && (pass_line[x_cnt_r] == 1) )//pass_line[x_cnt_r] == 1
		bin_out <= 1'b1;
	else
		bin_out <= 1'b0;





assign	href_out	= href_in_d2;
assign	vsync_out	= vsync_in_d2;
assign	de_out		= de_in_d2;



endmodule
