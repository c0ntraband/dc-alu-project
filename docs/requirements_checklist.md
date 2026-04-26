# Requirements Checklist

## Interface

Top module: `alu8`

| Requirement | Signal |
| --- | --- |
| first 8-bit operand | `A[7:0]` |
| second 8-bit operand | `B[7:0]` |
| operation select | `ALU_Sel[3:0]` |
| 8-bit result | `Result[7:0]` |
| zero flag | `Z` |
| negative flag | `N` |
| overflow flag | `V` |

## Operations

| Operation | Opcode | Implementation |
| --- | --- | --- |
| Addition | `0000` | ripple adder |
| Subtraction | `0001` | ripple adder with inverted `B` and carry-in 1 |
| Multiplication | `0010` | Booth radix-8 |
| Division | `0011` | SRT radix-2 |
| AND | `0100` | bitwise AND module |
| OR | `0101` | bitwise OR module |
| XOR | `0110` | bitwise XOR module |
| LEFT SHIFT | `0111` | mux barrel shifter |
| RIGHT SHIFT | `1000` | mux barrel shifter |

## Main Files

| File | Purpose |
| --- | --- |
| `rtl/alu8.v` | connects control, datapath, and flags |
| `rtl/control/alu_control_unit.v` | decodes `ALU_Sel` |
| `rtl/datapath/alu_datapath.v` | operation hardware and result mux |
| `rtl/control/alu_flag_unit.v` | status flags |
| `rtl/common/full_adder.v` | one-bit adder |
| `rtl/common/ripple_adder.v` | multi-bit adder |
| `rtl/arithmetic/booth_multiplier_8.v` | Booth radix-8 multiplication |
| `rtl/arithmetic/srt_radix2_divider_8.v` | SRT radix-2 division |
| `rtl/shift/shifters_8.v` | left/right shifts |
| `rtl/logic/bitwise_logic_8.v` | AND/OR/XOR |

## Structural Points

- No `*` or `/` operators are used in the arithmetic datapath.
- Addition and subtraction are made from full adders.
- Multiplication is built from Booth recoding, multiple generation, and adders.
- Division is built from repeated SRT add/subtract stages.
- The result is selected with one-hot control signals from the control unit.
