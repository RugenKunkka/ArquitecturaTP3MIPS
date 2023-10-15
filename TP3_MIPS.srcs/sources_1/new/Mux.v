`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2023 06:21:54 PM
// Design Name: 
// Module Name: Mux
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

//siempre va a tener de salida i_dataA al menos que el bit de control sea 1
module Mux#(
        parameter DATA_LENGTH=32
    )
    (
        input wire [DATA_LENGTH-1:0] i_dataA,
        input wire [DATA_LENGTH-1:0] i_dataB,
        input wire i_controlMux,
        
        output reg [DATA_LENGTH-1:0] o_data
    );
    //interface 
    /*
    Mux #(32) 
    u1_Mux (
        .i_dataA(),
        .i_dataB(),
        .i_controlMux(),
        .o_data()
    );
    */
    
    always @(*) begin
        if(i_controlMux) begin 
            o_data=i_dataB;
        end 
        else begin 
            o_data=i_dataB;
        end
    end
    
endmodule
