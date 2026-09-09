module SPI_Shengteng
#(
    parameter       width = 6'd32
)
(
    //system_ctrl
    input           clk             , //20M
    input           rst_n           ,
    //spi_ctrl
    //spi_master
    output          spi_sck         ,
    input           spi_miso        ,
    output          spi_mosi        ,
    output          spi_cs          ,
    input           spi_start       , //脉冲
    output          spi_done        ,
    //data
    input   [31:0]  Din             ,
    output  [9:0]   VIP_X           ,
    output  [9:0]   VIP_Y           ,
    output  [8:0]   catch_4_angle
);
//spi_ctrl
    wire    [31:0]  Dout/*synthesis keep*/;

    SPI_master
    #(
        .DNUM           (32),
        .FRE_DIV        (2),
        .FRE_DIV_INDEX  (1)
    )
    (
        .clk            (clk),    //20M
        .rst_n          (rst_n),

        .spi_start      (spi_start),  //脉冲
        .spi_din        (Din),
        .spi_dout       (Dout),
        .spi_over       (spi_done),

        .spi_miso       (spi_miso),
        .spi_sck        (spi_sck),
        .spi_mosi       (spi_mosi),
        .spi_cs         (spi_cs)
    );
// assign spi_done       = Dout[31];//8bit-0x80
    assign VIP_X         = Dout[31:22];  //10bit
    assign VIP_Y         = Dout[21:12];  //10bit
    assign catch_4_angle = Dout[11:3];   // 9bit

endmodule
