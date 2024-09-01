  class C4;
      rand bit [c4_Width-1:0][c4_Lenght-1:0][Byte_Num-1:0] data;

      function void pre_randomize ();
          //$display ("This will be called just before randomization");
      endfunction

      function void post_randomize ();
          //$display ("This will be called just after randomization");
      endfunction

      function int index_2Dto1D(input int row, column);
          return row * c4_Width + column;
      endfunction   
  endclass
