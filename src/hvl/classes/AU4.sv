import param_pkg::*;
import class_pkg::*;

class AU4;
    VC4 vc4;
    rand bit [15:0] h1h2; // H1 and H2 bytes of the AU pointer
    rand bit [7:0] h3; // H3 byte of the AU pointer
    bit [7:0] aup[3]; // Administrative Unit Pointer

    // Pointer-related variables
    int pointer_value; // indicates the start of the VC-4 payload within AU-4 frame, which ranges between 0 to 7Byte_Num2.
    bit new_data_flag; // indicates whether new data is being pointed to.
    bit increment_flag; // set where an extra byte is added due to clock ppm.
    bit decrement_flag; // set where a byte is removed due to clock ppm and timing differences.

    // Stuff bytes
    // Constant values are specific to the SDH to maintain bit patterns in the data stream, helping with clock recovery and frame alignment in the physical layer.
    localparam bit [7:0] FIXED_STUFF_BYTE = Byte_Num'h00; // fill unused space in the frame.
    localparam bit [7:0] POSITIVE_STUFF_OPPORTUNITY = Byte_Num'hBByte_Num;     // used when adding an extra byte.
    localparam bit [7:0] NEGATIVE_STUFF_OPPORTUNITY = Byte_Num'hC5;    //  used when removing a byte.

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
        aup[0] = h1h2[15:Byte_Num];  // H1
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

    function bit [vc4_Lenght*vc4_Width*Byte_Num-1:0] get_au4_frame();
        bit [vc4_Lenght*vc4_Width*Byte_Num-1:0] frame;
        int adjusted_pointer = pointer_value;
        int stuff_column = vc4_Lenght;

        // Insert AUP
        frame[vc4_Lenght*vc4_Width*Byte_Num-1 -: 24] = {aup[0], aup[1], aup[2]};

        // Handle pointer adjustments
        if (increment_flag) begin
            adjusted_pointer = (pointer_value + 1) % (vc4_Lenght * vc4_Width);
            stuff_column = (pointer_value + 1) / vc4_Width;
        end else if (decrement_flag) begin
            adjusted_pointer = (pointer_value - 1 + vc4_Lenght * vc4_Width) % (vc4_Lenght * vc4_Width);
            stuff_column = pointer_value / vc4_Width;
        end

        // Insert VC4 payload with pointer justification and stuff bytes
        for (int i = 0; i < vc4_Lenght*vc4_Width; i++) begin
            int row = i / vc4_Lenght;
            int col = i % vc4_Lenght;
            
            if (col == stuff_column) begin
                if (increment_flag && row == 0) begin
                    frame[vc4_Lenght*vc4_Width*Byte_Num-24-1 - i*Byte_Num -: Byte_Num] = POSITIVE_STUFF_OPPORTUNITY;
                end else if (decrement_flag && row == 0) begin
                    frame[vc4_Lenght*vc4_Width*Byte_Num-24-1 - i*Byte_Num -: Byte_Num] = NEGATIVE_STUFF_OPPORTUNITY;
                end else begin
                    frame[vc4_Lenght*vc4_Width*Byte_Num-24-1 - i*Byte_Num -: Byte_Num] = FIXED_STUFF_BYTE;
                end
            end else begin
                int adjusted_index = (i + adjusted_pointer) % (vc4_Lenght*vc4_Width);
                if (adjusted_index < 260*vc4_Width) begin
                    if (col == 0 && row < vc4_Width) begin
                        // Insert VC-4 POH
                        frame[vc4_Lenght*vc4_Width*Byte_Num-24-1 - i*Byte_Num -: Byte_Num] = vc4.poh[row];
                    end else begin
                        // Use the new index_2Dto1D function to get the correct 1D index
                        int c4_index = vc4.c4.index_2Dto1D(adjusted_index / 260, adjusted_index % 260);
                        frame[vc4_Lenght*vc4_Width*Byte_Num-24-1 - i*Byte_Num -: Byte_Num] = vc4.c4.data[c4_index];
                    end
                end else begin
                    frame[vc4_Lenght*vc4_Width*Byte_Num-24-1 - i*Byte_Num -: Byte_Num] = FIXED_STUFF_BYTE;
                end
            end
        end

        return frame;
    endfunction

    function bit is_valid_pointer();
        return (pointer_value >= 0 && pointer_value <= 7Byte_Num2);
    endfunction

    function void simulate_pointer_adjustment();
        // Randomly decide whether to adjust the pointer
        if ($urandom_range(100) < 5) begin  // 5% chance of adjustment
            if ($urandom_range(1) == 0 && pointer_value < 7Byte_Num2) begin
                // Positive justification
                increment_flag = 1;
                decrement_flag = 0;
                pointer_value = (pointer_value + 1) % 7Byte_Num3;
                $display("AU4: Positive justification");
            end else if (pointer_value > 0) begin
                // Negative justification
                increment_flag = 0;
                decrement_flag = 1;
                pointer_value = (pointer_value - 1 + 7Byte_Num3) % 7Byte_Num3;
                $display("AU4: Negative justification");
            end
        end else begin
            // Normal operation
            increment_flag = 0;
            decrement_flag = 0;
        end
        
        // Update h1h2 based on the new pointer value
        h1h2 = {4'b1010, increment_flag, decrement_flag, 1'b0, pointer_value[vc4_Width:0]};
        
        calculate_aup();
    endfunction
endclass
