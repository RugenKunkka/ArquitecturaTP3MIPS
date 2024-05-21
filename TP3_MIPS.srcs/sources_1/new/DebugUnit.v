`include "Macros.v"

module DebugUnit
    #(
        // For UART
        parameter UART_DATA_LEN  = `UART_DATA_LEN,

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

        // For Uart
        input wire i_rx_fromTopToDU,
        output wire o_tx_fromDUToTop,
    
        // For Program Counter
        input wire [INS_LEN-1:0]    i_pc_fromPcToDU, 
        output wire                 o_clockIgnore_fromDUToPcAndLatches,

        // For Instructions Memory
        output wire                         o_we_fromDUToInsMem,
        output wire [INSMEM_ADDR_LEN-1:0]   o_addr_fromDUToInsMem,
        output wire [INSMEM_DAT_LEN-1:0]    o_data_fromDUToInsMem, 
        output wire                         o_muxSel_fromDUToInsMemMux,
        output wire                         o_clockIgnore_fromDUToInsMem,

        // For Register File
        output wire [REGFILE_ADDR_LEN-1:0]  o_addr_fromDUToRegFile, // Address to read from Register File
        input wire [REGFILE_LEN-1:0]        i_data_fromRegFileToDU, // Data read from Register File
        output wire                         o_muxSel_fromDUToRegFileMux,
        output wire                         o_clockIgnore_fromDUToRegFile,

        // For Data Memory
        output wire [DATMEM_ADDR_LEN-1:0]   o_addr_fromDUToDatMem, // Address to read from Data Memory
        input wire [DAT_LEN-1:0]            i_data_fromDatMemToDU, // Data read from Data memory
        output wire                         o_muxSel_fromDUToDatMemMux,
        output wire                         o_re_fromDUToDatMem,
        output wire                         o_clockIgnore_fromDUToDatMem,

        // Other IO Ports
        input wire i_halt_fromCUToDU
    );


    wire w_tickSource; 
    DU_BaudRateGenerator
    #(
        //Default Parameters
    )
    u_BaudRateGenerator
    (
        .i_clock(i_globalClock),
        .i_reset(i_globalReset),
        .o_tick(w_tickSource)
    );


    wire                        w_rxDone_fromRxToDUFSM;
    wire [UART_DATA_LEN-1:0]    w_data_fromRxToDUFSM;
    DU_RxUART 
    #(
        //Default Parameters
    )
    u_RxUART
    (
        .i_clock    (i_globalClock),
        .i_reset    (i_globalReset),
        .i_tick     (w_tickSource),
        .i_rxData   (i_rx_fromTopToDU),
        .o_data     (w_data_fromRxToDUFSM),
        .o_rxDone   (w_rxDone_fromRxToDUFSM)
    );

    wire                        w_txStart_fromDUFSMToTx;
    wire [UART_DATA_LEN-1:0]    w_data_fromDUFSMToTx;
    wire                        w_txDone_fromTxToDUFSM;
    DU_TxUART
    #(
        //Default Parameters
    )
    u_TxUART
    (
        .i_clock    (i_globalClock), 
        .i_reset    (i_globalReset),
        .i_tick     (w_tickSource), 
        .i_txStart  (w_txStart_fromDUFSMToTx),
        .i_data     (w_data_fromDUFSMToTx),
        .o_doneTx   (w_txDone_fromTxToDUFSM),
        .o_txData   (o_tx_fromDUToTop)
    );

    DU_FSM
    #(
        //Default Parameters
    )
    u_DebugUnitFSM
    (
        // Global
        .i_globalClock              (i_globalClock),
        .i_globalReset              (i_globalReset),

        // For Uart
        .i_data_fromRxToDUFSM       (w_data_fromRxToDUFSM),
        .i_rxDone_fromRxToDUFSM     (w_rxDone_fromRxToDUFSM),
        .o_data_fromDUFSMToTx       (w_data_fromDUFSMToTx),
        .i_txDone_fromTxToDUFSM     (w_txDone_fromTxToDUFSM),
        .o_txStart_fromDUFSMToTx    (w_txStart_fromDUFSMToTx),

        // For Program Counter
        .i_pc_fromPcToDUFSM(i_pc_fromPcToDU), 
        .o_clockIgnore_fromDUFSMToPcAndLatches   (o_clockIgnore_fromDUToPcAndLatches),        

        // For Instructions Memory
        .o_we_fromDUFSMToInsMem             (o_we_fromDUToInsMem), // Write Enable
        .o_muxSel_fromDUFSMToInsMemMux      (o_muxSel_fromDUToInsMemMux), // Mux Selector
        .o_addr_fromDUFSMToInsMem           (o_addr_fromDUToInsMem), // Adress where to write
        .o_data_fromDUFSMToInsMem           (o_data_fromDUToInsMem), // Data to write
        .o_clockIgnore_fromDUFSMToInsMem    (o_clockIgnore_fromDUToInsMem),

        // For Register File
        .o_addr_fromDUFSMToRegFile          (o_addr_fromDUToRegFile), // Address to read from Register File
        .i_data_fromRegFileToDUFSM          (i_data_fromRegFileToDU), // Data read from Register File
        .o_muxSel_fromDUFSMToRegFileMux     (o_muxSel_fromDUToRegFileMux), // Mux Selector
        .o_clockIgnore_fromDUFSMToRegFile   (o_clockIgnore_fromDUToRegFile),        

        // For Data Memory
        .o_addr_fromDUFSMToDatMem           (o_addr_fromDUToDatMem), // Address to read from Data Memory
        .i_data_fromDatMemToDUFSM           (i_data_fromDatMemToDU), // Data read from Data memory
        .o_muxSel_fromDUFSMToDatMemMux      (o_muxSel_fromDUToDatMemMux), // Mux Selector
        .o_re_fromDUFSMToDatMem             (o_re_fromDUToDatMem),
        .o_clockIgnore_fromDUFSMToDatMem    (o_clockIgnore_fromDUToDatMem),        

        // Other IO Ports
        .i_halt_fromCUToDUFSM           (i_halt_fromCUToDU)
    );

endmodule