import param_pkg::*;
import C4::*;

class VC4;
    C4 c4;
    rand bit [Byte_Num-1:0] poh[c4_Width]; // Path Overhead
    bit[7:0] J1, B3, C2, G1, F2, H4, F3, K3, N1;

    // J1 trace variables
    string J1_TRACE_MESSAGE = "PARMAN_________";
    localparam int J1_FRAME_LENGTH = 16;
    byte j1_frame[J1_FRAME_LENGTH];
    int j1_frame_counter;

    // B3 and C2 related variables
    byte previous_vc4_data[];
    byte c2_value;

    function new();
        c4 = new();
        j1_frame_counter = 0;
        init_j1_frame();
        c2_value = 8'h02;
    endfunction

    function void init_j1_frame();
        for (int i = 0; i < J1_FRAME_LENGTH; i++) begin
            if (i < J1_TRACE_MESSAGE.len()) begin
                j1_frame[i] = byte'(J1_TRACE_MESSAGE[i]);
            end else begin
                j1_frame[i] = " "; // Space character
            end
        end
    endfunction

    // New function to update J1 trace message
    // Usage:     vc4_instance.update_j1_trace_message("NEW_MESSAGE____");
    function void update_j1_trace_message(string new_message);
        J1_TRACE_MESSAGE = new_message;
        init_j1_frame();
    endfunction

    function void pre_randomize();
        if (!c4.randomize()) begin
            $display("VC4: C4 randomization failed");
        end else begin
            $display("VC4: This will be called just before randomization");
        end
    endfunction

    function void post_randomize();
        $display("VC4: This will be called just after randomization");

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
    endfunction

    function byte calculate_J1();
        byte crc;
        byte frame_start;

        // Calculate CRC-7 for the previous frame
        crc = calculate_crc7(j1_frame);

        // Prepare the frame start byte (CRC in bits 1-7, frame start indicator in bit 8)
        frame_start = (crc << 1) | 1'b1;

        // Increment the frame counter and wrap around if necessary
        j1_frame_counter = (j1_frame_counter + 1) % J1_FRAME_LENGTH;

        // Return the appropriate byte based on the current frame position
        if (j1_frame_counter == 0) begin
            return frame_start;
        end else begin
            return j1_frame[j1_frame_counter - 1];
        end
    endfunction

    function byte calculate_crc7(byte data[J1_FRAME_LENGTH]);
        bit [6:0] crc = 7'h7F;
        bit [7:0] current_byte;

        for (int i = 0; i < J1_FRAME_LENGTH; i++) begin
            current_byte = data[i];
            for (int j = 0; j < 8; j++) begin
                if ((crc[6] ^ current_byte[7]) == 1'b1) begin
                    crc = (crc << 1) ^ 7'h09;
                end else begin
                    crc = crc << 1;
                end
                current_byte = current_byte << 1;
            end
        end

        return byte'(crc);
    endfunction

    function byte calculate_B3();
        byte bip8 = 8'h00;
        if (previous_vc4_data.size() > 0) begin
            for (int i = 0; i < previous_vc4_data.size(); i++) begin
                bip8 ^= previous_vc4_data[i];
            end
        end
        return bip8;
    endfunction

    function byte calculate_C2();
        return c2_value;
    endfunction

    function byte calculate_G1();
        // G1: Path Status
        // Bits 1-4: REI (Remote Error Indication)
        // Bits 5-7: Path Status
        // Bit 8: Reserved
        byte rei = 4'h0; // Assuming no errors
        byte path_status = 3'b000; // Assuming normal operation
        return {1'b0, path_status, rei};
    endfunction

    function byte calculate_F2();
        // F2: Path User Channel
        // This is typically used for communication between path terminating equipment
        // For this application, we'll just return a fixed value
        return 8'hAA;
    endfunction

    function byte calculate_H4();
        // H4: Multiframe Indicator
        // Used for payloads requiring multiframe alignment
        // For this application, we'll use a simple counter
        static byte h4_counter = 0;
        h4_counter = (h4_counter + 1) % 16; // 4-bit counter
        return h4_counter;
    endfunction

    function byte calculate_F3();
        // F3: Path User Channel
        // Similar to F2, but for a different user
        // For this application, we'll just return a fixed value
        return 8'h55;
    endfunction

    function byte calculate_K3();
        // K3: APS (Automatic Protection Switching) Channel
        // Bits 1-4: Switching request type
        // Bits 5-8: Channel number
        // For this application, we'll assume no switching request
        return 8'h00;
    endfunction

    function byte calculate_N1();
        // N1: Network Operator Byte
        // This byte is reserved for network operator use
        // For this application, we'll just return a fixed value
        return 8'hFF;
    endfunction

    function void insert_poh();
        // Create a new array with increased width
        bit [Byte_Num-1:0] new_data[c4_Width][261];

        // Copy existing data
        for (int i = 0; i < c4_Width; i++) begin
            for (int j = 0; j < 260; j++) begin
                new_data[i][j] = c4.data[i][j];
            end
        end

        // Add POH as the last column
        for (int i = 0; i < 9; i++) begin
            new_data[i][260] = poh[i];
        end

        // Fill the rest of the new column with zeros
        for (int i = 9; i < c4_Width; i++) begin
            new_data[i][260] = 8'h00;
        end

        // Update c4.data with the new array
        c4.data = new_data;
    endfunction

    function void display_poh();
        $display("VC4: Path Overhead");
        for (int i = 0; i < 9; i++) begin
            $display("POH[%0d] = 0x%0h", i, poh[i]);
        end
    endfunction

    // Function to set C2 value
    function void set_c2_value(byte value);
        c2_value = value;
    endfunction

    // Function to update previous VC-4 data
    function void update_previous_vc4_data();
        previous_vc4_data = new[c4.data.size() * c4.data[0].size()];
        int index = 0;
        for (int i = 0; i < c4.data.size(); i++) begin
            for (int j = 0; j < c4.data[i].size(); j++) begin
                previous_vc4_data[index++] = c4.data[i][j];
            end
        end
    endfunction
endclass