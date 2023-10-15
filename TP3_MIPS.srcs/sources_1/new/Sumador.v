`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2023 07:54:34 PM
// Design Name: 
// Module Name: Sumador
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Sumador#(
        parameter DATA_LENGTH=32
    )
    (
        input  wire [DATA_LENGTH-1:0] i_dataA,
        input  wire [DATA_LENGTH-1:0] i_dataB,
        output wire [DATA_LENGTH-1:0] o_sumadorResult
    );
    //interface
    /*
    E1_Sumador#(32)
    u_E1_Sumador(
        .i_dataA(),
        .i_dataB(),
        .o_sumadorResult()
    );
    */
    
    assign o_sumadorResult=i_dataA+i_dataB;
    
endmodule
