import param_pkg::*;
import class_pkg::*;

class STM1;
    AU4 au4;
    bit [STM1_Width-1:0][STM1_Length-1:0][Byte_Num-1:0] frame;
    bit [7:0] A1, A2, C1, J0, B1, E1, F1, D1, D2, D3;
    bit [7:0] K1, K2, D4, D5, D6, D7, D8, D9, D10, D11, D12, S1, Z1, Z2, M1, E2;
    bit [23:0] B2;
    bit [7:0] previous_B1;
    bit [23:0] previous_B2;


    static bit [15:0][7:0] previous_J0_frame;
    static logic first = 1;
    static bit [3:0] counter_for_J0_frame = 0;

    localparam int J0_FRAME_LENGTH = 16;
    string J0_TRACE_MESSAGE = "PARMAN          ";

    function new();
        au4 = new(); 
        if(this.fisrt) begin
            previous_J0_frame[15] = 8'b00000000;
            for (int i = J0_FRAME_LENGTH-2; i >= 0 ; i--) begin
                previous_J0_frame[i] = byte'(J0_TRACE_MESSAGE[i+1]);
            end
            this.first = 0;
        end 
        
        else begin
            if(counter_for_J0_frame == 4'b0000) begin
                previous_J0_frame[15] = crc7_sdh_j0(previous_J0_frame);
            end
            counter_for_J0_frame++;
        end 
    endfunction

    function void pre_randomize();
        if (!au4.randomize()) begin
            $display("STM-1: AU4 randomization failed");
        end else begin
            $display("STM-1: This will be called just before randomization");

            A1 = calculate_A1();
            A2 = calculate_A2();
            C1 = calculate_C1();
            J0 = calculate_J0();
            B1 = calculate_B1();
            E1 = calculate_E1();
            F1 = calculate_F1();
            D1 = calculate_D1();
            D2 = calculate_D2();
            D3 = calculate_D3();

            K1 = calculate_K1();
            K2 = calculate_K2();
            D4 = calculate_D4();
            D5 = calculate_D5();
            D6 = calculate_D6();
            D7 = calculate_D7();
            D8 = calculate_D8();
            D9 = calculate_D9();
            D10 = calculate_D10();
            D11 = calculate_D11();
            D12 = calculate_D12();
            S1 = calculate_S1();
            Z1 = calculate_Z1();
            Z2 = calculate_Z2();
            M1 = calculate_M1();
            E2 = calculate_E2();      
        end
    endfunction

    function void post_randomize();
        $display("STM-1: This will be called just after randomization");
    endfunction

    function void calculate_soh();

    endfunction
    
    function bit [STM1_Width-1:0][STM1_Length-1:0][Byte_Num-1:0]  get_stm_frame();
        bit [STM1_Width-1:0][STM1_Length-1:0][Byte_Num-1:0]  frame;
        for (int i = 0; i < STM1_Width ; i++) begin
            for (int j = 0; j < STM1_Length ; j++) begin
                if(j < 9) begin
                case (j)
                    0 : case (i)
                        0 : frame[i][j] = A1;
                        1 : frame[i][j] = A1;
                        2 : frame[i][j] = A1;
                        3 : frame[i][j] = A2;
                        4 : frame[i][j] = A2;
                        5 : frame[i][j] = A2;
                        6 : frame[i][j] = J0;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase
                    1 : case (i)
                        0 : frame[i][j] = B1;
                        1 : frame[i][j] = 8'b0;
                        2 : frame[i][j] = 8'b0;
                        3 : frame[i][j] = E1;
                        4 : frame[i][j] = 8'b0;
                        5 : frame[i][j] = 8'b0;
                        6 : frame[i][j] = F1;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase
                    2 : case (i)
                        0 : frame[i][j] = D1;
                        1 : frame[i][j] = 8'b0;
                        2 : frame[i][j] = 8'b0;
                        3 : frame[i][j] = D2;
                        4 : frame[i][j] = 8'b0;
                        5 : frame[i][j] = 8'b0;
                        6 : frame[i][j] = D3;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase
                    3 : case (i)
                        0 : frame[i][j] = au4.aup[0];
                        1 : frame[i][j] = 8'b0;
                        2 : frame[i][j] = 8'b0;
                        3 : frame[i][j] = au4.aup[1];
                        4 : frame[i][j] = 8'b0;
                        5 : frame[i][j] = 8'b0;
                        6 : frame[i][j] = au4.aup[2];
                        7 : frame[i][j] = au4.aup[2];
                        8 : frame[i][j] = au4.aup[2];
                        default: frame[i][j] = 8'b0;
                    endcase
                    4 : case (i)
                        0 : frame[i][j] = B2;
                        1 : frame[i][j] = B2;
                        2 : frame[i][j] = B2;
                        3 : frame[i][j] = K1;
                        4 : frame[i][j] = 8'b0;
                        5 : frame[i][j] = 8'b0;
                        6 : frame[i][j] = K2;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase
                    5 : case (i)
                        0 : frame[i][j] = D4;
                        1 : frame[i][j] = 8'b0;
                        2 : frame[i][j] = 8'b0;
                        3 : frame[i][j] = D5;
                        4 : frame[i][j] = 8'b0;
                        5 : frame[i][j] = 8'b0;
                        6 : frame[i][j] = D6;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase
                    6 : case (i)
                        0 : frame[i][j] = D7;
                        1 : frame[i][j] = 8'b0;
                        2 : frame[i][j] = 8'b0;
                        3 : frame[i][j] = D8;
                        4 : frame[i][j] = 8'b0;
                        5 : frame[i][j] = 8'b0;
                        6 : frame[i][j] = D9;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase
                    7 : case (i)
                        0 : frame[i][j] = D10;
                        1 : frame[i][j] = 8'b0;
                        2 : frame[i][j] = 8'b0;
                        3 : frame[i][j] = D11;
                        4 : frame[i][j] = 8'b0;
                        5 : frame[i][j] = 8'b0;
                        6 : frame[i][j] = D12;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase
                    8 : case (i)
                        0 : frame[i][j] = S1;
                        1 : frame[i][j] = Z1;
                        2 : frame[i][j] = Z1;
                        3 : frame[i][j] = Z2;
                        4 : frame[i][j] = Z2;
                        5 : frame[i][j] = M1;
                        6 : frame[i][j] = E2;
                        7 : frame[i][j] = 8'b0;
                        8 : frame[i][j] = 8'b0;
                        default: frame[i][j] = 8'b0;
                    endcase 
                    default: frame[i][j] = 8'b0;
                endcase
            end else begin
                frame[i][j] = au4.vc4.data[(i*vc4_Length)+(j-9)];
            end
            frame = this.frame;
            
            end
        end
        return frame;
    endfunction


    function bit [7:0] calculate_A1();
        return 8'hF6;
    endfunction

    function bit [7:0] calculate_A2();
        return 8'h28;
    endfunction

    function bit [7:0] calculate_C1();
        return 0;
    endfunction
    
    function bit [7:0] calculate_J0();
        bit [7:0] calculated_J0;
        case (counter_for_J0_frame)
            0 : calculated_J0 = previous_J0_frame[15];
            1 : calculated_J0 = previous_J0_frame[14];
            2 : calculated_J0 = previous_J0_frame[13];
            3 : calculated_J0 = previous_J0_frame[12];
            4 : calculated_J0 = previous_J0_frame[11];
            5 : calculated_J0 = previous_J0_frame[10];
            6 : calculated_J0 = previous_J0_frame[9];
            7 : calculated_J0 = previous_J0_frame[8];
            8 : calculated_J0 = previous_J0_frame[7];
            9 : calculated_J0 = previous_J0_frame[6];
            10 : calculated_J0 = previous_J0_frame[5];
            11 : calculated_J0 = previous_J0_frame[4];
            12 : calculated_J0 = previous_J0_frame[3];
            13 : calculated_J0 = previous_J0_frame[2];
            14 : calculated_J0 = previous_J0_frame[1];
            15 : calculated_J0 = previous_J0_frame[0];
            default: calculated_J0 = 8'b0;
        endcase
    endfunction

    function bit [7:0] calculate_B1();
        previous_B1 = 8'b0;
        for (int i = 0; i < STM1_Length*STM1_Width; i++) begin
            previous_B1 = previous_B1 ^ frame[i];
        end
        return previous_B1;
    endfunction

    function bit [7:0] calculate_E1();
        // null 0 
        return 8'b0;
    endfunction

    function bit [7:0] calculate_F1();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D1();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D2();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D3();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_B2();
        previous_B2 = 24'h0;
        for (int i = 0; i < STM1_Length*STM1_Width ; i+=3 ) begin
            previous_B2 = previous_B2 ^ {frame[i],frame[i+1],frame[i+2]};
        end
        return previous_B2;
    endfunction

    function bit [7:0] calculate_K1();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] calculate_K2();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D4();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D5();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D6();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D7();
        // writable
        return 8'b0;
    endfunction
    
    function bit [7:0] calculate_D8();
        // writable
        return 8'b0;
    endfunction
    
    function bit [7:0] calculate_D9();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D10();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D11();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_D12();
        // writable
        return 8'b0;
    endfunction

    function bit [7:0] calculate_S1();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] calculate_Z1();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] calculate_Z2();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] calculate_M1();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] calculate_E2();
        // null
        return 8'b0;
    endfunction

    function bit [7:0] crc7_sdh_j0 (bit [127:0] data_in); // 16 bytes (128 bits) input data
         
        
        bit [7:0]   crc_out;
        bit [7:0]  crc;
        bit [127:0] data;
        integer i, j;

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
        return crc_out;
    endfunction


endclass
