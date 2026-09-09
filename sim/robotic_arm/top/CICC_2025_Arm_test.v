module CICC_2025_Arm_test
(
    input           sys_clk     ,   //系统时钟:50MHz
    input           sys_rst_n   ,   //系统复位
////////////////////////////////////////////image_process
    // input   [3:0]   button_key  ,
    // input   [6:0]   push_key    ,//sw10-sw9-sw2-sw3-sw4-sw5-sw6
    // output  [5:0]   seg_sel     ,
    // output  [7:0]   seg_dig     ,
//////////////////////////////////////////////robotic_arm
    output          pwm_0       ,   //PWM驱动舵机0
    output          pwm_1       ,   //PWM驱动舵机1
    output          pwm_2       ,   //PWM驱动舵机2
    output          pwm_3       ,   //PWM驱动舵机3
    output          pwm_4       ,   //PWM驱动舵机4

    output          air_pump    ,   //气泵使能
//////////////////////////////////////////////外设
//按键
    input           start_VIP       //key_1
    //input             key_2       ,
    // input            key_3       ,
    // input            key_4
//灯
    // output          image_led    ,
    // output          led_check
);
///////////////////////////////////
    wire            clk_1M;

    pll_ip  pll_ip_inst
    (
        .areset (~sys_rst_n),
        .inclk0 (sys_clk),
        .c0     (clk_1M),
        .locked (locked)
    );

    wire    rst_n;

    assign rst_n = locked & sys_rst_n;
/////////////////////////////////////////
    reg             start_VIP_reg;

    always@( posedge clk_1M or negedge rst_n )
        begin
            if(!rst_n) start_VIP_reg <= 1'b0;
            else start_VIP_reg <= start_VIP;
        end

    wire            start_VIP_flag;

    assign start_VIP_flag = start_VIP_reg & (!start_VIP);
//////////////////////////////////////////////////////////
    wire    [9:0]   VIP_X;
    wire    [9:0]   VIP_Y;
    wire    [1:0]   shape;
    wire    [1:0]   color;
    wire    [8:0]   catch_4_angle;
    wire    [1:0]   release_triangle_pos;
    wire            VIP_done;

    test_VIP test_VIP_inst
    (
        .clk                    (clk_1M),
        .rst_n                  (rst_n),

        .start_VIP              (start_VIP_flag),

        .VIP_X                  (VIP_X),
        .VIP_Y                  (VIP_Y),
        .shape                  (shape),
        .color                  (color),
        .catch_4_angle          (catch_4_angle),
        .release_triangle_pos   (release_triangle_pos),
        .VIP_done               (VIP_done),

        .loop_done              (loop_done),
        .all_done               (all_done)
    );
/////////////////////////////////////////////////////
    wire    [7:0]   X;
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
        .clk                (clk_1M),         //模块时钟：1MHz
        .rst_n              (rst_n),          //模块复位

        .VIP_X              (VIP_X),
        .VIP_Y              (VIP_Y),
        .shape              (shape),
        .color              (color),
        .catch_4_angle      (catch_4_angle),
        .release_tri_pos    (release_tri_pos),
        .VIP_done           (VIP_done),

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
/////////////////////////////////////////////////////
    wire            rob_rst_n;

    assign rob_rst_n = rst_n & (~all_done);
/////////////////////////////////////////////////////
    robotic_arm_low_clk robotic_arm_low_clk_inst
    (
        .clk                (clk_1M),           //模块时钟:1MHz
        .rst_n              (rob_rst_n),        //模块复位

        .X                  (X),                //物块在仓库中的X坐标(mm):0~265
        .Y                  (Y),                //物块在仓库中的Y坐标(mm):0~175
        .des_X              (des_X),            //目的地X:0~5
        .des_Y              (des_Y),            //目的地Y:0~3
        .catch_4_delay      (catch_4_delay),    //抓取时舵机4旋转的角度:0~270
        .release_4_change   (release_4_change), //
        .VIP_data_valid     (VIP_data_valid),   //坐标信息有效

        // .DUTY_STEP          (4'd1),             //7'd10
        // .CNT_DELAY_DUTY     (14'd6500),         //20'd10000

        .pwm_0              (pwm_0),            //PWM驱动舵机0
        .pwm_1              (pwm_1),            //PWM驱动舵机1
        .pwm_2              (pwm_2),            //PWM驱动舵机2
        .pwm_3              (pwm_3),            //PWM驱动舵机3
        .pwm_4              (pwm_4),            //PWM驱动舵机4
        .air_pump           (air_pump),         //气泵使能

        .arm_half_done      (arm_half_done),    //机械臂完成一半工作
        .loop_done          (loop_done)         //完成一个物体放置
    );

endmodule
