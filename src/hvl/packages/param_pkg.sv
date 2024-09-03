package param_pkg;

    // global params & typedefs 
    typedef bit [0:1][31:0] dimensions_t;


    // C4 params & typedefs    
    parameter c4_Length = 260,
              c4_Width = 9, 
              Byte_Num = 8;

    // VC4 params & typedefs    
    parameter vc4_Length = 261,
              vc4_Width = 9;

    // STM1 params & typedefs
    parameter STM1_Length = 270, STM1_Width = 9; 

    // CSV params & typedefs
    parameter bit row_based = 0;
    parameter bit col_based = 1;
    parameter bit HEX = 0;
    parameter bit DEC = 1;
    parameter bit TRANSLATE_OFF = 0;
    parameter bit TRANSLATE_ON = 1;    


endpackage
