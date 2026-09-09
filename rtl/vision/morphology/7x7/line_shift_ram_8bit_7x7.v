module line_shift_ram_8bit_7x7(
    input          clock,
    input          clken,
    input          per_frame_href,

    input   [7:0]  shiftin,
    output  [7:0]  taps0x,
    output  [7:0]  taps1x,
    output  [7:0]  taps2x,
    output  [7:0]  taps3x,
    output  [7:0]  taps4x,
    output  [7:0]  taps5x

);

//reg define
reg  [6:0]  clken_dly;
reg  [9:0]  ram_rd_addr;
reg  [9:0]  ram_rd_addr_d0;
reg  [9:0]  ram_rd_addr_d1;
reg  [9:0]  ram_rd_addr_d2;
reg  [9:0]  ram_rd_addr_d3;
reg  [9:0]  ram_rd_addr_d4;
reg  [9:0]  ram_rd_addr_d5;
reg  [9:0]  ram_rd_addr_d6;
reg  [7:0]  shiftin_d0;
reg  [7:0]  shiftin_d1;
reg  [7:0]  shiftin_d2;
reg  [7:0]  shiftin_d3;
reg  [7:0]  shiftin_d4;
reg  [7:0]  shiftin_d5;
reg  [7:0]  shiftin_d6;
reg  [7:0]  taps0x_d0;
reg  [7:0]  taps1x_d0;
reg  [7:0]  taps2x_d0;
reg  [7:0]  taps3x_d0;
reg  [7:0]  taps4x_d0;
reg  [7:0]  taps5x_d0;
reg  [7:0]  taps6x_d0;

//*****************************************************
//**                    main code
//*****************************************************

//在数据来到时，ram地址累加
always@(posedge clock)begin
    if(per_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//时钟使能信号延迟7拍
always@(posedge clock) begin
    clken_dly <= { clken_dly[5:0] , clken };
end


//将ram地址延迟6拍
always@(posedge clock ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
    ram_rd_addr_d2 <= ram_rd_addr_d1;
    ram_rd_addr_d3 <= ram_rd_addr_d2;
    ram_rd_addr_d4 <= ram_rd_addr_d3;
    ram_rd_addr_d5 <= ram_rd_addr_d4;
end

//输入数据延迟7拍
always@(posedge clock)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
    shiftin_d3 <= shiftin_d2;
    shiftin_d4 <= shiftin_d3;
    shiftin_d5 <= shiftin_d4;
    shiftin_d6 <= shiftin_d5;
end

//用于存储前一行图像的RAM
//blk_mem_gen_0  u_ram_1024x8_0(
//    .clka   (clock),
//    .wea   (clken_dly[2]),    //在延迟的第三个时钟周期，当前行的数据写入RAM0
//    .addra (ram_rd_addr_d1),
//    .dina  (shiftin_d2),
//    .clkb  (clock),
//    .addrb (ram_rd_addr),
//    .doutb (taps0x)           //延迟一个时钟周期，输出RAM0中前一行图像的数据
//);

//blk_mem_gen_0	u_ram_1024x8_0
//(
//	.clock ( clock ),
//	.data ( shiftin_d2 ),
//	.rdaddress ( ram_rd_addr_d1 ),
//	.wraddress ( ram_rd_addr ),
//	.wren ( clken_dly[2] ),
//	.q ( taps0x )
//);

ram_8x1024 u_ram_1024x8_0 (
  .clka(clock),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(clken_dly[6]),      // input wire [0 : 0] wea
  .addra(ram_rd_addr_d5),  // input wire [9 : 0] addra
  .dina(shiftin_d6),    // input wire [7 : 0] dina
  .clkb(clock),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(ram_rd_addr),  // input wire [9 : 0] addrb
  .doutb(taps0x)  // output wire [7 : 0] doutb
);





//寄存一次前一行图像的数据
always@(posedge clock ) begin
    taps0x_d0 <= taps0x;
end

//blk_mem_gen_0  u_ram_1024x8_1(
//    .clka   (clock),
//    .wea   (clken_dly[1]),    //在延迟的第二个时钟周期，将前一行图像的数据写入RAM1
//    .addra (ram_rd_addr_d0),
//    .dina  (taps0x_d0),
//    .clkb  (clock),
//    .addrb (ram_rd_addr),
//    .doutb (taps1x)           //延迟一个时钟周期，输出RAM1中前前一行图像的数据
//);

//blk_mem_gen_0	u_ram_1024x8_1
//(
//	.clock ( clock ),
//	.data ( taps0x_d0 ),
//	.rdaddress ( ram_rd_addr_d0 ),
//	.wraddress ( ram_rd_addr ),
//	.wren ( clken_dly[1] ),
//	.q ( taps1x )
//	);

ram_8x1024 u_ram_1024x8_1 (
  .clka(clock),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(clken_dly[5]),      // input wire [0 : 0] wea
  .addra(ram_rd_addr_d4),  // input wire [9 : 0] addra
  .dina(taps0x_d0),    // input wire [7 : 0] dina
  .clkb(clock),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(ram_rd_addr),  // input wire [9 : 0] addrb
  .doutb(taps1x)  // output wire [7 : 0] doutb
);

//寄存一次前一行图像的数据
always@(posedge clock ) begin
    taps1x_d0 <= taps1x;
end

ram_8x1024 u_ram_1024x8_2 (
  .clka(clock),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(clken_dly[4]),      // input wire [0 : 0] wea
  .addra(ram_rd_addr_d3),  // input wire [9 : 0] addra
  .dina(taps1x_d0),    // input wire [7 : 0] dina
  .clkb(clock),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(ram_rd_addr),  // input wire [9 : 0] addrb
  .doutb(taps2x)  // output wire [7 : 0] doutb
);

//寄存一次前一行图像的数据
always@(posedge clock ) begin
    taps2x_d0 <= taps2x;
end

ram_8x1024 u_ram_1024x8_3 (
  .clka(clock),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(clken_dly[3]),      // input wire [0 : 0] wea
  .addra(ram_rd_addr_d2),  // input wire [9 : 0] addra
  .dina(taps2x_d0),    // input wire [7 : 0] dina
  .clkb(clock),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(ram_rd_addr),  // input wire [9 : 0] addrb
  .doutb(taps3x)  // output wire [7 : 0] doutb
);

//寄存一次前一行图像的数据
always@(posedge clock ) begin
    taps3x_d0 <= taps3x;
end

ram_8x1024 u_ram_1024x8_4 (
  .clka(clock),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(clken_dly[2]),      // input wire [0 : 0] wea
  .addra(ram_rd_addr_d1),  // input wire [9 : 0] addra
  .dina(taps3x_d0),    // input wire [7 : 0] dina
  .clkb(clock),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(ram_rd_addr),  // input wire [9 : 0] addrb
  .doutb(taps4x)  // output wire [7 : 0] doutb
);

//寄存一次前一行图像的数据
always@(posedge clock ) begin
    taps4x_d0 <= taps4x;
end

ram_8x1024 u_ram_1024x8_5 (
  .clka(clock),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(clken_dly[1]),      // input wire [0 : 0] wea
  .addra(ram_rd_addr_d0),  // input wire [9 : 0] addra
  .dina(taps4x_d0),    // input wire [7 : 0] dina
  .clkb(clock),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(ram_rd_addr),  // input wire [9 : 0] addrb
  .doutb(taps5x)  // output wire [7 : 0] doutb
);

endmodule