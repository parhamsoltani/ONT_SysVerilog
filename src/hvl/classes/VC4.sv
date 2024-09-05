import param_pkg::*;
import class_pkg::*;

class VC4;
    C4 c4;
    rand bit [Byte_Num-1:0] poh[c4_Width]; // Path Overhead
    bit [vc4_Width-1:0][vc4_Length-1:0][Byte_Num-1:0] data;
    bit[7:0] J1, B3, C2, G1, F2, H4, F3, K3, N1;

    // J1 trace variables
    localparam int J1_FRAME_LENGTH = 16;
    string J1_TRACE_MESSAGE = "PARMAN";
    static byte j1_frame[0:J1_FRAME_LENGTH-1];
    static int j1_frame_counter = 0;

    // B3 and C2 related variables
    bit[7:0] vc4_xor;
    bit[7:0] c2_value;
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



    function new(bit[7:0] vc4_xor = 0);
        c4 = new();
        init_j1_frame();
        B3 = vc4_xor;
    endfunction


    function void pre_randomize();
        if (!c4.randomize()) begin
            $display("VC4: C4 randomization failed");
        end else begin
            $display("VC4: This will be called just before randomization");
            // Initialize Path Overhead according to ITU-T G.707
            J1 = calculate_J1();
            B3 = calculate_B3();
            C2 = calculate_C2();
            G1 = calculate_G1();
            F2 = calculate_F2();
            H4 = calculate_H4();
            F3 = calculate_F3();
            K3 = calculate_K3();
            N1 = calculate_N1();

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
            insert_poh(); 
            calculate_vc4_xor();
        end
    endfunction

    function void post_randomize();
        $display("VC4: This will be called just after randomization");
    endfunction

    function void  update_vc4_data();
        for (int i = 0; i < vc4_Width ; i++) begin
            for (int j = 0; j < vc4_Length ; j++) begin
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

    
    function bit [7:0] calculate_J1();
        return j1_frame[j1_frame_counter++];
    endfunction

    function bit [7:0] calculate_B3();
        return B3;
    endfunction

    function bit [7:0] calculate_C2();
        c2_value = 8'h00;
        return c2_value;
    endfunction

    function bit [7:0] calculate_G1();
        // G1: Path Status
        // Bits 1-4: REI (Remote Error Indication)
        // Bits 5-7: Path Status
        // Bit 8: Reserved
        byte rei = 4'h0; // Assuming no errors
        byte path_status = 3'b000; // Assuming normal operation
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
        static byte h4_counter = 0;
        h4_counter = (h4_counter + 1) % 16; // 4-bit counter
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
                j1_frame[i][6:0] = byte'(J1_TRACE_MESSAGE[i - 1]);
            end else begin
                j1_frame[i][7] = 1'b0;
                j1_frame[i][6:0] = byte'(" "); // Space character
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
    endfunction

    function bit [6:0] crc7_calculate (input byte data [0:J1_FRAME_LENGTH-2]);
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
        for (int i = 0; i < vc4_Width ; i++) begin
            for (int j = 0; j < vc4_Length ; j++) begin
                current_vc4_xor ^= data[i][j];
            end
        end
        vc4_xor = current_vc4_xor;
    endfunction

    // Function to set C2 value
    function void set_c2_value(bit[7:0] value);
        c2_value = value;
        C2 = value;
        poh[2] = C2;
        data[2][0] = C2;
        update_vc4_data();
        display_c2_state(value);
    endfunction

    // Function to get C2 state as a string based on the current c2_value
    function string get_c2_state_string();
        case (c2_value)
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
        for (int i = 0; i < 9; i++) begin
            data[i][0] = poh[i];
        end
        

        // Copy existing data
        for (int i = 0; i < c4_Width; i++) begin
            for (int j = 1; j < 261; j++) begin
                data[i][j] = c4.data[i][j-1];
            end
        end
    endfunction

    function void display_poh();
        $display("VC4: Path Overhead");
        for (int i = 0; i < 9; i++) begin
            $display("POH[%0d] = 0x%0h", i, poh[i]);
        end
    endfunction

endclass
