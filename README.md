# 8-bit-ALU-SIMULATOR

You will design and simulate an 8-bit Arithmetic Logic Unit (ALU) using a
Hardware Description Language (HDL). The project is completed structurally,
with the operations built from smaller hardware blocks.

# Project Requirements

The ALU supports:

1. Addition
2. Subtraction
3. Multiplication
4. Division
5. AND
6. OR
7. XOR
8. LEFT SHIFT
9. RIGHT SHIFT

# Used Algorithms

Multiplication -> Booth Radix-8

Division -> SRT Radix-2

# Interface

Top module: `alu8`

| Signal | Direction | Width | Description |
| --- | --- | ---: | --- |
| `A` | input | 8 | first operand |
| `B` | input | 8 | second operand / shift amount |
| `ALU_Sel` | input | 4 | operation select |
| `Result` | output | 8 | selected result |
| `Z` | output | 1 | set when `Result` is zero |
| `N` | output | 1 | set when `Result[7]` is one |
| `V` | output | 1 | set on signed overflow / invalid division |

# Operation Select

| `ALU_Sel` | Operation |
| --- | --- |
| `0000` | Addition |
| `0001` | Subtraction |
| `0010` | Multiplication |
| `0011` | Division |
| `0100` | AND |
| `0101` | OR |
| `0110` | XOR |
| `0111` | LEFT SHIFT |
| `1000` | RIGHT SHIFT |

Unused operation codes return `8'h00` and `V = 0`.

# Project Structure

- `rtl/alu8.v` - top module
- `rtl/control/alu_control_unit.v` - operation decoder
- `rtl/control/alu_flag_unit.v` - `Z`, `N`, `V` flags
- `rtl/datapath/alu_datapath.v` - main datapath and output mux
- `rtl/common/` - full adder, ripple adder, muxes, zero detector
- `rtl/arithmetic/` - Booth multiplier, SRT divider, two's complement helper
- `rtl/logic/` - AND, OR, XOR
- `rtl/shift/` - left and right mux shifters
- `tb/alu8_tb.v` - self-checking testbench
- `docs/` - hardware explanation and requirement mapping
- `control_unit_signals.txt` - decoded control signals

# Hardware Notes

The top level is split like a small processor datapath:

- control unit creates one-hot control signals from `ALU_Sel`
- datapath computes all candidate operation results
- output mux selects the active result
- flag unit calculates status flags from the selected result

Addition and subtraction use ripple adders made from one-bit full adders.
Subtraction is done as `A + (~B) + 1`.

Multiplication uses three Booth radix-8 recoding groups. Each group selects
`0`, `+/-M`, `+/-2M`, `+/-3M`, or `+/-4M`. The shifted partial products are
then added with ripple adders.

Division uses SRT radix-2 / non-restoring stages. The signed wrapper converts
operands to magnitudes, divides them, and reapplies the sign to the quotient.

Logical shifts use `B[2:0]` as the shift amount.

# Run the Testbench

With Icarus Verilog:

```sh
make run
```

Manual command:

```sh
mkdir -p build
iverilog -g2012 -o build/alu8_tb.vvp \
  tb/alu8_tb.v \
  rtl/common/full_adder.v \
  rtl/common/ripple_adder.v \
  rtl/common/mux2.v \
  rtl/common/zero_detector_8.v \
  rtl/logic/bitwise_logic_8.v \
  rtl/shift/shifters_8.v \
  rtl/arithmetic/twos_complement_cond.v \
  rtl/arithmetic/booth_multiplier_8.v \
  rtl/arithmetic/srt_radix2_divider_8.v \
  rtl/control/alu_control_unit.v \
  rtl/control/alu_flag_unit.v \
  rtl/datapath/alu_datapath.v \
  rtl/alu8.v
vvp build/alu8_tb.vvp
```

With ModelSim/Questa:

```tcl
do run.do
```
