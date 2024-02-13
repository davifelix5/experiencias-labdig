onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /circuito_exp6_tb/cenario
add wave -noupdate -height 25 -radix decimal /circuito_exp6_tb/caso
add wave -noupdate -height 25 /circuito_exp6_tb/clock_in
add wave -noupdate -divider input
add wave -noupdate -height 25 /circuito_exp6_tb/chaves_in
add wave -noupdate -height 25 /circuito_exp6_tb/reset_in
add wave -noupdate -height 25 /circuito_exp6_tb/iniciar_in
add wave -noupdate -height 25 /circuito_exp6_tb/nivel_tempo_in
add wave -noupdate -height 25 /circuito_exp6_tb/nivel_jogadas_in
add wave -noupdate -divider output
add wave -noupdate -height 25 /circuito_exp6_tb/pronto_out
add wave -noupdate -height 25 /circuito_exp6_tb/acertou_out
add wave -noupdate -height 25 /circuito_exp6_tb/timeout_out
add wave -noupdate -height 25 /circuito_exp6_tb/errou_out
add wave -noupdate -height 25 /circuito_exp6_tb/leds_out
add wave -noupdate -height 25 /circuito_exp6_tb/vez_jogador_out
add wave -noupdate -divider depuracao
add wave -noupdate /circuito_exp6_tb/DUT/fluxo_dados/ativa_leds
add wave -noupdate -height 25 -radix hexadecimal /circuito_exp6_tb/DUT/unidade_controle/db_estado
add wave -noupdate -height 25 -radix hexadecimal /circuito_exp6_tb/DUT/fluxo_dados/s_endereco
add wave -noupdate -height 25 /circuito_exp6_tb/DUT/fluxo_dados/enderecoIgualRodada
add wave -noupdate -height 25 -radix hexadecimal /circuito_exp6_tb/DUT/fluxo_dados/s_rodada
add wave -noupdate -height 25 /circuito_exp6_tb/DUT/fluxo_dados/contaCR
add wave -noupdate -height 25 -radix hexadecimal /circuito_exp6_tb/DUT/fluxo_dados/s_jogada
add wave -noupdate -height 25 /circuito_exp6_tb/db_igual
add wave -noupdate -height 25 /circuito_exp6_tb/db_iniciar
add wave -noupdate -height 25 /circuito_exp6_tb/db_nivel_jogadas
add wave -noupdate -height 25 /circuito_exp6_tb/db_nivel_tempo
add wave -noupdate -height 25 /circuito_exp6_tb/db_tem_jogada
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1308280 ns} 0} {{Cursor 2} {1006757 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 289
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
WaveRestoreZoom {0 ns} {1495183 ns}
