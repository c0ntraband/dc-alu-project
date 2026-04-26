`timescale 1ns/1ps
`default_nettype none

// Radix-8 modified Booth recoder.
//
// The multiplier is scanned in overlapping groups of 4 bits:
//   {q[3i+2], q[3i+1], q[3i], q[3i-1]}
//
// The recoded digit is in the set:
//   -4, -3, -2, -1, 0, +1, +2, +3, +4
module booth_radix8_recoder (
    input  wire [3:0] code,
    output reg  [2:0] multiple,
    output reg        negative
);
    always @* begin
        multiple = 3'd0;
        negative = 1'b0;

        case (code)
            4'b0000: begin multiple = 3'd0; negative = 1'b0; end
            4'b0001: begin multiple = 3'd1; negative = 1'b0; end
            4'b0010: begin multiple = 3'd1; negative = 1'b0; end
            4'b0011: begin multiple = 3'd2; negative = 1'b0; end
            4'b0100: begin multiple = 3'd2; negative = 1'b0; end
            4'b0101: begin multiple = 3'd3; negative = 1'b0; end
            4'b0110: begin multiple = 3'd3; negative = 1'b0; end
            4'b0111: begin multiple = 3'd4; negative = 1'b0; end
            4'b1000: begin multiple = 3'd4; negative = 1'b1; end
            4'b1001: begin multiple = 3'd3; negative = 1'b1; end
            4'b1010: begin multiple = 3'd3; negative = 1'b1; end
            4'b1011: begin multiple = 3'd2; negative = 1'b1; end
            4'b1100: begin multiple = 3'd2; negative = 1'b1; end
            4'b1101: begin multiple = 3'd1; negative = 1'b1; end
            4'b1110: begin multiple = 3'd1; negative = 1'b1; end
            4'b1111: begin multiple = 3'd0; negative = 1'b0; end
        endcase
    end
endmodule

// Creates one unshifted radix-8 Booth partial product.
// It builds 1*M, 2*M, 3*M, and 4*M using wiring and ripple adders.
module booth_radix8_partial_product (
    input  wire [7:0]  multiplicand,
    input  wire [3:0]  code,
    output wire [17:0] partial_product
);
    wire [2:0]  multiple;
    wire        negative;
    wire [17:0] m1;
    wire [17:0] m2;
    wire [17:0] m3;
    wire [17:0] m4;
    reg  [17:0] selected_positive;
    wire        unused_cout;
    wire        unused_carry_into_msb;

    booth_radix8_recoder recode (
        .code(code),
        .multiple(multiple),
        .negative(negative)
    );

    assign m1 = {{10{multiplicand[7]}}, multiplicand};
    assign m2 = {m1[16:0], 1'b0};
    assign m4 = {m1[15:0], 2'b00};

    ripple_adder #(.WIDTH(18)) make_three_m (
        .a(m1),
        .b(m2),
        .cin(1'b0),
        .sum(m3),
        .cout(unused_cout),
        .carry_into_msb(unused_carry_into_msb)
    );

    always @* begin
        selected_positive = 18'b000000000000000000;

        case (multiple)
            3'd0: selected_positive = 18'b000000000000000000;
            3'd1: selected_positive = m1;
            3'd2: selected_positive = m2;
            3'd3: selected_positive = m3;
            3'd4: selected_positive = m4;
            default: selected_positive = 18'b000000000000000000;
        endcase
    end

    twos_complement_cond #(.WIDTH(18)) apply_partial_product_sign (
        .in(selected_positive),
        .negate(negative),
        .out(partial_product)
    );
endmodule

// Signed 8x8 radix-8 Booth multiplier.
//
// For an 8-bit multiplier only three radix-8 groups are needed:
//   group 0: {a[2], a[1], a[0], 0}
//   group 1: {a[5], a[4], a[3], a[2]}
//   group 2: {a[7], a[7], a[6], a[5]} with sign extension
//
// The three partial products are shifted by 0, 3, and 6 bits, then added.
module signed_booth_radix8_multiplier_8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] result,
    output wire       overflow
);
    wire [3:0] group0;
    wire [3:0] group1;
    wire [3:0] group2;
    wire [17:0] pp0;
    wire [17:0] pp1;
    wire [17:0] pp2;
    wire [17:0] shifted_pp0;
    wire [17:0] shifted_pp1;
    wire [17:0] shifted_pp2;
    wire [17:0] sum01;
    wire [17:0] product;
    wire        unused_cout01;
    wire        unused_cout_final;
    wire        unused_cim01;
    wire        unused_cim_final;
    wire        unused_pp1_shift_top;
    wire        unused_pp2_shift_top;

    assign group0 = {a[2], a[1], a[0], 1'b0};
    assign group1 = {a[5], a[4], a[3], a[2]};
    assign group2 = {a[7], a[7], a[6], a[5]};

    booth_radix8_partial_product pp_group0 (
        .multiplicand(b),
        .code(group0),
        .partial_product(pp0)
    );

    booth_radix8_partial_product pp_group1 (
        .multiplicand(b),
        .code(group1),
        .partial_product(pp1)
    );

    booth_radix8_partial_product pp_group2 (
        .multiplicand(b),
        .code(group2),
        .partial_product(pp2)
    );

    // Fixed-width left shifts drop the bits that move past bit 17.
    assign unused_pp1_shift_top = |pp1[17:15];
    assign unused_pp2_shift_top = |pp2[17:12];
    assign shifted_pp0          = pp0;
    assign shifted_pp1          = {pp1[14:0], 3'b000};
    assign shifted_pp2          = {pp2[11:0], 6'b000000};

    ripple_adder #(.WIDTH(18)) add_low_groups (
        .a(shifted_pp0),
        .b(shifted_pp1),
        .cin(1'b0),
        .sum(sum01),
        .cout(unused_cout01),
        .carry_into_msb(unused_cim01)
    );

    ripple_adder #(.WIDTH(18)) add_high_group (
        .a(sum01),
        .b(shifted_pp2),
        .cin(1'b0),
        .sum(product),
        .cout(unused_cout_final),
        .carry_into_msb(unused_cim_final)
    );

    assign result   = product[7:0];
    assign overflow = |(product[17:8] ^ {10{product[7]}});
endmodule

`default_nettype wire
