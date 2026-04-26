if [file exists work] {
    vdel -all
}

vlib work

vlog rtl/common/full_adder.v
vlog rtl/common/ripple_adder.v
vlog rtl/common/mux2.v
vlog rtl/common/zero_detector_8.v
vlog rtl/logic/bitwise_logic_8.v
vlog rtl/shift/shifters_8.v
vlog rtl/arithmetic/twos_complement_cond.v
vlog rtl/arithmetic/booth_multiplier_8.v
vlog rtl/arithmetic/srt_radix2_divider_8.v
vlog rtl/control/alu_control_unit.v
vlog rtl/control/alu_flag_unit.v
vlog rtl/datapath/alu_datapath.v
vlog rtl/alu8.v
vlog tb/alu8_tb.v

vsim -voptargs=+acc work.alu8_tb

add wave /alu8_tb/A
add wave /alu8_tb/B
add wave /alu8_tb/ALU_Sel
add wave /alu8_tb/Result
add wave /alu8_tb/Z
add wave /alu8_tb/N
add wave /alu8_tb/V

add wave /alu8_tb/dut/c_add
add wave /alu8_tb/dut/c_sub
add wave /alu8_tb/dut/c_mul
add wave /alu8_tb/dut/c_div
add wave /alu8_tb/dut/c_and
add wave /alu8_tb/dut/c_or
add wave /alu8_tb/dut/c_xor
add wave /alu8_tb/dut/c_shl
add wave /alu8_tb/dut/c_shr

add wave /alu8_tb/dut/datapath/add_result
add wave /alu8_tb/dut/datapath/sub_result
add wave /alu8_tb/dut/datapath/mul_result
add wave /alu8_tb/dut/datapath/div_result
add wave /alu8_tb/dut/datapath/shl_result
add wave /alu8_tb/dut/datapath/shr_result

run -all

wave zoom full
