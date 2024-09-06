import param_pkg::*;
import class_pkg::*;


module tb1;

    CSV file;
    STM1 stm1_obj;
    bit[7:0] vc4_xor = 0;
    bit[7:0] frame_xor = 0;
    bit [23:0] semi_frame_xor = 0;     

    int index = 0;
    string J0_Messages [0:2]  = {"TRACE_MESSAGE"  , "IS_CHANGING", "CONSTANTLY"};
    string J1_Messages [0:2]  = {"AND_STM1_FRAME" , "IS_BEING"   , "ADJUSTED"  };

    bit [0:7][7:0] c2_values = {8'd0, 8'd1, 8'd2, 8'd3, 8'd4,
                           8'd12, 8'd13, 8'd14, 8'd15};


    initial begin   
        file = new();
        stm1_obj = new();
        file.open_csv("STM1");

        for (int i = 0; i<100 ;i=i+1) begin
            stm1_obj = new(vc4_xor, frame_xor, semi_frame_xor);
            
            if(stm1_obj.randomize()) begin
                if(i==32 || i==57 || i==70) begin
                    stm1_obj.update_J0_trace_message(J0_Messages[index++]);
                    stm1_obj.au4.vc4.update_j1_trace_message(J1_Messages[index++]);
                end
                stm1_obj.au4.vc4.set_c2_value(c2_values[i%8]);
                stm1_obj.update_stm_frame();

                vc4_xor = stm1_obj.au4.vc4.vc4_xor;
                frame_xor = stm1_obj.frame_xor;
                semi_frame_xor = stm1_obj.semi_frame_xor;
                file.container_write(stm1_obj.frame , STM1_OUT, DEC);     // {>>8{obj.data}} use streaming operator if it didn't work properly
            end

            else begin
                $display("well! randomization failed!");
            end
        end

        file.close_csv();
    end



endmodule
