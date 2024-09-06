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

    // overheads parameter for updating 
    parameter byte UPDATE_C2 = 1;
    parameter byte UPDATE_G1 = 2;
    parameter byte UPDATE_F2 = 3;
    parameter byte UPDATE_H4 = 4;
    parameter byte UPDATE_F3 = 5;
    parameter byte UPDATE_K3 = 6;
    parameter byte UPDATE_N1 = 7;
    parameter byte UPDATE_A1 = 8;
    parameter byte UPDATE_A2 = 9;
    parameter byte UPDATE_E1 = 10;
    parameter byte UPDATE_F1 = 11;
    parameter byte UPDATE_D1 = 12;
    parameter byte UPDATE_D2 = 13;
    parameter byte UPDATE_D3 = 14;
    parameter byte UPDATE_K1 = 15;
    parameter byte UPDATE_K2 = 16;
    parameter byte UPDATE_D4 = 17;
    parameter byte UPDATE_D5 = 18;
    parameter byte UPDATE_D6 = 19;
    parameter byte UPDATE_D7 = 20;
    parameter byte UPDATE_D8 = 21;
    parameter byte UPDATE_D9 = 22;
    parameter byte UPDATE_D10 =23;
    parameter byte UPDATE_D11 =24;
    parameter byte UPDATE_D12 =25;
    parameter byte UPDATE_S1 = 26;
    parameter byte UPDATE_Z1 = 27;
    parameter byte UPDATE_Z2 = 28;
    parameter byte UPDATE_M1 = 29;
    parameter byte UPDATE_E2 = 30;
    parameter byte UPDATE_H1 = 31;
    parameter byte UPDATE_H2 = 32;
    parameter byte UPDATE_H3 = 33;

endpackage
