
import param_pkg::*;
import class_pkg::*;

class AU4;
    VC4 vc4;
    bit [15:0] h1h2; // H1 and H2 bytes of the AU pointer
    bit [BYTE_NUM-1:0] h3; // H3 byte of the AU pointer
    bit [7:0] aup[3]; // Administrative Unit Pointer
    typedef bit [BYTE_NUM-1:0] au4_frame_t [VC4_WIDTH][VC4_LENGTH];  // Define a typedef for the array dimensions of the frame
    
    // Pointer-related variables
    static int pointer_value; // indicates the start of the VC-4 payload within AU-4 frame, which ranges between 0 to 782.
    static bit new_data_flag; // indicates whether new data is being pointed to.
    static bit increment_flag; // set where an extra byte is added due to clock ppm.
    static bit decrement_flag; // set where a byte is removed due to clock ppm and timing differences.
    
    // Stuff bytes
    // Constant values are specific to the SDH to maintain bit patterns in the data stream, helping with clock recovery and frame alignment in the physical layer.
    localparam bit [BYTE_NUM-1:0] FIXED_STUFF_BYTE = 8'h00;
    localparam bit [BYTE_NUM-1:0] POSITIVE_STUFF_OPPORTUNITY = 8'hB8;
    localparam bit [BYTE_NUM-1:0] NEGATIVE_STUFF_OPPORTUNITY = 8'hC5;
    
/*    constraint h1h2_format {
        h1h2[15:12] == 4'b0110;  // NDF disabled by default
        h1h2[11:10] == 2'b10;    // SS bits set to '1 0'
        h1h2[9:0] == 10'h20A;    // Default pointer value 522 (0x20A)
    }
 */   
    function new(bit[7:0] vc4_xor = 0);
        vc4 = new(vc4_xor);
    endfunction
    
    function void pre_randomize();
        // $display("AU4: This will be called just before randomization");
    endfunction
    
    function void post_randomize();
        // $display("AU4: This will be called just after randomization");
        calculate_aup();
    endfunction
    
    function void assign_pointer_value(int new_pointer_value);
        if (new_pointer_value < 0 || new_pointer_value > 3*VC4_LENGTH-1) begin
            $error("AU4: Invalid pointer value. Must be between 0 and 782.");
            return;
        end
        pointer_value = new_pointer_value;
        // Update h1h2 based on the new pointer value
        h1h2 = {4'b0110, 2'b10, pointer_value[9:0]};
        // Update h3 based on the new pointer value
        h3 = calculate_h3(pointer_value);
        // Recalculate AUP
        calculate_aup();
        $display("AU4: New pointer value assigned: %0d", pointer_value);
    endfunction
    
    function bit [BYTE_NUM-1:0] calculate_h3(int ptr_value);
        // Calculate H3 based on pointer value
        if (ptr_value == 0) begin
            return NEGATIVE_STUFF_OPPORTUNITY;
        end else if (ptr_value == 3*VC4_LENGTH-1) begin
            return POSITIVE_STUFF_OPPORTUNITY;
        end else begin
            // For normal operation, H3 contains the byte that would be in this position
            // if the pointer value was decreased by 1
            return vc4.c4.data[(ptr_value - 1) / C4_LENGTH][(ptr_value - 1) % C4_LENGTH];
        end
    endfunction
    
    function void calculate_aup();
        // Extract pointer value from h1h2
        pointer_value = h1h2 & 10'h3FF;
        // NDF (New Data Flag) is disabled when it's 0110, enabled when it's 1001
        new_data_flag = (h1h2[15:12] == 4'b1001);
        // I and D bits
        increment_flag = h1h2[9];
        decrement_flag = h1h2[8];
        // Construct H1 and H2 bytes
        aup[0] = h1h2[15:8];  // H1
        aup[1] = h1h2[BYTE_NUM-1:0];   // H2
        aup[2] = h3;          // H3 (already calculated in assign_pointer_value)
        $display("AU4: Pointer Value: %0d, New Data Flag: %b, Increment: %b, Decrement: %b", 
                 pointer_value, new_data_flag, increment_flag, decrement_flag);
        $display("AU4: H3 value: 0x%h", h3);
    endfunction 
    
    function au4_frame_t build_au4_frame();
        au4_frame_t frame;
        int row, column;
        // Insert section overhead
        frame[0][0] = 8'hF6;  // A1 byte
        frame[0][1] = 8'h28;  // A2 byte
        frame[0][2] = 8'h00;  // J0 byte
        frame[0][3:5] = aup;  // AU-4 Pointer (H1, H2, H3)
        frame[0][6:8] = '{8'h00, 8'h00, 8'h00};  // B1, E1, F1 bytes (placeholder values)   
        // Insert fixed stuff bytes
        for (row = 1; row < VC4_WIDTH; row++) begin
            frame[row][0:2] = '{FIXED_STUFF_BYTE, FIXED_STUFF_BYTE, FIXED_STUFF_BYTE};
        end
        // Insert VC-4 payload
        for (row = 0; row < VC4_WIDTH; row++) begin
            for (column = 0; column < VC4_LENGTH; column++) begin
                if (row == 0 && column < VC4_WIDTH) continue;  // Skip SOH bytes
                if (column < 3) continue;  // Skip fixed stuff bytes
                frame[row][column] = vc4.c4.data[row][column-3];
            end
        end
        return frame;
    endfunction
    
    function void print_frame(au4_frame_t frame);
        for (int i = 0; i < VC4_WIDTH; i++) begin
            for (int j = 0; j < VC4_LENGTH; j++) begin
                $write("%h ", frame[i][j]);
            end
            $write("\n");
        end
    endfunction
    
    function void simulate_pointer_adjustment();
        // Randomly decide whether to adjust the pointer
        if ($urandom_range(100) < 5) begin  // 5% chance of adjustment
            if ($urandom_range(1) == 0 && pointer_value < 3*VC4_LENGTH-1) begin
                // Positive justification
                increment_flag = 1;
                decrement_flag = 0;
                pointer_value = (pointer_value + 1) % (3*VC4_LENGTH);
                $display("AU4: Positive justification");
            end else if (pointer_value > 0) begin
                // Negative justification
                increment_flag = 0;
                decrement_flag = 1;
                pointer_value = (pointer_value - 1 + 3*VC4_LENGTH) % VC4_LENGTH;
                $display("AU4: Negative justification");
            end
        end else begin
            // Normal operation
            increment_flag = 0;
            decrement_flag = 0;
        end
        
        // Update h1h2 based on the new pointer value
        h1h2 = {4'b1010, 2'b10, increment_flag, decrement_flag, pointer_value[9:0]};
        
        calculate_aup();
    endfunction

    function void process_pointer();
        bit [9:0] id_bits;
        id_bits = h1h2[9:0];

        if (increment_flag) begin
            // Invert all 'I' bits for positive justification
            id_bits = id_bits ^ 10'b1010101010;
        end else if (decrement_flag) begin
            // Invert all 'D' bits for negative justification
            id_bits = id_bits ^ 10'b0101010101;
        end

        h1h2 = {h1h2[15:10], id_bits};
        calculate_aup();

    endfunction
    
endclass
