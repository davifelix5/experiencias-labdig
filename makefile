all: vlog
	@vsim -c -do "run -all; q" work.circuito_exp5_tb
vlog: 
	@vlog circuito_exp5.v circuito_exp5_tb.v comparador_85.v contador_163.v contador_m.v contador_m_tb.v edge_detector.v exp5_fluxo_dados.v exp5_unidade_controle.v hexa7seg.v registrador_4.v sync_rom_16x4.v