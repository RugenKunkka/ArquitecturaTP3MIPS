`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2023 12:10:56 PM
// Design Name: 
// Module Name: E3_BranchControl
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


module E3_BranchControl(
        input wire i_zeroBit,
        input wire i_isBNEQ,//branch not equal
        input wire i_isBranch,//branch ==> esto lo pensamos por el BEQ
        output reg o_controlBranchAddressMux
    );
    
    //interface
    /*
        E3_BranchControl#()
        u1_E3_BranchControl(
            .i_zeroBit(),
            .i_isBNEQ(),
            .i_isBranch(),
            .o_controlBranchAddressMux()
        );
    */    
    
    always@(*) begin
        if(i_zeroBit==0 && i_isBNEQ) begin
            o_controlBranchAddressMux=1;
        end
        else if (i_zeroBit && i_isBranch) begin
            o_controlBranchAddressMux=1;
        end
        else begin
            o_controlBranchAddressMux=0;
        end
    end
endmodule
