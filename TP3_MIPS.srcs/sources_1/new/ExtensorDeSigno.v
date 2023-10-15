`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2023 09:37:38 PM
// Design Name: 
// Module Name: ExtensorDeSigno
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


module ExtensorDeSigno#(
        parameter INPUT_DATA_LENGTH=16,
        parameter OUTPUT_DATA_LENGTH=32
    )
    (
        input wire [INPUT_DATA_LENGTH-1:0] i_data,
        output wire [31:0] o_extendedSignedData
    );
    
    //interface
    /*
    ExtensorDeSigno#(28,32)
    u1_ExtensorDeSigno(
        .i_data(),
        .o_extendedSignedData()
    );
    */
    
    assign o_extendedSignedData = (i_data[INPUT_DATA_LENGTH-1] == 1) ? {{OUTPUT_DATA_LENGTH-INPUT_DATA_LENGTH{1'b1}}, i_data} : {{OUTPUT_DATA_LENGTH-INPUT_DATA_LENGTH{1'b0}}, i_data};
endmodule
