import param_pkg::*;
import class_pkg::*;

class STM_1;
    AU4 au4;
    bit [STM1_Lenght*STM1_Width*Byte_Num-1:0] frame;
    bit [7:0] A1, A2, C1, J0, B1, E1, F1, D1, D2, D3;
    bit [7:0] K1, K2, D4, D5, D6, D7, D8, D9, D10, D11, D12, S1, Z1, Z2, M1, E2;
    bit [23:0] B2;
    bit [7:0] previous_B1;
    bit [23:0] previous_B2;
    
    static bit [15:0][7:0] previous_J0_frame;
    static bit first = 1;
    static bit [3:0] counter_for_J0_frame = 0;

    function new();
        au4 = new();

        if(fisrt) begin
            previous_J0_frame[15] = 8'b00000000;
            previous_J0_frame[14] = P_letter;
            previous_J0_frame[13] = A_letter;
            previous_J0_frame[12] = R_letter;
            previous_J0_frame[11] = M_letter;
            previous_J0_frame[10] = A_letter;
            previous_J0_frame[9] = N_letter;
            for (int i = 8 ; i <= 0 ; i--) begin
                previous_J0_frame[i] = SPACE_letter;
            end
            first = 0;
        end else begin
            if(counter_for_J0_frame == 4'b0000) begin
                previous_J0_frame[15] = crc7_sdh_j0(previous_J0_frame)
            end
            counter_for_J0_frame++;
        end
        
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

    // function bit [7:0] calculate_C1();
    //     ...
    // endfunction
    
    function bit [7:0] calculate_J0();
        case (counter_for_J0_frame)
            0 : previous_J0_frame[15];
            1 : previous_J0_frame[14];
            2 : previous_J0_frame[13];
            3 : previous_J0_frame[12];
            4 : previous_J0_frame[11];
            5 : previous_J0_frame[10];
            6 : previous_J0_frame[9];
            7 : previous_J0_frame[8];
            8 : previous_J0_frame[7];
            9 : previous_J0_frame[6];
            10 : previous_J0_frame[5];
            11 : previous_J0_frame[4];
            12 : previous_J0_frame[3];
            13 : previous_J0_frame[2];
            14 : previous_J0_frame[1];
            15 : previous_J0_frame[0];
            default: 8'b00000000;
        endcase
    endfunction

    function bit [7:0] calculate_B1();
        previous_B1 = 8'b00000000;
        for (int i = 0; i < STM1_Lenght*STM1_Width*Byte_Num ; i++) begin
            previous_B1 = previous_B1 ^ frame[i];
        end
        return previous_B1;
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
        previous_B2 = 24'h000000;
        for (int i = 0; i < STM1_Lenght*STM1_Width*Byte_Num ; i+=3 ) begin
            previous_B2 = previous_B2 ^ {frame[i],frame[i+1],frame[i+2]};
        end
        return previous_B2;
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

    function bit [7:0] crc7_sdh_j0 (
        input  bit [127:0] data_in, // 16 bytes (128 bits) input data
        );
        bit [7:0]   crc_out
        bit [7:0]  crc;
        bit [127:0] data;
        integer i, j;

        always_comb begin
            // Initialize the CRC value
            crc = 8'h00;
            data = data_in;

            // CRC calculation loop
            for (i = 0; i < 16; i++) begin
                crc ^= data[127:120];  // XOR the next byte into the CRC
                data = data << 8;      // Shift data left by 1 byte (8 bits)
                
                // Bitwise operations on each byte
                for (j = 0; j < 8; j++) begin
                    if (crc[7] == 1'b1) begin
                        crc = (crc << 1) ^ 8'h89; // Shift left and XOR with polynomial
                    end else begin
                        crc = crc << 1;  // Just shift left
                    end
                end
            end

            // Assign the top 7 bits of the CRC register to the output
            crc_out = {1'b1,crc[7:1]};
        end
    endfunction


endclass
