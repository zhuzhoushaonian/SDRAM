transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/ip {D:/fpga_prj/sdram_three_version/ip/fifo_wr.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/ip {D:/fpga_prj/sdram_three_version/ip/fifo_rd.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/sdram_init.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/sdram_control_top.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/sdram_control.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/auto_refre_state.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/write_state.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/read_state.v}

vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/sdram_control_top_tb.v}
vlog -vlog01compat -work work +incdir+D:/fpga_prj/sdram_three_version/prj {D:/fpga_prj/sdram_three_version/prj/sdr.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  sdram_control_top_tb

add wave *
view structure
view signals
run -all
