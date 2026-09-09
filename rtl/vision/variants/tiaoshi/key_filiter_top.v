module	key_filiter_top
(
	input	wire			clk			,
	input	wire			rst_n		,
	input	wire			change_in	,

	output	wire			key_change

);

key_filter
#(
    .CNT_MAX (20'd999_999)
)key_filter_inst_4
(
    .sys_clk     (clk	),
    .sys_rst_n   (rst_n ),
    .key_in      (change_in),

    .key_flag    (key_change)

);



endmodule