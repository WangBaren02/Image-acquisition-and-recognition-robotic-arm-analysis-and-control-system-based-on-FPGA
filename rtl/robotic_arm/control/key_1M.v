module key_1M
(
    input   clk,
    input   rst_n,

    input   key_in,

    output reg key_out
);
///////////////////////////
    reg [22:0]   cnt_count;

    always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n) cnt_count <= 23'b0;
            else if(cnt_count==23'd299999) cnt_count <= 23'b0;
            else if(key_in!=1'b1) cnt_count <= cnt_count + 1'b1;
            else cnt_count <= 23'b0;
        end
///////////////////////////
    always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n) key_out <= 1'b0;
            else if(cnt_count==23'd299999) key_out <= ~ key_in;
            else key_out <= 1'b0;
        end

endmodule
