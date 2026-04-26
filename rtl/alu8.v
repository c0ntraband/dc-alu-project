`timescale 1ns/1ps
`default_nettype none

module alu8 (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [3:0] ALU_Sel,
    output wire [7:0] Result,
    output wire       Z,
    output wire       N,
    output wire       V
);
    wire c_add;
    wire c_sub;
    wire c_mul;
    wire c_div;
    wire c_and;
    wire c_or;
    wire c_xor;
    wire c_shl;
    wire c_shr;
    wire selected_overflow;

    alu_control_unit control_unit (
        .alu_sel(ALU_Sel),
        .c_add(c_add),
        .c_sub(c_sub),
        .c_mul(c_mul),
        .c_div(c_div),
        .c_and(c_and),
        .c_or(c_or),
        .c_xor(c_xor),
        .c_shl(c_shl),
        .c_shr(c_shr)
    );

    alu_datapath datapath (
        .A(A),
        .B(B),
        .c_add(c_add),
        .c_sub(c_sub),
        .c_mul(c_mul),
        .c_div(c_div),
        .c_and(c_and),
        .c_or(c_or),
        .c_xor(c_xor),
        .c_shl(c_shl),
        .c_shr(c_shr),
        .result(Result),
        .overflow(selected_overflow)
    );

    alu_flag_unit flag_unit (
        .result(Result),
        .overflow_in(selected_overflow),
        .Z(Z),
        .N(N),
        .V(V)
    );
endmodule

`default_nettype wire
