import param_pkg::*;
import class_pkg::*;

class VC4;
    C4 c4;
    rand bit [Byte_Num-1:0] poh[c4_Width]; // Path Overhead
    bit [vc4_Width-1:0][vc4_Length-1:0][Byte_Num-1:0] data;
    bit[7:0] J1, B3, C2, G1, F2, H4, F3, K3, N1;

    // J1 trace variables
    localparam int J1_FRAME_LENGTH = 16;
    byte j1_frame[J1_FRAME_LENGTH];
    static int j1_frame_counter = 0;

    // B3 related variable
    static bit[7:0] previous_frame_xor 8'h00;

    // C2 related variables
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

    function new();
        c4 = new();
        j1_frame_counter;
        init_j1_frame();
        B3 = previous_frame_xor;
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

            update_previous_frame_xor();
        end
    endfunction

    function void post_randomize();
        //$display("VC4: This will be called just after randomization");
    endfunction

    function void init_j1_frame(string J1_TRACE_MESSAGE = "PARMAN_________");
        for (int i = 0; i < J1_FRAME_LENGTH - 1; i++) begin
            if (i < J1_TRACE_MESSAGE.len()) begin
                j1_frame[i+1] = int'(byte'(J1_TRACE_MESSAGE[i]));
            end else begin
                j1_frame[i+1] = " "; // Space character
            end
        end
        j1_frame[0] = calculate_crc7(j1_frame[1:J1_FRAME_LENGTH-1]);
    endfunction

    function byte calculate_J1();
        byte frame_byte;

        // Increment the frame counter and wrap around if necessary
        j1_frame_counter = (j1_frame_counter + 1) % J1_FRAME_LENGTH;

        frame_byte = j1_frame[j1_frame_counter];

        // Set the first bit to 1 for CRC byte, 0 for other bytes
        if (j1_frame_counter == 0) begin
            frame_byte = frame_byte | 8'h80;
        end else begin
            frame_byte = frame_byte & 8'h7F;
        end

        add_poh_byte("J1", 0, frame_byte);
        return frame_byte;
    endfunction

    function byte calculate_crc7(byte data[J1_FRAME_LENGTH-1]);
        bit [6:0] crc = 7'h7F;
        bit [7:0] current_byte;

        for (int i = 0; i < J1_FRAME_LENGTH-1; i++) begin
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
        byte bip8 = previous_frame_xor;
        add_poh_byte("B3", 1, bip8);
        return bip8;
    endfunction

    function byte calculate_C2();
        add_poh_byte("C2", 2, c2_value);
        return c2_value;
    endfunction

    function void set_c2_value(bit[7:0] value);
        c2_value = value;
        display_c2_state(value);
    endfunction

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

    function byte calculate_G1();
        byte rei = 4'h0; // Assuming no errors
        byte path_status = 3'b000; // Assuming normal operation
        byte g1_byte = {1'b0, path_status, rei};
        add_poh_byte("G1", 3, g1_byte);
        return g1_byte;
    endfunction

    function byte calculate_F2();
        byte f2_byte = 8'hAA;
        add_poh_byte("F2", 4, f2_byte);
        return f2_byte;
    endfunction

    function byte calculate_H4();
        static byte h4_counter = 0;
        h4_counter = (h4_counter + 1) % 16; // 4-bit counter
        add_poh_byte("H4", 5, h4_counter);
        return h4_counter;
    endfunction

    function byte calculate_F3();
        byte f3_byte = 8'h55;
        add_poh_byte("F3", 6, f3_byte);
        return f3_byte;
    endfunction

    function byte calculate_K3();
        byte k3_byte = 8'h00;
        add_poh_byte("K3", 7, k3_byte);
        return k3_byte;
    endfunction

    function byte calculate_N1();
        byte n1_byte = 8'hFF;
        add_poh_byte("N1", 8, n1_byte);
        return n1_byte;
    endfunction

    function void add_poh_byte(string byte_name, int poh_index, byte value);
        poh[poh_index] = value;
        data[poh_index][0] = value;
        $display("Added %s byte to POH at index %0d with value 0x%0h", byte_name, poh_index, value);
    endfunction

    function void display_poh();
        $display("VC4: Path Overhead");
        for (int i = 0; i < 9; i++) begin
            $display("POH[%0d] = 0x%0h", i, poh[i]);
        end
    endfunction

    function void update_previous_frame_xor();
        bit[7:0] current_frame_xor = 8'h00;
        for (int i = 0; i < vc4_Width; i++) begin
            for (int j = 0; j < vc4_Length; j++) begin
                current_frame_xor ^= data[i][j];
            end
        end
        previous_frame_xor = current_frame_xor;
    endfunction

endclass