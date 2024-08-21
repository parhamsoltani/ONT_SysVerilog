import param_pkg::*;

class C4;
    rand bit [c4_Lenght*c4_Width-1:0][Byte_Num-1:0] data;
    
    function void pre_randomize ();
        $display ("This will be called just before randomization");
    endfunction

    function void post_randomize ();
        $display ("This will be called just after randomization");
    endfunction

    function c4_index_fixed_array2_t location_1Dto2D (input int index_a,Length_total);
        automatic int lenght_a = (index_a) % Length_total;
        automatic int width_a = (index_a+1) / Length_total;
        location_a[0] = lenght_a;
        location_a[1] = width_a;
    endfunction
    c4_index_fixed_array2_t location1;
    initial begin
    location1 = location_a(1200,260);
    foreach (location1[i])
            $display("location1[%0d] = %0d", i, location1[i]);
    end

endclass