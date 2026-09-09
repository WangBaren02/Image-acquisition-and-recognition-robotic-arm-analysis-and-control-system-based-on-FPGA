module CICC_2025_Arm
(
    input           sys_clk     ,   //系统时钟:50MHz
    input           sys_rst_n   ,   //系统复位
////////////////////////////////////////////image_process通讯
//spi_master
    output          spi_sck     ,
    input           spi_miso    ,
    output          spi_mosi    ,
    output          spi_cs      ,
//IO
    input   [1:0]   shape       ,
    input   [1:0]   color       ,
    output          arm_half_done,
//////////////////////////////////////////////robotic_arm
    output          pwm_0       ,   //PWM驱动舵机0
    output          pwm_1       ,   //PWM驱动舵机1
    output          pwm_2       ,   //PWM驱动舵机2
    output          pwm_3       ,   //PWM驱动舵机3
    output          pwm_4       ,   //PWM驱动舵机4

    output          air_pump    ,   //气泵使能
//////////////////////////////////////////////AWC_C4外设
    // input   [3:0]   button_key   ,
    // input   [6:0]   push_key     ,   //sw10-sw9-sw2-sw3-sw4-sw5-sw6
    // output  [5:0]   seg_sel      ,
    // output  [7:0]   seg_dig      ,
//////////////////////////////////////////////扩展版外设
//按键
    input           start_VIP   ,       //key_1
    input           key_2       ,
    input           key_3       ,
    input           key_4       ,
    input           key_5
//灯
    // output          image_led   ,
    // output          led_check
);
////////////////////////////////
//     reg [22:0]   cnt_count;

//     always@(posedge clk_20M or negedge sys_rst_n)
//         begin
//             if(!sys_rst_n) cnt_count <= 23'b0;
//             else if(cnt_count==23'd4999999) cnt_count <= 23'b0;
//             else if(!sys_rst_n) cnt_count <= cnt_count + 1'b1;
//             else cnt_count <= 23'b0;
//         end
// ////////////////////////////////
//     reg     sys_rst_n_flag;

//     always@(posedge clk_20M or negedge sys_rst_n)
//         begin
//             if(!sys_rst_n) sys_rst_n_flag <= 1'b1;
//             else if(cnt_count==23'd4999999) sys_rst_n_flag <= ~ sys_rst_n;
//             else sys_rst_n_flag <= 1'b1;
//         end
/////////////////////////////////////////////////////
    wire            clk_1M;
    wire            clk_20M;
    wire            clk_100M;

    pll_ip  pll_ip_inst
    (
        .areset (~sys_rst_n),
        .inclk0 (sys_clk),
        .c0     (clk_1M),
        .c1     (clk_20M),
        .c2     (clk_100M),
        .locked (locked)
    );

    wire    rst_n;

    assign rst_n = locked & sys_rst_n;
//////////////////////////////////////////////
    wire    start_VIP_flag;

    key key_inst
    (
       .clk     (clk_20M),
       .rst_n   (rst_n),

       .key_in  (start_VIP),

       .key_out (start_VIP_flag)
    );

    wire    des_X_add_flag;

    key key_inst_1
    (
       .clk     (clk_20M),
       .rst_n   (rst_n),

       .key_in  (key_2),

       .key_out (des_X_add_flag)
    );

    wire    des_Y_add_flag;

    key key_inst_2
    (
       .clk     (clk_20M),
       .rst_n   (rst_n),

       .key_in  (key_3),

       .key_out (des_Y_add_flag)
    );

    wire    lay_0_add_flag;

    key_1M key_inst_3
    (
       .clk     (clk_1M),
       .rst_n   (rst_n),

       .key_in  (key_4),

       .key_out (lay_0_add_flag)
    );

    wire    lay_3_add_flag;

    key_1M key_inst_4
    (
       .clk     (clk_1M),
       .rst_n   (rst_n),

       .key_in  (key_5),

       .key_out (lay_3_add_flag)
    );
    // reg             start_VIP_reg;

    // always@( posedge clk_20M or negedge rst_n )
    //     begin
    //         if(!rst_n) start_VIP_reg <= 1'b0;
    //         else start_VIP_reg <= start_VIP;
    //     end

    // wire            start_VIP_flag;

    // assign start_VIP_flag = start_VIP_reg & (!start_VIP);
////////////////////////////////////////////////////////////
    wire            spi_start;
    wire            spi_done;

    wire    [31:0]  Din;
    wire    [9:0]   VIP_X;
    wire    [9:0]   VIP_Y;
    wire    [8:0]   catch_4_angle;

    SPI_Shengteng
    #(
        .width           (6'd32)
    )
    SPI_Shengteng_inst
    (
        //system_ctrl
        .clk             (clk_20M),
        .rst_n           (rst_n),
        //spi_ctrl
        .spi_sck         (spi_sck),
        .spi_miso        (spi_miso),
        .spi_mosi        (spi_mosi),
        .spi_cs          (spi_cs),
        .spi_start       (spi_start),
        .spi_done        (spi_done),
        //data
        .Din             (spi_Din),
        .VIP_X           (VIP_X),
        .VIP_Y           (VIP_Y),
        .catch_4_angle   (catch_4_angle)
    );

    assign spi_Din = 32'b0;
/////////////////////////////////////////////////////////////////////////////////////////
    wire    [8:0]   X;
    wire    [7:0]   Y;
    wire    [2:0]   des_X;
    wire    [1:0]   des_Y;
    wire    [11:0]  catch_4_delay;
    wire    [11:0]  release_4_change;

    wire            VIP_data_valid;

    wire            loop_done;
    wire            all_done;

    send_location send_location_inst
    (
        .clk_20M            (clk_20M),		  //模块时钟：20MHz
        .rst_n              (rst_n),          //模块复位

        .key_start          (start_VIP_flag),
        .spi_start          (spi_start),
        .des_X_add_flag     (des_X_add_flag),
        .des_Y_add_flag     (des_Y_add_flag),

        .VIP_X              (VIP_X),
        .VIP_Y              (VIP_Y),
        .shape              (shape),
        .color              (color),
        .catch_4_angle      (catch_4_angle),
        .VIP_done           (spi_done),

        .X                  (X),
        .Y                  (Y),
        .des_X              (des_X),
        .des_Y              (des_Y),
        .catch_4_delay      (catch_4_delay),
        .release_4_change   (release_4_change),
        .VIP_data_valid     (VIP_data_valid),

        .loop_done          (loop_done),
        .all_done           (all_done)
    );
////////////////////////////////////
    wire            rob_rst_n;

    assign rob_rst_n = rst_n & (~all_done);
////////////////////////////////////
    robotic_arm_low_clk robotic_arm_low_clk_inst
    (
        .clk                (clk_1M),           //模块时钟:1MHz
        .clk_100M           (clk_100M),
        .rst_n              (rob_rst_n),        //模块复位

        .X                  (X),                //物块在仓库中的X坐标(mm):0~265
        .Y                  (Y),                //物块在仓库中的Y坐标(mm):0~175
        .des_X              (des_X),            //目的地X:0~5
        .des_Y              (des_Y),            //目的地Y:0~3
        .catch_4_delay      (catch_4_delay),    //抓取时舵机4旋转的角度:0~270
        .release_4_change   (release_4_change), //
        .VIP_data_valid     (VIP_data_valid),   //坐标信息有效

        .lay_0_add_flag     (lay_0_add_flag),
        .lay_3_add_flag     (lay_3_add_flag),

        // .DUTY_STEP          (4'd1),             //7'd10
        // .CNT_DELAY_DUTY     (14'd6500),         //20'd10000

        .pwm_0              (pwm_0),            //PWM驱动舵机0
        .pwm_1              (pwm_1),            //PWM驱动舵机1
        .pwm_2              (pwm_2),            //PWM驱动舵机2
        .pwm_3              (pwm_3),            //PWM驱动舵机3
        .pwm_4              (pwm_4),            //PWM驱动舵机4
        .air_pump           (air_pump),         //气泵使能

        .loop_half_done     (arm_half_done),    //机械臂完成一半工作
        .loop_done          (loop_done)         //完成一个物体放置
    );


endmodule
