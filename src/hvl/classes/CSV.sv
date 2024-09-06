    import param_pkg::*;
    import class_pkg::*;

    class CSV;
        int file;

        localparam int MAX_COL_SIZE = 270;
        localparam int MAX_ROW_SIZE = 9;

        function void open_csv(input string file_name = "output");
            file = $fopen({file_name,".csv"} , "w");

            if(file == 0) begin
                $display("'%s.csv' is being accessed by another application(probably opened in excel)",file_name);
                $display("%s close it and run the code again!",file_name);
            end

            else begin
                $display("'%s.csv' is opened!", file_name);
            end
        endfunction : open_csv


        // unpacked input
        function void arr2D_write(input bit [7:0] data [][], bit alignment, string col_names []={}, string row_names []={});
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
                for (int i = 1; i<=data[1].size() ;i=i+1 ) begin
                    col_names_str = $sformatf("%s,%d",col_names_str, i);
                end
            end


            $fdisplay(file, col_names_str);



            // COL_ALIGNED data writing
            // ========================
            if(alignment == COL_BASED) begin
                foreach(data[i]) begin
                    data_str = (row_names.size()!=0)? row_names[i] : $sformatf("%d", i+1);
                    foreach (data[i,j]) begin
                        data_str = $sformatf("%s,%d", data_str, data[i][j]);
                    end

                    $fdisplay(file, data_str);
                end
            end

            

            // ROW_ALIGNED data writing
            // ========================
            else if(alignment == ROW_BASED) begin
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
        function void arr1D_write(input bit [7:0] data [], int col_size, int row_size, string col_names []={}, string row_names []={});

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
        function void container_write(input bit [0:MAX_COL_SIZE*MAX_ROW_SIZE-1][7:0] data ,byte cont_type, bit out_b=DEC, string col_names []={}, string row_names []={});
            int row_size;
            int col_size;

            string data_str;
            string line_str;
            string col_names_str;
            string frame_name;
            string out_base = (out_b==DEC)? "%0d" : "%0h";  //0x


            static string STM_pointers[dimensions_t]= {
                {32'd 0,32'd 0} : "A1",  // Illegal concatenation of an unsized constant. Will treat it as a 32-bit value.
                {32'd 0,32'd 1} : "A1",  // Should be defined as 32'b0 to wave it
                {32'd 0,32'd 2} : "A1",
                {32'd 0,32'd 3} : "A2",
                {32'd 0,32'd 4} : "A2",
                {32'd 0,32'd 5} : "A2",
                {32'd 0,32'd 6} : "J0",
                {32'd 0,32'd 9} : "J1",  // POH

                
                {32'd 1,32'd 0} : "B1",
                {32'd 1,32'd 3} : "E1",
                {32'd 1,32'd 6} : "F1",
                {32'd 1,32'd 9} : "B3", // POH


                {32'd  2,32'd 0} : "D1",
                {32'd  2,32'd 3} : "D2",
                {32'd  2,32'd 6} : "D3",
                {32'd  2,32'd 9} : "C2", // POH
 
 
                {32'd 3,32'd 0} : "H1",
                {32'd 3,32'd 3} : "H2",
                {32'd 3,32'd 6} : "H3",
                {32'd 3,32'd 7} : "H3",
                {32'd 3,32'd 8} : "H3",
                {32'd 3,32'd 9} : "G1", // POH


                {32'd 4,32'd 0} : "B2",
                {32'd 4,32'd 1} : "B2",
                {32'd 4,32'd 2} : "B2",
                {32'd 4,32'd 3} : "K1",
                {32'd 4,32'd 6} : "K2",
                {32'd 4,32'd 9} : "F2",


                {32'd 5,32'd 0} : "D4",
                {32'd 5,32'd 3} : "D5",
                {32'd 5,32'd 6} : "D6",
                {32'd 5,32'd 9} : "H4", // POH


                {32'd 6,32'd 0} : "D7",
                {32'd 6,32'd 3} : "D8",
                {32'd 6,32'd 6} : "D9",
                {32'd 6,32'd 9} : "F3", // POH


                {32'd 7,32'd 0} : "D10",
                {32'd 7,32'd 3} : "D11",
                {32'd 7,32'd 6} : "D12",
                {32'd 7,32'd 9} : "N1", // POH


                {32'd 8,32'd 0} : "S1",
                {32'd 8,32'd 1} : "Z1",
                {32'd 8,32'd 2} : "Z1",
                {32'd 8,32'd 3} : "Z2",
                {32'd 8,32'd 4} : "Z2",
                {32'd 8,32'd 5} : "M1",
                {32'd 8,32'd 6} : "E2",
                {32'd 8,32'd 9} : "K4" // POH
            };

                       

            static byte frame_counter[int] = '{
                C4_OUT   : 0,
                VC4_OUT  : 0,
                STM1_OUT : 0
            };


            // Setting dims based on the cont_type
            // ==================================
            static dimensions_t dimensions[byte] = {
                C4_OUT   : {32'd 260, 32'd 9},
                VC4_OUT  : {32'd 261, 32'd 9},
                STM1_OUT : {32'd 270, 32'd 9}
            };



            if(dimensions.exists(cont_type)) begin
                col_size = dimensions[cont_type][0];
                row_size = dimensions[cont_type][1];
                            
                case (cont_type)
                    C4_OUT :  begin
                        frame_name = "C4";
                        frame_counter[C4_OUT]++;
                    end

                    VC4_OUT : begin
                        frame_name = "VC4"; 
                        frame_counter[VC4_OUT]++;
                    end

                    STM1_OUT : begin
                        frame_name = "STM1";
                        frame_counter[STM1_OUT]++; 
                    end

                    default: frame_name = "";
                endcase

                col_names_str = $sformatf("%s / frame %0d", frame_name , frame_counter[cont_type]);
            end


            else begin
                $display("Error: Either not defined or Unsupported container type!");
                $display("C4_out , VC4_OUT & STM1_OUT are available as now!");
                return;
            end
            


            
            // Col_names labelling:
            // if given:
            if(col_names.size()!=0) begin
                foreach(col_names[i]) begin
                    col_names_str = {col_names_str, ",", col_names[i]};
                end
            end

            // else filled with indices:
            else begin
                for (int i = 1; i<=col_size ;i=i+1 ) begin
                    col_names_str = $sformatf("%s,%d",col_names_str, i);
                end
            end


            $fdisplay(file, col_names_str);
            $display("%s / frame %0d is written!", frame_name, frame_counter[cont_type]);



            // Writing the data
            for (int i = 0; i<row_size ; i=i+1) begin
                // write row label
                line_str = (row_names.size()!=0)? row_names[i] : $sformatf("%d", i+1);
                for (int j = 0; j<col_size ; j=j+1) begin
                    // write data in the desired base
                    data_str = $sformatf(out_base, data[i*col_size + j]);
                    // write pointer name if frame = STM1
                    if(cont_type == STM1_OUT && STM_pointers.exists({i,j}))
                        data_str = {STM_pointers[{i,j}], " = ", data_str};

                    line_str = {line_str , "," , data_str}; 
                end

                $fdisplay(file, line_str);
            end

            // leave a row for the next frame
            $fdisplay(file, " ");
        endfunction : container_write


        function void close_csv();
            $display("File's saved!");
            $fclose(file);
        endfunction : close_csv

    endclass
