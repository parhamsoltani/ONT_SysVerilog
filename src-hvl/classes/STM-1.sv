import param_pkg::*;
import class_pkg::*;

class STM_1;
    AU4 au4;
    bit [STM1_Lenght*STM1_Width*Byte_Num-1:0] frame;
    bit [7:0] A1, A2, C1, J0, B1, E1, F1, D1, D2, D3;
    bit [7:0] B2, K1, K2, D4, D5, D6, D7, D8, D9, D10, D11, D12, S1, Z1, Z2, M1, E2;

    function new();
        au4 = new();
    endfunction

    function void pre_randomize();
        if (!au4.randomize()) begin
            $display("STM-1: AU4 randomization failed");
        end else begin
            $display("STM-1: This will be called just before randomization");
        end
    endfunction

    function void post_randomize();
        $display("STM-1: This will be called just after randomization");
        calculate_aup();
    endfunction

    function void calculate_soh();

    endfunction
    
    function bit [STM1_Lenght*STM1_Width*Byte_Num-1:0] get_stm_frame();
        bit [STM1_Lenght*STM1_Width*Byte_Num-1:0] frame;
        for (int i = 0; i < STM1_Lenght*STM1_Width*Byte_Num ; i++) begin
            int row = i / STM1_Lenght;
            int col = i % STM1_Lenght;

            if(col < 9) begin
                case (col)
                    0 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    1 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    2 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    3 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    4 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    5 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    6 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    7 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    8 : case (row)
                        0 : frame[i] = 0;
                        1 : frame[i] = 0;
                        2 : frame[i] = 0;
                        3 : frame[i] = 0;
                        4 : frame[i] = 0;
                        5 : frame[i] = 0;
                        6 : frame[i] = 0;
                        7 : frame[i] = 0;
                        8 : frame[i] = 0;
                        default: frame[i] = 0;
                    endcase
                    default: default: frame[i] = 0;
                endcase
            end else begin
                frame[i] = au4.vc4.c4.data[(row*c4_Lenght)+(col-9)];
            end
            frame = this.frame;
            return frame;
        end
    endfunction


    function bit [7:0] calculate_A1();
        return 8'hF6;
    endfunction

    function bit [7:0] calculate_A2();
        return 8'h28;
    endfunction

    function bit [7:0] calculate_C1();
        ...
    endfunction
    
    function bit [7:0] calculate_J0();
        ...
    endfunction

    function bit [7:0] calculate_B1();
        ...
    endfunction

    function bit [7:0] calculate_E1();
        // null 0 
    endfunction

    function bit [7:0] calculate_F1();
        // null
    endfunction

    function bit [7:0] calculate_D1();
        // writable
    endfunction

    function bit [7:0] calculate_D2();
        // writable
    endfunction

    function bit [7:0] calculate_D3();
        // writable
    endfunction

    function bit [7:0] calculate_B2();
        ...
    endfunction

    function bit [7:0] calculate_K1();
        // null
    endfunction

    function bit [7:0] calculate_K2();
        // null
    endfunction

    function bit [7:0] calculate_D4();
        // writable
    endfunction

    function bit [7:0] calculate_D5();
        // writable
    endfunction

    function bit [7:0] calculate_D6();
        // writable
    endfunction

    function bit [7:0] calculate_D7();
        // writable
    endfunction
    
    function bit [7:0] calculate_D8();
        // writable
    endfunction
    
    function bit [7:0] calculate_D9();
        // writable
    endfunction

    function bit [7:0] calculate_D10();
        // writable
    endfunction

    function bit [7:0] calculate_D11();
        // writable
    endfunction

    function bit [7:0] calculate_D12();
        // writable
    endfunction

    function bit [7:0] calculate_S1();
        // null
    endfunction

    function bit [7:0] calculate_Z1();
        // null
    endfunction

    function bit [7:0] calculate_Z2();
        // null
    endfunction

    function bit [7:0] calculate_M1();
        // null
    endfunction

    function bit [7:0] calculate_E2();
        // null
    endfunction


endclass
