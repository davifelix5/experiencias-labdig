TOP_LEVEL := circuito_exp5_tb

all: vlog
	@vsim -c -do "run -all; q" work.$(TOP_LEVEL)
vlog: 
	@vlog *.v