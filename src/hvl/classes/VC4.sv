import param_pkg::*;
import class_pkg::*;

class VC4;
    C4 c4;
    rand bit [0:C4_WIDTH-1][BYTE_NUM-1:0] poh; // Path Overhead
    bit [0:VC4_WIDTH-1][0:VC4_LENGTH-1][BYTE_NUM-1:0] data;
    bit [7:0] J1; 
    bit [7:0] B3;
    static bit [7:0] C2;
    static bit [7:0] G1;
    static bit [7:0] F2;
    static bit [7:0] H4;
    static bit [7:0] F3;
    static bit [7:0] K3;
    static bit [7:0] N1;

    // J1 trace variables
    localparam int J1_FRAME_LENGTH = 16;
    static string J1_TRACE_MESSAGE = "PARMAN";
    static bit[0:J1_FRAME_LENGTH-1][7:0] j1_frame;
    static bit[3:0] j1_frame_counter = 0;

    // B3 and C2 related variables
    bit[7:0] vc4_xor;
    

    /*
    typedef enum bit [7:0] {
        UNEQUIPPED           = 8'h00,
        EQUIPPED_NON_SPECIFIC = 8'h01,
        TUG_STRUCTURE        = 8'h02,
        LOCKED_TU            = 8'h03,
        ASYNC_34_368_OR_44_736 = 8'h04,
        ASYNC_139_264        = 8'h12,
        ATM_MAPPING          = 8'h13,
        MAN_DQDB_MAPPING     = 8'h14,
        FDDI_MAPPING         = 8'h15
    } c2_state_e;
    */


    function new(bit[7:0] vc4_xor = 0);
        c4 = new();
        init_j1_frame();
        B3 = vc4_xor;
    endfunction


    function void pre_randomize();
        // $display("VC4: This will be called just before randomization");
        if(c4.randomize()) begin
        end
        else begin
            $display("C4 randomization failed!");
        end
    endfunction

    function void post_randomize();
        // $display("VC4: This will be called just after randomization");
        J1 = calculate_J1();
        B3 = calculate_B3();
        C2 = calculate_C2();
        G1 = calculate_G1();
        F2 = calculate_F2();
        H4 = calculate_H4();
        F3 = calculate_F3();
        K3 = calculate_K3();
        N1 = calculate_N1();
        insert_data();
        insert_poh();
    endfunction

    function void  update_vc4_data();
        for (int i = 0; i < VC4_WIDTH ; i++) begin
            for (int j = 0; j < VC4_LENGTH ; j++) begin
                if(j == 0) begin
                    case (i)
                        0 : data[i][j] = J1;
                        1 : data[i][j] = B3;
                        2 : data[i][j] = C2;
                        3 : data[i][j] = G1;
                        4 : data[i][j] = F2;
                        5 : data[i][j] = H4;
                        6 : data[i][j] = F3;
                        7 : data[i][j] = K3;
                        8 : data[i][j] = N1;
                        default: data[i][j] = 8'b0;
                    endcase
                end else begin
                    data[i][j] = c4.data[i][j-1];
                end
            end
            calculate_vc4_xor();
        end
    endfunction

    function void update_poh_value(int i, bit [7:0] overheads_value);
        case (i)
            1 : begin C2 = overheads_value; data[2][0] = C2; poh[2] = C2; display_c2_state(C2); end
            2 : begin G1 = overheads_value; data[3][0] = G1; poh[3] = G1; end
            3 : begin F2 = overheads_value; data[4][0] = F2; poh[4] = F2; end
            4 : begin H4 = overheads_value; data[5][0] = H4; poh[5] = H4; end
            5 : begin F3 = overheads_value; data[6][0] = F3; poh[6] = F3; end
            6 : begin K3 = overheads_value; data[7][0] = K3; poh[7] = K3; end
            7 : begin N1 = overheads_value; data[8][0] = N1; poh[8] = N1; end 
            default : $display("VC4: Error! No such a poh!");  
        endcase
        calculate_vc4_xor();
    endfunction
    
    function bit [7:0] calculate_J1();
        return j1_frame[j1_frame_counter++];
    endfunction

    function bit [7:0] calculate_B3();
        return B3;
    endfunction

    function bit [7:0] calculate_C2();
        return C2;
    endfunction

    function bit [7:0] calculate_G1();
        // G1: Path Status
        // Bits 1-4: REI (Remote Error Indication)
        // Bits 5-7: Path Status
        // Bit 8: Reserved
        bit[3:0] rei = 4'h0; // Assuming no errors
        bit[3:0] path_status = 3'b000; // Assuming normal operation
        return {1'b0, path_status, rei};
    endfunction

    function bit [7:0] calculate_F2();
        // F2: Path User Channel
        // This is typically used for communication between path terminating equipment
        // For this application, we'll just return a fixed value
        return 8'hAA;
    endfunction

    function bit [7:0] calculate_H4();
        // H4: Multiframe Indicator
        // Used for payloads requiring multiframe alignment
        // For this application, we'll use a simple counter
        static bit[3:0] h4_counter = 0;    // 4-bit counter
        h4_counter = (h4_counter + 1);   
        return h4_counter;
    endfunction

    function bit [7:0] calculate_F3();
        // F3: Path User Channel
        // Similar to F2, but for a different user
        // For this application, we'll just return a fixed value
        return 8'h55;
    endfunction

    function bit [7:0] calculate_K3();
        // K3: APS (Automatic Protection Switching) Channel
        // Bits 1-4: Switching request type
        // Bits 5-8: Channel number
        // For this application, we'll assume no switching request
        return 8'h00;
    endfunction

    function bit [7:0] calculate_N1();
        // N1: Network Operator Byte
        // This byte is reserved for network operator use
        // For this application, we'll just return a fixed value
        return 8'hFF;
    endfunction


    function void init_j1_frame();
        for (int i = 1; i < J1_FRAME_LENGTH; i++) begin
            if (i - 1 < J1_TRACE_MESSAGE.len()) begin
                j1_frame[i][7] = 1'b0;
                j1_frame[i][6:0] = int'(J1_TRACE_MESSAGE[i - 1]);
            end else begin
                j1_frame[i][7] = 1'b0;
                j1_frame[i][6:0] = int'(" "); // Space character
            end
        end
        j1_frame[0][7] = 1'b1;
        j1_frame[0][6:0] = crc7_calculate(j1_frame[1:J1_FRAME_LENGTH-1]);
    endfunction

    // New function to update J1 trace message
    // Usage:     vc4_instance.update_j1_trace_message("NEW_MESSAGE____");
    function void update_j1_trace_message(string new_message);
        J1_TRACE_MESSAGE = new_message;
        init_j1_frame();
        j1_frame_counter = 0;
        J1 = calculate_J1();
        data[0][0] = J1;
        calculate_vc4_xor();
    endfunction

    function bit [6:0] crc7_calculate (input bit [0:J1_FRAME_LENGTH-2][7:0] data );
        bit [7:0] crc;
        bit [7:0] byte1;
        integer i, j;

        begin
            crc = 8'h00;  // Initialize CRC to 0

            // Iterate over each byte in the input data
            for (i = 0; i < J1_FRAME_LENGTH-1; i++) begin
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

    function void calculate_vc4_xor();
        bit[7:0] current_vc4_xor = 8'h00;
        for (int i = 0; i < VC4_WIDTH ; i++) begin
            for (int j = 0; j < VC4_LENGTH ; j++) begin
                current_vc4_xor ^= data[i][j];
            end
        end
        vc4_xor = current_vc4_xor;
    endfunction

    // Function to get C2 state as a string based on the current c2_value
    function string get_c2_state_string();
        case (C2)
            8'h00: return "Unequipped";
            8'h01: return "Equipped - non specific";
            8'h02: return "TUG structure";
            8'h03: return "Locked TU";
            8'h04: return "Asynchronous mapping of 34,368 kbit/s or 44,736 kbit/s into Container-3";
            8'h12: return "Asynchronous mapping of 139,264 kbit/s into Container-4";
            8'h13: return "ATM mapping";
            8'h14: return "MAN (DQDB) mapping";
            8'h15: return "FDDI mapping";
            default: return "Unknown";
        endcase
    endfunction

    function void display_c2_state(bit [7:0] input_byte);
        $display("C2 Byte: 0x%0h", input_byte);
        $display("C2 State: %s", get_c2_state_string());
    endfunction




    function void insert_poh();
        // Create a new array with increased width
        // Add POH as the last column

        // Update POH array
        poh[0] = J1;
        poh[1] = B3;
        poh[2] = C2;
        poh[3] = G1;
        poh[4] = F2;
        poh[5] = H4;
        poh[6] = F3;
        poh[7] = K3;
        poh[8] = N1;

        for (int i = 0; i < 9; i++) begin
            data[i][0] = poh[i];
        end

        calculate_vc4_xor();
    endfunction

    function void display_poh();
        $display("VC4: Path Overhead");
        for (int i = 0; i < 9; i++) begin
            $display("POH[%0d] = 0x%0h", i, poh[i]);
        end
    endfunction

    function void insert_data();
        // Copy existing data
        for (int i = 0; i < VC4_WIDTH; i++) begin
            for (int j = 1; j < VC4_LENGTH; j++) begin
                data[i][j] = c4.data[i][j-1];
            end
        end
    endfunction

endclass
