`timescale 1ns/1ps
`default_nettype none

// 1-bit full adder built from elementary Boolean logic.
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire axb;
    wire ab;
    wire ac;
    wire bc;

    assign axb  = a ^ b;
    assign sum  = axb ^ cin;
    assign ab   = a & b;
    assign ac   = a & cin;
    assign bc   = b & cin;
    assign cout = ab | ac | bc;
endmodule

`default_nettype wire
