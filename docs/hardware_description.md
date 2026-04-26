# Hardware Description

This is a structural 8-bit ALU. The main file does not calculate operations
directly. It connects a control unit, a datapath, and a flag unit.

## Top Level

Top module: `alu8`

Inputs:

- `A[7:0]`
- `B[7:0]`
- `ALU_Sel[3:0]`

Outputs:

- `Result[7:0]`
- `Z`
- `N`
- `V`

The control unit decodes the operation code into one-hot control signals.
The datapath computes the possible operation results. The final mux selects
the result that belongs to the active control signal.

## Control Unit

`alu_control_unit` has one output per operation:

- `c_add`
- `c_sub`
- `c_mul`
- `c_div`
- `c_and`
- `c_or`
- `c_xor`
- `c_shl`
- `c_shr`

For normal opcodes, exactly one control signal is active. For undefined
opcodes, all control signals stay zero.

## Addition

Addition uses `ripple_adder`.

One full adder is used for each bit. Carry propagates from bit 0 toward bit 7.
Overflow is:

```text
carry_into_bit7 XOR carry_out_bit7
```

## Subtraction

Subtraction uses the same adder:

```text
A - B = A + (~B) + 1
```

This keeps subtraction in the same hardware family as addition.

## Booth Radix-8 Multiplication

File: `rtl/arithmetic/booth_multiplier_8.v`

The multiplier operand is divided into three overlapping groups:

| Group | Bits |
| --- | --- |
| `group0` | `{a[2], a[1], a[0], 0}` |
| `group1` | `{a[5], a[4], a[3], a[2]}` |
| `group2` | `{a[7], a[7], a[6], a[5]}` |

`group2` repeats `a[7]` for sign extension.

The recoder maps every group to one of these multiples:

```text
0, +M, +2M, +3M, +4M, -M, -2M, -3M, -4M
```

`3M` is made as `M + 2M` using a ripple adder. Negative partial products are
made with the shared two's-complement block. The partial products are shifted
by 0, 3, and 6 bits, then added.

The ALU returns `product[7:0]`. Overflow is set if the rest of the product is
not a sign extension of bit 7.

## SRT Radix-2 Division

File: `rtl/arithmetic/srt_radix2_divider_8.v`

The divider uses positive magnitudes internally. The sign is handled before
and after the divider core.

Each SRT stage has:

- `A` - signed partial remainder
- `Q` - dividend/quotient register
- `divisor`

Each stage shifts `{A, Q}` left by one bit. Then:

- if the old partial remainder was positive, subtract the divisor
- if the old partial remainder was negative, add the divisor

The sign of the new partial remainder becomes the next quotient bit. After
the eighth stage, a negative remainder is corrected by adding the divisor
once.

Division by zero returns zero and sets `V`.

## Logic Operations

AND, OR, and XOR are separate 8-bit modules. They are simple bit-by-bit logic
blocks.

## Shifts

The shifters are mux-based barrel shifters. The shift amount is `B[2:0]`.

There are three stages:

- shift by 1
- shift by 2
- shift by 4

Left and right shifts are logical shifts, so empty positions are filled with
zero.

## Flags

- `Z` is set by `zero_detector_8`
- `N` is `Result[7]`
- `V` is selected from the arithmetic block that is currently active

For logical and shift operations, `V = 0`.
