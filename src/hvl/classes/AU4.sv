class AU4;
    VC4 vc4;
    rand bit [15:0] h1h2;  // H1 and H2 bytes of the AU pointer
    rand bit [7:0] h3;     // H3 byte of the AU pointer
    bit [7:0] aup[3];      // Administrative Unit Pointer
    
    // Pointer-related variables
    int pointer_value;
    bit new_data_flag;
    bit increment_flag;
    bit decrement_flag;

    // Stuff bytes
    localparam bit [7:0] FIXED_STUFF_BYTE = 8'h00;
    localparam bit [7:0] POSITIVE_STUFF_OPPORTUNITY = 8'hB8;
    localparam bit [7:0] NEGATIVE_STUFF_OPPORTUNITY = 8'hC5;

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
        // Calculate the AU pointer based on G.707
        pointer_value = h1h2 & 16'h03FF;  // Extract 10-bit pointer value
        new_data_flag = h1h2[10];
        increment_flag = h1h2[11];
        decrement_flag = h1h2[12];

        // Construct H1 and H2 bytes
        aup[0] = {1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, h1h2[9:8]};  // H1
        aup[1] = h1h2[7:0];  // H2

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

    // Function to display the Administrative Unit Pointer
    function void display_aup();
        $display("AU4: Administrative Unit Pointer");
        for (int i = 0; i < 3; i++) begin
            $display("AUP[%0d] = 0x%0h", i, aup[i]);
        end
    endfunction

    // Function to generate the AU-4 frame with pointer justification
    function bit [261*9*8-1:0] get_au4_frame();
        bit [261*9*8-1:0] frame;
        int adjusted_pointer = pointer_value;
        int stuff_column = 261;

        // Insert AUP
        frame[261*9*8-1 -: 24] = {aup[0], aup[1], aup[2]};

        // Handle pointer adjustments
        if (increment_flag) begin
            adjusted_pointer = (pointer_value + 1) % (261 * 9);
            stuff_column = (pointer_value + 1) / 9;
        end else if (decrement_flag) begin
            adjusted_pointer = (pointer_value - 1 + 261 * 9) % (261 * 9);
            stuff_column = pointer_value / 9;
        end

        // Insert VC4 payload with pointer justification and stuff bytes
        for (int i = 0; i < 261*9; i++) begin
            int row = i / 261;
            int col = i % 261;
            
            if (col == stuff_column) begin
                if (increment_flag && row == 0) begin
                    frame[261*9*8-24-1 - i*8 -: 8] = POSITIVE_STUFF_OPPORTUNITY;
                end else if (decrement_flag && row == 0) begin
                    frame[261*9*8-24-1 - i*8 -: 8] = NEGATIVE_STUFF_OPPORTUNITY;
                end else begin
                    frame[261*9*8-24-1 - i*8 -: 8] = FIXED_STUFF_BYTE;
                end
            end else begin
                int adjusted_index = (i + adjusted_pointer) % (261*9);
                if (adjusted_index < 260*9) begin
                    frame[261*9*8-24-1 - i*8 -: 8] = vc4.c4.data[adjusted_index / 260][adjusted_index % 260];
                end else begin
                    frame[261*9*8-24-1 - i*8 -: 8] = FIXED_STUFF_BYTE;
                end
            end
        end

        return frame;
    endfunction

    // Function to simulate pointer adjustments over time
    function void simulate_pointer_adjustment();
        // Randomly decide whether to adjust the pointer
        if ($urandom_range(100) < 5) begin  // 5% chance of adjustment
            if ($urandom_range(1) == 0) begin
                // Positive justification
                increment_flag = 1;
                decrement_flag = 0;
                $display("AU4: Positive justification");
            end else begin
                // Negative justification
                increment_flag = 0;
                decrement_flag = 1;
                $display("AU4: Negative justification");
            end
        end else begin
            // Normal operation
            increment_flag = 0;
            decrement_flag = 0;
        end
        
        calculate_aup();
    endfunction
endclass
