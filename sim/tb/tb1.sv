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


    bit [5:0] overheads_name[$][$] = '{{UPDATE_C2, UPDATE_D2, UPDATE_S1, UPDATE_Z2},
                                    {UPDATE_D2, UPDATE_Z1},
                                    {UPDATE_G1, UPDATE_M1, UPDATE_D4, UPDATE_F3, UPDATE_N1}};
    bit [7:0] overheads_value[$][$] = '{{8'h15,60,7,90},
                                    {57,8},
                                    {227,200,153,107,3}};

    initial begin   
        file = new();
        stm1_obj = new();
        file.open_csv("STM1");

        for (int i = 1; i<100 ;i=i+1) begin
            stm1_obj = new(vc4_xor, frame_xor, semi_frame_xor);
            
            if(stm1_obj.randomize()) begin
                if(i==33 || i==57 || i==70) begin
                    stm1_obj.update_overheads_value(overheads_name[index],overheads_value[index]);
                    stm1_obj.update_J0_trace_message(J0_Messages[index]);
                    stm1_obj.update_J1_trace_message(J1_Messages[index]);
                    index++;
                end
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
