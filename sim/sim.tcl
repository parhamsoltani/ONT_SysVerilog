

	alias clc ".main clear"
	# clc

	exec vlib work
	vmap work work
	
	file mkdir files
	file mkdir scr
	file mkdir tb
	file mkdir wlf
	file mkdir wave
	
	set project_path		".."
	set include_path		"$project_path/src/inc"
	
	set TB					"tb1"
	set wlf_save_name		"wlf/vsim.wlf"
	set opened_wlf_name		"ref_sim"
	set run_time			"5 ms"
	set path_sdh_module		"uut"

	

	
#===============================================================================
#===============================================================================
	
#========== complile modules
	#onerror {break}
	# XILINX_VIVADO is an environment variable pointing to a (preferably the latest) VIVADO directory
    # If you do not have VIVADO, you can comment this part!
	vlog -work work $env(XILINX_VIVADO)/data/verilog/src/glbl.v
	vlog -work work $env(XILINX_VIVADO)/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv
	vlog -work work $env(XILINX_VIVADO)/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv
	vlog -work work $env(XILINX_VIVADO)/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv
	vlog -work work $env(XILINX_VIVADO)/data/verilog/src/unisims/MMCME2_BASE.v
	vlog -work work $env(XILINX_VIVADO)/data/verilog/src/unisims/MMCME2_ADV.v

	do scr/compile_all.tcl

#	set line_file_list [list "$project_path/" "csa.sv" "csa_tb.sv"]
	
#========== simulate design
	
	# optimization is required for schematic view
# -voptargs=+acc=rnb+tb_E1_63_PRBS+E1_SDH_deMapper_v2 -debugDB \
	
	vsim	-wlf $wlf_save_name  -wlfopt -wlfslim 10000 -wlftlim {500 ms}\
			 -voptargs=+acc -debugDB \
			-L unisims_ver -L unimacro_ver $TB work.glbl

#========== add breakpoints

	# bp $project_path/sim/tb/inc/MicroReadWrite.sv 14
	# bp $project_path/sim/tb/inc/MicroReadWrite.sv 19
	# bp $project_path/sim/tb/inc/MicroReadWrite.sv 21
	# bp $project_path/sim/tb/inc/MicroReadWrite.sv 25
	#bp
#========== adding signals to wave window
	do wave/wave.tcl
#========== run simulation
	run -all