`include "Macros.v"

module Etapa2_InstructionDecode
    #(
        // For Instruction Memory
        parameter INS_LEN = `INS_LEN,
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN,

        // For Register File
        parameter REGFILE_DEPTH =  `REGFILE_DEPTH,
        parameter REGFILE_ADDR_LEN =  `REGFILE_ADDR_LEN,
        parameter REGFILE_LEN =  `REGFILE_LEN
    )
    (
        // Control Signals To The Next Stage
        output wire         o_controlBNEQ,       
        output wire         o_controlBranch,     
        output wire         o_controlJumpR,      
        output wire         o_controlRegWrite,   
        output wire         o_controlMemWrite,   
        output wire         o_controlMemRead,    
        output wire         o_controlMemtoReg,   
        output wire         o_controlRegDst,     
        output wire         o_controlPC4WB,      
        output wire         o_controlGpr31,      
        output wire [3-1:0] o_controlWHBLS,      
        output wire         o_controlSignedLoad, 
        output wire         o_controlHalt,  
        output wire [6-1:0] o_controlALUOp,     
             

        // Data to the next stage
        output wire [REGFILE_LEN-1:0] o_dataA,
        output wire [REGFILE_LEN-1:0] o_dataBFromMux,
        output wire [REGFILE_LEN-1:0] o_ReadData2,

        // For J, JAL (From E2 To E1)
        output wire [INSMEM_ADDR_LEN-1:0]   o_incoditionalJumpAddress,
        output wire                         o_controlJump,  

        // Directly between stages
        input  wire [INSMEM_ADDR_LEN-1:0]   i_pcMas4,
        output wire [INSMEM_ADDR_LEN-1:0]   o_pcMas4, 
        input wire [INS_LEN-1:0]            i_instruction,
        output wire [INS_LEN-1:0]           o_instruction,
        
        // From E5 To E2
        input wire                      i_controlRegWriteToRegisterMemory,
        input wire [REGFILE_DEPTH-1:0]  i_datoAEscribirToRegisterMemory,
        input wire [REGFILE_ADDR_LEN-1:0] i_addressEscrituraToRegisterMemory, 

        //For Hazard Unit
        output wire                         o_stallPC_fromHUToE1,
        output wire                         o_stallIFID_fromHUToE1,
        output wire                         o_flushEXMEM_fromHUToE3,
        input wire                          i_MemToReg_fromE4ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rs_fromE3ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rt_fromE3ToHU,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rd_fromE4ToHU,
        input wire                          i_RegDst_fromE3ToHU,
        
        //For/From Debug Unit
        input wire [REGFILE_ADDR_LEN-1:0]   i_addr_fromDUToRegFile,
        output wire [REGFILE_LEN-1:0]       o_data_fromRegFileToDU, 
        input wire                          i_muxSel_fromDUToRegFileMux,
        input wire                          i_clockIgnore_fromDUToLatch,
        input wire                          i_clockIgnore_fromDUToRegFile,

        input wire i_clock,
        input wire i_reset        
    );
    
    wire            o_wire_controlRegDst;
    wire            o_wire_controlJump;
    wire            o_wire_controlBranch;
    wire            o_wire_controlMemRead;
    wire            o_wire_controlMemtoReg;
    wire [6-1:0]    o_wire_controlALUOp;//este no se si lo vamos a sacar afuera
    wire            o_wire_controlMemWrite;
    wire            o_wire_controlALUSrc;
    wire            o_wire_controlRegWrite;
    wire            o_wire_controlHalt;
    wire            o_wire_isSLL_SRL_SRA;
    wire [3-1:0]    o_wire_control_whbLS ;
    wire            o_wire_controlBNEQ;
    wire            o_wire_controlIsJumpTipoR;
    
    wire w_reset_fromHUToCU;
    
    E2_ControlUnit
    #(
    )
    u_ControlUnit
    (
        .i_operationCode    (i_instruction[31:26]),
        .i_bits20_16        (i_instruction[20:15]),
        .i_bits10_6         (i_instruction[11:6]), 
        .i_bits20_6         (i_instruction[20:6]),
        .i_functionCode     (i_instruction[5:0]),

        .o_controlIsBNEQ        (o_wire_controlBNEQ),
        .o_controlIsBranch      (o_wire_controlBranch),
        .o_controlIsJumpTipoR   (o_wire_controlIsJumpTipoR),
        .o_controlIsJump        (o_controlJump),
        .o_controlRegWrite      (o_wire_controlRegWrite),
        .o_controlMemWrite      (o_wire_controlMemWrite),
        .o_controlMemRead       (o_wire_controlMemRead),
        .o_controlMemtoReg      (o_wire_controlMemtoReg),
        .o_controlRegDst        (o_wire_controlRegDst),
        .o_controlPC4WB         (o_wire_controlPC4WB),
        .o_controlGpr31         (o_wire_controlGpr31),    
        .o_controlWHBLS        (o_wire_control_whbLS),
        .o_controlSignedLoad    (o_wire_controlSignedLoad),
        .o_controlALUSrc        (o_wire_controlALUSrc),
        .o_controlHalt          (o_wire_controlHalt),
        .o_isSLL_SRL_SRA        (o_wire_isSLL_SRL_SRA),
        //.o_controlALUOp         (o_wire_controlALUOp),

        .i_resetForHazard       (w_reset_fromHUToCU),
        .i_reset(i_reset)
    );

    wire [REGFILE_ADDR_LEN-1:0] w_addr_fromMuxForDUToRegFile;

        E2_ControlUnitAluOP
    #(
        
    )
    u_E2_ControlUnitAluOP
    (
        .i_reset        (i_reset),
    
        .i_operationCode    (i_instruction[31:26]),
        .i_bits20_16        (i_instruction[20:15]),
        .i_bits10_6         (i_instruction[11:6]), 
        .i_bits20_6         (i_instruction[20:6]),
        .i_functionCode     (i_instruction[5:0]),
        
        .o_controlALUOp(o_wire_controlALUOp)
    );

    GenericMux2to1 
    #(
        .LEN(REGFILE_ADDR_LEN)
    ) 
    u1_MuxForDU 
    (
        .i_bus0 (i_instruction[25:21]),
        .i_bus1 (i_addr_fromDUToRegFile),
        .i_muxSel(i_muxSel_fromDUToRegFileMux),
        .o_bus  (w_addr_fromMuxForDUToRegFile)
    );
      
    wire [32-1:0] wire_o_dataBFromRegisterMemoryToMuxALU;
    wire [REGFILE_LEN-1:0] w_dataA;
    //wire o_wire_dataA
    E2_RegisterMemory
    #(
        .REGFILE_LEN        (REGFILE_LEN),
        .REGFILE_DEPTH      (REGFILE_DEPTH),
        .REGFILE_ADDR_LEN   (REGFILE_ADDR_LEN)
    )
    u_RegisterMemory
    (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_clockIgnore_fromDU (i_clockIgnore_fromDUToRegFile),  

        .i_RegWrite_fromControl(i_controlRegWriteToRegisterMemory),
        
        .i_AddressLecturaA  (w_addr_fromMuxForDUToRegFile),
        .i_AddressLecturaB  (i_instruction[20:16]),
        .i_AddressEscritura (i_addressEscrituraToRegisterMemory),
        .i_DatoAEscribir    (i_datoAEscribirToRegisterMemory),
        
        .o_dataA    (w_dataA),
        .o_dataB    (wire_o_dataBFromRegisterMemoryToMuxALU)
    );
    
    wire [32-1:0] wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB;

    GenericZeroExtender
    #(
        .ZEXT_IN_LEN(16),
        .ZEXT_OUT_LEN(32)
    )
    u1_ExtensorDePalabra
    (
        .i_data(i_instruction[16-1:0]),//esto es para operaciones distintos del tipo R xq tiene el campo inmediato ahi... 
        .o_extendedData(wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB)
    );
    
    wire [32-1:0] wire_o_dataMuxAluSrc;
    wire  [32-1:0] w_dataBFromMux;
    wire  [32-1:0] w_dataAFromMux;
    wire  [32-1:0] w_o_ExtendedSLLFromExtensorPalabraToMuxAluInputA;
    
    GenericZeroExtender
    #(
        .ZEXT_IN_LEN(5),
        .ZEXT_OUT_LEN(32)
    )
    u1_ExtensorDePalabraSLL
    (
        .i_data(i_instruction[10:6]),//esto es para operaciones distintos del tipo R xq tiene el campo inmediato ahi... 
        .o_extendedData(w_o_ExtendedSLLFromExtensorPalabraToMuxAluInputA)
    );
    
    GenericMux2to1 
    #(
        .LEN(32)
    ) 
    u1_MuxAluInputA 
    (
        .i_bus0 (w_dataA),
        .i_bus1 (w_o_ExtendedSLLFromExtensorPalabraToMuxAluInputA),
        .i_muxSel(o_wire_isSLL_SRL_SRA),
        .o_bus  (w_dataAFromMux)
    );

    GenericMux2to1 
    #(
        .LEN(32)
    ) 
    u1_MuxAluInputB 
    (
        .i_bus0 (wire_o_dataBFromRegisterMemoryToMuxALU),
        .i_bus1 (wire_o_extendedDataFromExtensorDePalabraToMuxAluInputB),
        .i_muxSel(o_wire_controlALUSrc),
        .o_bus  (w_dataBFromMux)
    );
    
    wire [28-1:0] wire_shiftedInconditionalJumpAddress;

    GenericShifter
    #(
        .IN_LEN(26),
        .OUT_LEN(28),
        .NUM_TO_SHIFT(2)
    )
    u1_Shift2Unit
    (
        .i_data(i_instruction[25:0]),
        .o_shiftedData(wire_shiftedInconditionalJumpAddress)
    );
    
    GenericSignExtender
    #(
        .SIGNEXT_IN_LEN(28),
        .SIGNEXT_OUT_LEN(32)
    )
    u1_ExtensorDeSigno
    (
        .i_data(wire_shiftedInconditionalJumpAddress),
        .o_extendedSignedData(o_incoditionalJumpAddress)
    );
    
    wire w_stallIDEX_fromHUToE2;
    
    //es de la hazzard
    wire o_wire_PostBloqueo1FromRegIdExToHU;
    wire o_wire_PostBloqueo1FromHUToRegIdEx;

    E2_Reg_ID_EX
    #(

    )
    u_Reg_ID_EX
    (
        .i_controlBNEQ      (o_wire_controlBNEQ),
        .i_controlBranch    (o_wire_controlBranch),
        .i_controlJumpR     (o_wire_controlIsJumpTipoR),
        .i_controlRegWrite  (o_wire_controlRegWrite),
        .i_controlMemWrite  (o_wire_controlMemWrite),
        .i_controlMemRead   (o_wire_controlMemRead),
        .i_controlMemtoReg  (o_wire_controlMemtoReg),
        .i_controlRegDst    (o_wire_controlRegDst),
        .i_controlPC4WB     (o_wire_controlPC4WB),
        .i_controlGpr31     (o_wire_controlGpr31),
        .i_controlWHBLS     (o_wire_control_whbLS),
        .i_controlSignedLoad(o_wire_controlSignedLoad),
        .i_controlHalt      (o_wire_controlHalt),
        .i_controlALUOp     (o_wire_controlALUOp),

        .i_pcMas4       (i_pcMas4),
        .i_dataA        (w_dataAFromMux),
        .i_dataBFromMux (w_dataBFromMux),
        .i_ReadData2    (wire_o_dataBFromRegisterMemoryToMuxALU),
        .i_instruction  (i_instruction),
        .i_post_bloqueo_1 (o_wire_PostBloqueo1FromHUToRegIdEx),

        .o_controlBNEQ      (o_controlBNEQ),
        .o_controlBranch    (o_controlBranch),
        .o_controlJumpR     (o_controlJumpR),
        .o_controlRegWrite  (o_controlRegWrite),
        .o_controlMemWrite  (o_controlMemWrite),
        .o_controlMemRead   (o_controlMemRead),
        .o_controlMemtoReg  (o_controlMemtoReg),
        .o_controlRegDst    (o_controlRegDst),
        .o_controlPC4WB     (o_controlPC4WB),
        .o_controlGpr31     (o_controlGpr31),
        .o_controlWHBLS     (o_controlWHBLS),
        .o_controlSignedLoad(o_controlSignedLoad),
        .o_controlHalt      (o_controlHalt),
        .o_controlALUOp     (o_controlALUOp),
        .o_post_bloqueo_1  (o_wire_PostBloqueo1FromRegIdExToHU),

        .o_pcMas4       (o_pcMas4),
        .o_dataA        (o_dataA),
        .o_dataBFromMux (o_dataBFromMux),
        .o_ReadData2    (o_ReadData2),
        .o_instruction  (o_instruction),
                
        // From Hazard Detection Unit        
        .i_stall_fromHU (w_stallIDEX_fromHUToE2),

        // Form Debug Unit
        .i_clockIgnore_fromDU (i_clockIgnore_fromDUToLatch),

        .i_clock(i_clock),
        .i_reset(i_reset)

    );  
    
    wire w_stallPC_fromHUToE1;
    wire w_stallIFID_fromHUToE1;
    
    E2_HazardUnit
    #(

    )
    u_HazardUnit
    (
        .o_stallPC_fromHUToE1   (o_stallPC_fromHUToE1),
        .o_stallIFID_fromHUToE1 (o_stallIFID_fromHUToE1),
        .o_stallIDEX_fromHUToE2 (w_stallIDEX_fromHUToE2),
        .o_reset_fromHUToCU     (w_reset_fromHUToCU),
        .o_flushEXMEM_fromHUToE3(o_flushEXMEM_fromHUToE3),
        .o_post_bloqueo_1       (o_wire_PostBloqueo1FromHUToRegIdEx),
    
        .i_takeJumpR_fromE2ToHU (o_wire_controlIsJumpTipoR),  
        .i_controlBranch_fromE2ToHU(o_wire_controlBranch),
    
        .i_MemToReg_fromE4ToHU  (i_MemToReg_fromE4ToHU),
        .i_rs_fromE3ToHU        (i_rs_fromE3ToHU),
        .i_rt_fromE3ToHU        (i_rt_fromE3ToHU),
        .i_rd_fromE4ToHU        (i_rd_fromE4ToHU),
        .i_RegDst_fromE3ToHU    (i_RegDst_fromE3ToHU),
        .i_controlIsJump        (o_controlJump),
        
        .i_post_bloqueo_1       (o_wire_PostBloqueo1FromRegIdExToHU),
        
        .i_reset(i_reset)
    );
    assign o_data_fromRegFileToDU = w_dataA;
    
endmodule
