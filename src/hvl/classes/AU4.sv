import param_pkg::*;
import class_pkg::*;

class AU4;
    rand VC4 vc4;
    rand bit [15:0] h1h2; // H1 and H2 bytes of the AU pointer
    rand bit [7:0] h3; // H3 byte of the AU pointer
    bit [7:0] aup[3]; // Administrative Unit Pointer
    typedef bit [7:0] au4_frame_t [9][261];  // Define a typedef for the array dimensions of the frame

    // Pointer-related variables
    int pointer_value; // indicates the start of the VC-4 payload within AU-4 frame, which ranges between 0 to 782.
    bit new_data_flag; // indicates whether new data is being pointed to.
    bit increment_flag; // set where an extra byte is added due to clock ppm.
    bit decrement_flag; // set where a byte is removed due to clock ppm and timing differences.

    // Stuff bytes
    // Constant values are specific to the SDH to maintain bit patterns in the data stream, helping with clock recovery and frame alignment in the physical layer.
    localparam bit [7:0] FIXED_STUFF_BYTE = 8'h00; // fill unused space in the frame.
    localparam bit [7:0] POSITIVE_STUFF_OPPORTUNITY = 8'hB8;     // used when adding an extra byte.
    localparam bit [7:0] NEGATIVE_STUFF_OPPORTUNITY = 8'hC5;    //  used when removing a byte.

    constraint h1h2_format {
        h1h2[15:12] == 4'b1010;  // Fixed pattern for H1
        h1h2[13:11] != 3'b111;   // Invalid combination
    }

    function new();
        vc4 = new();
    endfunction

    function void pre_randomize();
        if (!vc4.randomize()) begin
            $display("AU4: VC4 randomization failed");
        end else begin
            $display("AU4: This will be called just before randomization");
        end
    endfunction

    function void post_randomize();
        $display("AU4: This will be called just after randomization");
        calculate_aup();
    endfunction

    function void calculate_aup();
        // Calculate the AU pointer based on ITU-T G.707 
        pointer_value = h1h2 & 16'h03FF;  // Extract 10-bit offset by masking the upper 6-bits (3FF --> 1023)
        new_data_flag = (h1h2[15:12] == 4'b0110);  // NDF is 0110 when active ,indicating new data. 1001 when inactive indicating normal operation.
        increment_flag = h1h2[11];
        decrement_flag = h1h2[12];

        // Construct H1 and H2 bytes
        aup[0] = h1h2[15:8];  // H1
        aup[1] = h1h2[7:0];   // H2

        // Construct H3 byte based on pointer adjustment
        if (increment_flag) begin
            aup[2] = POSITIVE_STUFF_OPPORTUNITY;
        end else if (decrement_flag) begin
            aup[2] = NEGATIVE_STUFF_OPPORTUNITY;
        end else begin
            aup[2] = h3;  // Normal operation
        end

        $display("AU4: Pointer Value: %0d, New Data Flag: %b, Increment: %b, Decrement: %b", 
                 pointer_value, new_data_flag, increment_flag, decrement_flag);
    endfunction

    function void display_aup();
        $display("AU4: Administrative Unit Pointer");
        for (int i = 0; i < 3; i++) begin
            $display("AUP[%0d] = 0x%0h", i, aup[i]);
        end
    endfunction

    function au4_frame_t get_au4_frame();  // Use typedef for the return type
        au4_frame_t frame;  // Declare the frame array using the typedef
        int adjusted_pointer = pointer_value;
        int stuff_column = 261;

        // Insert AUP
        frame[0][0] = aup[0];
        frame[0][1] = aup[1];
        frame[0][2] = aup[2];

        // Handle pointer adjustments
        if (increment_flag) begin
            adjusted_pointer = (pointer_value + 1) % (261 * 9);
            stuff_column = (pointer_value + 1) / 9;
        end else if (decrement_flag) begin
            adjusted_pointer = (pointer_value - 1 + 261 * 9) % (261 * 9);
            stuff_column = pointer_value / 9;
        end

        // Insert VC4 payload with pointer justification and stuff bytes
        for (int row = 0; row < 9; row++) begin
            for (int col = 0; col < 261; col++) begin
                int i = row * 261 + col;
                
                if (col == stuff_column) begin
                    if (increment_flag && row == 0) begin
                        frame[row][col] = POSITIVE_STUFF_OPPORTUNITY;
                    end else if (decrement_flag && row == 0) begin
                        frame[row][col] = NEGATIVE_STUFF_OPPORTUNITY;
                    end else begin
                        frame[row][col] = FIXED_STUFF_BYTE;
                    end
                end else begin
                    int adjusted_index = (i + adjusted_pointer) % (261*9);
                    if (adjusted_index < 260*9) begin
                        if (col == 0 && row < 9) begin
                            // Insert VC-4 POH
                            frame[row][col] = vc4.poh[row];
                        end else begin
                            frame[row][col] = vc4.c4.data[adjusted_index / 260][adjusted_index % 260];
                        end
                    end else begin
                        frame[row][col] = FIXED_STUFF_BYTE;
                    end
                end
            end
        end

        return frame;
    endfunction

    function bit is_valid_pointer();
        return (pointer_value >= 0 && pointer_value <= 782);
    endfunction

    function void simulate_pointer_adjustment();
        // Randomly decide whether to adjust the pointer
        if ($urandom_range(100) < 5) begin  // 5% chance of adjustment
            if ($urandom_range(1) == 0 && pointer_value < 782) begin
                // Positive justification
                increment_flag = 1;
                decrement_flag = 0;
                pointer_value = (pointer_value + 1) % 783;
                $display("AU4: Positive justification");
            end else if (pointer_value > 0) begin
                // Negative justification
                increment_flag = 0;
                decrement_flag = 1;
                pointer_value = (pointer_value - 1 + 783) % 783;
                $display("AU4: Negative justification");
            end
        end else begin
            // Normal operation
            increment_flag = 0;
            decrement_flag = 0;
        end
        
        // Update h1h2 based on the new pointer value
        h1h2 = {4'b1010, increment_flag, decrement_flag, 1'b0, pointer_value[9:0]};
        
        calculate_aup();
    endfunction
endclass