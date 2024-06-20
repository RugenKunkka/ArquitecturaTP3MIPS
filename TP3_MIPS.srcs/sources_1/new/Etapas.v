`include "Macros.v"

module Etapas
    #(
        // For Etapa 1 (Instruction Memory)
        parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN,   // Instruction Address Length
        parameter INSMEM_DAT_LEN    = `INSMEM_DAT_LEN,   // Instruction Legth
        parameter INS_LEN           = `INS_LEN,
    
        // For Etapa 2 (Register File)
        parameter REGFILE_ADDR_LEN  = `REGFILE_ADDR_LEN, // Register File Address Lenght
        parameter REGFILE_LEN       = `REGFILE_LEN, // Register File Lenght
    
        // For Etapa 4 (Data Memory)
        parameter DATMEM_ADDR_LEN   = `DATMEM_ADDR_LEN,   // Data Address Length
        parameter DAT_LEN           = `DAT_LEN,   
        parameter WORD_LEN          = `WORD_LEN         
    )(

        // For Multiple Etapas
        input wire i_globalClock,
        input wire i_globalReset,
        input wire i_clockIgnore_fromDUToPcAndLatches,

        // For Etapa 1 (Program Counter)
        output wire [INS_LEN-1:0]           o_pc_fromE1ToDU, 

        // For Etapa 1 (Instructions Memory)
        input wire                          i_weForInsMem_fromDUToE1,
        input wire [INSMEM_ADDR_LEN-1:0]    i_addrForInsMem_fromDUToE1,
        input wire [INSMEM_DAT_LEN-1:0]     i_dataForInsMem_fromDUToE1, 
        input wire                          i_muxSelForInsMemMux_fromDUToE1,
        input wire                          i_clockIgnore_fromDUToInsMem,

        // For Etapa 2 (Register File)
        input wire [REGFILE_ADDR_LEN-1:0]   i_addrForRegFile_fromDUToE2, // Address to read from Register File
        output wire [REGFILE_LEN-1:0]       o_dataForRegFile_fromE2ToDU, // Data read from Register File
        input wire                          i_muxSelForRegFileMux_fromDUToE2,
        input wire                          i_clockIgnore_fromDUToRegFile,

        // For Etapa 4 (From Control Unit  to Debug Unit)
        output wire o_halt_fromE4ToDU,
    
        // For Etapa 4 (Data Memory)
        input wire [DATMEM_ADDR_LEN-1:0]    i_addrForDatMem_fromDUToE4, // Address to read from Data Memory
        output wire [DAT_LEN-1:0]           o_dataForDatMem_fromE4ToDU, // Data read from Data memory
        input wire                          i_muxSelForDatMemMux_fromDUToE4,
        input wire                          i_reForDatMem_fromDUToE4,
        input wire                          i_clockIgnore_fromDUToDatMem
    );

    wire w_muxSelForJumpMux_fromE2ToE1; // For J, JAL
    wire w_muxSelForJumpRMux_fromE3ToE1; // For JR, JALR
    wire w_muxSelForBranchMux_fromE3ToE1; // For BEQ, BNEQ

    wire [INSMEM_ADDR_LEN-1:0] w_addrForJumpMux_fromE2ToE1;  // For J, JAL
    wire [INSMEM_ADDR_LEN-1:0] w_addrForJumpRMux_fromE3ToE1; // For JR, JALR
    wire [INSMEM_ADDR_LEN-1:0] w_addrForBranchMux_fromE3ToE1; // For BEQ, BNEQ

    wire [INS_LEN-1:0] w_pcMas4_fromE1ToE2;
    wire [INS_LEN-1:0] w_instruction_fromE1ToE2;

    wire w_stallPC_fromE2ToE1; // Hazard Unit is in E2
    wire w_stallIFID_fromE2ToE1; // Hazard Unit is in E2

    Etapa1_InstructionFetch
    #(
        
    )
    u_Etapa1_InstructionFetch
    (
        // To  the next stage
        .o_pcMas4       (w_pcMas4_fromE1ToE2),
        .o_instruction  (w_instruction_fromE1ToE2),

        // For J, JAL, JR, JALR, BEQ, BNEQ
        .i_controlMux1JumpAddress   (w_muxSelForJumpMux_fromE2ToE1),  
        .i_controlMux2JumpRAddress  (w_muxSelForJumpRMux_fromE3ToE1),
        .i_controlMux3BranchAddress (w_muxSelForBranchMux_fromE3ToE1),
        .i_dataPCJumpAddressToMux1  (w_addrForJumpMux_fromE2ToE1), 
        .i_dataPCJumpAddressRToMux2 (w_addrForJumpRMux_fromE3ToE1),
        .i_dataPCBranchAddressToMux3(w_addrForBranchMux_fromE3ToE1),
        
        // From Hazard Unit
        .i_stallPC_fromHU   (w_stallPC_fromE2ToE1),
        .i_stallIFID_fromHU (w_stallIFID_fromE2ToE1),

        // From/For Debug Unit
        .i_we_fromDUToInsMem        (i_weForInsMem_fromDUToE1),
        .i_addr_fromDUToInsMem      (i_addrForInsMem_fromDUToE1),
        .i_data_fromDUToInsMem      (i_dataForInsMem_fromDUToE1),
        .i_muxSel_fromDUToInsMemMux (i_muxSelForInsMemMux_fromDUToE1),
        .o_pc_fromPcToDU            (o_pc_fromE1ToDU),
        .i_clockIgnore_fromDUToPcAndLatch   (i_clockIgnore_fromDUToPcAndLatches),
        .i_clockIgnore_fromDUToInsMem       (i_clockIgnore_fromDUToInsMem),

        // Global
        .i_clock(i_globalClock),
        .i_reset(i_globalReset)
    );

    // Control Signals For The Next Stage
    wire            w_BNEQ_fromE2ToE3;
    wire            w_Branch_fromE2ToE3;
    wire            w_JumpR_fromE2ToE3;
    wire            w_Jump_fromE2ToE3;
    wire            w_RegWrite_fromE2ToE3;
    wire            w_MemWrite_fromE2ToE3;
    wire            w_MemRead_fromE2ToE3;
    wire            w_MemtoReg_fromE2ToE3;
    wire            w_RegDst_fromE2ToE3;
    wire            w_pc4WB_fromE2ToE3;
    wire            w_Gpr31_fromE2ToE3;
    wire [3-1:0]    w_whbLS_fromE2ToE3;
    wire            w_signedLoad_fromE2ToE3;
    wire [6-1:0]    w_ALUOp_fromE2ToE3;
    wire            w_halt_fromE2ToE3;

    wire [REGFILE_LEN-1:0]  w_ReadData1_fromE2ToE3;
    wire [REGFILE_LEN-1:0]  w_ReadData2FromMux_fromE2ToE3;
    wire [REGFILE_LEN-1:0]  w_ReadData2_fromE2ToE3;

    wire [INSMEM_ADDR_LEN-1:0]  w_pcMas4_fromE2ToE3;
    wire [INS_LEN-1:0]          w_instruction_fromE2ToE3;  

    // From E5 To E2
    wire [REGFILE_ADDR_LEN-1:0] w_rdToWriteRegFile_fromE5ToE2;
    wire [REGFILE_LEN-1:0]      w_dataToWriteRegFile_fromE5ToE2;
    wire                        w_RegWrite_fromE5ToE2;

    // For Hazard Unit
    wire                        w_flushEXMEM_fromE2ToE4;
    wire                        w_MemToRegForHazard_fromE4ToE2; 
    wire [REGFILE_ADDR_LEN-1:0] w_rsForHazard_fromE3ToE2;       
    wire [REGFILE_ADDR_LEN-1:0] w_rtForHazard_fromE3ToE2;       
    wire [REGFILE_ADDR_LEN-1:0] w_rdForHazard_fromE4ToE2;       
    wire                        w_RegDstForHazard_fromE3ToE2;   

    Etapa2_InstructionDecode
    #(

    )
    u_Etapa2_InstructionDecode
    (
        .o_branchAddress        (w_addrForBranchMux_fromE3ToE1),
        .o_controlIsBranchControlUnit   (w_muxSelForBranchMux_fromE3ToE1),
        // Control Signals To The Next Stage
        .o_controlBNEQ          (w_BNEQ_fromE2ToE3),
        .o_controlBranch        (w_Branch_fromE2ToE3),
        .o_controlJumpR         (w_JumpR_fromE2ToE3),
        .o_controlRegWrite      (w_RegWrite_fromE2ToE3),
        .o_controlMemWrite      (w_MemWrite_fromE2ToE3),
        .o_controlMemRead       (w_MemRead_fromE2ToE3),
        .o_controlMemtoReg      (w_MemtoReg_fromE2ToE3),
        .o_controlRegDst        (w_RegDst_fromE2ToE3),
        .o_controlPC4WB         (w_pc4WB_fromE2ToE3),
        .o_controlGpr31         (w_Gpr31_fromE2ToE3),
        .o_controlWHBLS         (w_whbLS_fromE2ToE3), // Word Half Byte To Load-store
        .o_controlSignedLoad    (w_signedLoad_fromE2ToE3), // LW,LH,LB (Not LWU,LHU, LBU)
        .o_controlALUOp         (w_ALUOp_fromE2ToE3),
        .o_controlHalt          (w_halt_fromE2ToE3),

        // To the next stage
        .o_dataA        (w_ReadData1_fromE2ToE3),
        .o_dataBFromMux (w_ReadData2FromMux_fromE2ToE3),
        .o_ReadData2    (w_ReadData2_fromE2ToE3),

        // For J, JAL (From E2 To E1)
        .o_incoditionalJumpAddress  (w_addrForJumpMux_fromE2ToE1),
        .o_controlJump              (w_muxSelForJumpMux_fromE2ToE1),
        .o_controlIsJumpR           (w_muxSelForJumpRMux_fromE3ToE1),
        .o_jumpRAddress             (w_addrForJumpRMux_fromE3ToE1),
        // Directly between stages
        .i_pcMas4       (w_pcMas4_fromE1ToE2),
        .o_pcMas4       (w_pcMas4_fromE2ToE3),
        .i_instruction  (w_instruction_fromE1ToE2),
        .o_instruction  (w_instruction_fromE2ToE3),

        // From E5 To E2
        .i_controlRegWriteToRegisterMemory  (w_RegWrite_fromE5ToE2),
        .i_datoAEscribirToRegisterMemory    (w_dataToWriteRegFile_fromE5ToE2),
        .i_addressEscrituraToRegisterMemory (w_rdToWriteRegFile_fromE5ToE2),

        // For Hazard Unit (Hazard Unit is in E2)
        .o_stallPC_fromHUToE1       (w_stallPC_fromE2ToE1),
        .o_stallIFID_fromHUToE1     (w_stallIFID_fromE2ToE1),
        .o_flushEXMEM_fromHUToE3    (w_flushEXMEM_fromE2ToE3),
        .i_MemToReg_fromE4ToHU      (w_MemToRegForHazard_fromE4ToE2),
        .i_rs_fromE3ToHU            (w_rsForHazard_fromE3ToE2),
        .i_rt_fromE3ToHU            (w_rtForHazard_fromE3ToE2),
        .i_rd_fromE4ToHU            (w_rdForHazard_fromE4ToE2),
        .i_RegDst_fromE3ToHU        (w_RegDstForHazard_fromE3ToE2),
  
        // From/For Debug Unit
        .i_addr_fromDUToRegFile     (i_addrForRegFile_fromDUToE2),
        .o_data_fromRegFileToDU     (o_dataForRegFile_fromE2ToDU),
        .i_muxSel_fromDUToRegFileMux (i_muxSelForRegFileMux_fromDUToE2),
        .i_clockIgnore_fromDUToLatch    (i_clockIgnore_fromDUToPcAndLatches),
        .i_clockIgnore_fromDUToRegFile  (i_clockIgnore_fromDUToRegFile),

        // Global
        .i_clock(i_globalClock),
        .i_reset(i_globalReset)
    );

    wire            w_RegWrite_fromE3ToE4;
    wire            w_MemWrite_fromE3ToE4;
    wire            w_MemRead_fromE3ToE4;
    wire            w_MemtoReg_fromE3ToE4;
    wire            w_pc4WB_fromE3ToE4;
    wire [3-1:0]    w_whbLS_fromE3ToE4;
    wire            w_signedLoad_fromE3ToE4;
    wire            w_halt_fromE3ToE4;

    wire [INSMEM_ADDR_LEN-1:0]  w_pcMas4_fromE3ToE4;
    wire [DATMEM_ADDR_LEN-1:0]  w_ALUResult_fromE3ToE4;
    wire [DAT_LEN-1:0]          w_dataForDatMem_fromE3ToE4;
    wire [REGFILE_ADDR_LEN-1:0] w_rdToWrite_fromE3ToE4; 

    wire [REGFILE_ADDR_LEN-1:0] w_rdForFU_fromE4ToE3;
    wire                        w_RegWriteForFU_fromE4ToE3;
    wire [REGFILE_ADDR_LEN-1:0] w_rdForFU_fromE5ToE3;
    wire                        w_RegWriteForFU_fromE5ToE3;
    wire [WORD_LEN-1:0]         w_dataForwarded_fromE4ToE3;
    wire [WORD_LEN-1:0]         w_dataForwarded_fromE5ToE3;

    Etapa3_Execution
    #(

    )
    u_Etapa3_Execution
    (
        // Control Signal from Previous Stage
        .i_controlIsBNEQ        (w_BNEQ_fromE2ToE3),
        .i_controlIsBranch      (w_Branch_fromE2ToE3),
        .i_controlIsJumpR       (w_JumpR_fromE2ToE3),
        .i_controlRegWrite      (w_RegWrite_fromE2ToE3),
        .i_controlMemWrite      (w_MemWrite_fromE2ToE3),
        .i_controlMemRead       (w_MemRead_fromE2ToE3),
        .i_controlMemtoReg      (w_MemtoReg_fromE2ToE3),
        .i_controlRegDst        (w_RegDst_fromE2ToE3),
        .i_controlPC4WB         (w_pc4WB_fromE2ToE3),
        .i_controlGpr31         (w_Gpr31_fromE2ToE3),
        .i_controlWHBLS         (w_whbLS_fromE2ToE3),
        .i_controlSignedLoad    (w_signedLoad_fromE2ToE3),
        .i_controlALUOperationCode(w_ALUOp_fromE2ToE3),
        .i_controlHalt          (w_halt_fromE2ToE3),
        
        // Data from Previous Stage
        .i_pcMas4               (w_pcMas4_fromE2ToE3),
        .i_dataAToALUMux        (w_ReadData1_fromE2ToE3),
        .i_dataBToALUMux        (w_ReadData2FromMux_fromE2ToE3),
        .i_dataBFromRegisterMemory(w_ReadData2_fromE2ToE3), 
        .i_instruction          (w_instruction_fromE2ToE3),

        // Control Signals to the next stage
        .o_controlRegWrite  (w_RegWrite_fromE3ToE4),
        .o_controlMemWrite  (w_MemWrite_fromE3ToE4),
        .o_controlMemRead   (w_MemRead_fromE3ToE4),
        .o_controlMemtoReg  (w_MemtoReg_fromE3ToE4),
        .o_controlPC4WB     (w_pc4WB_fromE3ToE4),
        .o_controlWHBLS     (w_whbLS_fromE3ToE4),
        .o_controlSignedLoad(w_signedLoad_fromE3ToE4),
        .o_controlHalt      (w_halt_fromE3ToE4),

        // Data to the next stage
        .o_programCounterMas4   (w_pcMas4_fromE3ToE4),
        .o_ALUResult            (w_ALUResult_fromE3ToE4),
        .o_dataQueQuieroEscribirEnMemoriaDeDatos (w_dataForDatMem_fromE3ToE4),
        .o_rdToWrite            (w_rdToWrite_fromE3ToE4), 

        // From E3 To E1 , (For BEQ, BNEQ, JAR, JALR)
        //.o_controlIsBranchControlUnit   (w_muxSelForBranchMux_fromE3ToE1),
        //.o_controlIsJumpR               (w_muxSelForJumpRMux_fromE3ToE1),
        //.o_branchAddress                (w_addrForBranchMux_fromE3ToE1),
        //.o_jumpRAddress                 (w_addrForJumpRMux_fromE3ToE1),

        // For Forwarding
        .i_rd_fromE4ToFU            (w_rdForFU_fromE4ToE3),
        .i_RegWrite_fromE4ToFU      (w_RegWriteForFU_fromE4ToE3),
        .i_rd_fromE5ToFU            (w_rdForFU_fromE5ToE3),
        .i_RegWrite_fromE5ToFU      (w_RegWriteForFU_fromE5ToE3),
        .i_dataForwarded_fromE4ToE3 (w_dataForwarded_fromE4ToE3),
        .i_dataForwarded_fromE5ToE3 (w_dataForwarded_fromE5ToE3),

        // From/For Hazard Unit
        .o_rsForHazard_fromE3ToE2       (w_rsForHazard_fromE3ToE2),
        .o_rtForHazard_fromE3ToE2       (w_rtForHazard_fromE3ToE2),
        .o_RegDstForHazard_fromE3ToE2   (w_RegDstForHazard_fromE3ToE2),
        .i_flushEXMEM_fromHU            (w_flushEXMEM_fromE2ToE3),

        // From Debug Unit
        .i_clockIgnore_fromDUToLatch  (i_clockIgnore_fromDUToPcAndLatches),
    
        // Global
        .i_clock(i_globalClock),
        .i_reset(i_globalReset)
    );


    Etapa4_MemoryAccess
    #(

    )
    u_Etapa4_MemoryAccess
    (
        // Control Signals from Previous Stage
        .i_controlRegWrite  (w_RegWrite_fromE3ToE4),
        .i_controlMemWrite  (w_MemWrite_fromE3ToE4),
        .i_controlMemRead   (w_MemRead_fromE3ToE4),
        .i_controlMemToReg  (w_MemtoReg_fromE3ToE4),
        .i_controlPC4WB     (w_pc4WB_fromE3ToE4),
        .i_controlWHBLS     (w_whbLS_fromE3ToE4),
        .i_controlSignedLoad(w_signedLoad_fromE3ToE4),
        .i_controlHalt      (w_halt_fromE3ToE4),
        
        // Data from The Previous Stage
        .i_pcMas4_fromE3ToMuxPC4    (w_pcMas4_fromE3ToE4),
        .i_ALUResult_fromE3ToE4     (w_ALUResult_fromE3ToE4),
        .i_data_fromE3ToDatMem      (w_dataForDatMem_fromE3ToE4), 
        .i_rdToWrite_fromE3ToE4     (w_rdToWrite_fromE3ToE4), 

        // To the next stage (There is no E5, just wired back to E2)
        .o_RegWriteForWB_fromE4ToE5 (w_RegWrite_fromE5ToE2),
        .o_dataForWB_fromE4ToE5     (w_dataToWriteRegFile_fromE5ToE2), 
        .o_rdForWB_fromE4ToE5       (w_rdToWriteRegFile_fromE5ToE2),  

        // For Hazard Unit
        .o_MemToRegForHazard_fromE4ToE2 (w_MemToRegForHazard_fromE4ToE2),
        .o_rdForHazard_fromE4ToE2       (w_rdForHazard_fromE4ToE2),
        
        // For Forwarding
        .o_RegWrite_fromE4ToFU          (w_RegWriteForFU_fromE4ToE3),
        .o_rd_fromE4ToFU                (w_rdForFU_fromE4ToE3),
        .o_RegWrite_fromE5ToFU          (w_RegWriteForFU_fromE5ToE3),
        .o_rd_fromE5ToFU                (w_rdForFU_fromE5ToE3),
        .o_dataToForward_fromE4ToE3     (w_dataForwarded_fromE4ToE3),
        .o_dataToForward_fromE5ToE3     (w_dataForwarded_fromE5ToE3), 
        
        // For/From Debug Unit
        .o_halt_fromE4ToDU          (o_halt_fromE4ToDU),
        .i_addr_fromDUToDatMem      (i_addrForDatMem_fromDUToE4), 
        .o_data_fromDatMemToDU      (o_dataForDatMem_fromE4ToDU), 
        .i_muxSel_fromDUToDatMemMux (i_muxSelForDatMemMux_fromDUToE4),
        .i_re_fromDUToDatMem        (i_reForDatMem_fromDUToE4),
        .i_clockIgnore_fromDUToLatch    (i_clockIgnore_fromDUToPcAndLatches),
        .i_clockIgnore_fromDUToDatMem   (i_clockIgnore_fromDUToDatMem),
        
        .i_clock(i_globalClock),
        .i_reset(i_globalReset)
    );

/*
    Etapa 5

    No need
*/



endmodule
