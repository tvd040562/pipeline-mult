# Makefile

# defaults
SIM ?= icarus
WAVES ?= 1
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/ba_pipelined.v
# use VHDL_SOURCES for VHDL files

# COCOTB_TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
COCOTB_TOPLEVEL = pipelined_mult

# COCOTB_TEST_MODULES is the basename of the Python test file(s)
COCOTB_TEST_MODULES = mult_tb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim