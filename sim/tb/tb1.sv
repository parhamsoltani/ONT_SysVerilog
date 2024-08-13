`timescale 1ns/1ns

import param_pkg::*;
import class_pkg::*;

module tb1;
    C4 c4;

    initial
    begin
        c4=new();
    end
endmodule