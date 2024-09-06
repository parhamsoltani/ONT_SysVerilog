package param_pkg;

    // global params & typedefs 
    typedef bit[0:1][31:0] dimensions_t;


    // C4 params & typedefs    
    parameter int C4_LENGTH = 260;
    parameter int C4_WIDTH = 9; 
    parameter int BYTE_NUM = 8;

    // VC4 params & typedefs    
    parameter int VC4_LENGTH = 261;
    parameter int VC4_WIDTH = 9;

    // STM1 params & typedefs
    parameter int STM1_LENGTH = 270;
    parameter int STM1_WIDTH = 9; 

    // CSV params & typedefs   
    parameter byte C4_OUT = 0;
    parameter byte VC4_OUT = 1;   
    parameter byte STM1_OUT = 2;  

    parameter bit ROW_BASED = 0;
    parameter bit COL_BASED = 1;
    parameter bit HEX = 0;
    parameter bit DEC = 1;
endpackage
