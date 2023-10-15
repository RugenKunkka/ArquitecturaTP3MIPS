`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 01:25:32 PM
// Design Name: 
// Module Name: Reg_IF_ID
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


module Reg_IF_ID(
        input wire i_clock,
        input wire i_reset,
        input wire [32-1:0] i_instruction,
        input wire [32-1:0] i_pcMas4,
        
        output reg [32-1:0] o_instruction,
        output reg [32-1:0] o_pcMas4
    );
    
    //interface
    /*
    Reg_IF_ID#()
    u1_Reg_IF_ID(
        .i_clock(),
        .i_reset(),
        .i_instruction(),
        .i_pcMas4(),
        
        .o_instruction(),
        .o_pcMas4()
    );
    */
    
    //no se si resetear la instruccion pero lo pongo por las dudas
    always @(posedge i_clock) begin
        // pase lo que pase la instruccion no la puedo resetear en cero xq ya con resetear el pc a cero,
        //obtengo la instruccion cero del banco de memoria y 99,9999% que no son 32 ceros consecutivos.. ya el bloque de instrucciones
        //me va a devolver la instruccion que se encuentra en la posicion cero 
        o_instruction<=i_instruction;
        if(i_reset) begin
            o_pcMas4<={32{1'b0}};
        end
        else begin
            o_pcMas4<=i_pcMas4;
        end
    end
endmodule
