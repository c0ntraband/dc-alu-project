`timescale 1ns/1ps
`default_nettype none

// Parameterized ripple-carry adder. The carry chain is explicit so the
// signed overflow flag can use carry_into_msb XOR cout.
module ripple_adder #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout,
    output wire             carry_into_msb
);
    wire [WIDTH:0] carry;

    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_full_adders
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i + 1])
            );
        end
    endgenerate

    assign carry_into_msb = carry[WIDTH-1];
    assign cout           = carry[WIDTH];
endmodule

`default_nettype wire
