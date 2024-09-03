import param_pkg::*;
import class_pkg::*;


module tb1;

    CSV file;
    //C4 c4Obj;
    VC4 vc4_obj;
    //string col_names[] = {"col1" ,"col2" ,"col3" ,"col4" ,"col5" ,"col6" ,"col7" ,"col8" ,"col9" ,"col10"};
    //string row_names[] = {"row1" ,"row2" ,"row3" ,"row4" ,"row5" ,"row6" ,"row7" ,"row8" ,"row9" ,"row10"};

    initial begin   
        file = new();
        vc4_obj = new();
        if(vc4_obj.randomize()) begin
            
            file.open_csv("VC4");
            file.container_write(vc4_obj.data , "vc4", DEC);     // {>>8{obj.data}} use streaming operator if it didn't work properly
            file.close_csv();
        end

        else begin
            $display("well! randomization failed!");
        end
    end



endmodule