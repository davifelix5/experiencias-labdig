onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/cenario
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/caso
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/clock_freq
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/clockPeriod
add wave -noupdate -divider input
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/clock_in
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/botoes_in
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/iniciar_in
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/reset_in
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_clock
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/nivel_jogadas_in
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/nivel_tempo_in
add wave -noupdate -divider output
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/ganhou_out
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/leds_out
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/nova_jogada_out
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/perdeu_out
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/pronto_out
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/pulso_buzzer_out
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/vez_jogador_out
add wave -noupdate -divider depuracao
add wave -noupdate -height 30 -radix hexadecimal /circuito_exp6_desafio_tb/DUT/unidade_controle/Eatual
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/DUT/fluxo_dados/s_memoria
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/DUT/fluxo_dados/s_endereco
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/DUT/fluxo_dados/jogada_feita
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/DUT/fluxo_dados/gravaM
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/DUT/fluxo_dados/meioTM
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/DUT/fluxo_dados/s_jogada
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/DUT/nova_jogada
add wave -noupdate -height 30 -radix hexadecimal /circuito_exp6_desafio_tb/db_contagem
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_enderecoIgualRodada
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_jogada
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_jogada_correta
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_memoria
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_nivel_jogadas
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_nivel_tempo
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_rodada
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/db_timeout
add wave -noupdate -height 30 /circuito_exp6_desafio_tb/novos_valores
add wave -noupdate /circuito_exp6_desafio_tb/DUT/fluxo_dados/contaC
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {200280 ns} 0} {{Cursor 3} {250280 ns} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {250270 ns} {250289 ns}
