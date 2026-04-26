`timescale 1ns/1ps
`default_nettype none

// Main ALU datapath. Operation blocks are computed in parallel and selected
// with one-hot control lines.
module alu_datapath (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire       c_add,
    input  wire       c_sub,
    input  wire       c_mul,
    input  wire       c_div,
    input  wire       c_and,
    input  wire       c_or,
    input  wire       c_xor,
    input  wire       c_shl,
    input  wire       c_shr,
    output wire [7:0] result,
    output wire       overflow
);
    wire [7:0] add_result;
    wire [7:0] sub_result;
    wire [7:0] mul_result;
    wire [7:0] div_result;
    wire [7:0] and_result;
    wire [7:0] or_result;
    wire [7:0] xor_result;
    wire [7:0] shl_result;
    wire [7:0] shr_result;

    wire       add_cout;
    wire       add_carry_into_msb;
    wire       sub_cout;
    wire       sub_carry_into_msb;
    wire       add_overflow;
    wire       sub_overflow;
    wire       mul_overflow;
    wire       div_overflow;

    ripple_adder #(.WIDTH(8)) add_unit (
        .a(A),
        .b(B),
        .cin(1'b0),
        .sum(add_result),
        .cout(add_cout),
        .carry_into_msb(add_carry_into_msb)
    );

    ripple_adder #(.WIDTH(8)) sub_unit (
        .a(A),
        .b(~B),
        .cin(1'b1),
        .sum(sub_result),
        .cout(sub_cout),
        .carry_into_msb(sub_carry_into_msb)
    );

    signed_booth_radix8_multiplier_8 mul_unit (
        .a(A),
        .b(B),
        .result(mul_result),
        .overflow(mul_overflow)
    );

    signed_srt_radix2_divider_8 div_unit (
        .a(A),
        .b(B),
        .result(div_result),
        .overflow(div_overflow)
    );

    bitwise_and_8 and_unit (.a(A), .b(B), .y(and_result));
    bitwise_or_8  or_unit  (.a(A), .b(B), .y(or_result));
    bitwise_xor_8 xor_unit (.a(A), .b(B), .y(xor_result));

    left_shifter_8 shl_unit (
        .data(A),
        .shamt(B[2:0]),
        .y(shl_result)
    );

    right_shifter_8 shr_unit (
        .data(A),
        .shamt(B[2:0]),
        .y(shr_result)
    );

    assign add_overflow = add_carry_into_msb ^ add_cout;
    assign sub_overflow = sub_carry_into_msb ^ sub_cout;

    assign result =
        ({8{c_add}} & add_result) |
        ({8{c_sub}} & sub_result) |
        ({8{c_mul}} & mul_result) |
        ({8{c_div}} & div_result) |
        ({8{c_and}} & and_result) |
        ({8{c_or}}  & or_result)  |
        ({8{c_xor}} & xor_result) |
        ({8{c_shl}} & shl_result) |
        ({8{c_shr}} & shr_result);

    assign overflow =
        (c_add & add_overflow) |
        (c_sub & sub_overflow) |
        (c_mul & mul_overflow) |
        (c_div & div_overflow);
endmodule

`default_nettype wire
