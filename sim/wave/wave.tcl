#========== adding signals to wave window
	# default radix (hex without base)
	radix -hexadecimal -enumnumeric

	add wave -hex -group  	"TB"					sim:/$TB/*
	

	configure wave -signalnamewidth 1

	configure wave -griddelta 40
	configure wave -gridoffset 0
	configure wave -gridperiod 10
	
	configure wave -timelineunits us
	configure wave -namecolwidth 200
	configure wave -valuecolwidth 50
	configure wave -justifyvalue right

	#########################################
	