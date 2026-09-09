module cordic_ATAN2
(
	input			clk_100M,
	input			rst_n,

	input	[8:0]	X,
	input	[8:0]	Y,

	output	[8:0]	res
);
//////////////////////////////////////////////
    wire	[17:0]	X_cal;

    assign X_cal = {2'b0,X,8'b0};

    wire	[17:0]	Y_cal;

    assign Y_cal = {1'b0,Y,8'b0};
////////////////////////////////////////////////
	wire	[10:0]	res_cal;

	atan2 u0
	(
		.clk    (clk_100M), // clk.clk
		.areset (~rst_n), 	// areset.reset
		.x      (X_cal),    // x.x
		.y      (Y_cal),    // y.y
		.q      (res_cal)   // q.q
	);

	wire	[18:0]	res_unsigned;

	assign res_unsigned = {res_cal[9:0],5'b0} + {res_cal[9:0],4'b0} + {res_cal[9:0],3'b0} + res_cal[9:0] + res_cal[9:2] + res_cal[9:5] + res_cal[9:7];

	wire	[16:0]	res_unsigned_d_10_a_5;

	assign res_unsigned_d_10_a_5 = res_unsigned/10 + 5;

	assign res = (res_unsigned_d_10_a_5 * 10) >> 8;

endmodule
