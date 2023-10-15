`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2023 09:24:23 PM
// Design Name: 
// Module Name: Etapa1FetchInstruction
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


module Etapa1_FetchInstruction#(
        parameter DATA_LENGTH=32
    )
    ( 
        output wire i_clock,//resolver el warning este [Synth 8-3848] Net i_clock in module/entity Etapa1_FetchInstruction does not have driver. ["D:/Facultad/Arquitectura de computadoras/MIS_TPS/TP3_MIPS/TP3_MIPS.srcs/sources_1/new/Etapa1FetchInstruction.v":27]
        output wire i_reset,
        
        //input data To muxs
        input wire [32-1:0] i_dataPCJumpAddressToMux1,
        input wire [32-1:0] i_dataPCJumpAddressRToMux2,
        input wire [32-1:0] i_dataPCBranchAddressToMux3,
        
        //controll bits
        //mux controll
        input wire i_controlMux1JumpAddress,
        input wire i_controlMux2JumpRAddress,
        input wire i_controlMux3BranchAddress,
        
        //output de la etapa
        output wire [32-1:0] o_pcMas4,
        output wire [32-1:0] o_instruction
    );
    
    
    wire [32-1:0] wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID;
    wire [32-1:0] wire_o_dataFromMux1ToMux2;
    Mux #(32) 
    u1_Mux1 (
        .i_dataA(i_dataPCJumpAddressToMux1),
        .i_dataB(wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID),
        .i_controlMux(i_controlMux1JumpAddress),
        .o_data(wire_o_dataFromMux1ToMux2)
    );
    
    wire [32-1:0] wire_o_dataFromMux2ToMux3;
    Mux #(32) 
    u1_Mux2 (
        .i_dataA(i_dataPCJumpAddressRToMux2),
        .i_dataB(wire_o_dataFromMux1ToMux2),
        .i_controlMux(i_controlMux2JumpRAddress),
        .o_data(wire_o_dataFromMux2ToMux3)
    );
    
    wire [32-1:0] wire_o_dataFromMux3ToPC;
    Mux #(32) 
    u1_Mux3 (
        .i_dataA(i_dataPCBranchAddressToMux3),
        .i_dataB(wire_o_dataFromMux2ToMux3),
        .i_controlMux(i_controlMux3BranchAddress),
        .o_data(wire_o_dataFromMux3ToPC)
    );
    
    wire [32-1:0] wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4;
    
    E1_PC#()
    u1_PC( 
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_pcAddressIn(wire_o_dataFromMux3ToPC),
        
        .o_pcAddressOut(wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4)
    );
    
    
    
    Sumador#(32)
    u_SumadorMas4(
        .i_dataA(wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4),
        .i_dataB(4),
        .o_sumadorResult(wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID)
    );
    
    
    wire [32-1:0] wire_o_intructionFromMemoryToReg_IF_ID;
    E1_InstructionMemory #(1024, 8) 
    u1_InstructionMemory (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_adressPC(wire_pcAddressFromPCToInstructionMemoryAndSumadorMas4),
        .o_instruction(wire_o_intructionFromMemoryToReg_IF_ID)
    );
    
    
    
    Reg_IF_ID#()
    u1_Reg_IF_ID(
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_instruction(wire_o_intructionFromMemoryToReg_IF_ID),
        .i_pcMas4(wire_pcSumadorResultFromSumadorMas4ToMuxAndReg_IF_ID),
        
        .o_instruction(o_instruction),
        .o_pcMas4(o_pcMas4)
    );
    
    
endmodule
