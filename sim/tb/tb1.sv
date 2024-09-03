import param_pkg::*;
import class_pkg::*;

module tb1 ;
    CSV file;
    AU4 au4_obj;


    initial begin   
        file = new();
        au4_obj = new();
        
        if(au4_obj.randomize()) begin
            file.open_csv("excel_output");
            //file.arr2D_write(file.random_data , row_based, col_names, row_names);
            file.container_write(au4_obj.vc4.data , "vc4");
            file.close_csv();
        end

        else begin
            $display("well! randomization failed!");
        end    
    end
endmodule