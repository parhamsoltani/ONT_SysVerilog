class C4;
    randc bit [8:0] payload [259:0]; // 260x9 block of bits (each bit[8:0] represents a byte)
    
    // Constructor to initialize and randomize the payload array
    function new();
        void'(randomize_payload());
    endfunction
    
    // Function to randomize the payload array using randc
    function void randomize_payload();
        foreach (payload[i]) begin
            payload[i] = $urandom(); // Initialize with a random seed
            payload[i] = payload[i].randomize(); // Use randc to generate random values
        end
    endfunction
    
    // Task to display the contents of the payload array
    task display_payload();
        foreach (payload[i]) begin
            $display("payload[%0d] = %b", i, payload[i]);
        end
    endtask
endclass

// Example usage
module testbench;
    initial begin
        C4 c4_block = new();
        c4_block.display_payload();
    end
endmodule
