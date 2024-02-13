onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /circuito_exp6_tb/caso
add wave -noupdate /circuito_exp6_tb/clock_in
add wave -noupdate /circuito_exp6_tb/chaves_in
add wave -noupdate /circuito_exp6_tb/reset_in
add wave -noupdate /circuito_exp6_tb/iniciar_in
add wave -noupdate /circuito_exp6_tb/nivel_tempo_in
add wave -noupdate /circuito_exp6_tb/nivel_jogadas_in
add wave -noupdate /circuito_exp6_tb/pronto_out
add wave -noupdate /circuito_exp6_tb/acertou_out
add wave -noupdate /circuito_exp6_tb/timeout_out
add wave -noupdate /circuito_exp6_tb/errou_out
add wave -noupdate /circuito_exp6_tb/leds_out
add wave -noupdate /circuito_exp6_tb/vez_jogador_out
add wave -noupdate -radix hexadecimal /circuito_exp6_tb/DUT/unidade_controle/db_estado
add wave -noupdate -radix hexadecimal /circuito_exp6_tb/DUT/fluxo_dados/s_endereco
add wave -noupdate -radix hexadecimal /circuito_exp6_tb/DUT/fluxo_dados/s_jogada
add wave -noupdate /circuito_exp6_tb/DUT/fluxo_dados/enderecoIgualRodada
add wave -noupdate -radix hexadecimal /circuito_exp6_tb/DUT/fluxo_dados/s_rodada
add wave -noupdate /circuito_exp6_tb/DUT/fluxo_dados/contaCR
add wave -noupdate -radix hexadecimal /circuito_exp6_tb/db_estado
add wave -noupdate /circuito_exp6_tb/db_contagem
add wave -noupdate /circuito_exp6_tb/db_memoria
add wave -noupdate /circuito_exp6_tb/db_jogada
add wave -noupdate /circuito_exp6_tb/db_igual
add wave -noupdate /circuito_exp6_tb/db_iniciar
add wave -noupdate /circuito_exp6_tb/db_nivel_jogadas
add wave -noupdate /circuito_exp6_tb/db_nivel_tempo
add wave -noupdate /circuito_exp6_tb/db_tem_jogada
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {121792 ns} 0} {{Cursor 2} {120475 ns} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {121192 ns} {121948 ns}
