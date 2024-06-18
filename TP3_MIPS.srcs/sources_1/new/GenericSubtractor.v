`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2024 12:41:02 AM
// Design Name: 
// Module Name: GenericSubtractor
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


module GenericSubtractor
    #(
        parameter LEN = 32
    )
    (
        input  wire [LEN-1:0] i_dataA,
        input  wire [LEN-1:0] i_dataB,
        output wire [LEN-1:0] o_result
    );
    
    /*
    GenericSubtractor
    #(
        .LEN(32)
    )
    u1_RestaMenos4
    (
        .i_dataA  (),
        .i_dataB  (),
        .o_result ()
    );
    */
    
    assign o_result = i_dataA - i_dataB;
endmodule
