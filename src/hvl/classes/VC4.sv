class VC4;
    C4 c4;
    rand bit [Byte_Num-1:0] poh[c4_Width]; // Path Overhead
    bit [vc4_Width-1:0][vc4_Lenght-1:0][Byte_Num-1:0] data;
    bit[7:0] J1, B3, C2, G1, F2, H4, F3, K3, N1;

    // J1 trace variables
    localparam int J1_FRAME_LENGTH = 16;
    byte j1_frame[J1_FRAME_LENGTH];
    static int j1_frame_counter;

    // B3 and C2 related variables
    byte previous_vc4_data[];
    byte c2_value;


    function new();
        c4 = new();
        j1_frame_counter = 0;
        init_j1_frame();
        c2_value = 8'h02;
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
            
            // Copy existing data
            for (int i = 0; i < c4_Width; i++) begin
                for (int j = 1; j < 261; j++) begin
                    data[i][j] = c4.data[i][j-1];
                end
            end

            insert_poh(); 
        end
    endfunction

    function void post_randomize();
        //$display("VC4: This will be called just after randomization");
    endfunction

       function void init_j1_frame(string J1_TRACE_MESSAGE = "PARMAN_________");
        for (int i = 0; i < J1_FRAME_LENGTH; i++) begin
            if (i < J1_TRACE_MESSAGE.len()) begin
                j1_frame[i] = int'(byte'(J1_TRACE_MESSAGE[i]));
            end else begin
                j1_frame[i] = " "; // Space character
            end
        end
    endfunction

    // New function to update J1 trace message
    // Usage:     vc4_instance.update_j1_trace_message("NEW_MESSAGE____");
    //function void update_j1_trace_message(string new_message);
    //    J1_TRACE_MESSAGE = new_message;
    //    init_j1_frame();
    //endfunction


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
