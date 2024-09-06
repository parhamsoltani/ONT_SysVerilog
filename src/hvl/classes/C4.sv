import param_pkg::*;
import class_pkg::*;


class C4;
    rand bit [0:C4_WIDTH-1][0:C4_LENGTH-1][BYTE_NUM-1:0] data;

    function void pre_randomize ();
        // $display ("C4: This will be called just before randomization");
    endfunction

    function void post_randomize ();
        // $display ("C4: This will be called just after randomization");
    endfunction

    function int index_2Dto1D(input int row, column);
        return row * C4_WIDTH + column;
    endfunction
endclass


