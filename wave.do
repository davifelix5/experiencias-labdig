onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 25 /circuito_exp5_tb/clock_in
add wave -noupdate -height 25 -radix decimal /circuito_exp5_tb/caso
add wave -noupdate -divider input
add wave -noupdate -height 25 /circuito_exp5_tb/reset_in
add wave -noupdate -height 25 /circuito_exp5_tb/iniciar_in
add wave -noupdate -height 25 /circuito_exp5_tb/chaves_in
add wave -noupdate -height 25 /circuito_exp5_tb/nivel_in
add wave -noupdate -divider output
add wave -noupdate -height 25 /circuito_exp5_tb/acertou_out
add wave -noupdate -height 25 /circuito_exp5_tb/errou_out
add wave -noupdate -height 25 /circuito_exp5_tb/pronto_out
add wave -noupdate /circuito_exp5_tb/DUT/timeout
add wave -noupdate -height 25 /circuito_exp5_tb/leds_out
add wave -noupdate -divider depuraç~ao
add wave -noupdate -height 25 -radix hexadecimal /circuito_exp5_tb/DUT/exp5_unidade_controle/Eatual
add wave -noupdate -radix hexadecimal /circuito_exp5_tb/DUT/exp5_fluxo_dados/db_contagem
add wave -noupdate -height 25 /circuito_exp5_tb/DUT/exp5_fluxo_dados/valor_memoria
add wave -noupdate /circuito_exp5_tb/db_nivel
add wave -noupdate /circuito_exp5_tb/DUT/db_meioTempo
add wave -noupdate /circuito_exp5_tb/DUT/fimTempo
add wave -noupdate /circuito_exp5_tb/DUT/exp5_fluxo_dados/contaTempo
add wave -noupdate /circuito_exp5_tb/DUT/exp5_fluxo_dados/registraN
add wave -noupdate -height 25 /circuito_exp5_tb/DUT/exp5_fluxo_dados/jogada_feita
add wave -noupdate /circuito_exp5_tb/db_igual
add wave -noupdate /circuito_exp5_tb/db_tem_jogada
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {288 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 281
configure wave -valuecolwidth 40
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
WaveRestoreZoom {140 ns} {699 ns}
