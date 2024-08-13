    vlog -vopt -sv $project_path/src/hvl/packages/param_pkg.sv
    vlog -vopt -sv $project_path/src/hvl/classes/class_pkg.sv

    vlog -vopt -sv +incdir+$project_path/sim/tb/*.sv