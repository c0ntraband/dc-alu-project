`timescale 1ns/1ps
`default_nettype none

// Operation decoder. Only one control line is active for a valid opcode.
module alu_control_unit (
    input  wire [3:0] alu_sel,
    output reg        c_add,
    output reg        c_sub,
    output reg        c_mul,
    output reg        c_div,
    output reg        c_and,
    output reg        c_or,
    output reg        c_xor,
    output reg        c_shl,
    output reg        c_shr
);
    localparam [3:0] OP_ADD = 4'b0000;
    localparam [3:0] OP_SUB = 4'b0001;
    localparam [3:0] OP_MUL = 4'b0010;
    localparam [3:0] OP_DIV = 4'b0011;
    localparam [3:0] OP_AND = 4'b0100;
    localparam [3:0] OP_OR  = 4'b0101;
    localparam [3:0] OP_XOR = 4'b0110;
    localparam [3:0] OP_SHL = 4'b0111;
    localparam [3:0] OP_SHR = 4'b1000;

    always @* begin
        c_add = 1'b0;
        c_sub = 1'b0;
        c_mul = 1'b0;
        c_div = 1'b0;
        c_and = 1'b0;
        c_or  = 1'b0;
        c_xor = 1'b0;
        c_shl = 1'b0;
        c_shr = 1'b0;

        case (alu_sel)
            OP_ADD: c_add = 1'b1;
            OP_SUB: c_sub = 1'b1;
            OP_MUL: c_mul = 1'b1;
            OP_DIV: c_div = 1'b1;
            OP_AND: c_and = 1'b1;
            OP_OR:  c_or  = 1'b1;
            OP_XOR: c_xor = 1'b1;
            OP_SHL: c_shl = 1'b1;
            OP_SHR: c_shr = 1'b1;
            default: begin end
        endcase
    end
endmodule

`default_nettype wire
