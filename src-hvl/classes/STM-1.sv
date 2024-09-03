import param_pkg::*;
import class_pkg::*;

class STM1;
    rand AU4 au4;
    // STM-1 full frame
    bit [STM1_Width-1:0][STM1_Length-1:0][Byte_Num-1:0] frame;
    // RSOH
    bit [7:0] A1;
    bit [7:0] A2;
    bit [7:0] C1;
    bit [7:0] J0;
    bit [7:0] B1;
    bit [7:0] E1;
    bit [7:0] F1;
    bit [7:0] D1;
    bit [7:0] D2;
    bit [7:0] D3;
    // MSOH
    bit [23:0] B2;
    bit [7:0] K1;
    bit [7:0] K2;
    bit [7:0] D4;
    bit [7:0] D5;
    bit [7:0] D6;
    bit [7:0] D7;
    bit [7:0] D8;
    bit [7:0] D9;
    bit [7:0] D10;
    bit [7:0] D11;
    bit [7:0] D12;
    bit [7:0] S1;
    bit [7:0] Z1;
    bit [7:0] Z2;
    bit [7:0] M1;
    bit [7:0] E2;

    // extra variables for xor calculation for B1 and B2
    bit[7:0] frame_xor;
    bit [23:0] semi_frame_xor;
    
    // J0 parametere
    localparam int J0_FRAME_LENGTH = 16;
    string J0_TRACE_MESSAGE = "PARMAN";
    static byte  j0_frame [0:J0_FRAME_LENGTH-1];
    static bit [3:0] j0_frame_counter = 0;

    rand bit [8:0][269:0][7:0] f;

    function new(bit[7:0] frame_xor = 0,bit [23:0] semi_frame_xor = 0);
        au4 = new(); 
        j0_frame_counter = 0;
        init_j0_frame();
        B1 = frame_xor;
        B2 = semi_frame_xor;
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
            j0_frame_counter++;
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

            frame = get_stm_frame();
            calculate_frame_xor();
            calculate_semi_frame_xor();     
        end
    endfunction

    function void post_randomize();
        $display("STM-1: This will be called just after randomization");
        
    endfunction

    function void calculate_soh();

    endfunction
    
    function bit [STM1_Width-1:0][STM1_Length-1:0][Byte_Num-1:0]  get_stm_frame();
        for (int i = 0; i < STM1_Width ; i++) begin
            for (int j = 0; j < STM1_Length ; j++) begin
                if(j < 9) begin
                case (i)
                    0 : case (j)
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
                    1 : case (j)
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
                    2 : case (j)
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
                    3 : case (j)
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
                    4 : case (j)
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
                    5 : case (j)
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
                    6 : case (j)
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
                    7 : case (j)
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
                    8 : case (j)
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
                // $display("data[%d][%d] = %d",i,j,frame[i][j]);
            end else begin
                frame[i][j] = au4.vc4.data[i][j-9];
                // $display("data[%d][%d] = %d",i,j,frame[i][j]);
            end
            
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
        case (j0_frame_counter)
            0 : return j0_frame[0];
            1 : return j0_frame[1];
            2 : return j0_frame[2];
            3 : return j0_frame[3];
            4 : return j0_frame[4];
            5 : return j0_frame[5];
            6 : return j0_frame[6];
            7 : return j0_frame[7];
            8 : return j0_frame[8];
            9 : return j0_frame[9];
            10 : return j0_frame[10];
            11 : return j0_frame[11];
            12 : return j0_frame[12];
            13 : return j0_frame[13];
            14 : return j0_frame[14];
            15 : return j0_frame[15];
            default: return 8'b0;
        endcase
    endfunction

    function bit [7:0] calculate_B1();
        return B1;
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
        return B2;
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

    function bit [6:0] crc7_calculate (
        input byte data [0:J0_FRAME_LENGTH-2]  // 15-byte array input
    );
        bit [7:0] crc;
        bit [7:0] byte1;
        integer i, j;

        begin
            crc = 8'h00;  // Initialize CRC to 0

            // Iterate over each byte in the input data
            for (i = 0; i < J0_FRAME_LENGTH-1; i++) begin
                byte1 = data[i];
                crc ^= byte1;  // XOR byte into the CRC

                // Process each bit in the byte
                for (j = 0; j < 8; j++) begin
                    if (crc[7] == 1'b1) begin
                        crc = (crc << 1) ^ 8'h89;  // Shift left and XOR with polynomial
                    end else begin
                        crc = crc << 1;  // Just shift left
                    end
                end
            end

            crc7_calculate = crc[7:1];  // Return the top 7 bits as CRC-7
        end
    endfunction


    function void init_j0_frame();
        for (int i = 1; i < J0_FRAME_LENGTH; i++) begin
            if (i - 1 < J0_TRACE_MESSAGE.len()) begin
                j0_frame[i][7] = 1'b0;
                j0_frame[i][6:0] = byte'(J0_TRACE_MESSAGE[i - 1]);
            end else begin
                j0_frame[i][7] = 1'b0;
                j0_frame[i][6:0] = byte'(" "); // Space character
            end
        end
        j0_frame[0][7] = 1'b1;
        j0_frame[0][6:0] = crc7_calculate(j0_frame[1:J0_FRAME_LENGTH-1]);
    endfunction

    function void update_J0_trace_message(string new_message);
        J0_TRACE_MESSAGE = new_message;
        init_j0_frame();
    endfunction

    function void calculate_frame_xor();
        bit[7:0] current_frame_xor = 8'h00;
        for (int i = 0; i < STM1_Width ; i++) begin
            for (int j = 0; j < STM1_Length ; j++) begin
                current_frame_xor ^= frame[i][j];
            end
        end
        frame_xor = current_frame_xor;
        // $display(frame_xor);
    endfunction

    function void calculate_semi_frame_xor();
        bit[7:0] current_semi_frame_xor = 8'h00;
        for (int i = 3; i < STM1_Width ; i++) begin
            for (int j = 0; j < STM1_Length ; j++) begin
                current_semi_frame_xor ^= frame[i][j];
            end
        end
        semi_frame_xor = current_semi_frame_xor;
        // $display(semi_frame_xor);
    endfunction

endclass
