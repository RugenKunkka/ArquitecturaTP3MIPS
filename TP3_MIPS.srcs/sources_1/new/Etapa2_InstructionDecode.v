`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2023 02:20:53 PM
// Design Name: 
// Module Name: Etapa2_InstructionDecode
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


module Etapa2_InstructionDecode#(
        parameter DATA_LENGTH=32
    )
    (
        input wire i_clock,
        input wire i_reset,
        input wire [DATA_LENGTH-1:0] i_instruction,
        
        
        input wire [5-1:0] i_addressEscrituraToRegisterMemory,
        input wire [5-1:0] i_datoAEscribirToRegisterMemory,
        
        input wire i_controlRegWriteToRegisterMemory,
        
        //outputs wireados a otras etapas sin necesidad de reistro intermedio
        //osea.. NO VA AL REGISTRO.. sale de one
        output wire [32-1:0] o_incoditionalJumpAddress,
        
        //--------------REISTROS RELACIONADOS con el el registro intermedio------------------------ 
        output wire [DATA_LENGTH-1:0] o_dataA,
        output wire [DATA_LENGTH-1:0] o_dataBFromMux,
        
        
        //control outputs
        output wire o_controlRegDst,
        output wire o_controlJump,
        output wire o_controlBranch,
        output wire o_controlMemRead,
        output wire o_controlMemtoReg,
        output wire [6-1:0]o_controlALUOp,//este no se si lo vamos a sacar afuera
        output wire o_controlMemWrite,
        output wire o_controlALUSrc,
        output wire o_controlRegWrite,
        output wire o_controlIsJALR
        
        
    );
    
    wire o_wire_controlRegDst;
    wire o_wire_controlJump;
    wire o_wire_controlBranch;
    wire o_wire_controlMemRead;
    wire o_wire_controlMemtoReg;
    wire [6-1:0]o_wire_controlALUOp;//este no se si lo vamos a sacar afuera
    wire o_wire_controlMemWrite;
    wire o_wire_controlALUSrc;
    wire o_wire_controlRegWrite;
    
    E2_ControlUnit#()
    u_ControlUnit(
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_operationCode(i_instruction[31:26]),
        .i_bits20_16(i_instruction[20:15]),
        .i_bits10_6(i_instruction[10:6]),
        .i_bits20_6(i_instruction[20:6]),
        
        .i_functionCode(i_instruction[5:0]),
        
        .o_controlRegDst(o_wire_controlRegDst),
        .o_controlJump(o_wire_controlJump),
        .o_controlBranch(o_wire_controlBranch),
        .o_controlMemRead(o_wire_controlMemRead),
        .o_controlMemtoReg(o_wire_controlMemtoReg),
        .o_controlALUOp(o_wire_controlALUOp),
        .o_controlMemWrite(o_wire_controlMemWrite),
        .o_controlALUSrc(o_wire_controlALUSrc),
        .o_controlRegWrite(o_wire_controlRegWrite)
    );
    
    wire [32-1:0] wire_o_dataBFromRegisterMemoryToMuxALU;
    E2_RegisterMemory#()
    u_RegisterMemory(
        .i_clock(i_clock),
        .i_reset(i_reset),
        
        .i_AddressLecturaA(i_instruction[25:21]),
        .i_AddressLecturaB(i_instruction[20:16]),
        .i_AddressEscritura(i_addressEscrituraToRegisterMemory),
        .i_DatoAEscribir(i_datoAEscribirToRegisterMemory),
        
        .i_controlRegWrite(i_controlRegWriteToRegisterMemory),
        
        .o_dataA(o_dataA),
        .o_dataB(wire_o_dataBFromRegisterMemoryToMuxALU)
    );
    
    wire [32-1:0] wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB;
    ExtensorDePalabra#()
    u1_ExtensorDePalabra(
        .i_data(i_instruction[16-1:0]),//esto es para operaciones distintos del tipo R xq tiene el campo inmediato ahi... 
        
        .o_extendedData(wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB)
    );
    
    wire [32-1:0] wire_o_dataMuxAluSrc;
    Mux #(32) 
    u1_MuxAluInputB (
        .i_dataA(wire_o_dataBFromRegisterMemoryToMuxALU),
        .i_dataB(wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB),
        .i_controlMux(o_wire_controlALUSrc),
        .o_data(o_dataBFromMux)
    );
    
    wire [28-1:0] wire_shiftedInconditionalJumpAddress;
    Shift2Unit#(26)
        u1_Shift2Unit(
        .i_data(i_instruction[25:0]),
        .o_shiftedData(wire_shiftedInconditionalJumpAddress)
    );
    
    ExtensorDeSigno#(28,32)
    u1_ExtensorDeSigno(
        .i_data(wire_shiftedInconditionalJumpAddress),
        .o_extendedSignedData(o_incoditionalJumpAddress)
    );
    
    
endmodule
