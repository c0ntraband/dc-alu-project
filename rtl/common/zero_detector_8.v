`timescale 1ns/1ps
`default_nettype none

module zero_detector_8 (
    input  wire [7:0] value,
    output wire       is_zero
);
    assign is_zero = ~(value[0] | value[1] | value[2] | value[3] |
                       value[4] | value[5] | value[6] | value[7]);
endmodule

`default_nettype wire
