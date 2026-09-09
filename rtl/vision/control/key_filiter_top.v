module	key_filiter_top
(
	input	wire			clk			,
	input	wire			rst_n		,
	input	wire			color_in	,
	input	wire			mode_in		,
	input	wire			ycbcr_in	,
	input	wire			add_div_in	,


    output	wire			key_color	,
	output	wire            key_mode	,
	output	wire            key_ycbcr	,
	output	wire            key_add_div

);

key_filter
#(
    .CNT_MAX (20'd999_999)
)key_filter_inst_1
(
    .sys_clk     (clk	),
    .sys_rst_n   (rst_n ),
    .key_in      (color_in),

    .key_flag    (key_color)

);

key_filter
#(
    .CNT_MAX (20'd999_999)
)key_filter_inst_2
(
    .sys_clk     (clk	),
    .sys_rst_n   (rst_n ),
    .key_in      (mode_in),

    .key_flag    (key_mode)

);

key_filter
#(
    .CNT_MAX (20'd999_999)
)key_filter_inst_3
(
    .sys_clk     (clk	),
    .sys_rst_n   (rst_n ),
    .key_in      (ycbcr_in),

    .key_flag    (key_ycbcr)

);

key_filter
#(
    .CNT_MAX (20'd999_999)
)key_filter_inst_4
(
    .sys_clk     (clk	),
    .sys_rst_n   (rst_n ),
    .key_in      (add_div_in),

    .key_flag    (key_add_div)

);



endmodule