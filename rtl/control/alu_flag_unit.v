`timescale 1ns/1ps
`default_nettype none

// Status flags for the selected datapath result.
module alu_flag_unit (
    input  wire [7:0] result,
    input  wire       overflow_in,
    output wire       Z,
    output wire       N,
    output wire       V
);
    wire result_is_zero;

    zero_detector_8 zero_check (
        .value(result),
        .is_zero(result_is_zero)
    );

    assign Z = result_is_zero;
    assign N = result[7];
    assign V = overflow_in;
endmodule

`default_nettype wire
