onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sdram_control_top_tb/Clk
add wave -noupdate /sdram_control_top_tb/Rst_n
add wave -noupdate /sdram_control_top_tb/Wr_data
add wave -noupdate /sdram_control_top_tb/Wr_en
add wave -noupdate /sdram_control_top_tb/Wr_load
add wave -noupdate /sdram_control_top_tb/Wr_clk
add wave -noupdate /sdram_control_top_tb/Rd_data
add wave -noupdate /sdram_control_top_tb/Rd_en
add wave -noupdate /sdram_control_top_tb/Rd_load
add wave -noupdate /sdram_control_top_tb/Rd_clk
add wave -noupdate /sdram_control_top_tb/sd_caddr
add wave -noupdate /sdram_control_top_tb/sd_raddr
add wave -noupdate /sdram_control_top_tb/sd_baddr
add wave -noupdate /sdram_control_top_tb/Sa
add wave -noupdate /sdram_control_top_tb/Ba
add wave -noupdate /sdram_control_top_tb/Cs_n
add wave -noupdate /sdram_control_top_tb/Cke
add wave -noupdate /sdram_control_top_tb/Ras_n
add wave -noupdate /sdram_control_top_tb/Cas_n
add wave -noupdate /sdram_control_top_tb/We_n
add wave -noupdate /sdram_control_top_tb/Dq
add wave -noupdate /sdram_control_top_tb/Dqm
add wave -noupdate /sdram_control_top_tb/sdram_clk
add wave -noupdate -radix decimal /sdram_control_top_tb/Wr_data
add wave -noupdate /sdram_control_top_tb/sdram_control_top/sdram_control/aref_request
add wave -noupdate /sdram_control_top_tb/sdram_control_top/sdram_control/no_request
add wave -noupdate /sdram_control_top_tb/sdram_control_top/sdram_control/read_request
add wave -noupdate /sdram_control_top_tb/sdram_control_top/sdram_control/write_request
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {210330000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 71
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {337872161 ps} {338290939 ps}
