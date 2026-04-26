`timescale 1ns/1ps
`default_nettype none

// 2:1 mux written as gates, reused by shifters, divider, and ALU muxing.
module mux2_1 (
    input  wire d0,
    input  wire d1,
    input  wire sel,
    output wire y
);
    assign y = ((~sel) & d0) | (sel & d1);
endmodule

module mux2_bus #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire             sel,
    output wire [WIDTH-1:0] y
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_mux_bits
            mux2_1 mux_bit (
                .d0(d0[i]),
                .d1(d1[i]),
                .sel(sel),
                .y(y[i])
            );
        end
    endgenerate
endmodule

`default_nettype wire
