`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2023 04:41:33 PM
// Design Name: 
// Module Name: REG_ID_EX
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


module REG_ID_EX(
        input wire i_clock,
        input wire i_reset,
        
        
        //inputs normales
        input wire [32-1:0] i_instruction,
        input wire [32-1:0] i_dataA,
        input wire [32-1:0] i_dataBFromMux,
        

        //input control info
        input wire i_controlRegDst,
        input wire i_controlJump,
        input wire i_controlBranch,
        input wire i_controlMemRead,
        input wire i_controlMemtoReg,
        input wire [6-1:0]i_controlALUOp,//este no se si lo vamos a sacar afuera
        input wire i_controlMemWrite,
        input wire i_controlALUSrc,
        input wire i_controlRegWrite,
        
        
        //outputs normales
        output reg [32-1:0] o_instruction,//lo vamos a necesitar para sacar el rt y rd  
        output reg [32-1:0] o_dataA,//va a la ALU
        output reg [32-1:0] o_dataBFromMux,//va a la ALU
        
        //output control info
        output reg o_controlRegDst,
        output reg o_controlJump,
        output reg o_controlBranch,
        output reg o_controlMemRead,
        output reg o_controlMemtoReg,
        output reg [6-1:0]o_controlALUOp,//este no se si lo vamos a sacar afuera
        output reg o_controlMemWrite,
        output reg o_controlALUSrc,
        output reg o_controlRegWrite
        
        
    );
    
    always@(posedge i_clock) begin
        if(i_reset) begin
            o_instruction<=0;
            o_dataA<=0;
            o_dataBFromMux<=0;
            
            o_controlRegDst<=0;
            o_controlJump<=0;
            o_controlBranch<=0;
            o_controlMemRead<=0;
            o_controlMemtoReg<=0;
            o_controlALUOp<=0;//este no se si lo vamos a sacar afuera
            o_controlMemWrite<=0;
            o_controlALUSrc<=0;
            o_controlRegWrite<=0;
        end
        else begin
            o_instruction<=i_instruction;
            o_dataA<=i_dataA;
            o_dataBFromMux<=i_dataBFromMux;
            
            o_controlRegDst<=i_controlRegDst;
            o_controlJump<=i_controlJump;
            o_controlBranch<=i_controlBranch;
            o_controlMemRead<=i_controlMemRead;
            o_controlMemtoReg<=i_controlMemtoReg;
            o_controlALUOp<=i_controlALUOp;//este no se si lo vamos a sacar afuera
            o_controlMemWrite<=i_controlMemWrite;
            o_controlALUSrc<=i_controlALUSrc;
            o_controlRegWrite<=i_controlRegWrite;
        end 
    
    end
endmodule
