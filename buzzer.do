onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /buzzer_tb/UUT/reset
add wave -noupdate /buzzer_tb/UUT/conta
add wave -noupdate /buzzer_tb/UUT/seletor
add wave -noupdate /buzzer_tb/UUT/clock
add wave -noupdate /buzzer_tb/UUT/pulso
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2000998050 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 152
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
WaveRestoreZoom {2000997852 ns} {2001005875 ns}
