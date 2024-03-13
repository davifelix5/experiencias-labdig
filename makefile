TOP_LEVEL := circuito_principal_tb
WAVES     := wave.do

all: vlog
	@vsim -do "do $(WAVES); run -all; q" work.$(TOP_LEVEL)
vlog: 
	@vlog *.v
gtkwave: vlog vsim
	gtkwave waveforms.vcd default.gtkw
vsim: 
	@vsim -c -do "run -all; q" work.$(TOP_LEVEL)