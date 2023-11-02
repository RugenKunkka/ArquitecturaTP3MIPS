`include "Macros.v"

module TopLevel 
#(
    // For Instructions Memory
    parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN,   // Instruction Address Length
    parameter INSMEM_DAT_LEN    = `INSMEM_DAT_LEN,   // Instruction Legth
    parameter INS_LEN           = `INS_LEN,

    // For Register File
    parameter REGFILE_ADDR_LEN  = `REGFILE_ADDR_LEN, // Register File Address Lenght
    parameter REGFILE_LEN       = `REGFILE_LEN, // Register File Lenght

    // For Data Memory
    parameter DATMEM_ADDR_LEN   = `DATMEM_ADDR_LEN,   // Data Address Length
    parameter DAT_LEN           = `DAT_LEN   // Instruction Legth
)
(
    input wire i_clock_fromPin,
    input wire i_reset_fromPin,
    input wire i_halt_just4tb, // Delete it!!!

    input wire i_rx_fromPin,
    output wire o_tx_fromPin
);

/*
     Internals Wires:
*/

// For Program Counter
wire [INS_LEN-1:0]          w_pc_fromPcToDU;

// For Instructions Memory
wire                        w_we_fromDUToInsMem;
wire [INSMEM_ADDR_LEN-1:0]  w_addr_fromDUToInsMem;
wire [INSMEM_DAT_LEN-1:0]   w_data_fromDUToInsMem;
wire                        w_muxSel_fromDUToInsMemMux;

// For Register File
wire [REGFILE_ADDR_LEN-1:0]  w_addr_fromDUToRegFile; // Address to read from Register File
wire [REGFILE_LEN-1:0]       w_data_fromRegFileToDU; // Data read from Register File
wire                         w_muxSel_fromDUToRegFileMux; //  Mux Selector

// For Data Memory
wire [DATMEM_ADDR_LEN-1:0]    w_addr_fromDUToDatMem; // Address to read from Data Memory
wire [DAT_LEN-1:0]            w_data_fromDatMemToDU; // Data read from Data memory
wire                          w_muxSel_fromDUToDatMemMux; //  Mux Selector

// Others
wire                        w_halt_fromTargetToDU;
wire                        w_clockIgnore_fromDUToTarget;

DebugUnit
#(
    //Default Parameters
)
 u_DebugUnit
(
    .i_globalClock          (i_clock_fromPin),
    .i_globalReset          (i_reset_fromPin),

    // For Uart
    .i_rx_fromTopToDU       (i_rx_fromPin),
    .o_tx_fromDUToTop       (o_tx_fromPin),

    // For Program Counter
    .i_pc_fromPcToDU        (w_pc_fromPcToDU), 

    // For Instructions Memory
    .o_we_fromDUToInsMem        (w_we_fromDUToInsMem),
    .o_muxSel_fromDUToInsMemMux (w_muxSel_fromDUToInsMemMux),
    .o_addr_fromDUToInsMem      (w_addr_fromDUToInsMem),
    .o_data_fromDUToInsMem      (w_data_fromDUToInsMem), 

    // For Register File
    .o_addr_fromDUToRegFile     (w_addr_fromDUToRegFile), // Address to read from Register File
    .i_data_fromRegFileToDU     (w_data_fromRegFileToDU), // Data read from Register File
    .o_muxSel_fromDUToRegFileMux(w_muxSel_fromDUToRegFileMux), // Mux Selector 

    // For Data Memory
    .o_addr_fromDUToDatMem          (w_addr_fromDUToDatMem), // Address to read from Data Memory
    .i_data_fromDatMemToDU          (w_data_fromDatMemToDU), // Data read from Data memory
    .o_muxSel_fromDUToDatMemMux     (w_muxSel_fromDUToDatMemMux), // Mux Selector

    // Other IO Ports
    .i_halt_fromTargetToDU      (i_halt_just4tb),
    .o_clockIgnore_fromDUToTarget(w_clockIgnore_fromDUToTarget)
    
);

Targets
#(

)
u_Targets
(
    .i_globalClock          (i_clock_fromPin),
    .i_globalReset          (i_reset_fromPin),

    // For Program Counter
    .o_pc_fromPcToDU        (w_pc_fromPcToDU), 

    // For Instructions Memory
    .i_we_fromDUToInsMem        (w_we_fromDUToInsMem),
    .i_addr_fromDUToInsMem      (w_addr_fromDUToInsMem),
    .i_data_fromDUToInsMem      (w_data_fromDUToInsMem), 
    .i_muxSel_fromDUToInsMemMux (w_muxSel_fromDUToInsMemMux), // Mux Selector

    // For Register File
    .i_addr_fromDUToRegFile     (w_addr_fromDUToRegFile), // Address to read from Register File
    .o_data_fromRegFileToDU     (w_data_fromRegFileToDU), // Data read from Register File
    .i_muxSel_fromDUToRegFileMux(w_muxSel_fromDUToRegFileMux), // Mux Selector
    
    // For Data Memory
    .i_addr_fromDUToDatMem      (w_addr_fromDUToDatMem), // Address to read from Data Memory
    .o_data_fromDatMemToDU      (w_data_fromDatMemToDU), // Data read from Data memory
    .i_muxSel_fromDUToDatMemMux (w_muxSel_fromDUToDatMemMux), // Mux Selector

    // Other IO Ports
    .o_halt_fromTargetToDU      (w_halt_fromTargetToDU),
    .i_clockIgnore_fromDUToTarget(w_clockIgnore_fromDUToTarget)
);


endmodule
