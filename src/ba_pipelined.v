module stage3 (
	input clk,
	input rst,
	input [31:0] p_hh, 
	input [31:0] p_hl, 
	input [31:0] p_lh, 
	input [31:0] p_ll,
	output reg [63:0] p
);
`ifndef MACRO
    // --- STAGE 3: FIRST ADDITION (Cộng các phần chéo trước) ---
    // Thay vì cộng tất cả, nhịp này chỉ cộng HL + LH thôi cho nhẹ.
    reg [32:0] mid_sum;
    reg [31:0] p_hh_pipe, p_ll_pipe;

    always @(posedge clk) begin
        if (rst) begin
            mid_sum <= 0; p_hh_pipe <= 0; p_ll_pipe <= 0;
        end else begin
            mid_sum <= p_hl + p_lh; // Chỉ làm mỗi việc cộng 2 số này
            p_hh_pipe <= p_hh;      // Mấy cái kia chỉ việc đi chơi (truyền thẳng)
            p_ll_pipe <= p_ll;
        end
    end

    // --- STAGE 4: SECOND ADDITION (Chuẩn bị số hạng) ---
    // Tách việc dịch bit và cộng ra
    reg [63:0] term_high, term_mid, term_low;

    always @(posedge clk) begin
         if (rst) begin
            term_high <= 0; term_mid <= 0; term_low <= 0;
         end else begin
            term_high <= {32'b0, p_hh_pipe} << 32;
            term_mid  <= {31'b0, mid_sum}   << 16;
            term_low  <= {32'b0, p_ll_pipe};
         end
    end

    always @(posedge clk) begin
        if (rst)
			p <= 0;
		else
			p <= term_high + term_mid + term_low;
	end
	
`endif
endmodule

module mult_16x16 (
	input clk,
	input rst,
	input [15:0] in1,
	input [15:0] in2,
	output reg [31:0] out
);
`ifndef MACRO
	reg [15:0] in1_reg, in2_reg;
    always @(posedge clk) begin
        if (rst) begin
			out <= 0;
			in1_reg <= 0;
			in2_reg <= 0;
		end else begin
			in1_reg <= in1;
			in2_reg <= in2;
			out <= in1_reg*in2_reg;
		end
	end
`endif
endmodule

`ifdef MACRO
module pipelined_mult (
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output [63:0] p
);

    // --- STAGE 1: INPUT SPLIT ---
//    reg [15:0] a_h, a_l;
//    reg [15:0] b_h, b_l;

//    always @(posedge clk) begin
//        if (rst) begin
//            a_h <= 0; a_l <= 0; b_h <= 0; b_l <= 0;
//        end else begin
//            a_h <= a[31:16]; a_l <= a[15:0];
//            b_h <= b[31:16]; b_l <= b[15:0];
//        end
//    end

    // --- STAGE 2: MULTIPLICATION ---
    wire [31:0] p_hh, p_hl, p_lh, p_ll;
	
	mult_16x16 i_hh (clk, rst, a[31:16], b[31:16], p_hh);
	mult_16x16 i_hl (clk, rst, a[31:16], b[15:0], p_hl);
	mult_16x16 i_lh (clk, rst, a[15:0], b[31:16], p_lh);
	mult_16x16 i_ll (clk, rst, a[15:0], b[15:0], p_ll);

    // --- STAGE 3: FIRST ADDITION (Cộng các phần chéo trước) ---
    // Thay vì cộng tất cả, nhịp này chỉ cộng HL + LH thôi cho nhẹ.
    //reg [32:0] mid_sum;
    //reg [31:0] p_hh_pipe, p_ll_pipe;
	//
    //always @(posedge clk) begin
    //    if (rst) begin
    //        mid_sum <= 0; p_hh_pipe <= 0; p_ll_pipe <= 0;
    //    end else begin
    //        mid_sum <= p_hl + p_lh; // Chỉ làm mỗi việc cộng 2 số này
    //        p_hh_pipe <= p_hh;      // Mấy cái kia chỉ việc đi chơi (truyền thẳng)
    //        p_ll_pipe <= p_ll;
    //    end
    //end
	//
    //// --- STAGE 4: SECOND ADDITION (Chuẩn bị số hạng) ---
    //// Tách việc dịch bit và cộng ra
    //reg [63:0] term_high, term_mid, term_low;
	//
    //always @(posedge clk) begin
    //     if (rst) begin
    //        term_high <= 0; term_mid <= 0; term_low <= 0;
    //     end else begin
    //        term_high <= {32'b0, p_hh_pipe} << 32;
    //        term_mid  <= {31'b0, mid_sum}   << 16;
    //        term_low  <= {32'b0, p_ll_pipe};
    //     end
    //end
	//
    //// --- STAGE 5: FINAL MERGE ---
    //// Cộng 3 số hạng cuối cùng
	//add3x64 i_add (.clk(clk), .rst(rst), .in1(term_high), .in2(term_mid), .in3(term_low), .out(p)); 
	stage3 i_stage3 (.clk(clk), .rst(rst), .p_hh(p_hh), .p_hl(p_hl), .p_lh(p_lh), .p_ll(p_ll), .p(p));
	
endmodule 
`endif