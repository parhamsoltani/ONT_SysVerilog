import param_pkg::*;
import C4::*;

class VC4;
    C4 c4;
    rand bit [Byte_Num-1:0] poh[c4_Width];  // Path Overhead
    byte J1, B3, C2, G1, F2, H4, F3, K3, N1;
    function new();
        c4 = new ();
    endfunction 

    function void pre_randomize ();
        if (!c4.randomize()) begin
            $display("VC4: C4 randomization failed");
        else
            $display ("VC4: This will be called just before randomization");
        end
    endfunction

    function void post_randomize ();
        $display("VC4: This will be called just after randomization");
        // Initialize Path Overhead according to ITU-T G.707
        poh[0] = calculate_J1();
        poh[1] = calculate_B3();
        poh[2] = calculate_C2();
        poh[3] = calculate_G1();
        poh[4] = calculate_F2();
        poh[5] = calculate_H4();
        poh[6] = calculate_F3();
        poh[7] = calculate_K3();
        poh[8] = calculate_N1();


    endfunction


    function byte calculate_J1(C4 c4,);
        // J1: Path Trace
        // In practice, this would be a 16-byte frame-aligned trace message
        // For simplicity, we'll just use a counter here
        static byte j1_counter = 0;
        j1_counter++;
        return j1_counter;
    endfunction

    function byte calculate_B3();
        // B3: Path BIP-8
        byte bip8 = 8'h00;
        for (int i = 0; i < c4.data.size(); i++) begin
            bip8 ^= c4.data[i];
        end
        return bip8;
    endfunction

    function byte calculate_C2();
        // C2: Path Signal Label
        // For example, 0x02 indicates "TU-3 Structured"
        return 8'h02;
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


    //This function needs some correction as it is not 
    //adding the POH to the block with 261 columns, but the 260.
    function void insert_poh();
        for (int i = 0; i < 9; i++) begin
            c4.data[i][0] = poh[i];
        end
    endfunction

    function void display_poh();
        $display("VC4: Path Overhead");
        for (int i = 0; i < 9; i++) begin
            $display("POH[%0d] = 0x%0h", i, poh[i]);
        end
    endfunction


endclass 
