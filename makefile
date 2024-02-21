TOP_LEVEL := circuito_exp6_desafio_tb
WAVES     := wave_desafio.do

all: vlog
	@vsim -do "do $(WAVES); run -all;" work.$(TOP_LEVEL)
vlog: 
	@vlog *.v
headless: vlog
	@vsim -c -do "run -all; q" work.$(TOP_LEVEL)
