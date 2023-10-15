`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2023 08:36:58 PM
// Design Name: 
// Module Name: Mux3DataInputs
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


module Mux3DataInputs #(
        parameter DATA_LENGTH=32
    )
    (
        input wire [DATA_LENGTH-1:0] i_dataA,
        input wire [DATA_LENGTH-1:0] i_dataB,
        input wire [DATA_LENGTH-1:0] i_dataC,
        
        input wire [2-1:0] i_controlMux,
        
        output reg [DATA_LENGTH-1:0] o_data

    );
    
    //interface
    /*
    Mux3DataInputs#(32)
    u1_Mux3DataInputs(
        .i_dataA(),
        .i_dataB(),
        .i_dataC(),
        
        .i_controlMux(),
        
        .o_data()
    );
        
    */
    
    always @(*) begin
        if(i_controlMux==2'b00) begin  
            o_data=i_dataA;
        end
        else if(i_controlMux==2'b01) begin 
            o_data=i_dataB;
        end 
        else if (i_controlMux==2'b10) begin 
            o_data=i_dataC;
        end
        else begin
            o_data=i_dataA;
        end
        
    end
    
endmodule
