TOP_LEVEL := circuito_principal_modo1_memoria_tb
WAVES     := wave.do
GTKWAVE   := default2.gtkw

all: vlog
	@vsim -do "do $(WAVES); run -all; q" work.$(TOP_LEVEL)
vlog: 
	@vlog *.v
gtkwave: vlog vsim
	gtkwave waveforms.vcd $(GTKWAVE)
vsim: 
	@vsim -c -do "run -all; q" work.$(TOP_LEVEL)