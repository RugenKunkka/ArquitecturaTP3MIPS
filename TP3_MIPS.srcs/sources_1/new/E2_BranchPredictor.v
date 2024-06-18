`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2024 11:09:08 PM
// Design Name: 
// Module Name: E2_BranchPredictor
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


module E2_BranchPredictor #()
    (
        input wire signed [32-1:0] i_dataA,
        input wire signed [32-1:0] i_dataB,    
        input wire                 i_isBEQ,
        input wire                 i_isBNQ,
        
        output reg                 o_isZero
    );
    
    /*
    E2_BranchPredictor
    #(

    )
    u1_E2_BranchPredictor
    (
        .i_dataA (),
        .i_dataB (),    
        .i_isBEQ (),
        .i_isBNQ (),
        
        .o_isZero ()
    );
    */
    always @(*) begin
        o_isZero = 0;
        if(i_isBEQ)begin
            o_isZero = (i_dataA==i_dataB) ? 1'b1 : 1'b0;
        end
        else if(i_isBNQ) begin 
            o_isZero = (i_dataA==i_dataB) ? 1'b1 : 1'b0;
        end
    end
    
    
endmodule
