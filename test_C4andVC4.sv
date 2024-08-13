parameter Lenght = 260, Width = 9, Byte_Num = 8 ;
typedef int fixed_array2_t[2];

class C4;
    rand bit [Lenght*Width-1:0][Byte_Num-1:0] data;
    
    function void pre_randomize ();
        $display ("This will be called just before randomization");
    endfunction

    function void post_randomize ();
        $display ("This will be called just after randomization");
    endfunction

    function fixed_array2_t location_1Dto2D (input int index_a,Length_total);
        automatic int lenght_a = (index_a) % Length_total;
        automatic int width_a = (index_a+1) / Length_total;
        location_a[0] = lenght_a;
        location_a[1] = width_a;
    endfunction
    fixed_array2_t lacation1;
    initial begin
    lacation1 = location_a(1200,260);
    foreach (lacation1[i])
            $display("lacation1[%0d] = %0d", i, lacation1[i]);
    end

endclass

class VC4;
    C4 c4;
    byte J1, B3, C2, G1, F2, H4, F3, K3, N1;
    function new();
        c4 = new ();
    endfunction 

    function void pre_randomize ();
        $display ("This will be called just before randomization");
        c4.randomize ()
    endfunction

    function void post_randomize ();
        $display ("This will be called just after randomization");

    endfunction

    function byte calculate_J1(C4 c4,);
        ;
        
    endfunction

    function byte calculate_B3;
        ;
        
    endfunction

    function byte calculate_C2;
        ;
        
    endfunction

    function byte calculate_G1;
        ;
        
    endfunction

    function byte calculate_F2;
        ;
        
    endfunction

    function byte calculate_H4;
        ;
        
    endfunction

    function byte calculate_F3;
        ;
        
    endfunction

    function byte calculate_K3;
        ;
        
    endfunction

    function byte calculate_N1;
        ;
        
    endfunction
endclass 

module tb2;
    C4 c4_1;
    initial begin
        c4_1 = new ();
        foreach (c4_1.data[i])
            $display("data[%0d] = %8b", i, c4_1.data[i]);
        
        if (c4_1.randomize ())
        $display ("Randomization successful !");
        foreach (c4_1.data[i])
            $display("data[%0d] = %8b", i, c4_1.data[i]);

    end
endmodule



module tb2;
    typedef int fixed_array2_t[2];
    function fixed_array2_t location_a (input int index_a,Length_total);
        automatic int lenght_a = index_a % Length_total;
        automatic int width_a = index_a / Length_total;
        location_a[0] = lenght_a;
        location_a[1] = width_a;
    endfunction
    fixed_array2_t lacation1;
    initial begin
    lacation1 = location_a(1200,260);
    foreach (lacation1[i])
            $display("lacation1[%0d] = %0d", i, lacation1[i]);
    end
endmodule