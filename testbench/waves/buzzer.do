onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /buzzer_tb/caso
add wave -noupdate /buzzer_tb/UUT/conta
add wave -noupdate /buzzer_tb/UUT/clock
add wave -noupdate /buzzer_tb/UUT/pulso
add wave -noupdate /buzzer_tb/UUT/CLOCK_FREQ
add wave -noupdate /buzzer_tb/UUT/seletor
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {72726390 ns} 0} {{Cursor 2} {74998956 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 212
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
configure wave -timelineunits sec
update
WaveRestoreZoom {74998950 ns} {74999214 ns}
