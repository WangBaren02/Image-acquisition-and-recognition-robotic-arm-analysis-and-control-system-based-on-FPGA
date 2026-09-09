module pwm_servo_1M			//pwm模块：驱动舵机
(
	input				sys_clk,		//1MHz：1us
	input				sys_rst_n,

	input		[11:0]	delay_us,
	input				work,

	output	reg			pwm
);

	reg		[11:0]	delay_us_reg;	//500——2500

	reg		[14:0]	cnt_20ms;

	//delay_us = 500 + angle * (2000/270)
	//assign delay_us = 9'd500 + {1'b0,angle[8:0],2'b0}+{2'b0,angle[8:0],1'b0}+{3'b0,angle[8:0]}+{5'b0,angle[8:2]}+{6'b0,angle[8:3]};

	always@( posedge sys_clk or negedge sys_rst_n )
		begin
			if(!sys_rst_n) delay_us_reg <= 12'b0;
			else if(cnt_20ms==15'b0) delay_us_reg <= delay_us;
			else delay_us_reg <= delay_us_reg;
		end

	always@(posedge sys_clk or negedge sys_rst_n)
		begin
			if(!sys_rst_n) cnt_20ms <= 15'b0;
			else if(cnt_20ms==15'd19999) cnt_20ms <= 15'b0;
			else cnt_20ms <= cnt_20ms + 1'b1;
		end

	always@(posedge sys_clk or negedge sys_rst_n)
		begin
			if(!sys_rst_n) pwm <= 1'b0;
			else if(cnt_20ms==delay_us_reg) pwm <= 1'b0;
			else if((cnt_20ms==15'b0)&&(work)) pwm <= 1'b1;
			else pwm <= pwm;
		end

endmodule
