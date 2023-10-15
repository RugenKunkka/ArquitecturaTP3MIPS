`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2023 09:46:19 PM
// Design Name: 
// Module Name: Shift2Unit
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


module Shift2Unit#(
        parameter DATA_LEGNTH=26
    )
    (
        input wire [DATA_LEGNTH-1:0] i_data,
        output wire [DATA_LEGNTH-1:0] o_shiftedData
    );
    
    //interface
    /*
        Shift2Unit#()
        u1_Shift2Unit(
        .i_data(),
        .o_shiftedData()
        );
    */
    assign o_shiftedData=i_data<<2;
endmodule
