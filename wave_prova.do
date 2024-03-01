onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 30 /circuito_exp7_tb_prova/cenario
add wave -noupdate -height 30 /circuito_exp7_tb_prova/caso
add wave -noupdate -height 30 /circuito_exp7_tb_prova/clock_freq
add wave -noupdate -height 30 /circuito_exp7_tb_prova/clockPeriod
add wave -noupdate -divider input
add wave -noupdate -height 30 /circuito_exp7_tb_prova/clock_in
add wave -noupdate -height 30 /circuito_exp7_tb_prova/botoes_in
add wave -noupdate -height 30 /circuito_exp7_tb_prova/iniciar_in
add wave -noupdate -height 30 /circuito_exp7_tb_prova/reset_in
add wave -noupdate -height 30 /circuito_exp7_tb_prova/db_clock
add wave -noupdate -height 30 /circuito_exp7_tb_prova/nivel_jogadas_in
add wave -noupdate -height 30 /circuito_exp7_tb_prova/nivel_tempo_in
add wave -noupdate -divider output
add wave -noupdate -height 30 /circuito_exp7_tb_prova/ganhou_out
add wave -noupdate -height 30 /circuito_exp7_tb_prova/leds_out
add wave -noupdate -height 30 /circuito_exp7_tb_prova/nova_jogada_out
add wave -noupdate -height 30 /circuito_exp7_tb_prova/perdeu_out
add wave -noupdate -height 30 /circuito_exp7_tb_prova/pronto_out
add wave -noupdate -height 30 /circuito_exp7_tb_prova/pulso_buzzer_out
add wave -noupdate -height 30 /circuito_exp7_tb_prova/vez_jogador_out
add wave -noupdate -divider depuracao
add wave -noupdate -height 30 -radix hexadecimal /circuito_exp7_tb_prova/DUT/unidade_controle/Eatual
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/fluxo_dados/modo2_reg
add wave -noupdate -height 30 -radix hexadecimal /circuito_exp7_tb_prova/DUT/fluxo_dados/s_memoria
add wave -noupdate -height 30 -radix hexadecimal /circuito_exp7_tb_prova/DUT/fluxo_dados/s_endereco
add wave -noupdate -height 30 -radix hexadecimal /circuito_exp7_tb_prova/DUT/fluxo_dados/s_rodada
add wave -noupdate -height 30 -radix hexadecimal /circuito_exp7_tb_prova/DUT/fluxo_dados/s_jogada
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/fluxo_dados/jogada_feita
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/nova_jogada
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/db_fimTM
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/db_gravaM
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/db_meioTM
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/db_modo2
add wave -noupdate -height 30 /circuito_exp7_tb_prova/DUT/fluxo_dados/contaC
add wave -noupdate -height 30 /circuito_exp7_tb_prova/db_enderecoIgualRodada
add wave -noupdate -height 30 /circuito_exp7_tb_prova/db_jogada_correta
add wave -noupdate -height 30 /circuito_exp7_tb_prova/db_nivel_jogadas
add wave -noupdate -height 30 /circuito_exp7_tb_prova/db_nivel_tempo
add wave -noupdate -height 30 /circuito_exp7_tb_prova/db_timeout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {15918580 ns} 0} {{Cursor 3} {47499260 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 390
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {35939540 ns} {35940909 ns}
