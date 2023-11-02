`include "Macros.v"

module Targets
    #(
        // For Instructions Memory
        parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN,   // Instruction Address Length
        parameter INSMEM_DAT_LEN     = `INSMEM_DAT_LEN,   // Instruction Legth
        parameter INS_LEN           = `INS_LEN,

        // For Register File
        parameter REGFILE_ADDR_LEN  = `REGFILE_ADDR_LEN, // Register File Address Lenght
        parameter REGFILE_LEN       = `REGFILE_LEN, // Register File Lenght

        // For Data Memory
        parameter DATMEM_ADDR_LEN   = `DATMEM_ADDR_LEN,   // Data Address Length
        parameter DAT_LEN           = `DAT_LEN   // Instruction Legth
    )
    (
        // Global
        input wire i_globalClock,
        input wire i_globalReset,
    
        // For Program Counter
        output wire [INS_LEN-1:0]           o_pc_fromPcToDU, 

        // For Instructions Memory
        input wire                          i_we_fromDUToInsMem,
        input wire [INSMEM_ADDR_LEN-1:0]    i_addr_fromDUToInsMem,
        input wire [INSMEM_DAT_LEN-1:0]     i_data_fromDUToInsMem, 
        input wire                          i_muxSel_fromDUToInsMemMux,

        // For Register File
        input wire [REGFILE_ADDR_LEN-1:0]   i_addr_fromDUToRegFile, // Address to read from Register File
        output wire [REGFILE_LEN-1:0]       o_data_fromRegFileToDU, // Data read from Register File
        input wire                          i_muxSel_fromDUToRegFileMux,

        // For Data Memory
        input wire [DATMEM_ADDR_LEN-1:0]    i_addr_fromDUToDatMem, // Address to read from Data Memory
        output wire [DAT_LEN-1:0]           o_data_fromDatMemToDU, // Data read from Data memory
        input wire                          i_muxSel_fromDUToDatMemMux,

        // Other IO Ports
        output wire o_halt_fromTargetToDU,
        input wire i_clockIgnore_fromDUToTarget
    );
    
    E1_PC
    #(
    )   
    u1_PC
    (
        .i_globalClock(i_globalClock),
        .i_globalReset(i_globalReset),

        //.i_pcAddressIn()
        .o_pcAddressOut(o_pc_fromPcToDU),

        .i_clockIgnore_fromDU(i_clockIgnore_fromDUToTarget)
    );

    wire [INSMEM_ADDR_LEN-1: 0] w_fromDUMuxToInsMem;
    Mux // Generic Mux
    #(
        .BUS_LEN(INSMEM_ADDR_LEN)
    )
    u_MuxForDUInsMem
    (
        //.i_bus0(),
        .i_bus1     (i_addr_fromDUToInsMem),
        .i_muxSel   (i_muxSel_fromDUToInsMemMux),
        .o_bus      (w_fromDUMuxToInsMem)
        
    );
    
    E1_InstructionMemory 
    #( 
    )
    u1_InstructionMemory 
    (
        .i_globalClock      (i_globalClock),
        .i_globalReset      (i_globalReset),

        .i_address          (w_fromDUMuxToInsMem),
        //.o_instruction()

        .i_data_fromDU      (i_data_fromDUToInsMem),
        .i_writeEnable_fromDU(i_we_fromDUToInsMem),
        .i_clockIgnore_fromDU(i_clockIgnore_fromDUToTarget)
    );


    wire [REGFILE_ADDR_LEN-1:0] w_fromDUMuxToRegFile;
    Mux // Generic Mux
    #(
        .BUS_LEN(REGFILE_ADDR_LEN)
    )
    u_MuxForDURegFile
    (
        //.i_bus0(),
        .i_bus1     (i_addr_fromDUToRegFile),
        .i_muxSel   (i_muxSel_fromDUToRegFileMux),
        .o_bus      (w_fromDUMuxToRegFile)        
    );
    
    E2_RegisterMemory
    #(
        
    )
    u_RegisterMemory
    (
        .i_globalClock      (i_globalClock),
        .i_globalReset      (i_globalReset),

        .i_AddressLecturaA  (w_fromDUMuxToRegFile),

        .o_dataA            (o_data_fromRegFileToDU),
        .i_clockIgnore_fromDU(i_clockIgnore_fromDUToTarget)
    );


    wire [DATMEM_ADDR_LEN-1:0] w_fromDUMuxToDatMem;
    Mux // Generic Mux
    #(
        .BUS_LEN(DATMEM_ADDR_LEN)
    )
    u_MuxForDUDatMem
    (
        //.i_bus0(),
        .i_bus1     (i_addr_fromDUToDatMem),
        .i_muxSel   (i_muxSel_fromDUToDatMemMux),
        .o_bus      (w_fromDUMuxToDatMem)        
    );

    E4_DataMemory
    #(
    )
    u_DataMemory
    (
        .i_globalClock      (i_globalClock),
        .i_globalReset      (i_globalReset),

        .i_address          (w_fromDUMuxToDatMem),
        //.i_data(),

        .o_data             (o_data_fromDatMemToDU),
        .i_clockIgnore_fromDU(i_clockIgnore_fromDUToTarget)

    );
    

    
endmodule
