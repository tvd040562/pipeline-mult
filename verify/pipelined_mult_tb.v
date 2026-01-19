`timescale 1ns / 1ps

module tb_pipelined_mult;

    // 1. Tín hiệu giao tiếp với DUT
    reg clk;
    reg rst;
    reg [31:0] a;
    reg [31:0] b;
    wire [63:0] p;
	int in[$], out[$];
	int exp, act;

    // 2. Gọi Module (Device Under Test)
    pipelined_mult uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .p(p)
    );

    // 3. Tạo Clock 500MHz (Chu kỳ 2ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

	reg [2:0] count; 
	always @(posedge clk) begin
		if (rst)
			count <= 0;
		else if (count < 6)
			count <= count + 1;
		else
			out.push_front(p);
	end
	
    // 6. STIMULUS (Kịch bản Test)
    initial begin
        // Khởi tạo
        rst = 1; a = 0; b = 0;
        @(posedge clk); // Giữ reset 10 chu kỳ
		@(posedge clk);
        rst = 0;
        
        $display("==================================================");
        $display("   BẮT ĐẦU TEST BENCH CHO 5-STAGE PIPELINE");
        $display("==================================================");

        // --- TEST CASE 1: Cơ bản ---
        @(posedge clk); a = 2; b = 3;         // Exp = 6
		in.push_front(a * b);
        @(posedge clk); a = 10; b = 20;       // Exp = 200
		in.push_front(a * b);
        @(posedge clk); a = 100; b = 100;     // Exp = 10000
		in.push_front(a * b);

        // --- TEST CASE 2: Corner Cases (Số đặc biệt) ---
        @(posedge clk); a = 0; b = 12345;     // Nhân với 0
		in.push_front(a * b);
        @(posedge clk); a = 1; b = 99999;     // Nhân với 1
		in.push_front(a * b);
        @(posedge clk); a = 32'hFFFFFFFF; b = 1; // Số lớn nhất 32bit * 1
		in.push_front(a * b);
        @(posedge clk); a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; // Max * Max (Test 64bit Output)
		in.push_front(a * b);

        // --- TEST CASE 3: Random Stress Test ---
        $display("Running 2000 Random Vectors...");
        repeat (2000) begin
            @(posedge clk);
            a = $urandom; 
            b = $urandom;
			in.push_front(a * b);
        end
		while (out.size() > 0) begin
			exp = in.pop_back();
			act = out.pop_back();
			if (exp != act)
				$display("Expected: %d; Actual: %d", exp, act);
		end
		$finish();
	end
	
    // Tạo file sóng
    initial begin
        $dumpfile("tb_pipelined_mult.vcd");
        $dumpvars(0, tb_pipelined_mult);
    end

endmodule
