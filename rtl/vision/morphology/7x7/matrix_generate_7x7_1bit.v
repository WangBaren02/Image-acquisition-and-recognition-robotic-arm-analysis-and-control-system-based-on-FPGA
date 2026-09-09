module  matrix_generate_7x7_1bit(
    input             clk,
    input             rst_n,

    input             per_frame_vsync,
    input             per_frame_href,
    input             per_frame_clken,
    input             per_img_y,

    output            matrix_frame_vsync,
    output            matrix_frame_href,
    output            matrix_frame_clken,
    output	reg		  matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17,
    output	reg		  matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27,
    output	reg		  matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37,
    output	reg		  matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47,
    output	reg		  matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57,
    output	reg		  matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67,
    output	reg		  matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77

);

//wire define
wire       row1_data;
wire       row2_data;
wire       row3_data;
wire       row4_data;
wire       row5_data;
wire       row6_data;
wire       read_frame_href;
wire       read_frame_clken;

//reg define
reg        row7_data;
reg  [5:0] per_frame_vsync_r;
reg  [5:0] per_frame_href_r;
reg  [5:0] per_frame_clken_r;

//*****************************************************
//**                    main code
//*****************************************************

assign read_frame_href    = per_frame_href_r[0] ;
assign read_frame_clken   = per_frame_clken_r[0];
assign matrix_frame_vsync = per_frame_vsync_r[5];
assign matrix_frame_href  = per_frame_href_r[5] ;
assign matrix_frame_clken = per_frame_clken_r[5];

//当前数据放在第3行
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        row7_data <= 0;
    else begin
        if(per_frame_clken)
            row7_data <= per_img_y ;
        else
            row7_data <= row7_data ;
    end
end

//用于存储列数据的RAM
line_shift_ram_8bit_7x7  u_line_shift_ram_8bit
(
    .clock          (clk),
    .clken          (per_frame_clken),
    .per_frame_href (per_frame_href),

    .shiftin        ({8{per_img_y}}),
    .taps0x         (row6_data),
    .taps1x         (row5_data),
    .taps2x         (row4_data),
    .taps3x         (row3_data),
    .taps4x         (row2_data),
    .taps5x         (row1_data)

);

//将同步信号延迟两拍，用于同步化处理
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        per_frame_vsync_r <= 0;
        per_frame_href_r  <= 0;
        per_frame_clken_r <= 0;
    end
    else begin
        per_frame_vsync_r <= { per_frame_vsync_r[4:0], per_frame_vsync };
        per_frame_href_r  <= { per_frame_href_r[4:0],  per_frame_href  };
        per_frame_clken_r <= { per_frame_clken_r[4:0], per_frame_clken };
    end
end

//在同步处理后的控制信号下，输出图像矩阵
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17} <= 7'd0;
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27} <= 7'd0;
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37} <= 7'd0;
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47} <= 7'd0;
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57} <= 7'd0;
        {matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67} <= 7'd0;
        {matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77} <= 7'd0;
    end
    else if(read_frame_href) begin
        if(read_frame_clken) begin
            {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17} <= { matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17, row1_data};
            {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27} <= { matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27, row2_data};
            {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37} <= { matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37, row3_data};
            {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47} <= { matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47, row4_data};
            {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57} <= { matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57, row5_data};
            {matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67} <= { matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67, row6_data};
            {matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77} <= { matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77, row7_data};

        end
        else begin
            {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17} <= {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17};
            {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27} <= {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27};
            {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37} <= {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37};
            {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47} <= {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47};
            {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57} <= {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57};
            {matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67} <= {matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67};
            {matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77} <= {matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77};

        end
    end
    else begin
        {matrix_p11, matrix_p12, matrix_p13, matrix_p14, matrix_p15, matrix_p16, matrix_p17} <= 7'd0;
        {matrix_p21, matrix_p22, matrix_p23, matrix_p24, matrix_p25, matrix_p26, matrix_p27} <= 7'd0;
        {matrix_p31, matrix_p32, matrix_p33, matrix_p34, matrix_p35, matrix_p36, matrix_p37} <= 7'd0;
        {matrix_p41, matrix_p42, matrix_p43, matrix_p44, matrix_p45, matrix_p46, matrix_p47} <= 7'd0;
        {matrix_p51, matrix_p52, matrix_p53, matrix_p54, matrix_p55, matrix_p56, matrix_p57} <= 7'd0;
        {matrix_p61, matrix_p62, matrix_p63, matrix_p64, matrix_p65, matrix_p66, matrix_p67} <= 7'd0;
        {matrix_p71, matrix_p72, matrix_p73, matrix_p74, matrix_p75, matrix_p76, matrix_p77} <= 7'd0;
    end
end

endmodule