# You may change these configuration to fit your need
UVM_VERBOSITY = UVM_LOW

# You HAVE TO change this to your UVM package path
UVM_HOME = /change/to/your/path

# Files declaration
RTL_FILES = ../rtl/uart_pkg.sv \
			../rtl/uart_if.sv \
			../rtl/uart_bclk_gen.sv \
			../rtl/uart_rx.sv  \
			../rtl/uart_tx.sv  \
			../rtl/uart_top.sv \

TB_FILES =  ../test/uart_test_pkg.sv \
            ../test/uart_tb.sv

# Directory declaration
RTL_DIR       = +incdir+../rtl
UVM_TB_DIR    = +incdir+../test+../test/seq+../test/env


# Other declarations
UVM_TESTNAME = uart_half_duplex_test

# VCS related commands
VCS = vcs
VCS_OPTS = -full64 -sverilog -timescale=1ns/1ns +acc +vpi +v2k
UVM_OPTS = +incdir+$(UVM_HOME)/src \
                   $(UVM_HOME)/src/uvm.sv \
                   $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS

INCDIRS = $(RTL_DIR) \
		  $(ASSERTION_DIR) \
          $(UVM_TB_DIR)

SRC_FILES = $(RTL_FILES) \
            $(TB_FILES)

.PHONY: vcs_std run_test_hd run_test_fd vcs_urg clean

all: vcs_std run_test_hd vcs_urg 

vcs_std:
	$(VCS) $(VCS_OPTS) $(UVM_OPTS) $(INCDIRS) $(SRC_FILES)

run_test_hd:
	./simv +UVM_TESTNAME=uart_half_duplex_test +UVM_VERBOSITY=$(UVM_VERBOSITY)

run_test_fd:
	./simv +UVM_TESTNAME=uart_full_duplex_test +UVM_VERBOSITY=$(UVM_VERBOSITY)

vcs_urg:
	urg -dir simv.vdb

clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log dump* DVE*