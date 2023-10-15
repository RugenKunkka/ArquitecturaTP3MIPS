`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2023 02:39:52 PM
// Design Name: 
// Module Name: Etapa3_Execution
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


module Etapa3_Execution(
        input wire i_clock,
        input wire i_reset,
        
        input wire [32-1:0] i_dataAToALUMux,
        input wire [32-1:0] i_dataBToALUMux,
        input wire [32-1:0] i_dataBFromRegisterMemory,
        
        input wire [32-1:0] i_instruction,
        input wire [32-1:0] i_pcMas4,
        
        
        //bits de control que salen de la control unit de la etapa anterior
        input wire i_controlIsBNEQ,//termina acá
        input wire i_controlIsBranch,//termina acá
        input wire i_controlIsJumpR,
        input wire [4-1:0] i_controlALUOperationCode,
        input wire i_controlRegDst,
        input wire i_controlMemWrite,
       
        //a estas 2 directamente l epuse instruction y el rango
        //input wire [5-1:0] i_rsFromEtapa2RegID_EX,
        //input wire [5-1:0] i_rtFromEtapa2RegID_EX,
        //inputs de etapas adelantadas (4 y 5)
        input wire [5-1:0] i_rdFromEtapa4Reg_Ex_MEM,
        input wire [5-1:0] i_rdFromEtapa5Reg_MEM_WB,
        input wire i_controlRegWriteFromEtapa4RegEX_MEM,
        input wire i_controlRegWriteFromEtapa5RegMEM_WB,
        
        
        
        
        
        
        
        
        //outputs sin registros intermedios
        output wire o_controlIsBranchControlUnit,
        output wire o_controlIsJumpR,
        output wire o_branchAddress,
        output wire [32-1:0] o_jumpRAddress,
        
        //Datos que van en el registro intermedio a etapa 4
        output wire o_controlRegWrite,
        output wire o_controlMemWrite,
        output wire o_controlMemtoReg,
        output wire [32-1:0] o_programCounterMas4,
        output wire [32-1:0] o_ALUResult,
        output wire [32-1:0] o_dataQueQuieroEscribirEnMemoriaDeDatosToReg_EX_MEM,
        output wire [5-1:0] o_addresWriteRegisterMemory
        
    );
    
    assign o_controlIsJumpR=i_controlIsJumpR;
    
    wire [2-1:0] o_controlForwarding1;
    wire [2-1:0] o_controlForwarding2;
    wire [2-1:0] o_controlForwarding3;
    
    
    //------------------------------------multiplexores de forwarding------------------------------------
    /*son para poder hacer el bypass y obtener un dato que esta listo en la etapa 4 y lo puedo necesitar de la etapa 4 o 5  y es antes de quese escriba
    en la memoria de registro. Essto lo hago haciendo una predicción dentro de la forwardingUnit viendo si se necesita para el calculo (dentro de los registros
    base ya sea rso rt) un valor que no se guardo en memoria y eso lo hago comparando el contenido de rs o rt con el de rd en las etapas 4 y 5,
    si tienen la misma direccion / valor, quiere decir que necesito ese valor de manera anticipada
    */
    
    /*
    Los muxes de forwarding A y B se usa cuando necesitas un dato en memoria de una instruccion que debe de hacer uso del controlRegWrite
    que son las tipos R y algunas tipo I y J y obtenés el dato antes de escribir en memoria
    */
    wire [32-1:0] wire_o_dataAFromMux3ToALU;
    Mux3DataInputs#(32)
    u1_Mux3Frowarding1DataAToALU(
        .i_dataA(i_dataAToALUMux),
        .i_dataB(i_rdFromEtapa5Reg_MEM_WB),
        .i_dataC(i_rdFromEtapa4Reg_Ex_MEM),
        
        .i_controlMux(o_controlForwarding1),
        
        .o_data(wire_o_dataAFromMux3ToALU)
    );
    assign o_jumpRAddress=wire_o_dataBFromMux3ToALU;
    
    wire [32-1:0] u1_Mux3Frowarding2DataAToALU;
    Mux3DataInputs#(32)
    u1_Mux3Frowarding2DataBToALU(
        .i_dataA(i_dataBToALUMux),
        .i_dataB(i_rdFromEtapa5Reg_MEM_WB),
        .i_dataC(i_rdFromEtapa4Reg_Ex_MEM),
        
        .i_controlMux(o_controlForwarding2),
        
        .o_data(wire_o_dataBFromMux3ToALU)
    );
    
    /*este mux es para las instrucciones que tiene en alto el controlMemWrite que es la memoria de datos de la etapa 4
    y analizando las instrucciones damos que son las instruccione tipo save eg... sw
    */ 
    Mux3DataInputs#(32)
    u1_Mux3DataQueQuieroEscribirEnMemoriaDeDatos(
        .i_dataA(i_dataBFromRegisterMemory),
        .i_dataB(i_rdFromEtapa5Reg_MEM_WB),
        .i_dataC(i_rdFromEtapa4Reg_Ex_MEM),
        
        .i_controlMux(o_controlForwarding3),
        
        .o_data(o_dataQueQuieroEscribirEnMemoriaDeDatosToReg_EX_MEM)
    );
    
    E3_ForwardingUnit#()
    u1_E3_ForwardingUnit(
        .i_rs(i_instruction[15:11]),
        .i_rt(i_instruction[20:16]),
        
        .i_rdFromEtapa4RegEX_MEM(i_rdFromEtapa4Reg_EX_MEM),
        .i_rdFromEtapa5RegMEM_WB(i_rdFromEtapa5Reg_MEM_WB),
        
        .i_controlRegWriteFromEtapa4RegEX_MEM(i_controlRegWriteFromEtapa4RegEX_MEM),
        .i_controlRegWriteFromEtapa5RegMEM_WB(i_controlRegWriteFromEtapa5RegMEM_WB),
        
        .i_controlRegDst(i_controlRegDst),
        .i_controlMemWrite(i_controlMemWrite),
        
        
        .o_forwardA(o_controlForwarding1),
        .o_forwardB(o_controlForwarding2),
        .o_forwardC(o_controlForwarding3)
    );
    
    //####################fin de los muxes de forwarding!!!!##################
    wire wire_o_isZeroFromALU;
    wire [32-1:0] wire_o_ALUResultToEX_MEM;
    E3_ALU#(32,4)
    u1_ALU(
        .i_dataA(wire_o_dataAFromMux3ToALU),
        .i_dataB(wire_o_dataBFromMux3ToALU),
        .i_controlOperationCode(i_controlALUOperationCode),
        
        .o_ALUResult(wire_o_ALUResultToEX_MEM),
        .o_Zero(wire_o_isZeroFromALU)
    );
    
    wire[5-1:0] wire_o_dataToJALRMux;
    Mux#(5) 
    u1_MuxDst (
        .i_dataA(i_instruction[20:16]),//rt
        .i_dataB(i_instruction[15:11]),//rd
        .i_controlMux(i_controlRegDst),
        .o_data(wire_o_dataToJALRMux)
    );
    
    wire[5-1:0] wire_o_addressDeEscrituraRegisterMemory;
    Mux#(5) 
    u1_MuxJALR (
        .i_dataA(wire_o_dataToJALRMux),
        .i_dataB(5'b11111),
        .i_controlMux(i_controlIsJALR),
        .o_data(wire_o_addressDeEscrituraRegisterMemory)
    );
    
    
    
    
    
    
    //--------------------bloque para calcular el address de una nistruccion branch o BNEQ
    wire [18-1:0] wire_o_shiftedData;
    Shift2Unit#(16)
    u1_Shift2Unit(
        .i_data(i_instruction[15:0]),
        .o_shiftedData(wire_o_shiftedData)//si entra 16 bits sale en 18
    );
    
    
    wire [32-1:0] wire_o_extendedSignedData;
    ExtensorDeSigno#(18,32)
    u1_ExtensorDeSigno(
        .i_data(wire_o_shiftedData),
        .o_extendedSignedData(wire_o_extendedSignedData)
    );
    
    Sumador#(32)
    u1_Sumador(
        .i_dataA(i_pcMas4),
        .i_dataB(wire_o_extendedSignedData),
        .o_sumadorResult(o_branchAddress)
    );
    
    //-----------------------Fin del bloque para Branch o BNEQ----------------------
    
    E3_BranchControl#()
    u1_E3_BranchControl(
        .i_zeroBit(wire_o_isZeroFromALU),//viene de la alu que está en esta etapa (3)
        .i_isBNEQ(i_controlIsBNEQ),
        .i_isBranch(i_controlIsBranch),
        .o_controlBranchAddressMux(o_controlIsBranchControlUnit)
    );
    
    
    
endmodule
