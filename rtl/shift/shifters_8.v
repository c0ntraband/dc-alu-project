`timescale 1ns/1ps
`default_nettype none

// Logic-left shifter. B[2:0] selects 0..7 shifts. The three stages are
// mux levels for shift-by-1, shift-by-2, and shift-by-4.
module left_shifter_8 (
    input  wire [7:0] data,
    input  wire [2:0] shamt,
    output wire [7:0] y
);
    wire [7:0] stage1;
    wire [7:0] stage2;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_shift_by_1
            if (i < 1) begin : zero_fill
                mux2_1 mux_shift (.d0(data[i]), .d1(1'b0), .sel(shamt[0]), .y(stage1[i]));
            end else begin : shifted
                mux2_1 mux_shift (.d0(data[i]), .d1(data[i-1]), .sel(shamt[0]), .y(stage1[i]));
            end
        end

        for (i = 0; i < 8; i = i + 1) begin : gen_shift_by_2
            if (i < 2) begin : zero_fill
                mux2_1 mux_shift (.d0(stage1[i]), .d1(1'b0), .sel(shamt[1]), .y(stage2[i]));
            end else begin : shifted
                mux2_1 mux_shift (.d0(stage1[i]), .d1(stage1[i-2]), .sel(shamt[1]), .y(stage2[i]));
            end
        end

        for (i = 0; i < 8; i = i + 1) begin : gen_shift_by_4
            if (i < 4) begin : zero_fill
                mux2_1 mux_shift (.d0(stage2[i]), .d1(1'b0), .sel(shamt[2]), .y(y[i]));
            end else begin : shifted
                mux2_1 mux_shift (.d0(stage2[i]), .d1(stage2[i-4]), .sel(shamt[2]), .y(y[i]));
            end
        end
    endgenerate
endmodule

// Logical-right shifter using the same mux-level style.
module right_shifter_8 (
    input  wire [7:0] data,
    input  wire [2:0] shamt,
    output wire [7:0] y
);
    wire [7:0] stage1;
    wire [7:0] stage2;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_shift_by_1
            if (i > 6) begin : zero_fill
                mux2_1 mux_shift (.d0(data[i]), .d1(1'b0), .sel(shamt[0]), .y(stage1[i]));
            end else begin : shifted
                mux2_1 mux_shift (.d0(data[i]), .d1(data[i+1]), .sel(shamt[0]), .y(stage1[i]));
            end
        end

        for (i = 0; i < 8; i = i + 1) begin : gen_shift_by_2
            if (i > 5) begin : zero_fill
                mux2_1 mux_shift (.d0(stage1[i]), .d1(1'b0), .sel(shamt[1]), .y(stage2[i]));
            end else begin : shifted
                mux2_1 mux_shift (.d0(stage1[i]), .d1(stage1[i+2]), .sel(shamt[1]), .y(stage2[i]));
            end
        end

        for (i = 0; i < 8; i = i + 1) begin : gen_shift_by_4
            if (i > 3) begin : zero_fill
                mux2_1 mux_shift (.d0(stage2[i]), .d1(1'b0), .sel(shamt[2]), .y(y[i]));
            end else begin : shifted
                mux2_1 mux_shift (.d0(stage2[i]), .d1(stage2[i+4]), .sel(shamt[2]), .y(y[i]));
            end
        end
    endgenerate
endmodule

`default_nettype wire
