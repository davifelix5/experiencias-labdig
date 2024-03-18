TOP_LEVEL := circuito_principal_tb
WAVES     := wave.do
GTKWAVE   := default2.gtkw

all: vlog vsim
	gtkwave waveforms.vcd $(GTKWAVE)
vlog: 
	@vlog *.v
modelsim: vlog vsim
	@vsim -do "do $(WAVES); run -all; q" work.$(TOP_LEVEL)
vsim: 
	@vsim -c -do "run -all; q" work.$(TOP_LEVEL)