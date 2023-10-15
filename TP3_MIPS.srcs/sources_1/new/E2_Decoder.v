`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2023 09:23:03 PM
// Design Name: 
// Module Name: E2_Decoder
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


module E2_Decoder#(
        parameter DATA_LENGTH=32,
        parameter REGISTER_DIRECTION_LENGTH=6
    )

    (
        
        input wire [DATA_LENGTH-1:0]i_instruction,
        
        output reg [6:0] o_operationCode,
        output reg [5:0] o_dataA,
        output reg [5:0] o_dataB,
        output reg [5:0] o_regEscritura,
        output reg [15:0]o_adressDeInstruccion,
        output reg [5:0] o_functionCode

    );
    //en base al tipo de instrucción es lo que vamos a hacer....
    //si son tipo R ( los 6 bits MSB son ==0)
    //recordemos el formato general
    //Tipo de instruccion (6 bits MSB) y los ultimos 6bits (LSB) son la operacion que se quiere realizar en concreto
    always@(*) begin
        o_operationCode=i_instruction[31:26];
        o_dataA=i_instruction[25:21];
        o_dataB=i_instruction[20:16];
        o_regEscritura=i_instruction[15:11];
        o_adressDeInstruccion=i_instruction[15:0];
        o_functionCode=i_instruction[5:0];
        
    end 
endmodule
