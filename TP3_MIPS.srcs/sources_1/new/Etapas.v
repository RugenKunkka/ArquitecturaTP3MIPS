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
        parameter DAT_LEN           = `DAT_LEN   // Instruction Legth
    )(

        // Multiple Etapas
        input wire i_globalClock,
        input wire i_globalReset,
        input wire i_clockIgnore_fromDUToEtapas,

        // For Etapa 1 (Program Counter)
        output wire [INS_LEN-1:0]           o_pc_fromPcToDU, 

        // For Etapa 1 (Instructions Memory)
        input wire                          i_we_fromDUToInsMem,
        input wire [INSMEM_ADDR_LEN-1:0]    i_addr_fromDUToInsMem,
        input wire [INSMEM_DAT_LEN-1:0]     i_data_fromDUToInsMem, 
        input wire                          i_muxSel_fromDUToInsMemMux,

        // For Etapa 2 (Register File)
        input wire [REGFILE_ADDR_LEN-1:0]   i_addr_fromDUToRegFile, // Address to read from Register File
        output wire [REGFILE_LEN-1:0]       o_data_fromRegFileToDU, // Data read from Register File
        input wire                          i_muxSel_fromDUToRegFileMux,

        // For Etapa 4 (From Control Unit  to Debug Unit)
        output wire o_halt_fromCUToDU,
    
        // For Etapa 4 (Data Memory)
        input wire [DATMEM_ADDR_LEN-1:0]    i_addr_fromDUToDatMem, // Address to read from Data Memory
        output wire [DAT_LEN-1:0]           o_data_fromDatMemToDU, // Data read from Data memory
        input wire                          i_muxSel_fromDUToDatMemMux

    );

    wire w_muxSel_fromE2ToJumpAddrMux1;
    wire w_muxSel_fromE3ToJumpRAddrMux2;
    wire w_muxSel_fromE3ToBranchAddrMux3;

    wire [INSMEM_ADDR_LEN-1:0] w_addr_fromE2ToJumpAddrMux1;
    wire [INSMEM_ADDR_LEN-1:0] w_addr_fromE3ToJumpRAddrMux2;
    wire [INSMEM_ADDR_LEN-1:0] w_addr_fromE3ToBranchAddrMux3;

    wire [INS_LEN-1:0] w_pcMas4_fromE1ToE2;
    wire [INS_LEN-1:0] w_instruction_fromE1ToE2;

    Etapa1_InstructionFetch
    #(
        
    )
    u_Etapa1_InstructionFetch
    (
        // From/For Debug Unit
        .i_clockIgnore_fromDU       (i_clockIgnore_fromDU),
        .i_we_fromDUToInsMem        (i_we_fromDUToInsMem),
        .i_addr_fromDUToInsMem      (i_addr_fromDUToInsMem),
        .i_data_fromDUToInsMem      (i_data_fromDUToInsMem),
        .i_muxSel_fromDUToInsMemMux (i_muxSel_fromDUToInsMemMux),
        .o_pc_fromPcToDU            (o_pc_fromPcToDU), // Debug Unit need to read PC content.

        // For Control Branching
        .i_controlMux1JumpAddress   (w_muxSel_fromE2ToJumpAddrMux1), 
        .i_controlMux2JumpRAddress  (w_muxSel_fromE3ToJumpRAddrMux2), 
        .i_controlMux3BranchAddress (w_muxSel_fromE3ToBranchAddrMux3),

        // For Branch Instructions
        .i_dataPCJumpAddressToMux1      (w_addr_fromE2ToJumpAddrMux1), 
        .i_dataPCJumpAddressRToMux2     (w_addr_fromE3ToJumpRAddrMux2),
        .i_dataPCBranchAddressToMux3    (w_addr_fromE3ToBranchAddrMux3),
        
        // To  the next stage
        .o_pcMas4       (w_pcMas4_fromE1ToE2),
        .o_instruction  (w_instruction_fromE1ToE2),

        // Global
        .i_clock(i_globalClock),
        .i_reset(i_globalReset)
    );

    wire w_BNEQ_fromCUToE3;
    wire w_Branch_fromCUToE3;
    wire w_JALR_fromCUToE3;

    wire w_RegWrite_fromCUToE3;
    wire w_MemWrite_fromCUToE3;
    wire w_MemtoReg_fromCUToE3;
    wire w_RegDst_fromCUToE3;
    wire [3-1:0] w_whbLS_fromCUToE3;
    wire w_signedLoad_fromCUToE3;

    wire w_halt_fromCUToE3;
    wire [4-1:0] w_ALUOp_fromCUToE3;

    wire [INSMEM_ADDR_LEN-1:0]  w_pcMas4_fromE2ToE3;

    wire [INS_LEN-1:0] w_instruction_fromE2ToE3;  

    wire w_MemRead_fromCUToE3;

    wire [REGFILE_LEN-1:0]  w_ReadData1_fromRegFileToE3;
    wire [REGFILE_LEN-1:0]  w_ReadData2OrSignExtOut_fromMuxToE3;
    wire [REGFILE_LEN-1:0]  w_ReadData2_fromRegFileToE3;

    wire [REGFILE_ADDR_LEN-1:0] w_rdToWrite_fromE5ToRegFile;
    wire [REGFILE_LEN-1:0]      w_dataToWrite_fromE5ToRegFile;
    wire                        w_RegWrite_fromE5ToRegFile;

    Etapa2_InstructionDecode
    #(

    )
    u_Etapa2_InstructionDecode
    (
        // From/For Debug Unit
        .i_addr_fromDUToRegFile     (i_addr_fromDUToRegFile),
        .o_data_fromRegFileToDU     (o_data_fromRegFileToDU),
        .i_muxSel_fromDUToRegFileMux (i_muxSel_fromDUToRegFileMux),

        .o_controlJump      (w_muxSel_fromE2ToJumpAddrMux1),
        .o_BNEQ_fromCUToE3  (w_BNEQ_fromCUToE3),
        .o_controlBranch    (w_Branch_fromCUToE3),
        .o_controlIsJALR    (w_JALR_fromCUToE3), 
        .o_incoditionalJumpAddress  (w_addr_fromE2ToJumpAddrMux1),

        .o_controlRegWrite  (w_RegWrite_fromCUToE3),
        .o_controlMemWrite  (w_MemWrite_fromCUToE3),
        .o_controlMemtoReg  (w_MemtoReg_fromCUToE3),
        .o_controlRegDst    (w_RegDst_fromCUToE3),
        .o_whbLS_fromCUToE3 (w_whbLS_fromCUToE3),
        .o_signedLoad_fromCUToE3(w_signedLoad_fromCUToE3),

        .o_halt_fromCUToE3  (w_halt_fromCUToE3),
        .o_controlALUOp     (w_ALUOp_fromCUToE3),

        .i_pcMas4(w_pcMas4_fromE1ToE2),
        .o_pcMas4(w_pcMas4_fromE2ToE3),

        .i_instruction(w_instruction_fromE1ToE2),
        .o_instruction(w_instruction_fromE2ToE3),

        .o_controlMemRead   (w_MemRead_fromCUToE3),

        .o_dataA        (w_ReadData1_fromRegFileToE3),
        .o_dataBFromMux (w_ReadData2OrSignExtOut_fromMuxToE3),
        .o_ReadData2    (w_ReadData2_fromRegFileToE3),
    
        // From E5
        .i_addressEscrituraToRegisterMemory (w_rdToWrite_fromE5ToRegFile),
        .i_datoAEscribirToRegisterMemory    (w_dataToWrite_fromE5ToRegFile),
        .i_controlRegWriteToRegisterMemory  (w_RegWrite_fromE5ToRegFile),

        // Global
        .i_clock(i_globalClock),
        .i_reset(i_globalReset)
    );



    wire            w_RegWrite_fromCUToE4;
    wire            w_MemWrite_fromCUToE4;
    wire            w_MemtoReg_fromCUToE4;
    wire [3-1:0]    w_whbLS_fromCUToE4;
    wire            w_signedLoad_fromCUToE4;
    wire            w_halt_fromCUToE4;

    wire [INSMEM_ADDR_LEN-1:0] w_pcMas4_fromE3ToE4;

    wire [DATMEM_ADDR_LEN-1:0] w_ALUResult_fromALUToE4;
    wire [DAT_LEN-1:0]          w_data_fromE3ToDatMem;
    wire [REGFILE_ADDR_LEN-1:0] w_rdToWrite_fromE3ToE4; 

    wire [32-1:0] w_rd_fromE4ToFU; // RENOMBRAR. NO es RD
    wire [32-1:0] w_rd_fromE5ToFU; // RENOMBRAR. NO es RD
    wire w_RegWrite_fromE4ToFU;
    wire w_RegWrite_fromE5ToFU;

    Etapa3_Execution
    #(

    )
    u_Etapa3_Execution
    (
        // From E3 To E1
        .o_controlIsBranchControlUnit   (w_muxSel_fromE3ToBranchAddrMux3),
        .o_controlIsJumpR   (w_muxSel_fromE3ToJumpRAddrMux2),
        .o_branchAddress    (w_addr_fromE3ToBranchAddrMux3),
        .o_jumpRAddress     (w_addr_fromE3ToJumpRAddrMux2),

        .i_controlIsBNEQ    (w_BNEQ_fromCUToE3),
        .i_controlIsBranch  (w_Branch_fromCUToE3),
        .i_controlIsJumpR   (w_JALR_fromCUToE3),

        .i_controlRegWrite  (w_RegWrite_fromCUToE3),
        .o_controlRegWrite  (w_RegWrite_fromCUToE4),
        .i_controlMemWrite  (w_MemWrite_fromCUToE3),
        .o_controlMemWrite  (w_MemWrite_fromCUToE4),
        .i_controlMemtoReg  (w_MemtoReg_fromCUToE3),
        .o_controlMemtoReg  (w_MemtoReg_fromCUToE4),
        .i_whbLS_fromCUToE3 (w_whbLS_fromCUToE3),
        .o_whbLS_fromCUToE4 (w_whbLS_fromCUToE4),
        .i_signedLoad_fromCUToE3(w_signedLoad_fromCUToE3),
        .o_signedLoad_fromCUToE4(w_signedLoad_fromCUToE4),
        .i_halt_fromCU  (w_halt_fromCUToE3),
        .o_halt_fromCU  (w_halt_fromCUToE4),

        .i_controlRegDst(w_RegDst_fromCUToE3),
        .i_controlALUOperationCode(w_ALUOp_fromCUToE3),

        .i_pcMas4   (w_pcMas4_fromE2ToE3),
        .o_programCounterMas4   (w_pcMas4_fromE3ToE4),

        .i_dataAToALUMux(w_ReadData1_fromRegFileToE3),
        .i_dataBToALUMux(w_ReadData2OrSignExtOut_fromMuxToE3),
        .i_dataBFromRegisterMemory(w_ReadData2_fromRegFileToE3), 
        .i_instruction(w_instruction_fromE2ToE3),
  
        .o_ALUResult            (w_ALUResult_fromALUToE4),
        .o_dataQueQuieroEscribirEnMemoriaDeDatos (w_data_fromE3ToDatMem),
        .o_rdToWrite(w_rdToWrite_fromE3ToE4), // rd ?

        // Forwarding Unit Inputs
        .i_rdFromEtapa4Reg_Ex_MEM   (w_rd_fromE4ToFU),
        .i_rdFromEtapa5Reg_MEM_WB   (w_rd_fromE5ToFU),
        .i_controlRegWriteFromEtapa4RegEX_MEM(w_RegWrite_fromE4ToFU),
        .i_controlRegWriteFromEtapa5RegMEM_WB(w_RegWrite_fromE5ToFU),
    
        // Global
        .i_clock(i_globalClock),
        .i_reset(i_globalReset),
        
        .i_controlIsJALR()

    );

    wire w_RegWrite_fromCUToE5;

    wire [DAT_LEN-1:0] w_data_fromDatMemToE5; 

    wire [REGFILE_ADDR_LEN-1:0] w_rdToWrite_fromE4ToE5 ;
     


    Etapa4_MemoryAccess
    #(

    )
    u_Etapa4_MemoryAccess
    (
        // For/From Debug Unit
        .i_addr_fromDUToDatMem(i_addr_fromDUToDatMem), 
        .o_data_fromDatMemToDU(o_data_fromDatMemToDU), 
        .i_muxSel_fromDUToDatMemMux(i_muxSel_fromDUToDatMemMux),

        .i_RegWrite_fromCUToE4(w_RegWrite_fromCUToE4),
        .o_RegWrite_fromCUToE5(w_RegWrite_fromCUToE5),

        //.i_MemWrite_fromCUToE4(w_MemToReg_fromCUToE4),
        .i_MemToReg_fromCUToE4(w_MemToReg_fromCUToE4),
        //.i_PC4W_fromCUToE4(w_MemToReg_fromCUToE4),
        .i_whbLS_fromCUToE4(w_whbLS_fromCUToE4),
        .i_signedLoad_fromCU(w_signedLoad_fromCUToE4),

        .i_halt_fromCUToE4(w_halt_fromCUToE4),
        .o_halt_fromCUToDU(o_halt_fromCUToDU),

        .i_pcMas4_fromE3ToMuxPC4    (w_pcMas4_fromE3ToE4),
        .i_ALUResult_fromE3ToE4 (w_ALUResult_fromALUToE4),
        .i_data_fromE3ToDatMem      (w_data_fromE3ToDatMem), 
        
        .o_data_fromDatMemToE5(w_data_fromDatMemToE5), 

        .i_rdToWrite_fromE3ToE4(w_rdToWrite_fromE3ToE4), 
        .o_rdToWrite_fromE4ToE5(w_rdToWrite_fromE4ToE5),  

        // For Forwarding
        .o_RegWrite_fromE4ToFU(w_RegWrite_fromE4ToFU),
        .o_rd_fromE4ToFU(w_rd_fromE4ToFU),
        
        .i_clock(i_clock),
        .i_reset(i_reset)
    );

/*
    Etapa 5

    // From Etapa 5 To Etapa 2
    w_rdToWrite_fromE5ToRegFile
    w_dataToWrite_fromE5ToRegFile
    w_RegWrite_fromE5ToRegFile

    // From Etapa 5 To Etapa 3
    w_rd_fromE5ToFU
    w_RegWrite_fromE5ToFU

    // Falta 3 wires de etapa 3    

*/



endmodule
