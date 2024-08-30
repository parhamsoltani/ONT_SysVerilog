    import param_pkg::*;

    
    class CSV;
        int file;

        localparam max_col_size = 270,
                   max_row_size = 9;


        function void open_csv(input string file_name = "output");
            file = $fopen({file_name,".csv"} , "w");

            if(file == 0) begin
                $display("%s is being accessed by another application(probably opened in excel)",file_name);
                $display("%s close it and run the code again!",file_name);
            end

            else begin
                $display("File is opened!");
            end
        endfunction : open_csv


        // unpacked input
        function void arr2D_write(input bit [7:0] data [][], input bit alignment, input string col_names []={}, input string row_names []={});
            string col_names_str = "";
            string data_str = "";

            
            // Col_names labelling
            // ===================
            // if col_names are given:
            if(col_names.size()!=0) begin
                foreach(col_names[i]) begin
                    col_names_str = {col_names_str, ",", col_names[i]};
                end
            end

            // else filled with indices
            else begin
                for (int i = 1; i<=data[0].size() ;i=i+1 ) begin
                    col_names_str = $sformatf("%s,%d",col_names_str, i);
                end
            end


            $fdisplay(file, col_names_str);



            // ROW_ALIGNED data writing
            // ========================
            if(alignment == row_based) begin
                foreach(data[i]) begin
                    data_str = (row_names.size()!=0)? row_names[i] : $sformatf("%d", i+1);
                    foreach (data[i][j]) begin
                        data_str = $sformatf("%s,%d", data_str, data[i][j]);
                    end

                    $fdisplay(file, data_str);
                end
            end

            

            // COL_ALIGNED data writing
            // ========================
            else if(alignment == col_based) begin
                for (int j = 0; j<data[0].size(); j=j+1) begin
                    data_str = (row_names.size()!=0)? row_names[j] : $sformatf("%d", j+1);
                    foreach (data[i]) begin
                        data_str = $sformatf("%s,%d", data_str, data[i][j]);
                    end

                    $fdisplay(file, data_str);
                end
            end
        endfunction : arr2D_write


        // unpacked input
        function void arr1D_write(input bit [7:0] data [], input int col_size, input int row_size, input string col_names []={}, input string row_names []={});

            string col_names_str, line_str;

            // Col_names labelling
            // ===================

            // if col_names are given:
            if(col_names.size()!=0) begin
                foreach(col_names[i]) begin
                    col_names_str = {col_names_str, ",", col_names[i]};
                end
            end

            // else filled with indices
            else begin
                for (int i = 1; i<=col_size ;i=i+1 ) begin
                    col_names_str = $sformatf("%s,%d",col_names_str, i);
                end
            end



            // Writing the data
            // ================
            for (int i = 0; i<row_size ; i=i+1) begin
                line_str = (row_names.size()!=0)? row_names[i] : $sformatf("%d", i+1);

                for (int j = 0; j<col_size ; j=j+1) begin
                    line_str = $sformatf("%s,%d",line_str, data[i*col_size + j]); 
                end

                $fdisplay(file, line_str);
            end
        endfunction : arr1D_write


        // packed input
        // ============
        // Either had to make multiple exclusive functions or set the bigest size as the data size
        function void container_write(input bit [max_col_size*max_row_size-1:0][7:0] data ,string cont_type, input string col_names []={}, input string row_names []={});
            int row_size, col_size;
            string line_str, col_names_str;


            // Setting dims based on the con_type
            // ==================================
            dimensions_t dimensions[string] = '{
                "c4"   : '{260, 9},
                "vc4"  : '{261, 9},
                "au4"  : '{270, 9},
                "stm1" : '{270, 9}
            };


            if(dimensions.exists(cont_type)) begin
                col_size = dimensions[cont_type][0];
                row_size = dimensions[cont_type][1];
            end

            else begin
                $display("Error: Either not defined or Unsupported container type: %s", cont_type);
                return;
            end
            



            // Col_name labelling
            // ==================

            // if given:
            if(col_names.size()!=0) begin
                foreach(col_names[i]) begin
                    col_names_str = {col_names_str, ",", col_names[i]};
                end
            end

            // else filled with indices:
            else begin
                for (int i = 1; i<=row_size ;i=i+1 ) begin
                    col_names_str = $sformatf("%s,%d",col_names_str, i);
                end
            end


            $fdisplay(file, col_names_str);



            // Writing the data
            for (int i = 0; i<row_size ; i=i+1) begin
                line_str = (row_names.size()!=0)? row_names[i] : $sformatf("%d", i+1);
                for (int j = 0; j<col_size ; j=j+1) begin
                    line_str = $sformatf("%s,%d",line_str, data[i*col_size + j]); 
                end

                $fdisplay(file, line_str);
            end
        endfunction : container_write


        function void close_csv();
            $display("File saved!");
            $fclose(file);
        endfunction : close_csv

    endclass


