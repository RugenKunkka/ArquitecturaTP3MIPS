`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2023 07:21:43 PM
// Design Name: 
// Module Name: MuxToPCFromInstructionFetch
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


module E1_MuxToPCFromInstructionFetch#(
        parameter DATA_LENGTH=32
    )
    (
        input  wire [DATA_LENGTH-1:0] i_pcFromRegister,
        input  wire [DATA_LENGTH-1:0] i_pcBranch,
        input  wire [DATA_LENGTH-1:0] i_pcJump,
        input  wire [DATA_LENGTH-1:0] i_pcNormal,
        input  wire [3-1:0] i_selectPcSourceCode,  
        output reg  [DATA_LENGTH-1:0] o_muxToPC
    );
    //interface
    /*
    E1_MuxToPCFromInstructionFetch#(
        .DATA_LENGTH(32)
    )
    u1_E1_MuxToPCFromInstructionFetch(
        .i_pcFromRegister(),
        .i_pcBranch(),
        .i_pcJump(),
        .i_pcNormal(),
        .i_selectPcSourceCode(),  
        .o_muxToPC()
    );
    */
    always @(*) begin
        if(i_selectPcSourceCode == 3'b001) begin
            o_muxToPC=i_pcFromRegister;
        end
        else if(i_selectPcSourceCode == 3'b010) begin
            o_muxToPC=i_pcBranch;
        end
        else if(i_selectPcSourceCode == 3'b100) begin
            o_muxToPC=i_pcJump;  
        end
        else begin
            o_muxToPC=i_pcNormal;
        end
    end
    
    
    
endmodule
