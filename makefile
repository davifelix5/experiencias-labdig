TOP_LEVEL := circuito_exp6_tb

all: vlog
	@vsim -do "do wave.do; run -all;" work.$(TOP_LEVEL)
vlog: 
	@vlog *.v
headless: vlog
	@vsim -c -do "run -all; q" work.$(TOP_LEVEL)