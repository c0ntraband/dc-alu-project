`timescale 1ns/1ps
`default_nettype none

// Conditional two's-complement block:
// negate=0 -> out=in
// negate=1 -> out=(~in)+1
module twos_complement_cond #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] in,
    input  wire             negate,
    output wire [WIDTH-1:0] out
);
    wire [WIDTH-1:0] maybe_inverted;
    wire             unused_cout;
    wire             unused_carry_into_msb;

    assign maybe_inverted = in ^ {WIDTH{negate}};

    ripple_adder #(.WIDTH(WIDTH)) add_one_if_negated (
        .a(maybe_inverted),
        .b({WIDTH{1'b0}}),
        .cin(negate),
        .sum(out),
        .cout(unused_cout),
        .carry_into_msb(unused_carry_into_msb)
    );
endmodule

`default_nettype wire
