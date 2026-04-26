`timescale 1ns/1ps
`default_nettype none

module bitwise_and_8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] y
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_and
            assign y[i] = a[i] & b[i];
        end
    endgenerate
endmodule

module bitwise_or_8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] y
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_or
            assign y[i] = a[i] | b[i];
        end
    endgenerate
endmodule

module bitwise_xor_8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] y
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_xor
            assign y[i] = a[i] ^ b[i];
        end
    endgenerate
endmodule

`default_nettype wire
