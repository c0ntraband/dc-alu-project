`timescale 1ns/1ps
`default_nettype none

module alu8_tb;
    localparam [3:0] OP_ADD = 4'b0000;
    localparam [3:0] OP_SUB = 4'b0001;
    localparam [3:0] OP_MUL = 4'b0010;
    localparam [3:0] OP_DIV = 4'b0011;
    localparam [3:0] OP_AND = 4'b0100;
    localparam [3:0] OP_OR  = 4'b0101;
    localparam [3:0] OP_XOR = 4'b0110;
    localparam [3:0] OP_SHL = 4'b0111;
    localparam [3:0] OP_SHR = 4'b1000;

    reg  [7:0] A;
    reg  [7:0] B;
    reg  [3:0] ALU_Sel;
    wire [7:0] Result;
    wire       Z;
    wire       N;
    wire       V;

    integer errors;

    alu8 dut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .Result(Result),
        .Z(Z),
        .N(N),
        .V(V)
    );

    task check;
        input [8*40-1:0] label;
        input [7:0]      a;
        input [7:0]      b;
        input [3:0]      op;
        input [7:0]      expected_result;
        input            expected_z;
        input            expected_n;
        input            expected_v;
        begin
            A       = a;
            B       = b;
            ALU_Sel = op;
            #1;

            if ((Result !== expected_result) ||
                (Z !== expected_z) ||
                (N !== expected_n) ||
                (V !== expected_v)) begin
                $display("FAIL %-40s A=%02h B=%02h op=%01h got R=%02h ZNV=%b%b%b expected R=%02h ZNV=%b%b%b",
                         label, A, B, ALU_Sel, Result, Z, N, V,
                         expected_result, expected_z, expected_n, expected_v);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors  = 0;
        A       = 8'h00;
        B       = 8'h00;
        ALU_Sel = OP_ADD;

        check("add positive",               8'h05, 8'h03, OP_ADD, 8'h08, 1'b0, 1'b0, 1'b0);
        check("add positive overflow",      8'h7f, 8'h01, OP_ADD, 8'h80, 1'b0, 1'b1, 1'b1);
        check("add negative overflow",      8'h80, 8'hff, OP_ADD, 8'h7f, 1'b0, 1'b0, 1'b1);
        check("add zero result",            8'hff, 8'h01, OP_ADD, 8'h00, 1'b1, 1'b0, 1'b0);

        check("sub positive",               8'h05, 8'h03, OP_SUB, 8'h02, 1'b0, 1'b0, 1'b0);
        check("sub overflow negative",      8'h80, 8'h01, OP_SUB, 8'h7f, 1'b0, 1'b0, 1'b1);
        check("sub overflow positive",      8'h7f, 8'hff, OP_SUB, 8'h80, 1'b0, 1'b1, 1'b1);
        check("sub zero result",            8'h03, 8'h03, OP_SUB, 8'h00, 1'b1, 1'b0, 1'b0);

        check("mul positive",               8'h03, 8'h04, OP_MUL, 8'h0c, 1'b0, 1'b0, 1'b0);
        check("mul negative",               8'hff, 8'h05, OP_MUL, 8'hfb, 1'b0, 1'b1, 1'b0);
        check("mul booth radix8 mixed signs", 8'h07, 8'hfd, OP_MUL, 8'heb, 1'b0, 1'b1, 1'b0);
        check("mul booth radix8 overflow",   8'h44, 8'h32, OP_MUL, 8'h48, 1'b0, 1'b0, 1'b1);
        check("mul lower byte overflow",    8'h10, 8'h10, OP_MUL, 8'h00, 1'b1, 1'b0, 1'b1);
        check("mul min negative exact",     8'h80, 8'h01, OP_MUL, 8'h80, 1'b0, 1'b1, 1'b0);
        check("mul signed range overflow",  8'h80, 8'hff, OP_MUL, 8'h80, 1'b0, 1'b1, 1'b1);

        check("div positive",               8'h0c, 8'h03, OP_DIV, 8'h04, 1'b0, 1'b0, 1'b0);
        check("div srt remainder case 1",    8'h1b, 8'h06, OP_DIV, 8'h04, 1'b0, 1'b0, 1'b0);
        check("div srt remainder case 2",    8'h64, 8'h0f, OP_DIV, 8'h06, 1'b0, 1'b0, 1'b0);
        check("div negative by positive",   8'hfb, 8'h02, OP_DIV, 8'hfe, 1'b0, 1'b1, 1'b0);
        check("div negative by negative",   8'hfb, 8'hfe, OP_DIV, 8'h02, 1'b0, 1'b0, 1'b0);
        check("div signed range overflow",  8'h80, 8'hff, OP_DIV, 8'h80, 1'b0, 1'b1, 1'b1);
        check("div by zero",                8'h12, 8'h00, OP_DIV, 8'h00, 1'b1, 1'b0, 1'b1);

        check("and",                        8'ha5, 8'h3c, OP_AND, 8'h24, 1'b0, 1'b0, 1'b0);
        check("or",                         8'ha5, 8'h3c, OP_OR,  8'hbd, 1'b0, 1'b1, 1'b0);
        check("xor",                        8'ha5, 8'h3c, OP_XOR, 8'h99, 1'b0, 1'b1, 1'b0);

        check("left shift one",             8'h11, 8'h01, OP_SHL, 8'h22, 1'b0, 1'b0, 1'b0);
        check("left shift to zero",         8'h80, 8'h01, OP_SHL, 8'h00, 1'b1, 1'b0, 1'b0);
        check("right shift one",            8'h80, 8'h01, OP_SHR, 8'h40, 1'b0, 1'b0, 1'b0);
        check("right shift to zero",        8'h01, 8'h01, OP_SHR, 8'h00, 1'b1, 1'b0, 1'b0);
        check("undefined opcode",           8'haa, 8'h55, 4'hf,    8'h00, 1'b1, 1'b0, 1'b0);

        if (errors == 0) begin
            $display("PASS: all ALU checks completed");
            $finish;
        end

        $display("FAIL: %0d ALU checks failed", errors);
        $finish(1);
    end
endmodule

`default_nettype wire
