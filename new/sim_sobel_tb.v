`timescale 1ns / 1ps

//ʹ��BMPͼƬ��ʽ����VIP��Ƶͼ�����㷨
module sim_sobel_tb( );
 
integer iBmpFileId;                 //����BMPͼƬ
integer oBmpFileId_1;               //���BMPͼƬ 1
        
integer iIndex = 0;                 //���BMP��������
integer pixel_index = 0;            //��������������� 
        
integer iCode;      
        
integer iBmpWidth;                  //����BMP ���
integer iBmpHight;                  //����BMP �߶�
integer iBmpSize;                   //����BMP �ֽ���
integer iDataStartIndex;            //����BMP ��������ƫ����
    
reg [7:0] rBmpData [0:2000000];      //���ڼĴ�����BMPͼƬ�е��ֽ����ݣ�����54�ֽڵ��ļ�ͷ��
reg [7:0] Vip_BmpData_1 [0:2000000]; //���ڼĴ���Ƶͼ����֮�� ��BMPͼƬ ����  

reg [7:0] rBmpWord;                //���BMPͼƬʱ���ڼĴ����ݣ���byteΪ��λ��

reg [ 7:0] pixel_data;              //�����Ƶ��ʱ����������

reg clk;
reg rst_n;

reg [ 7:0] vip_pixel_data_1 [0:921600];   	//640x480x3

//---------------------------------------------
initial begin
    //������BMPͼƬ
	 iBmpFileId      = $fopen("F:\\FPGA-EP4CE10F17C8\\change\\sim\\bmp_tb_640x480\\bmp_pic_7.bmp","rb");

    //������BMPͼƬ���ص������� 
	iCode = $fread(rBmpData,iBmpFileId);
 
    //����BMPͼƬ�ļ�ͷ�ĸ�ʽ���ֱ�����ͼƬ�� ��� /�߶� /��������ƫ���� /ͼƬ�ֽ���
	iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
	iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
	iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
    
    //�ر�����BMPͼƬ
	$fclose(iBmpFileId);

	//�����BMPͼƬ
	oBmpFileId_1 = $fopen("F:\\FPGA-EP4CE10F17C8\\change\\sim\\bmp_tb_640x480\\output_file_1.bmp","wb+");
        
    //�ӳ�13ms���ȴ���һ֡VIP�������
    #13000000    
	
    //����ͼ�����BMPͼƬ���ļ�ͷ����������
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData_1[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData_1[iIndex] = vip_pixel_data_1[iIndex-54];
	end
    //�������е�����д�����BMPͼƬ��    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData_1[iIndex];
		$fwrite(oBmpFileId_1,"%c",rBmpWord);
	end
    	
    //�ر����BMPͼƬ
	$fclose(oBmpFileId_1);
		
end  
//initial end

//---------------------------------------------		
//��ʼ��ʱ�Ӻ͸�λ�ź�
initial begin
    clk     = 1;
    rst_n   = 0;
    #110
    rst_n   = 1;
end 

//����50MHzʱ��
always #10 clk = ~clk;
 
//---------------------------------------------		
//��ʱ�������£��������ж����������ݣ�������Modelsim�в鿴BMP�е����� 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        pixel_data  <=  8'd0;
        pixel_index <=  0;
    end
    else begin
        pixel_data  <=  rBmpData[pixel_index];
        pixel_index <=  pixel_index+1;
    end
end
 
//---------------------------------------------
//��������ͷʱ�� 

wire		cmos_vsync ;
reg			cmos_href;
wire        cmos_clken;
reg	[23:0]	cmos_data;	
		 
reg         cmos_clken_r;

reg [31:0]  cmos_index;

parameter [10:0] IMG_HDISP = 11'd640;
parameter [10:0] IMG_VDISP = 11'd480;

localparam H_SYNC = 11'd5;		
localparam H_BACK = 11'd5;		
localparam H_DISP = IMG_HDISP;	
localparam H_FRONT = 11'd5;		
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	

localparam V_SYNC = 11'd1;		
localparam V_BACK = 11'd0;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 11'd1;		
localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;

//---------------------------------------------
//ģ�� OV7725/OV5640 ����ģ�������ʱ��ʹ��
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_clken_r <= 0;
	else
        cmos_clken_r <= ~cmos_clken_r;
end

//---------------------------------------------
//ˮƽ������
reg	[10:0]	hcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		hcnt <= 11'd0;
	else if(cmos_clken_r) 
		hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 11'd0;
end

//---------------------------------------------
//��ֱ������
reg	[10:0]	vcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		vcnt <= 11'd0;		
	else if(cmos_clken_r) begin
		if(hcnt == H_TOTAL - 1'b1)
			vcnt <= (vcnt < V_TOTAL - 1'b1) ? vcnt + 1'b1 : 11'd0;
		else
			vcnt <= vcnt;
    end
end

//---------------------------------------------
//��ͬ��
reg	cmos_vsync_r;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_vsync_r <= 1'b0;			//H: Vaild, L: inVaild
	else begin
		if(vcnt <= V_SYNC - 1'b1)
			cmos_vsync_r <= 1'b0; 	//H: Vaild, L: inVaild
		else
			cmos_vsync_r <= 1'b1; 	//H: Vaild, L: inVaild
    end
end
assign	cmos_vsync	= cmos_vsync_r;

//---------------------------------------------
//����Ч
wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
                            && hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
						? 1'b1 : 1'b0;
      
reg			cmos_href_r;      
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href_r <= 0;
	else begin
		if(frame_valid_ahead)
			cmos_href_r <= 1;
		else
			cmos_href_r <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href <= 0;
	else
        cmos_href <= cmos_href_r;
end

assign cmos_clken = cmos_href & cmos_clken_r;

//-------------------------------------
//������������Ƶ��ʽ�����������
wire [10:0] x_pos;
wire [10:0] y_pos;

assign x_pos = frame_valid_ahead ? (hcnt - (H_SYNC + H_BACK )) : 0;
assign y_pos = frame_valid_ahead ? (vcnt - (V_SYNC + V_BACK )) : 0;

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
       cmos_index   <=  0;
       cmos_data    <=  24'd0;
   end
   else begin
       //cmos_index   <=  y_pos * 960  + x_pos*3 + 54;        //  3*(y*320 + x) + 54
       cmos_index   <=  y_pos * 1920  + x_pos*3 + 54;         //  3*(y*640 + x) + 54
       cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
   end
end
 
//-------------------------------------
//VIP�㷨--��ɫת�Ҷ�

wire 		per_frame_vsync	=	cmos_vsync ;	
wire 		per_frame_href	=	cmos_href;	
wire 		per_frame_clken	=	cmos_clken;	
wire [7:0]	per_img_red		=	cmos_data[ 7: 0];	   	
wire [7:0]	per_img_green	=	cmos_data[15: 8];   	            
wire [7:0]	per_img_blue	=	cmos_data[23:16];   	            


wire 		post0_frame_vsync;   
wire 		post0_frame_href ;   
wire 		post0_frame_clken;    
wire [7:0]	post0_img_Y      ;   
wire [7:0]	post0_img_Cb     ;   
wire [7:0]	post0_img_Cr     ;

wire		vsync_out	;
wire		href_out	;
wire		de_out		;
wire		bin_out     ;
//wire	[23:0]	rgb_out	; 
VIP_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
(
	//global clock
	.clk				(clk),					
	.rst_n				(rst_n),				

	//Image data prepred to be processd
	.per_frame_vsync	(per_frame_vsync),		
	.per_frame_href		(per_frame_href),		
	.per_frame_clken	(per_frame_clken),		
	.per_img_red		(per_img_red),			
	.per_img_green		(per_img_green),		
	.per_img_blue		(per_img_blue),			
	
	//Image data has been processd
	.post_frame_vsync	(post0_frame_vsync),	
	.post_frame_href	(post0_frame_href),		
	.post_frame_clken	(post0_frame_clken),	
	.post_img_Y			(post0_img_Y ),			
	.post_img_Cb		(post0_img_Cb),			
	.post_img_Cr		(post0_img_Cr)			
);

//--------------------------------------
//VIP�㷨--��ֵ��

wire			post1_frame_vsync;
wire			post1_frame_href ;
wire			post1_frame_clken;
wire	     	post1_img_Bit    ;

//binarization u_binarization (
//	.clk					(clk),  				
//	.rst_n					(rst_n),				
//
//	//Image data prepred to be processd
//	.per_frame_vsync		(post0_frame_vsync),	
//	.per_frame_href			(post0_frame_href),		
//	.per_frame_clken		(post0_frame_clken),	
//	.per_img_Y				(post0_img_Y),			
//    
//	//Image data has been processd
//	.post_frame_vsync		(post1_frame_vsync),	
//	.post_frame_href		(post1_frame_href),		
//	.post_frame_clken		(post1_frame_clken),	
//	.post_img_Bit			(post1_img_Bit),		
//	
//	//��ֵ����ֵ 
//	.Binary_Threshold		(150)				
//);

//connect_component_top	connect_component_top_inst//���ڷ���涥�����
//(
//	.clk				(clk),
//	.rst_n				(rst_n),
//	.per_frame_vsync	(post0_frame_vsync),
//	.per_frame_href		(post0_frame_href),
//	.per_frame_clken	(post0_frame_clken),
//	.per_img_Y			(post0_img_Y),
//	.per_img_Cb			(post0_img_Cb),
//	.per_img_Cr			(post0_img_Cr),
//   	.vsync_out			(vsync_out),
//	.href_out			(href_out),
//	.de_out				(de_out),
//
//	.bin_out            (bin_out)
//);
connect_component_top	connect_component_top_inst//���ڷ���涥�����
(
	.clk				(clk),
	.rst_n				(rst_n),
	.per_frame_vsync	(post0_frame_vsync),
	.per_frame_href		(post0_frame_href),
	.per_frame_clken	(post0_frame_clken),
	.per_img_Y			(post0_img_Y),
	.per_img_Cb			(post0_img_Cb),
	.per_img_Cr			(post0_img_Cr),

	.vsync_out			(vsync_out),
	.href_out			(href_out),
	.de_out				(de_out),
	.bin_out	        (bin_out) 
	//output	wire		rgb_out	bin_out
);








////--------------------------------------
////VIP�㷨--��ʴ
//wire			post2_frame_vsync;	
//wire			post2_frame_href;	
//wire			post2_frame_clken;	
//wire			post2_img_Bit;		
//
//VIP_Bit_Erosion_Detector
//#(
//	.IMG_HDISP	(IMG_HDISP),	//640*480
//	.IMG_VDISP	(IMG_VDISP)
//)
//u_VIP_Bit_Erosion_Detector
//(
//	//global clock
//	.clk					(clk),  				
//	.rst_n					(rst_n),				
//
//	//Image data prepred to be processd
//	.per_frame_vsync		(post1_frame_vsync),	
//	.per_frame_href			(post1_frame_href),		
//	.per_frame_clken		(post1_frame_clken),	
//	.per_img_Bit			(post1_img_Bit),		
//
//	//Image data has been processd
//	.post_frame_vsync		(post2_frame_vsync),	
//	.post_frame_href		(post2_frame_href),		
//	.post_frame_clken		(post2_frame_clken),	
//	.post_img_Bit			(post2_img_Bit)			
//);
//
//
////--------------------------------------
////VIP �㷨--Sobel��Ե���
//
//wire			post4_frame_vsync;	 
//wire			post4_frame_href;	 
//wire			post4_frame_clken;	 
//wire			post4_img_Bit;		 
//
//VIP_Sobel_Edge_Detector #(
//	.IMG_HDISP	(IMG_HDISP),	 
//	.IMG_VDISP	(IMG_VDISP)
//) u_VIP_Sobel_Edge_Detector (
//	.clk					(clk),  				
//	.rst_n					(rst_n),				
//
//	//Image data prepred to be processd
//	.per_frame_vsync		(post2_frame_vsync),	
//	.per_frame_href			(post2_frame_href),		
//	.per_frame_clken		(post2_frame_clken),	
//	.per_img_Y				({8{post2_img_Bit}}),			
//
//	//Image data has been processd
//	.post_frame_vsync		(post4_frame_vsync),	
//	.post_frame_href		(post4_frame_href),		
//	.post_frame_clken		(post4_frame_clken),	
//	.post_img_Bit			(post4_img_Bit),		
//	
//	//User interface
//	.Sobel_Threshold		(128)					
//);
//
////--------------------------------------
////VIP�㷨--����
//
//wire			post5_frame_vsync;	
//wire			post5_frame_href;	
//wire			post5_frame_clken;	
//wire			post5_img_Bit;	
//	
//VIP_Bit_Dilation_Detector
//#(
//	.IMG_HDISP	(IMG_HDISP),	//640*480
//	.IMG_VDISP	(IMG_VDISP)
//)
//u_VIP_Bit_Dilation_Detector
//(
//	//global clock
//	.clk					(clk),  				
//	.rst_n					(rst_n),				
//
//	//Image data prepred to be processd
//	.per_frame_vsync		(post4_frame_vsync),	
//	.per_frame_href		    (post4_frame_href),		
//	.per_frame_clken		(post4_frame_clken),	
//	.per_img_Bit			(post4_img_Bit),		
//
//	//Image data has been processd
//	.post_frame_vsync		(post5_frame_vsync),	
//	.post_frame_href		(post5_frame_href),		
//	.post_frame_clken		(post5_frame_clken),	
//	.post_img_Bit			(post5_img_Bit)			
//);
//

//-------------------------------------

wire 		PIC1_vip_out_frame_vsync;   
wire 		PIC1_vip_out_frame_href ;   
wire 		PIC1_vip_out_frame_clken;    
wire [7:0]	PIC1_vip_out_img_R     ;   
wire [7:0]	PIC1_vip_out_img_G     ;   
wire [7:0]	PIC1_vip_out_img_B     ;  

//��һ���������֮��Ľ��
 assign PIC1_vip_out_frame_vsync 	= vsync_out	; 	   
 assign PIC1_vip_out_frame_href  	= href_out 	; 	   
 assign PIC1_vip_out_frame_clken 	= de_out	; 	 
 assign PIC1_vip_out_img_R 			= {8{bin_out}};	
 assign PIC1_vip_out_img_G 			= {8{bin_out}};	
 assign PIC1_vip_out_img_B 			= {8{bin_out}};
//assign PIC1_vip_out_img_R 			= rgb_out[23:16];
//assign PIC1_vip_out_img_G 			= rgb_out[15:8] ;
//assign PIC1_vip_out_img_B 			= rgb_out[7:0]  ;



//�Ĵ�ͼ����֮�����������

//-------------------------------------
//��һ��ͼ
reg [31:0]  PIC1_vip_cnt;
reg         PIC1_vip_vsync_r;    //�Ĵ�VIP����ĳ�ͬ�� 
reg         PIC1_vip_out_en;     //�Ĵ�VIP����ͼ���ʹ���źţ���ά��һ֡��ʱ��

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC1_vip_vsync_r   <=  1'b0;
   else 
        PIC1_vip_vsync_r   <=  PIC1_vip_out_frame_vsync;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        PIC1_vip_out_en    <=  1'b1;
   else if(PIC1_vip_vsync_r & (!PIC1_vip_out_frame_vsync))  //��һ֡����֮��ʹ������
        PIC1_vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        PIC1_vip_cnt <=  32'd0;
   end
   else if(PIC1_vip_out_en) begin
        if(PIC1_vip_out_frame_href & PIC1_vip_out_frame_clken) begin
            PIC1_vip_cnt <=  PIC1_vip_cnt + 3;
            vip_pixel_data_1[PIC1_vip_cnt+0] <= PIC1_vip_out_img_R;
            vip_pixel_data_1[PIC1_vip_cnt+1] <= PIC1_vip_out_img_G;
            vip_pixel_data_1[PIC1_vip_cnt+2] <= PIC1_vip_out_img_B;
        end
   end
end


endmodule 
