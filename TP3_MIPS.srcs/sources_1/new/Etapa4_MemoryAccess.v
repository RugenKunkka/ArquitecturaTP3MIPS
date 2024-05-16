`include "Macros.v"

module Etapa4_MemoryAccess
    #(
        /*
            Parameters
        */  
        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN, 
        
        parameter INSMEM_ADDR_LEN = `INSMEM_ADDR_LEN,

        parameter DAT_LEN = `DAT_LEN,
        parameter DATMEM_ADDR_LEN = `DATMEM_ADDR_LEN,
        parameter DATMEM_DEPTH = `DATMEM_DEPTH,
        parameter DAT_ENTRY_LEN = `DAT_ENTRY_LEN,
        
        parameter WORD_LEN = `WORD_LEN,
        parameter HALF_LEN = `HALF_LEN,
        parameter BYTE_LEN = `BYTE_LEN
    )
    (
        // Control Signals from Previous Stage
        input wire          i_controlRegWrite,
        input wire          i_controlMemWrite,
        input wire          i_controlMemRead,
        input wire          i_controlMemToReg,
        input wire          i_controlPC4WB,
        input wire [3-1:0]  i_controlWHBLS,
        input wire          i_controlSignedLoad,
        input wire          i_controlHalt,

        // Data from The Previous Stage
        input wire [INSMEM_ADDR_LEN-1:0]    i_pcMas4_fromE3ToMuxPC4,
        input wire [DATMEM_ADDR_LEN-1:0]    i_ALUResult_fromE3ToE4,
        input wire [DAT_LEN-1:0]            i_data_fromE3ToDatMem, 
        input wire [REGFILE_ADDR_LEN-1:0]   i_rdToWrite_fromE3ToE4,

        // To the next stage (There is no E5, just wired back to E2)
        output wire                         o_RegWriteForWB_fromE4ToE5, 
        output wire [DAT_LEN-1:0]           o_dataForWB_fromE4ToE5,     
        output wire [REGFILE_ADDR_LEN-1:0]  o_rdForWB_fromE4ToE5,       

        // For Hazard Unit
        output wire                         o_MemToRegForHazard_fromE4ToE2, 
        output wire [REGFILE_ADDR_LEN-1:0]  o_rdForHazard_fromE4ToE2,       

        // For Forwarding
        output wire                         o_RegWrite_fromE4ToFU,
        output wire [REGFILE_ADDR_LEN-1:0]  o_rd_fromE4ToFU,
        output wire                         o_RegWrite_fromE5ToFU,
        output wire [REGFILE_ADDR_LEN-1:0]  o_rd_fromE5ToFU,
        output wire [WORD_LEN-1:0]          o_dataToForward_fromE4ToE3,
        output wire [WORD_LEN-1:0]          o_dataToForward_fromE5ToE3,  

        // For/From Debug Unit
        input wire [DATMEM_ADDR_LEN-1:0]    i_addr_fromDUToDatMem, 
        output wire [DAT_LEN-1:0]           o_data_fromDatMemToDU, 
        input wire                          i_muxSel_fromDUToDatMemMux,
        input wire                          i_re_fromDUToDatMem,
        input wire                          i_clockIgnore_fromDU,
        output wire                         o_halt_fromE4ToDU,      

        input wire i_clock,
        input wire i_reset    
    );

    wire [DATMEM_ADDR_LEN-1:0] w_addr_fromDUMuxToDatMem;

    GenericMux2to1
    #(
        .LEN(DATMEM_ADDR_LEN)
    )  
    u1_MuxForDU
    (
        .i_bus0(i_ALUResult_fromE3ToE4),
        .i_bus1(i_addr_fromDUToDatMem),
        .i_muxSel(i_muxSel_fromDUToDatMemMux),
        .o_bus(w_addr_fromDUMuxToDatMem)
    );


    wire [WORD_LEN-1:0] w_dataWord_fromDatMemToMuxWHB;
    wire [HALF_LEN-1:0] w_dataHalf_fromDatMemToExtenders;
    wire [BYTE_LEN-1:0] w_dataByte_fromDatMemToExtenders;
    

    E4_DataMemory
    #(
        .DATMEM_DEPTH(DATMEM_DEPTH),
        .DATMEM_ADDR_LEN(DATMEM_ADDR_LEN),
        .DAT_LEN(DAT_LEN),
        .DAT_ENTRY_LEN(DAT_ENTRY_LEN)
    ) 
    u_DataMemory
    (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_clockIgnore_fromDU(i_clockIgnore_fromDU),

        .i_addr_forWordMode         (w_addr_fromDUMuxToDatMem),     
        .i_data_forWordMode         (i_data_fromE3ToDatMem),   
        .o_data_forWordMode         (w_dataWord_fromDatMemToMuxWHB),
        .i_writeEnable_forWordMode  (i_controlMemWrite),  
        .i_readEnable_forWordMode   (i_controlMemToReg | i_controlMemRead | i_re_fromDUToDatMem),       

        .i_addr_forHalfMode         (i_ALUResult_fromE3ToE4),     
        .i_data_forHalfMode         (i_data_fromE3ToDatMem[16-1:0]),   
        .o_data_forHalfMode         (w_dataHalf_fromDatMemToExtenders),
        .i_writeEnable_forHalfMode  (i_controlMemWrite),  
        .i_readEnable_forHalfMode   (i_controlMemRead),       
        
        .i_addr_forByteMode         (i_ALUResult_fromE3ToE4),     
        .i_data_forByteMode         (i_data_fromE3ToDatMem[8-1:0]),   
        .o_data_forByteMode         (w_dataByte_fromDatMemToExtenders),
        .i_writeEnable_forByteMode  (i_controlMemWrite),  
        .i_readEnable_forByteMode   (i_controlMemRead)
    );

    wire [DAT_LEN-1:0] w_extended_fromZeroExtHToMuxHalfSigned;
    wire [DAT_LEN-1:0] w_extended_fromSignExtHToMuxHalfSigned;
    
    GenericSignExtender
    #(
        .SIGNEXT_IN_LEN(HALF_LEN),
        .SIGNEXT_OUT_LEN(WORD_LEN)
    )
    u_SignExtForHalf
    (
        .i_data(w_dataHalf_fromDatMemToExtenders),
        .o_extendedSignedData(w_extended_fromSignExtHToMuxHalfSigned)
    );

    GenericZeroExtender
    #(
        .ZEXT_IN_LEN(HALF_LEN),
        .ZEXT_OUT_LEN(WORD_LEN)
    )
    u_ZeroExtForHalf
    (
        .i_data(w_dataHalf_fromDatMemToExtenders),
        .o_extendedData(w_extended_fromZeroExtHToMuxHalfSigned)
    );

    wire [WORD_LEN-1:0] w_extended_fromMuxHSigMuxWHB;

     GenericMux2to1
    #(
        .LEN(WORD_LEN)
    )
    u_MuxHalfSigned
    (
        .i_bus0     (w_extended_fromZeroExtHToMuxHalfSigned),
        .i_bus1     (w_extended_fromSignExtHToMuxHalfSigned),
        .i_muxSel   (i_controlSignedLoad),
        .o_bus      (w_extended_fromMuxHSigMuxWHB)
    );

    wire [DAT_LEN-1:0] w_extended_fromZeroExtBToMuxByteSigned;
    wire [DAT_LEN-1:0] w_extended_fromSignExtBToMuxByteSigned;

    GenericSignExtender
    #(
        .SIGNEXT_IN_LEN(BYTE_LEN),
        .SIGNEXT_OUT_LEN(WORD_LEN)
    )
    u_SignExtForByte
    (
        .i_data(w_dataByte_fromDatMemToExtenders),
        .o_extendedSignedData(w_extended_fromSignExtBToMuxByteSigned)
    );

    GenericZeroExtender
    #(
        .ZEXT_IN_LEN(BYTE_LEN),
        .ZEXT_OUT_LEN(WORD_LEN)
    )
    u_ZeroExtForByte
    (
        .i_data(w_dataByte_fromDatMemToExtenders),
        .o_extendedData(w_extended_fromZeroExtBToMuxByteSigned)
    );

    wire [DAT_LEN-1:0] w_extended_fromMuxBSigMuxWHB;    

     GenericMux2to1
    #(
        .LEN(WORD_LEN)
    )
    u_MuxForByteLoad
    (
        .i_bus0     (w_extended_fromZeroExtBToMuxByteSigned),
        .i_bus1     (w_extended_fromSignExtBToMuxByteSigned),
        .i_muxSel   (i_controlSignedLoad),
        .o_bus      (w_extended_fromMuxBSigMuxWHB)
    );

// One Mux For Sign Extension (For Signed Instruction) and Zero Extension (For Unsigned Instructions)

    wire [WORD_LEN-1:0] w_data_fromMuxWHBToMuxForMemtoReg;

    GenericMux3to1_3bits
    #(
        .LEN(WORD_LEN)
    )  
    u1_MuxWHB
    (
        .i_bus001(w_extended_fromMuxBSigMuxWHB),
        .i_bus010(w_extended_fromMuxHSigMuxWHB),
        .i_bus100(w_dataWord_fromDatMemToMuxWHB),
        .i_muxSel(i_controlWHBLS),
        .o_bus(w_data_fromMuxWHBToMuxForMemtoReg)

    );

    wire [DAT_LEN-1:0] w_data_fromMuxWHBToMuxPC4;

    GenericMux2to1
    #(
        .LEN(DAT_LEN)
    )
    MuxForMemtoReg
    (
        .i_bus0     (i_ALUResult_fromE3ToE4),
        .i_bus1     (w_data_fromMuxWHBToMuxForMemtoReg),
        .i_muxSel   (i_controlMemToReg),
        .o_bus      (w_data_fromMuxWHBToMuxPC4)
    );
    
    wire [WORD_LEN-1:0] w_data_fromMuxPC4ToE5;
    
    GenericMux2to1
    #(
        .LEN(DAT_LEN)
    )
    MuxForPCMas4
    (
        .i_bus1 (i_pcMas4_fromE3ToMuxPC4),
        .i_bus0 (w_data_fromMuxWHBToMuxPC4),
        .i_muxSel(i_controlPC4WB),
        .o_bus  (w_data_fromMuxPC4ToE5)
    );

    E4_Reg_MEM_WB
    #(

    )
    u_Reg_MEM_WB
    (
        .i_controlRegWrite      (i_controlRegWrite),
        .i_data_fromDatMemToE5  (w_data_fromMuxPC4ToE5),
        .i_rdToWrite_fromE3ToE4 (i_rdToWrite_fromE3ToE4), 

        // To the next stage
        .o_controlRegWrite      (o_RegWriteForWB_fromE4ToE5),
        .o_data_fromDatMemToE5  (o_dataForWB_fromE4ToE5), 
        .o_rdToWrite_fromE4ToE5 (o_rdForWB_fromE4ToE5),   

        // For Debug Unit
        .i_clockIgnore_fromDU(i_clockIgnore_fromDU),

        .i_clock(i_clock),
        .i_reset(i_reset)
    );

    // To Forward Unit
    assign o_RegWrite_fromE4ToFU    = i_controlRegWrite;
    assign o_rd_fromE4ToFU          = i_rdToWrite_fromE3ToE4;
    assign o_RegWrite_fromE5ToFU    = o_RegWriteForWB_fromE4ToE5;          
    assign o_rd_fromE5ToFU          = o_rdForWB_fromE4ToE5;                
    
    // To Forward
    assign o_dataToForward_fromE4ToE3 = i_ALUResult_fromE3ToE4;
    assign o_dataToForward_fromE5ToE3 = o_dataForWB_fromE4ToE5;
    
    // To Hazard Unit
    assign o_MemToRegForHazard_fromE4ToE2 = i_controlMemToReg; 
    assign o_rdForHazard_fromE4ToE2 = i_rdToWrite_fromE3ToE4; 

    // For Debug Unit
    assign o_data_fromDatMemToDU = w_dataWord_fromDatMemToMuxWHB;
    assign o_halt_fromE4ToDU = i_controlHalt;


endmodule