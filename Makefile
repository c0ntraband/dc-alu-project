IVERILOG ?= iverilog
VVP ?= vvp
BUILD_DIR ?= build
RTL_SOURCES := \
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

.PHONY: run clean

run: $(BUILD_DIR)/alu8_tb.vvp
	$(VVP) $<

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/alu8_tb.vvp: $(RTL_SOURCES) tb/alu8_tb.v | $(BUILD_DIR)
	$(IVERILOG) -g2012 -o $@ tb/alu8_tb.v $(RTL_SOURCES)

clean:
	rm -rf $(BUILD_DIR)
