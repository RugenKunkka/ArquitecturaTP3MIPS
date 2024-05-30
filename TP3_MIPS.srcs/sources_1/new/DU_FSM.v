`include "Macros.v"

module DU_FSM
    #(  

    /*
        Parameters
    */  
        // For UART
        parameter UART_DATA_LEN = `UART_DATA_LEN,
        // Uart Keyword Commands
        parameter PROG_KW       = `PROG_KW, // P Ascii - To Program
        parameter TORUN_KW      = `TORUN_KW, // R Ascii - To Run
        parameter STEPMOD_KW    = `STEPMOD_KW, // S Ascii - To Select Step by Step Mode
        parameter CONTMOD_KW    = `CONTMOD_KW, // C Ascii - To Select Continuous Mode 
        
        // For Instructions Memory
        parameter INSMEM_DEPTH      = `INSMEM_DEPTH,        // Instruction Memory Depth
        parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN,   // Instruction Address Length
        parameter INSMEM_DAT_LEN    = `INSMEM_DAT_LEN,   // Instruction Data Length
        parameter INS_LEN           = `INS_LEN,

        // For Register File
        parameter REGFILE_DEPTH     = `REGFILE_DEPTH, // Register File Amount
        parameter REGFILE_ADDR_LEN  = `REGFILE_ADDR_LEN, // Register File Address Lenght
        parameter REGFILE_LEN       = `REGFILE_LEN, // Register File Lenght
    
        // For Data Memory
        parameter DATMEM_DEPTH      = `DATMEM_DEPTH, // Data Memory Depth
        parameter DATMEM_ADDR_LEN   = `DATMEM_ADDR_LEN,   // Data Address Length
        parameter DAT_LEN           = `DAT_LEN   // Instruction Legth
     )
    (
    /*
        IO Ports
    */  

        // For Multiple Etapas
        input wire i_globalClock,
        input wire i_globalReset,
        output wire o_clockIgnore_fromDUFSMToPcAndLatches,

        // For Uart
        input wire [UART_DATA_LEN-1:0]      i_data_fromRxToDUFSM,
        input wire                          i_rxDone_fromRxToDUFSM,
        output wire [UART_DATA_LEN-1:0]     o_data_fromDUFSMToTx,
        input wire                          i_txDone_fromTxToDUFSM,
        output wire                         o_txStart_fromDUFSMToTx,
    
        // For Program Counter
        input wire [INS_LEN-1:0]    i_pc_fromPcToDUFSM, 

        // For Instructions Memory 
        output wire [INSMEM_ADDR_LEN-1:0]   o_addr_fromDUFSMToInsMem, // Address to write
        output wire [INSMEM_DAT_LEN-1:0]    o_data_fromDUFSMToInsMem, // Data to write
        output wire                         o_we_fromDUFSMToInsMem, // Write Enable
        output wire                         o_muxSel_fromDUFSMToInsMemMux, // Mux Selector to handle extra mux for Instruction Memory
        output wire                         o_clockIgnore_fromDUFSMToInsMem,

        // For Register File
        output wire [REGFILE_ADDR_LEN-1:0]  o_addr_fromDUFSMToRegFile, // Address to read from Register File
        input wire [REGFILE_LEN-1:0]        i_data_fromRegFileToDUFSM, // Data read from Register File
        output wire                         o_muxSel_fromDUFSMToRegFileMux, // Mux Selector to handle extra mux for Register File
        output wire                         o_clockIgnore_fromDUFSMToRegFile,
        
        // For Data Memory
        output wire [DATMEM_ADDR_LEN-1:0]   o_addr_fromDUFSMToDatMem, // Address to read from Data Memory
        input wire [DAT_LEN-1:0]            i_data_fromDatMemToDUFSM, // Data read from Data memory
        output wire                         o_muxSel_fromDUFSMToDatMemMux, //Mux Selector to handle extra mux for Data memory
        output wire                         o_re_fromDUFSMToDatMem, // Read Enable for Data Memory
        output wire                         o_clockIgnore_fromDUFSMToDatMem,

        // Other IO Ports
        input wire i_halt_fromCUToDUFSM            // Halt coming from Control Unit
    );

    /*
        Local Parameters
    */  

    // Generaal
    localparam HIGH = 1'b1;
    localparam LOW  = 1'b0;
    localparam ONE  = 1'b1;
    localparam ZERO = 1'b0;

    //For UART
    //localparam TOTAL_BITS_TO_SEND = INS_LEN + (REGFILE_DEPTH * REGFILE_LEN) + (DATMEM_DEPTH * DAT_LEN); // PC  , Register File , Data Memory                                
    localparam INDEX_TO_SEND_LEN  = $clog2((REGFILE_DEPTH * REGFILE_LEN)/8); // The largest element

    // For FSM
    localparam [4-1:0] IDLE_STATE               = 4'b0000; //0
    localparam [4-1:0] PROGRAMMING_STATE        = 4'b0001; //1
    localparam [4-1:0] READY_STATE              = 4'b0010; //2
    localparam [4-1:0] STEP_MODE_RUNNING_STATE  = 4'b0011; //3
    localparam [4-1:0] CONT_MODE_RUNNING_STATE  = 4'b0100; //4
    localparam [4-1:0] SEND_PC_STATE_A          = 4'b0101; //5
    localparam [4-1:0] SEND_PC_STATE_B          = 4'b0110; //6
    localparam [4-1:0] SEND_REGFILE_STATE_A     = 4'b0111; //7
    localparam [4-1:0] SEND_REGFILE_STATE_B     = 4'b1000; //8
    localparam [4-1:0] SEND_REGFILE_STATE_C     = 4'b1001; //9
    localparam [4-1:0] SEND_REGFILE_STATE_D     = 4'b1010; //10
    localparam [4-1:0] SEND_DATMEM_STATE_A      = 4'b1011; //11
    localparam [4-1:0] SEND_DATMEM_STATE_B      = 4'b1100; //12
    localparam [4-1:0] SEND_DATMEM_STATE_C      = 4'b1101; //13
    localparam [4-1:0] SEND_DATMEM_STATE_D      = 4'b1110; //14

  /*
        Internal Wires
    */

    /*
        Internal Registers
    */

    // For Multiple Etapas
    reg regClockIgnoreForPcAndLatches,  regClockIgnoreForPcAndLatches_next;

    // For UART
    reg [UART_DATA_LEN-1:0]     reg_data_fromDUFSMToTx,     reg_data_fromDUFSMToTx_next;
    reg [INDEX_TO_SEND_LEN-1:0] regIndexToSend1,             regIndexToSend1_next;
    reg [INDEX_TO_SEND_LEN-1:0] regIndexToSend2,             regIndexToSend2_next;
    reg                         reg_txStart_fromDUFSMToTx,  reg_txStart_fromDUFSMToTx_next;
    reg                         reg_firstPackageFlag, reg_firstPackageFlag_next;
    reg                         reg_gotTxDone,              reg_gotTxDone_next;
    
    // For Instruction Memory
    reg [INSMEM_ADDR_LEN-1:0]   reg_addr_fromDUFSMToInsMem, reg_addr_fromDUFSMToInsMem_next; // Address to write
    reg [INSMEM_DAT_LEN-1:0]    reg_data_fromDUFSMToInsMem, reg_data_fromDUFSMToInsMem_next;
    reg                         reg_we_fromDUFSMToInsMem,   reg_we_fromDUFSMToInsMem_next;
    reg                         reg_muxSel_fromDUFSMToInsMemMux, reg_muxSel_fromDUFSMToInsMemMux_next;
    reg [INSMEM_ADDR_LEN-1:0]   regIndexToProgram,          regIndexToProgram_next;
    reg                         regClockIgnoreForInsMem,        regClockIgnoreForInsMem_next;
    
    // For Register File
    reg [REGFILE_ADDR_LEN-1:0]  reg_addr_fromDUFSMToRegFile, reg_addr_fromDUFSMToRegFile_next;
    reg                         reg_muxSel_fromDUFSMToRegFileMux,reg_muxSel_fromDUFSMToRegFileMux_next;
    reg                         regClockIgnoreForRegFile, regClockIgnoreForRegFile_next;    
  
    // For Data Memory
    reg [DATMEM_ADDR_LEN-1:0]   reg_addr_fromDUFSMToDatMem, reg_addr_fromDUFSMToDatMem_next;
    reg                         reg_muxSel_fromDUFSMToDatMemMux, reg_muxSel_fromDUFSMToDatMemMux_next;
    reg                         reg_re_fromDUFSMToDatMem, reg_re_fromDUFSMToDatMem_next;
    reg                         regClockIgnoreForDatMem, regClockIgnoreForDatMem_next;    

    // For FSM
    reg [4-1:0] regCurrentState, regNextState;
    
    /*
        Continuous Assignments
    */

    // For Multiple Etapas
    assign o_clockIgnore_fromDUFSMToPcAndLatches = regClockIgnoreForPcAndLatches;
    
    // For UART
    assign o_data_fromDUFSMToTx     = reg_data_fromDUFSMToTx;
    assign o_txStart_fromDUFSMToTx  = reg_txStart_fromDUFSMToTx;

    // For Instruction Memory
    assign o_addr_fromDUFSMToInsMem = reg_addr_fromDUFSMToInsMem;
    assign o_data_fromDUFSMToInsMem = reg_data_fromDUFSMToInsMem; 
    assign o_we_fromDUFSMToInsMem = reg_we_fromDUFSMToInsMem;
    assign o_muxSel_fromDUFSMToInsMemMux = reg_muxSel_fromDUFSMToInsMemMux;
    assign o_clockIgnore_fromDUFSMToInsMem = regClockIgnoreForInsMem;

    // For Register File
    assign  o_addr_fromDUFSMToRegFile  = reg_addr_fromDUFSMToRegFile;
    assign o_muxSel_fromDUFSMToRegFileMux = reg_muxSel_fromDUFSMToRegFileMux;
    assign o_clockIgnore_fromDUFSMToRegFile = regClockIgnoreForRegFile;

    // For Data Memory
    assign  o_addr_fromDUFSMToDatMem  = reg_addr_fromDUFSMToDatMem ;
    assign o_muxSel_fromDUFSMToDatMemMux = reg_muxSel_fromDUFSMToDatMemMux;
    assign o_re_fromDUFSMToDatMem = reg_re_fromDUFSMToDatMem;
    assign o_clockIgnore_fromDUFSMToDatMem = regClockIgnoreForDatMem;
    
    /*
        Procedural Blocks
    */

   always@( negedge i_globalClock) begin

        if(i_globalReset)begin

            // For Multiple Etapas
            regClockIgnoreForPcAndLatches <= HIGH;

            // For UART
            reg_data_fromDUFSMToTx <= {UART_DATA_LEN{ZERO}};
            reg_txStart_fromDUFSMToTx <=  LOW;
            regIndexToSend1          <= {INDEX_TO_SEND_LEN{ZERO}};
            regIndexToSend2          <= {INDEX_TO_SEND_LEN{ZERO}};
            reg_firstPackageFlag     <= HIGH;
            reg_gotTxDone            <= LOW;

            // For Instruction Memory
            reg_addr_fromDUFSMToInsMem  <= {INSMEM_ADDR_LEN{ZERO}};
            reg_data_fromDUFSMToInsMem  <= {INSMEM_DAT_LEN{ZERO}};
            reg_muxSel_fromDUFSMToInsMemMux <= LOW;
            reg_we_fromDUFSMToInsMem  <= LOW;
            regIndexToProgram       <= {INSMEM_ADDR_LEN{ZERO}};
            regClockIgnoreForInsMem <= HIGH;

            // For Register File
            reg_addr_fromDUFSMToRegFile <= {REGFILE_ADDR_LEN{ZERO}};
            reg_muxSel_fromDUFSMToRegFileMux <= LOW;// Should be low
            regClockIgnoreForRegFile <= HIGH;

            // For Data Memory
            reg_addr_fromDUFSMToDatMem <= {DATMEM_ADDR_LEN{ZERO}};
            reg_muxSel_fromDUFSMToDatMemMux <= LOW;
            reg_re_fromDUFSMToDatMem <= LOW;
            regClockIgnoreForDatMem <= HIGH;

            // For FSM
            regCurrentState         <= IDLE_STATE;  

        end
        else begin

            // For Multiple Etapas
            regClockIgnoreForPcAndLatches<= regClockIgnoreForPcAndLatches_next;

            // For UART
            reg_data_fromDUFSMToTx      <= reg_data_fromDUFSMToTx_next;  
            reg_txStart_fromDUFSMToTx   <= reg_txStart_fromDUFSMToTx_next;       
            regIndexToSend1             <= regIndexToSend1_next;   
            regIndexToSend2             <= regIndexToSend2_next;
            reg_firstPackageFlag        <= reg_firstPackageFlag_next;
            reg_gotTxDone                <= reg_gotTxDone_next;          

            // For Instruction Memory
            reg_addr_fromDUFSMToInsMem <= reg_addr_fromDUFSMToInsMem_next ;
            reg_data_fromDUFSMToInsMem <= reg_data_fromDUFSMToInsMem_next;
            regIndexToProgram        <= regIndexToProgram_next;
            reg_we_fromDUFSMToInsMem <= reg_we_fromDUFSMToInsMem_next;
            reg_muxSel_fromDUFSMToInsMemMux <= reg_muxSel_fromDUFSMToInsMemMux_next;
            regClockIgnoreForInsMem      <= regClockIgnoreForInsMem_next;

            // For Register File
            reg_addr_fromDUFSMToRegFile <= reg_addr_fromDUFSMToRegFile_next;
            reg_muxSel_fromDUFSMToRegFileMux <= reg_muxSel_fromDUFSMToRegFileMux_next;
            regClockIgnoreForRegFile     <= regClockIgnoreForRegFile_next;

            // For Data Memory
            reg_addr_fromDUFSMToDatMem <= reg_addr_fromDUFSMToDatMem_next;
            reg_muxSel_fromDUFSMToDatMemMux <= reg_muxSel_fromDUFSMToDatMemMux_next;
            reg_re_fromDUFSMToDatMem <= reg_re_fromDUFSMToDatMem_next;
            regClockIgnoreForDatMem      <= regClockIgnoreForDatMem_next;

            // For FSM
            regCurrentState          <= regNextState;
        end
    end
    
    always@(*) begin

        // For Multiple Etapas
        regClockIgnoreForPcAndLatches_next  = regClockIgnoreForPcAndLatches ;

        // For UART
        reg_data_fromDUFSMToTx_next = reg_data_fromDUFSMToTx;
        reg_txStart_fromDUFSMToTx_next  = LOW; 
        regIndexToSend1_next         = regIndexToSend1;
        regIndexToSend2_next         = regIndexToSend2;
        reg_firstPackageFlag_next   = reg_firstPackageFlag;
        reg_gotTxDone_next          = reg_gotTxDone;

        //For Instruction Memory
        reg_addr_fromDUFSMToInsMem_next = reg_addr_fromDUFSMToInsMem;
        reg_data_fromDUFSMToInsMem_next = reg_data_fromDUFSMToInsMem;
        reg_we_fromDUFSMToInsMem_next   = LOW;//reg_we_fromDUFSMToInsMem;     
        regIndexToProgram_next      =  regIndexToProgram;
        reg_muxSel_fromDUFSMToInsMemMux_next = reg_muxSel_fromDUFSMToInsMemMux;
        regClockIgnoreForInsMem_next        = regClockIgnoreForInsMem ;

        // For Register File
        reg_addr_fromDUFSMToRegFile_next = reg_addr_fromDUFSMToRegFile;
        reg_muxSel_fromDUFSMToRegFileMux_next = reg_muxSel_fromDUFSMToRegFileMux;
        regClockIgnoreForRegFile_next       = regClockIgnoreForRegFile ;

        // For Data Memory
        reg_addr_fromDUFSMToDatMem_next = reg_addr_fromDUFSMToDatMem;
        reg_muxSel_fromDUFSMToDatMemMux_next = reg_muxSel_fromDUFSMToDatMemMux;
        reg_re_fromDUFSMToDatMem_next = LOW;
        regClockIgnoreForDatMem_next        = regClockIgnoreForDatMem ;

        // For FSM
        regNextState = regCurrentState;

        case(regCurrentState)
            IDLE_STATE: begin
                if (i_rxDone_fromRxToDUFSM) begin
                    if (i_data_fromRxToDUFSM == PROG_KW) begin
                        regNextState = PROGRAMMING_STATE;
                    end
                end
            end           
            PROGRAMMING_STATE: begin
                if (i_rxDone_fromRxToDUFSM) begin    
                    regClockIgnoreForPcAndLatches_next = HIGH;
                    regClockIgnoreForInsMem_next = LOW;
                    regClockIgnoreForRegFile_next = HIGH;
                    regClockIgnoreForDatMem_next =  HIGH;
                    reg_muxSel_fromDUFSMToInsMemMux_next = HIGH;
                    reg_data_fromDUFSMToInsMem_next = i_data_fromRxToDUFSM;
                    reg_addr_fromDUFSMToInsMem_next = regIndexToProgram; 
                    reg_we_fromDUFSMToInsMem_next = HIGH; //Write Enable
                    if (regIndexToProgram == (INSMEM_DEPTH-1) ) begin
                        regIndexToProgram_next = {INSMEM_ADDR_LEN{ZERO}};                        
                        regNextState = READY_STATE;            
                    end else begin
                        regIndexToProgram_next = regIndexToProgram + 1;
                    end
                end                      
            end
            READY_STATE: begin
                reg_muxSel_fromDUFSMToInsMemMux_next = LOW;
                regClockIgnoreForPcAndLatches_next = HIGH;
                regClockIgnoreForInsMem_next = HIGH;
                regClockIgnoreForRegFile_next = HIGH;
                regClockIgnoreForDatMem_next =  HIGH;
                if (i_rxDone_fromRxToDUFSM) begin
                    if (i_data_fromRxToDUFSM == STEPMOD_KW) begin
                        regNextState = STEP_MODE_RUNNING_STATE;
                    end
                    if (i_data_fromRxToDUFSM == CONTMOD_KW) begin
                        regNextState = CONT_MODE_RUNNING_STATE;
                    end
                end
            end
            STEP_MODE_RUNNING_STATE: begin
                if (~i_halt_fromCUToDUFSM) begin
                    regClockIgnoreForPcAndLatches_next = LOW;
                    regClockIgnoreForInsMem_next = LOW;
                    regClockIgnoreForRegFile_next = LOW;
                    regClockIgnoreForDatMem_next =  LOW;
                end else begin   
                    regClockIgnoreForPcAndLatches_next = HIGH;
                    regClockIgnoreForInsMem_next = HIGH;
                    regClockIgnoreForRegFile_next = HIGH;
                    regClockIgnoreForDatMem_next =  HIGH;                    
                end
                regNextState = SEND_PC_STATE_A;
            end 
            CONT_MODE_RUNNING_STATE: begin
                if (~i_halt_fromCUToDUFSM )begin
                    regClockIgnoreForPcAndLatches_next = LOW;
                    regClockIgnoreForInsMem_next = LOW;
                    regClockIgnoreForRegFile_next = LOW;
                    regClockIgnoreForDatMem_next =  LOW;       
                end else begin
                    regClockIgnoreForPcAndLatches_next = HIGH;
                    regClockIgnoreForInsMem_next = HIGH;
                    regClockIgnoreForRegFile_next = HIGH;
                    regClockIgnoreForDatMem_next =  HIGH;  
                    regNextState = SEND_PC_STATE_A; 
                end
            end
            SEND_PC_STATE_A: begin
                if (regIndexToSend1 < (INS_LEN/8)) begin 
                    reg_data_fromDUFSMToTx_next = i_pc_fromPcToDUFSM[ regIndexToSend1 * UART_DATA_LEN  +: UART_DATA_LEN ]; 
                    reg_txStart_fromDUFSMToTx_next = HIGH;                    
                    regIndexToSend1_next = regIndexToSend1 + 1 ;
                    regNextState = SEND_PC_STATE_B;
                end else begin 
                    regIndexToSend1_next = {INDEX_TO_SEND_LEN{ZERO}};
                    regNextState = SEND_REGFILE_STATE_A;
                end
            end
            SEND_PC_STATE_B: begin
                if (i_txDone_fromTxToDUFSM)begin 
                    regNextState = SEND_PC_STATE_A;
                end
            end
            SEND_REGFILE_STATE_A: begin 
                if (regIndexToSend1 < REGFILE_DEPTH) begin 
                    regClockIgnoreForRegFile_next = LOW;
                    reg_muxSel_fromDUFSMToRegFileMux_next = HIGH;
                    reg_addr_fromDUFSMToRegFile_next = regIndexToSend1;
                    regIndexToSend1_next = regIndexToSend1 + 1 ;
                    regNextState = SEND_REGFILE_STATE_B;
                end else begin
                    reg_muxSel_fromDUFSMToRegFileMux_next = LOW;
                    regClockIgnoreForRegFile_next = HIGH;
                    regIndexToSend1_next = {INDEX_TO_SEND_LEN{ZERO}};
                    regNextState = SEND_DATMEM_STATE_A;
                end    
            end
            SEND_REGFILE_STATE_B: begin
                regNextState = SEND_REGFILE_STATE_C;
            end
            SEND_REGFILE_STATE_C: begin
                if (regIndexToSend2 < (INS_LEN/8)) begin 
                    reg_data_fromDUFSMToTx_next = i_data_fromRegFileToDUFSM[regIndexToSend2 * UART_DATA_LEN  +: UART_DATA_LEN]; 
                    reg_txStart_fromDUFSMToTx_next = HIGH;  
                    regIndexToSend2_next = regIndexToSend2 + 1 ;
                    regNextState = SEND_REGFILE_STATE_D;
                end else begin 
                    regIndexToSend2_next = {INDEX_TO_SEND_LEN{ZERO}};
                    regNextState = SEND_REGFILE_STATE_A;
                end
            end 
            SEND_REGFILE_STATE_D: begin
                if (i_txDone_fromTxToDUFSM)begin 
                    regNextState = SEND_REGFILE_STATE_C;
                end
            end
            SEND_DATMEM_STATE_A: begin
                if (regIndexToSend1 < DATMEM_DEPTH) begin 
                    regClockIgnoreForDatMem_next =  LOW;  
                    reg_muxSel_fromDUFSMToDatMemMux_next = HIGH;
                    reg_re_fromDUFSMToDatMem_next = HIGH; 
                    reg_addr_fromDUFSMToDatMem_next = regIndexToSend1;
                    regIndexToSend1_next = regIndexToSend1 + 4 ;
                    regNextState = SEND_DATMEM_STATE_B;
                end else begin 
                    reg_muxSel_fromDUFSMToDatMemMux_next = LOW;
                    regIndexToSend1_next = {INDEX_TO_SEND_LEN{ZERO}};
                    regNextState = READY_STATE;
                end
            end
            SEND_DATMEM_STATE_B: begin
                regNextState = SEND_DATMEM_STATE_C;
            end
            SEND_DATMEM_STATE_C: begin
                if (regIndexToSend2 < (INS_LEN/8)) begin 
                    reg_data_fromDUFSMToTx_next = i_data_fromDatMemToDUFSM[regIndexToSend2 * UART_DATA_LEN  +: UART_DATA_LEN]; 
                    reg_txStart_fromDUFSMToTx_next = HIGH;  
                    regIndexToSend2_next = regIndexToSend2 + 1 ;
                    regNextState = SEND_DATMEM_STATE_D;
                end else begin 
                    regIndexToSend2_next = {INDEX_TO_SEND_LEN{ZERO}};
                    regNextState = SEND_DATMEM_STATE_A;
                end
            end
            SEND_DATMEM_STATE_D: begin
                if (i_txDone_fromTxToDUFSM)begin 
                    regNextState = SEND_DATMEM_STATE_C;
                end
            end
        endcase  
    end
endmodule
