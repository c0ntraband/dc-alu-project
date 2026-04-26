`timescale 1ns/1ps
`default_nettype none

// One radix-2 SRT/non-restoring division step for positive magnitudes.
//
// A is the signed partial remainder. Q is both the shifted dividend and the
// quotient under construction.
//
// If the old partial remainder is positive, subtract the divisor.
// If the old partial remainder is negative, add the divisor.
// The sign of the new partial remainder becomes the new quotient bit.
module srt_radix2_stage_8 (
    input  wire [8:0] A_in,
    input  wire [7:0] Q_in,
    input  wire [7:0] divisor,
    output wire [8:0] A_out,
    output wire [7:0] Q_out
);
    wire       old_A_is_negative;
    wire [8:0] shifted_A;
    wire [8:0] divisor_ext;
    wire [8:0] adder_operand;
    wire       adder_cin;
    wire       unused_cout;
    wire       unused_carry_into_msb;

    assign old_A_is_negative = A_in[8];
    assign shifted_A         = {A_in[7:0], Q_in[7]};
    assign divisor_ext       = {1'b0, divisor};

    // Positive old A: shifted_A - divisor = shifted_A + ~divisor + 1.
    // Negative old A: shifted_A + divisor.
    assign adder_operand = divisor_ext ^ {9{~old_A_is_negative}};
    assign adder_cin     = ~old_A_is_negative;

    ripple_adder #(.WIDTH(9)) add_or_sub_divisor (
        .a(shifted_A),
        .b(adder_operand),
        .cin(adder_cin),
        .sum(A_out),
        .cout(unused_cout),
        .carry_into_msb(unused_carry_into_msb)
    );

    assign Q_out = {Q_in[6:0], ~A_out[8]};
endmodule

// Unrolled radix-2 SRT divider. It is the hardware form of the usual
// non-restoring divider, with 8 identical add/subtract stages.
module srt_radix2_unsigned_divider_8 (
    input  wire [7:0] dividend,
    input  wire [7:0] divisor,
    output wire [7:0] quotient,
    output wire [7:0] remainder
);
    wire [8:0] A0;
    wire [8:0] A1;
    wire [8:0] A2;
    wire [8:0] A3;
    wire [8:0] A4;
    wire [8:0] A5;
    wire [8:0] A6;
    wire [8:0] A7;
    wire [8:0] A8;
    wire [8:0] corrected_A;
    wire [8:0] final_A;
    wire [7:0] Q0;
    wire [7:0] Q1;
    wire [7:0] Q2;
    wire [7:0] Q3;
    wire [7:0] Q4;
    wire [7:0] Q5;
    wire [7:0] Q6;
    wire [7:0] Q7;
    wire [7:0] Q8;
    wire       unused_cout;
    wire       unused_carry_into_msb;

    assign A0 = 9'b000000000;
    assign Q0 = dividend;

    srt_radix2_stage_8 step0 (.A_in(A0), .Q_in(Q0), .divisor(divisor), .A_out(A1), .Q_out(Q1));
    srt_radix2_stage_8 step1 (.A_in(A1), .Q_in(Q1), .divisor(divisor), .A_out(A2), .Q_out(Q2));
    srt_radix2_stage_8 step2 (.A_in(A2), .Q_in(Q2), .divisor(divisor), .A_out(A3), .Q_out(Q3));
    srt_radix2_stage_8 step3 (.A_in(A3), .Q_in(Q3), .divisor(divisor), .A_out(A4), .Q_out(Q4));
    srt_radix2_stage_8 step4 (.A_in(A4), .Q_in(Q4), .divisor(divisor), .A_out(A5), .Q_out(Q5));
    srt_radix2_stage_8 step5 (.A_in(A5), .Q_in(Q5), .divisor(divisor), .A_out(A6), .Q_out(Q6));
    srt_radix2_stage_8 step6 (.A_in(A6), .Q_in(Q6), .divisor(divisor), .A_out(A7), .Q_out(Q7));
    srt_radix2_stage_8 step7 (.A_in(A7), .Q_in(Q7), .divisor(divisor), .A_out(A8), .Q_out(Q8));

    // If the final partial remainder is negative, add the divisor back once.
    ripple_adder #(.WIDTH(9)) final_remainder_fix (
        .a(A8),
        .b({1'b0, divisor}),
        .cin(1'b0),
        .sum(corrected_A),
        .cout(unused_cout),
        .carry_into_msb(unused_carry_into_msb)
    );

    mux2_bus #(.WIDTH(9)) choose_remainder (
        .d0(A8),
        .d1(corrected_A),
        .sel(A8[8]),
        .y(final_A)
    );

    assign quotient  = Q8;
    assign remainder = final_A[7:0];
endmodule

module signed_srt_radix2_divider_8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] result,
    output wire       overflow
);
    wire [7:0] magnitude_a;
    wire [7:0] magnitude_b;
    wire [7:0] unsigned_quotient;
    wire [7:0] unused_remainder;
    wire [7:0] signed_quotient;
    wire       divisor_is_zero;
    wire       quotient_is_negative;
    wire       a_is_min_negative;
    wire       b_is_minus_one;
    wire       signed_range_overflow;

    zero_detector_8 detect_zero_divisor (.value(b), .is_zero(divisor_is_zero));

    assign quotient_is_negative = a[7] ^ b[7];

    twos_complement_cond #(.WIDTH(8)) abs_a (.in(a), .negate(a[7]), .out(magnitude_a));
    twos_complement_cond #(.WIDTH(8)) abs_b (.in(b), .negate(b[7]), .out(magnitude_b));

    srt_radix2_unsigned_divider_8 divide_magnitudes (
        .dividend(magnitude_a),
        .divisor(magnitude_b),
        .quotient(unsigned_quotient),
        .remainder(unused_remainder)
    );

    twos_complement_cond #(.WIDTH(8)) apply_sign (
        .in(unsigned_quotient),
        .negate(quotient_is_negative),
        .out(signed_quotient)
    );

    assign a_is_min_negative     = a[7] & (~(a[6] | a[5] | a[4] | a[3] | a[2] | a[1] | a[0]));
    assign b_is_minus_one        = b[7] & b[6] & b[5] & b[4] & b[3] & b[2] & b[1] & b[0];
    assign signed_range_overflow = a_is_min_negative & b_is_minus_one;

    mux2_bus #(.WIDTH(8)) zero_result_on_divide_by_zero (
        .d0(signed_quotient),
        .d1(8'b00000000),
        .sel(divisor_is_zero),
        .y(result)
    );

    assign overflow = divisor_is_zero | signed_range_overflow;
endmodule

`default_nettype wire
