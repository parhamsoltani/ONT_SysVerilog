import param_pkg::*;
import class_pkg::*;

class C4;
    rand bit [Byte_Num-1:0] data[c4_Width][c4_Length];
    
    function void pre_randomize ();
    //    $display ("This will be called just before randomization");
    endfunction

    function void post_randomize ();
    //    $display ("This will be called just after randomization");
    endfunction

    function int index_2Dto1D(input int row, column);
        return row * c4_Width + column -1;
    endfunction

    function dimensions_t location_1Dto2D (input int index_a,Length_total);
        automatic int lenght_a = (index_a) % Length_total;
        automatic int width_a = (index_a+1) / Length_total;
        $display("Array[%0d] --> Mat[%0d][%0d]", index_a, lenght_a, width_a);
    endfunction

endclass