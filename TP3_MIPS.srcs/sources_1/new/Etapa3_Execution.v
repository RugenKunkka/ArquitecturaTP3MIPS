`include "Macros.v"

module Etapa3_Execution
    #(
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN
    )   
    (
        /*
            Direct Connection between stages
        */
        input wire [INSMEM_ADDR_LEN-1:0] i_pcMas4,
        output wire [INSMEM_ADDR_LEN-1:0] o_programCounterMas4,

        input wire i_controlMemWrite,
        output wire o_controlMemWrite,

        input wire i_halt_fromCU,
        output wire o_halt_fromCU,

        input wire [3-1:0] i_whbLS_fromCUToE3,
        output wire [3-1:0] o_whbLS_fromCUToE4,

        input wire i_controlMemtoReg,
        output wire o_controlMemtoReg,

        input wire i_controlRegWrite,
        output wire o_controlRegWrite,

        input wire  i_signedLoad_fromCUToE3,
        output wire  o_signedLoad_fromCUToE4,

        // Input For Each Mux
        input wire [32-1:0] i_dataAToALUMux,
        input wire [32-1:0] i_dataBToALUMux,
        input wire [32-1:0] i_dataBFromRegisterMemory,

        // Common for 3 Muxes 3To1
        input wire [32-1:0] i_rdFromEtapa5Reg_MEM_WB, // RENOMBRAR !! No son rd
        input wire [32-1:0] i_rdFromEtapa4Reg_Ex_MEM, // RENOMBRAR !! No son rd

        // For ALU
        input wire [4-1:0] i_controlALUOperationCode,

        // For BranchControlUnit
        input wire i_controlIsBNEQ,
        input wire i_controlIsBranch,
        output wire o_controlIsBranchControlUnit,

        // For RegDest Mux
        input wire i_controlRegDst,
        input wire [32-1:0] i_instruction,
           
        input wire i_controlIsJALR, // GPR31?
  
        input wire i_controlIsJumpR, // TakeJumpR
        output wire o_controlIsJumpR, // TakeJumpR

        output wire  [32-1:0]   o_branchAddress,
        output wire [32-1:0]    o_jumpRAddress,

        output wire [32-1:0] o_ALUResult,
        output wire [32-1:0] o_dataQueQuieroEscribirEnMemoriaDeDatos,
        output wire [5-1:0] o_rdToWrite,

        // For Forwarding Unit
        input wire i_controlRegWriteFromEtapa4RegEX_MEM,
        input wire i_controlRegWriteFromEtapa5RegMEM_WB,

        input wire i_clock,
        input wire i_reset


        
    );

    wire [2-1:0] o_controlForwarding1;
    wire [32-1:0] wire_o_dataAFromMux3ToALU;

    GenericMux3to1_2bits
    #(
        .LEN(32)
    )
    u1_Mux3Frowarding1DataAToALU
    (
        .i_bus00   (i_dataAToALUMux),
        .i_bus01   (i_rdFromEtapa5Reg_MEM_WB),
        .i_bus10   (i_rdFromEtapa4Reg_Ex_MEM),
        .i_muxSel   (o_controlForwarding1),
        .o_bus     (wire_o_dataAFromMux3ToALU)
    );

    wire [2-1:0] o_controlForwarding2;
    wire [32-1:0] wire_o_dataBFromMux3ToALU;

    GenericMux3to1_2bits
    #(
        .LEN(32)
    )
    u1_Mux3Frowarding2DataBToALU
    (
        .i_bus00    (i_dataBToALUMux),
        .i_bus01    (i_rdFromEtapa5Reg_MEM_WB),
        .i_bus10    (i_rdFromEtapa4Reg_Ex_MEM),
        .i_muxSel   (o_controlForwarding2),
        .o_bus      (wire_o_dataBFromMux3ToALU)
    );

    wire [2-1:0] o_controlForwarding3;
    wire [32-1:0] o_dataQueQuieroEscribirEnMemoriaDeDatosToReg_EX_MEM;

    GenericMux3to1_2bits
    #(
        .LEN(32)
    )
    u1_Mux3DataQueQuieroEscribirEnMemoriaDeDatos
    (
        .i_bus00    (i_dataBFromRegisterMemory),
        .i_bus01    (i_rdFromEtapa5Reg_MEM_WB),
        .i_bus10    (i_rdFromEtapa4Reg_Ex_MEM),
        .i_muxSel   (o_controlForwarding3),
        .o_bus      (o_dataQueQuieroEscribirEnMemoriaDeDatosToReg_EX_MEM)
    );

    wire wire_o_isZeroFromALU;
    wire [32-1:0] wire_o_ALUResultToEX_MEM;

    E3_ALU
    #(
        .DATA_LENGTH(32),
        .OPERATORS_INPUT_SIZE(4)
    )
    u1_ALU
    (
        .i_dataA    (wire_o_dataAFromMux3ToALU),
        .i_dataB    (wire_o_dataBFromMux3ToALU),
        .i_controlOperationCode (i_controlALUOperationCode),
        .o_ALUResult    (wire_o_ALUResultToEX_MEM),
        .o_Zero     (wire_o_isZeroFromALU)
    );

    /*
        For Branching 
    */

    wire [18-1:0] wire_o_shiftedData;
    
    GenericShifter
    #(
        .IN_LEN(16),
        .OUT_LEN(18),
        .NUM_TO_SHIFT(2)
    )
    u1_Shift2Unit
    (
        .i_data(i_instruction[15:0]),
        .o_shiftedData(wire_o_shiftedData)
    );

    wire [32-1:0] wire_o_extendedSignedData;

    GenericSignExtender
    #(
        .SIGNEXT_IN_LEN(18),
        .SIGNEXT_OUT_LEN(32)
    )
    u1_ExtensorDeSigno
    (
        .i_data(wire_o_shiftedData),
        .o_extendedSignedData(wire_o_extendedSignedData)
    );

    GenericAdder
    #(
        .LEN(32)
    )
    u1_Sumador
    (
        .i_dataA    (i_pcMas4),
        .i_dataB    (wire_o_extendedSignedData),
        .o_result    (o_branchAddress) // NonRegister output
    );
    
    E3_BranchControl
    #(

    )
    u1_E3_BranchControl
    (
        .i_zeroBit  (wire_o_isZeroFromALU),
        .i_isBNEQ   (i_controlIsBNEQ),
        .i_isBranch (i_controlIsBranch),
        .o_controlBranchAddressMux  (o_controlIsBranchControlUnit) // NonRegister output
    );

    /*
        Muxes For RegDst and JALR
    */
    
    wire[5-1:0] wire_o_dataToJALRMux;

    GenericMux2to1
    #(
        .LEN(5)
    )  
    u1_MuxRegDst (
        .i_bus0(i_instruction[20:16]),//rt
        .i_bus1(i_instruction[15:11]),//rd
        .i_muxSel(i_controlRegDst),
        .o_bus(wire_o_dataToJALRMux)
    );
    
    wire[5-1:0] wire_o_addressDeEscrituraRegisterMemory;
    
    GenericMux2to1
    #(
        .LEN(5)
    ) 
    u1_MuxJALR // GPR31?
    (
        .i_bus0(wire_o_dataToJALRMux),
        .i_bus1(5'b11111),
        .i_muxSel(i_controlIsJALR),
        .o_bus(wire_o_addressDeEscrituraRegisterMemory)
    );

    E3_Reg_EX_MEM
    #(

    )
    u_Reg_EX_MEM
    (

        .i_clock(i_clock),
        .i_reset(i_reset),

        .i_PcMas4(i_pcMas4),
        .i_ALUResult(wire_o_ALUResultToEX_MEM),
        
        .i_dataQueQuieroEscribirEnMemoriaDeDatos(o_dataQueQuieroEscribirEnMemoriaDeDatosToReg_EX_MEM),
        .i_addressDeEscrituraRegisterMemory(wire_o_addressDeEscrituraRegisterMemory),

        .i_controlRegWrite(i_controlRegWrite),
        .i_controlMemWrite(i_controlMemWrite),
        .i_controlMemtoReg(i_controlMemtoReg),
        .o_controlRegWrite(o_controlRegWrite),
        .o_controlMemWrite(o_controlMemWrite),
        .o_controlMemtoReg(o_controlMemtoReg),
    
        .o_PcMas4(o_programCounterMas4),
        .o_ALUResult(o_ALUResult),

        .i_halt_fromCU(i_halt_fromCU),
        .o_halt_fromCU(o_halt_fromCU),
        
        .o_dataQueQuieroEscribirEnMemoriaDeDatos(o_dataQueQuieroEscribirEnMemoriaDeDatos),
        .o_addressDeEscrituraRegisterMemory(o_rdToWrite),

        .i_signedLoad_fromCUToE3 (i_signedLoad_fromCUToE3),
        .o_signedLoad_fromCUToE4 (o_signedLoad_fromCUToE4)
    );



    assign o_controlIsJumpR = i_controlIsJumpR;
    assign o_jumpRAddress = wire_o_dataAFromMux3ToALU;

    E3_ForwardingUnit
    #(

    )
    u1_E3_ForwardingUnit
    (
        .i_rs(i_instruction[15:11]),
        .i_rt(i_instruction[20:16]),
        
        //.i_rdFromEtapa5RegMEM_WB(i_rdFromEtapa5Reg_MEM_WB),
        //.i_rdFromEtapa4RegEX_MEM(i_rdFromEtapa4Reg_EX_MEM),
        .i_rdFromEtapa5RegMEM_WB(),
        .i_rdFromEtapa4RegEX_MEM(),
        
        .i_controlRegWriteFromEtapa4RegEX_MEM(i_controlRegWriteFromEtapa4RegEX_MEM),
        .i_controlRegWriteFromEtapa5RegMEM_WB(i_controlRegWriteFromEtapa5RegMEM_WB),
        
        .i_controlRegDst(i_controlRegDst),
        .i_controlMemWrite(i_controlMemWrite),
        
        .o_forwardA(o_controlForwarding1),
        .o_forwardB(o_controlForwarding2),
        .o_forwardC(o_controlForwarding3)
    );


    //------------------------------------multiplexores de forwarding------------------------------------
    /*son para poder hacer el bypass y obtener un dato que esta listo en la etapa 4 y lo puedo necesitar de la etapa 4 o 5  y es antes de quese escriba
    en la memoria de registro. Essto lo hago haciendo una predicci�n dentro de la forwardingUnit viendo si se necesita para el calculo (dentro de los registros
    base ya sea rso rt) un valor que no se guardo en memoria y eso lo hago comparando el contenido de rs o rt con el de rd en las etapas 4 y 5,
    si tienen la misma direccion / valor, quiere decir que necesito ese valor de manera anticipada
    */
    
    /*
    Los muxes de forwarding A y B se usa cuando necesitas un dato en memoria de una instruccion que debe de hacer uso del controlRegWrite
    que son las tipos R y algunas tipo I y J y obten�s el dato antes de escribir en memoria
    */
    
    //wire [32-1:0] u1_Mux3Frowarding2DataAToALU;
    
    /*este mux es para las instrucciones que tiene en alto el controlMemWrite que es la memoria de datos de la etapa 4
    y analizando las instrucciones damos que son las instruccione tipo save eg... sw
    */ 
   

endmodule
