`include "Macros.v"

module Etapa3_Execution
    #(
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN,
        parameter INS_LEN = `INS_LEN,

        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN,
        parameter REGFILE_LEN = `REGFILE_LEN,

        parameter ALU_LEN = `ALU_LEN,

        parameter WORD_LEN = `WORD_LEN,
        parameter DAT_LEN = `DAT_LEN
    )   
    (
        //Control Signal from Previous Stage
        input wire          i_controlIsBNEQ,        
        input wire          i_controlIsBranch,      
        input wire          i_controlIsJumpR,       
        input wire          i_controlRegWrite,      
        input wire          i_controlMemWrite,      
        input wire          i_controlMemRead,       
        input wire          i_controlMemtoReg,      
        input wire          i_controlRegDst,        
        input wire          i_controlPC4WB,         
        input wire          i_controlGpr31,         
        input wire [3-1:0]  i_controlWHBLS,         
        input wire          i_controlSignedLoad,    
        input wire [6-1:0]  i_controlALUOperationCode,
        input wire          i_controlHalt,          

        // Data from Previous Stage
        input wire [INSMEM_ADDR_LEN-1:0]i_pcMas4,
        input wire [ALU_LEN-1:0]        i_dataAToALUMux,
        input wire [ALU_LEN-1:0]        i_dataBToALUMux,
        input wire [REGFILE_LEN-1:0]    i_dataBFromRegisterMemory,
        input wire [INS_LEN-1:0]        i_instruction,
 
        // Control Signals to the next stage
        output wire         o_controlRegWrite,
        output wire         o_controlMemWrite,
        output wire         o_controlMemRead,
        output wire         o_controlMemtoReg,
        output wire         o_controlPC4WB,
        output wire [3-1:0] o_controlWHBLS,
        output wire         o_controlSignedLoad,
        output wire         o_controlHalt,

        // Data to the next stage
        output wire [INSMEM_ADDR_LEN-1:0]   o_programCounterMas4,
        output wire [ALU_LEN-1:0]           o_ALUResult,
        output wire [DAT_LEN-1:0]           o_dataQueQuieroEscribirEnMemoriaDeDatos,
        output wire [REGFILE_ADDR_LEN-1:0]  o_rdToWrite,

        // From E3 To E1 , (For BEQ, BNEQ, JAR, JALR)
        output wire                         o_controlIsBranchControlUnit,
        output wire                         o_controlIsJumpR,
        output wire [INSMEM_ADDR_LEN-1:0]   o_branchAddress,
        output wire [INSMEM_ADDR_LEN-1:0]   o_jumpRAddress,

        // For Forwarding
        input wire                          i_RegWrite_fromE4ToFU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rd_fromE4ToFU,
        input wire                          i_RegWrite_fromE5ToFU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rd_fromE5ToFU,
        input wire [WORD_LEN-1:0]           i_dataForwarded_fromE4ToE3,
        input wire [WORD_LEN-1:0]           i_dataForwarded_fromE5ToE3,
        
        // From/For Hazard Unit
        output wire [REGFILE_ADDR_LEN-1:0]  o_rsForHazard_fromE3ToE2,     
        output wire [REGFILE_ADDR_LEN-1:0]  o_rtForHazard_fromE3ToE2,     
        output wire                         o_RegDstForHazard_fromE3ToE2, 
        input wire                          i_flushEXMEM_fromHU,          

        // From Debug Unit
        input wire i_clockIgnore_fromDUToLatch,

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
        .i_bus01   (i_dataForwarded_fromE5ToE3),
        .i_bus10   (i_dataForwarded_fromE4ToE3),
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
        .i_bus01   (i_dataForwarded_fromE5ToE3),
        .i_bus10   (i_dataForwarded_fromE4ToE3),
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
        .i_bus01    (i_dataForwarded_fromE5ToE3),
        .i_bus10    (i_dataForwarded_fromE4ToE3),
        .i_muxSel   (o_controlForwarding3),
        .o_bus      (o_dataQueQuieroEscribirEnMemoriaDeDatosToReg_EX_MEM)
    );

    wire wire_o_isZeroFromALU;
    wire [32-1:0] wire_o_ALUResultToEX_MEM;

    E3_ALU
    #(
        .DATA_LENGTH(32),
        .OPERATORS_INPUT_SIZE(6)
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
        .i_muxSel(i_controlGpr31),
        .o_bus(wire_o_addressDeEscrituraRegisterMemory)
    );

    E3_Reg_EX_MEM
    #(

    )
    u_Reg_EX_MEM
    (
        .i_controlRegWrite  (i_controlRegWrite),
        .i_controlMemWrite  (i_controlMemWrite),
        .i_controlMemRead   (i_controlMemRead),
        .i_controlMemtoReg  (i_controlMemtoReg),
        .i_controlPC4WB     (i_controlPC4WB),
        .i_controlWHBLS     (i_controlWHBLS),
        .i_controlSignedLoad(i_controlSignedLoad),
        .i_controlHalt      (i_controlHalt),

        .i_PcMas4(i_pcMas4),
        .i_ALUResult(wire_o_ALUResultToEX_MEM),       
        .i_dataQueQuieroEscribirEnMemoriaDeDatos(o_dataQueQuieroEscribirEnMemoriaDeDatosToReg_EX_MEM),
        .i_addressDeEscrituraRegisterMemory(wire_o_addressDeEscrituraRegisterMemory),

        .o_controlRegWrite  (o_controlRegWrite),
        .o_controlMemWrite  (o_controlMemWrite),
        .o_controlMemRead   (o_controlMemRead),
        .o_controlMemtoReg  (o_controlMemtoReg),
        .o_controlPC4WB     (o_controlPC4WB),
        .o_controlWHBLS     (o_controlWHBLS),
        .o_controlSignedLoad(o_controlSignedLoad),
        .o_controlHalt      (o_controlHalt),
        
        .o_PcMas4(o_programCounterMas4),
        .o_ALUResult(o_ALUResult),
        .o_dataQueQuieroEscribirEnMemoriaDeDatos(o_dataQueQuieroEscribirEnMemoriaDeDatos),
        .o_addressDeEscrituraRegisterMemory(o_rdToWrite),

        // For Hazard Unit
        .i_flushEXMEM_fromHU    (i_flushEXMEM_fromHU),

        // For Debug Unit
        .i_clockIgnore_fromDU (i_clockIgnore_fromDUToLatch),  
        
        .i_clock(i_clock),
        .i_reset(i_reset)
    );

    assign o_controlIsJumpR = i_controlIsJumpR;
    assign o_jumpRAddress = wire_o_dataAFromMux3ToALU;

    E3_ForwardingUnit
    #(

    )
    u1_E3_ForwardingUnit
    (
        // Inputs from Etapa 3
        .i_rs_fromE3ToFU        (i_instruction[25:21]),
        .i_rt_fromE3ToFU        (i_instruction[20:16]),
        .i_MemWrite_fromE3ToFU  (i_controlMemWrite),
        .i_RegDst_fromE3ToFU    (i_controlRegDst),

        // Inputs from Etapa 4
        .i_RegWrite_fromE4ToFU  (i_RegWrite_fromE4ToFU),
        .i_rd_fromE4ToFU        (i_rd_fromE4ToFU),

        // Inputs from Etapa 5    
        .i_RegWrite_fromE5ToFU  (i_RegWrite_fromE5ToFU),
        .i_rd_fromE5ToFU        (i_rd_fromE5ToFU),

        .o_forwardA_muxSel  (o_controlForwarding1),
        .o_forwardB_muxSel  (o_controlForwarding2),
        .o_forwardC_muxSel  (o_controlForwarding3)
    );

    assign o_rsForHazard_fromE3ToE2 = i_instruction[15:11];
    assign o_rtForHazard_fromE3ToE2 = i_instruction[20:16];
    assign o_RegDstForHazard_fromE3ToE2 = i_controlRegDst;

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
