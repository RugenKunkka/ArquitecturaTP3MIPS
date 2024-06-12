`include "Macros.v"

module TopLevel
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
)
(
    input wire i_clock_fromPin,
    input wire i_reset_fromPin,

    input wire i_rx_fromPin,
    output wire o_tx_fromPin
);


wire clk_out;
wire o_locked;
clk_wiz_0 u_ClockWizard
   (
    // Clock out ports
    .clk_out1(clk_out),     // output clk_out
    // Status and control signals
    .reset(i_reset_fromPin), // input reset
    .locked(o_locked),       // output locked
   // Clock in ports
    .clk_in1(i_clock_fromPin)
);

/*
     Internals Wires:
*/
// For Multiple Etapas
wire    w_clockIgnore_fromDUToPcAndLatches;

// For Etapa 1 (Program Counter)
wire [INS_LEN-1:0]          w_pc_fromPcToDU;

// For Etapa 1 (Instructions Memory)
wire                        w_we_fromDUToInsMem;
wire [INSMEM_ADDR_LEN-1:0]  w_addr_fromDUToInsMem;
wire [INSMEM_DAT_LEN-1:0]   w_data_fromDUToInsMem;
wire                        w_muxSel_fromDUToInsMemMux;
wire                         w_clockIgnore_fromDUToInsMem;


// For Etapa 2 (Register File)
wire [REGFILE_ADDR_LEN-1:0]  w_addr_fromDUToRegFile; // Address to read from Register File
wire [REGFILE_LEN-1:0]       w_data_fromRegFileToDU; // Data read from Register File
wire                         w_muxSel_fromDUToRegFileMux; //  Mux Selector
wire                         w_clockIgnore_fromDUToRegFile;

// For Etapa 2 (From Control Unit  to Debug Unit)
wire                        w_halt_fromCUToDU;

// For Etapa 4 (Data Memory)
wire [DATMEM_ADDR_LEN-1:0]    w_addr_fromDUToDatMem; // Address to read from Data Memory
wire [DAT_LEN-1:0]            w_data_fromDatMemToDU; // Data read from Data memory
wire                          w_muxSel_fromDUToDatMemMux; //  Mux Selector
wire                          w_re_fromDUToDatMem; // Read Enable
wire                          w_clockIgnore_fromDUToDatMem;

DebugUnit
#(
    //Default Parameters
)
 u_DebugUnit
(
    // Multiple Etapas
    .i_globalClock          (clk_out),
    //.i_globalClock          (i_clock_fromPin),
    .i_globalReset          (i_reset_fromPin|!o_locked),
    //.i_globalReset          (i_reset_fromPin),
    .o_clockIgnore_fromDUToPcAndLatches (w_clockIgnore_fromDUToPcAndLatches),   

    // For Uart
    .i_rx_fromTopToDU       (i_rx_fromPin),
    .o_tx_fromDUToTop       (o_tx_fromPin),

    // For Etapa 1 (Program Counter)
    .i_pc_fromPcToDU        (w_pc_fromPcToDU),  

    // For Etapa 1 (Instructions Memory)
    .o_we_fromDUToInsMem        (w_we_fromDUToInsMem),
    .o_muxSel_fromDUToInsMemMux (w_muxSel_fromDUToInsMemMux),
    .o_addr_fromDUToInsMem      (w_addr_fromDUToInsMem),
    .o_data_fromDUToInsMem      (w_data_fromDUToInsMem), 
    .o_clockIgnore_fromDUToInsMem(w_clockIgnore_fromDUToInsMem),    

    // For Etapa 2 (Register File)
    .o_addr_fromDUToRegFile         (w_addr_fromDUToRegFile), // Address to read from Register File
    .i_data_fromRegFileToDU         (w_data_fromRegFileToDU), // Data read from Register File
    .o_muxSel_fromDUToRegFileMux    (w_muxSel_fromDUToRegFileMux), // Mux Selector 
    .o_clockIgnore_fromDUToRegFile  (w_clockIgnore_fromDUToRegFile),    

    // For Etapa 2 (From Control Unit  to Debug Unit)
    .i_halt_fromCUToDU      (w_halt_fromCUToDU),

    // For Etapa 4 (Data Memory)
    .o_addr_fromDUToDatMem          (w_addr_fromDUToDatMem), // Address to read from Data Memory
    .i_data_fromDatMemToDU          (w_data_fromDatMemToDU), // Data read from Data memory
    .o_muxSel_fromDUToDatMemMux     (w_muxSel_fromDUToDatMemMux), // Mux Selector
    .o_re_fromDUToDatMem            (w_re_fromDUToDatMem),
    .o_clockIgnore_fromDUToDatMem   (w_clockIgnore_fromDUToDatMem)    
);

Etapas
#(

)
u_Etapas
(
    // Multiple Etapas
    .i_globalClock          (clk_out),
    //.i_globalClock          (i_clock_fromPin),
    .i_globalReset          (i_reset_fromPin|!o_locked),
    //.i_globalReset          (i_reset_fromPin),
    .i_clockIgnore_fromDUToPcAndLatches (w_clockIgnore_fromDUToPcAndLatches),

    // For Etapa 1 (Program Counter)
    .o_pc_fromE1ToDU        (w_pc_fromPcToDU),     

    // For Etapa 1 (Instructions Memory)
    .i_weForInsMem_fromDUToE1        (w_we_fromDUToInsMem),
    .i_addrForInsMem_fromDUToE1      (w_addr_fromDUToInsMem),
    .i_dataForInsMem_fromDUToE1      (w_data_fromDUToInsMem), 
    .i_muxSelForInsMemMux_fromDUToE1 (w_muxSel_fromDUToInsMemMux), // Mux Selector
    .i_clockIgnore_fromDUToInsMem    (w_clockIgnore_fromDUToInsMem),    

    // For Etapa 2 (Register File)
    .i_addrForRegFile_fromDUToE2     (w_addr_fromDUToRegFile), // Address to read from Register File
    .o_dataForRegFile_fromE2ToDU     (w_data_fromRegFileToDU), // Data read from Register File
    .i_muxSelForRegFileMux_fromDUToE2(w_muxSel_fromDUToRegFileMux), // Mux Selector
    .i_clockIgnore_fromDUToRegFile   (w_clockIgnore_fromDUToRegFile),

    // For Etapa 2 (From Control Unit  to Debug Unit)
    .o_halt_fromE4ToDU      (w_halt_fromCUToDU),
    
    // For Etapa 4 (Data Memory)
    .i_addrForDatMem_fromDUToE4      (w_addr_fromDUToDatMem), // Address to read from Data Memory
    .o_dataForDatMem_fromE4ToDU      (w_data_fromDatMemToDU), // Data read from Data memory
    .i_muxSelForDatMemMux_fromDUToE4 (w_muxSel_fromDUToDatMemMux), // Mux Selector
    .i_reForDatMem_fromDUToE4        (w_re_fromDUToDatMem),
    .i_clockIgnore_fromDUToDatMem    (w_clockIgnore_fromDUToDatMem)
);


endmodule
