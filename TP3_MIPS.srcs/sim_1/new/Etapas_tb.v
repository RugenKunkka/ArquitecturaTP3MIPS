`include "Macros.v"

module Etapas_tb
    (
        // No need
    );
/*
    (1/8) Nonlocal Paramaters
*/
    parameter HALF_CLK_CYCLE = `HALF_CLK_CYCLE;
    parameter PULSE_DELAY   = `PULSE_DELAY;
    parameter PROG_FILE     = `PROG_FILE;
    parameter PROG_LEN      = `PROG_LEN;
    parameter PROG_DEPTH    = `PROG_DEPTH;

    // For Etapa 1 (Instruction Memory)
    parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN;   // Instruction Address Length
    parameter INSMEM_DAT_LEN    = `INSMEM_DAT_LEN;   // Instruction Legth
    parameter INS_LEN           = `INS_LEN;

    // For Etapa 2 (Register File)
    parameter REGFILE_ADDR_LEN  = `REGFILE_ADDR_LEN; // Register File Address Lenght
    parameter REGFILE_LEN       = `REGFILE_LEN; // Register File Lenght

    // For Etapa 4 (Data Memory)
    parameter DATMEM_ADDR_LEN   = `DATMEM_ADDR_LEN;   // Data Address Length
    parameter DAT_LEN           = `DAT_LEN;   
    parameter WORD_LEN          = `WORD_LEN;
   
/*
    (2/8) Local Paramaters
*/   
    localparam HIGH     = `HIGH;
    localparam LOW      = `LOW;
    localparam ZERO     = `ZERO;
    localparam ONE      = `ONE;

/*
    (3/8) IO Ports (despite being reg)
*/
    // For Multiple Etapas
    reg i_globalClock;
    reg i_globalReset;
    reg i_clockIgnore_fromDU;

    // For Etapa 1 (Program Counter)
    wire [INS_LEN-1:0] o_pc_fromE1ToDU; 

    // For Etapa 1 (Instructions Memory)
    reg                         i_weForInsMem_fromDUToE1;
    reg [INSMEM_ADDR_LEN-1:0]   i_addrForInsMem_fromDUToE1;
    reg [INSMEM_DAT_LEN-1:0]    i_dataForInsMem_fromDUToE1; 
    reg                         i_muxSelForInsMemMux_fromDUToE1;

    // For Etapa 2 (Register File)
    reg [REGFILE_ADDR_LEN-1:0]  i_addrForRegFile_fromDUToE2; // Address to read from Register File
    wire [REGFILE_LEN-1:0]       o_dataForRegFile_fromE2ToDU; // Data read from Register File
    reg                         i_muxSelForRegFileMux_fromDUToE2;

    // For Etapa 4 (From Control Unit  to Debug Unit)
    wire o_halt_fromE4ToDU;
    
    // For Etapa 4 (Data Memory)
    reg [DATMEM_ADDR_LEN-1:0]   i_addrForDatMem_fromDUToE4; // Address to read from Data Memory
    wire [DAT_LEN-1:0]           o_dataForDatMem_fromE4ToDU; // Data read from Data memory
    reg                         i_muxSelForDatMemMux_fromDUToE4;
    reg                         i_reForDatMem_fromDUToE4;
    
/*
    (4/8) Another Regs
*/
    //reg [4-1:0]              regProgram [0:4-1];
/*
    (5/8) Variables
*/

 /*
    (6/8) Instantiation
 */    
    Etapas
    #(

    )
    u_Etapas
    (
        // For Multiple Etapas
        .i_globalClock(i_globalClock),
        .i_globalReset(i_globalReset),
        .i_clockIgnore_fromDU(i_clockIgnore_fromDU),
        
        // For Etapa 1 (Program Counter)
        .o_pc_fromE1ToDU(o_pc_fromE1ToDU),

        // For Etapa 1 (Instructions Memory)
        .i_weForInsMem_fromDUToE1       (i_weForInsMem_fromDUToE1), // Write Enable
        .i_addrForInsMem_fromDUToE1     (i_addrForInsMem_fromDUToE1),
        .i_dataForInsMem_fromDUToE1     (i_dataForInsMem_fromDUToE1),
        .i_muxSelForInsMemMux_fromDUToE1(i_muxSelForInsMemMux_fromDUToE1),

        // For Etapa 2 (Register File)
        .i_addrForRegFile_fromDUToE2        (i_addrForRegFile_fromDUToE2),        
        .o_dataForRegFile_fromE2ToDU        (o_dataForRegFile_fromE2ToDU),        
        .i_muxSelForRegFileMux_fromDUToE2   (i_muxSelForRegFileMux_fromDUToE2),

        // For Etapa 4 (From Control Unit  to Debug Unit)
        .o_halt_fromE4ToDU(o_halt_fromE4ToDU),

        // For Etapa 4 (Data Memory)
        .i_addrForDatMem_fromDUToE4         (i_addrForDatMem_fromDUToE4),
        .o_dataForDatMem_fromE4ToDU         (o_dataForDatMem_fromE4ToDU),
        .i_muxSelForDatMemMux_fromDUToE4    (i_muxSelForDatMemMux_fromDUToE4),
        .i_reForDatMem_fromDUToE4           (i_reForDatMem_fromDUToE4)
    );
 /*
    (7/8) Procedural Blocks
*/
    always 
        #HALF_CLK_CYCLE i_globalClock=~i_globalClock;    
    
    initial begin
        init();
        reset_pulse();
        load_insmem();
        load_datmem();
        #10003; // NO TIENE QUE SER MULTIPLO DE HALF_CLK_CYCLE
        i_clockIgnore_fromDU = LOW;
    end    
 /*
    (8/8) Tasks
*/
    task init; begin 
            // For Multiple Etapas
            i_globalClock = LOW;
            i_globalReset = LOW;
            i_clockIgnore_fromDU = HIGH;

            // For Etapa 1 (Program Counter)
            //o_pc_fromE1ToDU

            // For Etapa 1 (Instructions Memory)
            i_weForInsMem_fromDUToE1 = LOW; // Write Enable
            //i_addrForInsMem_fromDUToE1
            //i_dataForInsMem_fromDUToE1 
            i_muxSelForInsMemMux_fromDUToE1 = LOW;

            // For Etapa 2 (Register File)
            //i_addrForRegFile_fromDUToE2
            //o_dataForRegFile_fromE2ToDU        
            i_muxSelForRegFileMux_fromDUToE2  = LOW;

            // For Etapa 4 (From Control Unit  to Debug Unit)
            //o_halt_fromE4ToDU
            
            // For Etapa 4 (Data Memory)
            //i_addrForDatMem_fromDUToE4 
            //o_dataForDatMem_fromE4ToDU
            i_muxSelForDatMemMux_fromDUToE4 = LOW;
            i_reForDatMem_fromDUToE4 = LOW;
        end
    endtask

    task reset_pulse; begin
            #PULSE_DELAY;
            i_globalReset = HIGH;
            #PULSE_DELAY;
            i_globalReset = LOW;
            #PULSE_DELAY;
        end
    endtask

    task load_insmem; begin 
            $readmemh("StefProg2.hex",u_Etapas.u_Etapa1_InstructionFetch.u1_InstructionMemory.reg_memory);
        end 
    endtask
    
    task load_datmem; begin  
            $readmemh("datmem_init.hex",u_Etapas.u_Etapa4_MemoryAccess.u_DataMemory.reg_data_memory);         
        end  
    endtask 
endmodule
