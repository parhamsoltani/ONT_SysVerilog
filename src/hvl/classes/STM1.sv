import param_pkg::*;
import class_pkg::*;

class STM1;
    AU4 au4;
    // STM-1 full frame
    bit [0:STM1_WIDTH-1][0:STM1_LENGTH-1][BYTE_NUM-1:0] frame;
    // RSOH
    static bit [7:0] A1;
    static bit [7:0] A2;
    static bit [7:0] C1;
    static bit [7:0] J0;
    static bit [7:0] B1;
    static bit [7:0] E1;
    static bit [7:0] F1;
    static bit [7:0] D1;
    static bit [7:0] D2;
    static bit [7:0] D3;
    // MSO = 0H
    static bit [23:0] B2;
    static bit [7:0] K1;
    static bit [7:0] K2;
    static bit [7:0] D4;
    static bit [7:0] D5;
    static bit [7:0] D6;
    static bit [7:0] D7;
    static bit [7:0] D8;
    static bit [7:0] D9;
    static bit [7:0] D10;
    static bit [7:0] D11;
    static bit [7:0] D12;
    static bit [7:0] S1;
    static bit [7:0] Z1;
    static bit [7:0] Z2;
    static bit [7:0] M1;
    static bit [7:0] E2;

    // AUP
    bit [7:0] H1;
    bit [7:0] H2;
    bit [7:0] H3;

    // extra variables for xor calculation for B1 and B2
    bit[7:0] frame_xor;
    bit [23:0] semi_frame_xor;
    
    // J0 parametere
    localparam int J0_FRAME_LENGTH = 16;
    static string J0_TRACE_MESSAGE = "PARMAN";
    static bit [0:J0_FRAME_LENGTH-1][7:0] j0_frame ;
    static bit [3:0] j0_frame_counter = 0;


    function new(bit[7:0] vc4_xor = 0, bit[7:0] frame_xor = 0, bit[23:0] semi_frame_xor = 0);
        au4 = new(vc4_xor); 
        init_j0_frame();
        B1 = frame_xor;
        B2 = semi_frame_xor;
    endfunction

    function void pre_randomize();
        //$display("STM-1: This will be called just before randomization");
        if(au4.randomize()) begin
        end

        else begin
            $display("AU4 randomization failed!");
        end
    endfunction

    function void post_randomize();
        //$display("STM-1: This will be called just after randomization");
        calculate_soh();
    endfunction

    function void calculate_soh();
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

        update_stm_frame();
        calculate_frame_xor();
        calculate_semi_frame_xor();     
    endfunction
    

    function void update_stm_frame();
        H1 = au4.aup[0];
        H2 = au4.aup[1];
        H3 = au4.aup[2];

        frame[0][0:8] = {    A1     ,    A1    ,  A1     ,  A2  ,   A2   ,    A2   ,  J0  ,  8'b0  ,  8'b0 };
        frame[1][0:8] = {    B1     ,   8'b0   ,  8'b0   ,  E1  ,  8'b0  ,   8'b0  ,  F1  ,  8'b0  ,  8'b0 };
        frame[2][0:8] = {    D1     ,   8'b0   ,  8'b0   ,  D2  ,  8'b0  ,   8'b0  ,  D3  ,  8'b0  ,  8'b0 };
        frame[3][0:8] = {    H1     ,   8'b0   ,  8'b0   ,  H2  ,  8'b0  ,   8'b0  ,  H3  ,   H3   ,   H3  };
        frame[4][0:8] = { B2[23:16] , B2[15:8] , B2[7:0] ,  K1  ,  8'b0  ,   8'b0  ,  K2  ,  8'b0  ,  8'b0 };
        frame[5][0:8] = {    D4     ,   8'b0   ,  8'b0   ,  D5  ,  8'b0  ,   8'b0  ,  D6  ,  8'b0  ,  8'b0 };
        frame[6][0:8] = {    D7     ,   8'b0   ,  8'b0   ,  D8  ,  8'b0  ,   8'b0  ,  D9  ,  8'b0  ,  8'b0 };
        frame[7][0:8] = {    D10    ,   8'b0   ,  8'b0   ,  D11 ,  8'b0  ,   8'b0  ,  D12 ,  8'b0  ,  8'b0 };
        frame[8][0:8] = {    S1     ,    Z1    ,  Z1     ,  Z2  ,   Z2   ,    M1   ,  E2  ,  8'b0  ,  8'b0 };


        for (int i = 0; i < STM1_WIDTH ; i++) begin
            for (int j = 9; j < STM1_LENGTH ; j++) begin
                frame[i][j] = au4.vc4.data[i][j-9];
            end
        end
        calculate_frame_xor();
        calculate_semi_frame_xor();
    endfunction


    function void update_overheads_value(bit [5:0] overheads_name[$], bit [7:0] overheads_value[$]); 
        if( overheads_name.size() == overheads_value.size()) begin
            for (int i = 0; i < overheads_name.size() ; i++ ) begin
                if(overheads_name[i] < 8) begin
                        au4.vc4.update_poh_value(overheads_name[i],overheads_value[i]);
                        frame[overheads_name[i]+1][9] = overheads_value[i]; 
                end
                else begin
                    case (overheads_name[i])
                        8 : begin A1 = overheads_value[i]; frame[0][0:2] = {A1,A1,A1}; end
                        9 : begin A2 = overheads_value[i]; frame[0][3:5] = {A2,A2,A2}; end
                        10 : begin E1 = overheads_value[i]; frame[1][3] = E1; end
                        11 : begin F1 = overheads_value[i]; frame[1][6] = F1; end
                        12 : begin D1 = overheads_value[i]; frame[2][0] = D1; end
                        13 : begin D2 = overheads_value[i]; frame[2][3] = D2; end
                        14 : begin D3 = overheads_value[i]; frame[2][6] = D3; end
                        15 : begin K1 = overheads_value[i]; frame[4][3] = K1; end
                        16 : begin K2 = overheads_value[i]; frame[4][6] = K2; end
                        17 : begin D4 = overheads_value[i]; frame[5][0] = D4; end
                        18 : begin D5 = overheads_value[i]; frame[5][3] = D5; end
                        19 : begin D6 = overheads_value[i]; frame[5][6] = D6; end
                        20 : begin D7 = overheads_value[i]; frame[6][0] = D7; end
                        21 : begin D8 = overheads_value[i]; frame[6][3] = D8; end
                        22 : begin D9 = overheads_value[i]; frame[6][6] = D9; end
                        23 : begin D10 = overheads_value[i]; frame[7][0] = D10; end
                        24 : begin D11 = overheads_value[i]; frame[7][3] = D11; end
                        25 : begin D12 = overheads_value[i]; frame[7][6] = D12; end
                        26 : begin S1 = overheads_value[i]; frame[8][0] = S1; end
                        27 : begin Z1 = overheads_value[i]; frame[8][1:2] = {Z1,Z1}; end
                        28 : begin Z2 = overheads_value[i]; frame[8][3:4] = {Z2,Z2}; end
                        29 : begin M1 = overheads_value[i]; frame[8][5] = M1; end
                        30 : begin E2 = overheads_value[i]; frame[8][6] = E2; end
                        31 : begin H1 = overheads_value[i]; frame[3][0] = H1; end
                        32 : begin H2 = overheads_value[i]; frame[3][3] = H2; end
                        33 : begin H3 = overheads_value[i]; frame[3][6:8] = {H3,H3,H3}; end
                        default : $display("STM1: Error! No such an overhead exist!");
                    endcase
                end
                calculate_frame_xor();
                calculate_semi_frame_xor();
            end    
        end
        else begin
            $display("STM1 :Error! size of overheads_name and overheads_value doesn't mached!");
        end
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
        return j0_frame[j0_frame_counter++];
    endfunction

    function bit [7:0] calculate_B1();
        return B1;
    endfunction

    function bit [7:0] calculate_E1();
        // null 0 
        return E1;
    endfunction

    function bit [7:0] calculate_F1();
        // null
        return F1;
    endfunction

    function bit [7:0] calculate_D1();
        // writable
        return D1;
    endfunction

    function bit [7:0] calculate_D2();
        // writable
        return D2;
    endfunction

    function bit [7:0] calculate_D3();
        // writable
        return D3;
    endfunction

    function bit [23:0] calculate_B2();
        return B2;
    endfunction

    function bit [7:0] calculate_K1();
        // null
        return K1;
    endfunction

    function bit [7:0] calculate_K2();
        // null
        return K2;
    endfunction

    function bit [7:0] calculate_D4();
        // writable
        return D4;
    endfunction

    function bit [7:0] calculate_D5();
        // writable
        return D5;
    endfunction

    function bit [7:0] calculate_D6();
        // writable
        return D6;
    endfunction

    function bit [7:0] calculate_D7();
        // writable
        return D7;
    endfunction
    
    function bit [7:0] calculate_D8();
        // writable
        return D8;
    endfunction
    
    function bit [7:0] calculate_D9();
        // writable
        return D9;
    endfunction

    function bit [7:0] calculate_D10();
        // writable
        return D10;
    endfunction

    function bit [7:0] calculate_D11();
        // writable
        return D11;
    endfunction

    function bit [7:0] calculate_D12();
        // writable
        return D12;
    endfunction

    function bit [7:0] calculate_S1();
        // null
        return S1;
    endfunction

    function bit [7:0] calculate_Z1();
        // null
        return Z1;
    endfunction

    function bit [7:0] calculate_Z2();
        // null
        return Z2;
    endfunction

    function bit [7:0] calculate_M1();
        // null
        return M1;
    endfunction

    function bit [7:0] calculate_E2();
        // null
        return E2;
    endfunction

    function bit [6:0] crc7_calculate (input bit [0:J0_FRAME_LENGTH-2][7:0] data);
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

            return crc[7:1];  // Return the top 7 bits as CRC-7
            
        end
    endfunction


    function void init_j0_frame();
        for (int i = 1; i < J0_FRAME_LENGTH; i++) begin
            if (i - 1 < J0_TRACE_MESSAGE.len()) begin
                j0_frame[i][7] = 1'b0;
                j0_frame[i][6:0] = int'(J0_TRACE_MESSAGE[i - 1]);
            end else begin
                j0_frame[i][7] = 1'b0;
                j0_frame[i][6:0] = int'(" "); // Space character
            end
        end
        j0_frame[0][7] = 1'b1;
        j0_frame[0][6:0] = crc7_calculate(j0_frame[1:J0_FRAME_LENGTH-1]);
        
    endfunction

    function void update_J0_trace_message(string new_message);
        J0_TRACE_MESSAGE = new_message;
        init_j0_frame();
        j0_frame_counter = 0;
        J0 = calculate_J0();
        frame[0][6] = J0;
        calculate_frame_xor();
        calculate_semi_frame_xor();
    endfunction

    function void update_J1_trace_message(string new_message);
        au4.vc4.J1_TRACE_MESSAGE = new_message;
        au4.vc4.init_j1_frame();
        au4.vc4.j1_frame_counter = 0;
        au4.vc4.J1 = au4.vc4.calculate_J1();
        au4.vc4.data[0][0] = au4.vc4.J1;
        frame[0][9] = au4.vc4.J1;
        au4.vc4.calculate_vc4_xor();
        calculate_frame_xor();
        calculate_semi_frame_xor();
    endfunction

    function void calculate_frame_xor();
        bit[7:0] current_frame_xor = 8'h00;
        for (int i = 0; i < STM1_WIDTH ; i++) begin
            for (int j = 0; j < STM1_LENGTH ; j++) begin
                current_frame_xor ^= frame[i][j];
            end
        end
        frame_xor = current_frame_xor;
        // $display(frame_xor);
    endfunction

    function void calculate_semi_frame_xor();
        bit[23:0] current_semi_frame_xor = 24'h0;
        for (int i = 0; i < STM1_WIDTH ; i++) begin
            for (int j = 0; j < STM1_LENGTH ; j+=3) begin
                current_semi_frame_xor ^= {frame[i][j],frame[i][j+1],frame[i][j+2]};
            end
        end
        semi_frame_xor = current_semi_frame_xor;
        // $display(semi_frame_xor);
    endfunction

endclass
