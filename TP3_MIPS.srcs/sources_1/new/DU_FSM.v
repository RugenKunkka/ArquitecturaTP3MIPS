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

        // Global
        input wire i_globalClock,
        input wire i_globalReset,

        // For Uart
        input wire [UART_DATA_LEN-1:0]      i_data_fromRxToDUFSM,
        input wire                          i_rxDone_fromRxToDUFSM,
        output wire [UART_DATA_LEN-1:0]     o_data_fromDUFSMToTx,
        input wire                          i_txDone_fromTxToDUFSM,
        output wire                         o_txStart_fromDUFSMToTx,
    
        // For Program Counter
        input wire [INS_LEN-1:0] i_pc_fromPcToDUFSM, 

        // For Instructions Memory 
        output wire [INSMEM_ADDR_LEN-1:0]   o_addr_fromDUFSMToInsMem, // Address to write
        output wire [INSMEM_DAT_LEN-1:0]    o_data_fromDUFSMToInsMem, // Data to write
        output wire                         o_we_fromDUFSMToInsMem, // Write Enable
        output wire                         o_muxSel_fromDUFSMToInsMemMux, // Mux Selector to handle extra mux for Instruction Memory

        // For Register File
        output wire [REGFILE_ADDR_LEN-1:0]  o_addr_fromDUFSMToRegFile, // Address to read from Register File
        input wire [REGFILE_LEN-1:0]        i_data_fromRegFileToDUFSM, // Data read from Register File
        output wire                         o_muxSel_fromDUFSMToRegFileMux, // Mux Selector to handle extra mux for Register File
        
        // For Data Memory
        output wire [DATMEM_ADDR_LEN-1:0]    o_addr_fromDUFSMToDatMem, // Address to read from Data Memory
        input wire [DAT_LEN-1:0]            i_data_fromDatMemToDUFSM, // Data read from Data memory
        output wire                          o_muxSel_fromDUFSMToDatMemMux, //Mux Selector to handle extra mux for Data memory

        // Other IO Ports
        input wire i_halt_fromCUToDUFSM,            // Halt coming from Control Unit
        output wire  o_clockIgnore_fromDUFSMToEtapas    // Clock Enable to do Stepping
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
    localparam TOTAL_BITS_TO_SEND = INS_LEN + (REGFILE_DEPTH * REGFILE_LEN) + (DATMEM_DEPTH * DAT_LEN); // PC  , Register File , Data Memory                                
    localparam INDEX_TO_SEND_LEN  = $clog2((REGFILE_DEPTH * REGFILE_LEN)/8); // The largest element

    // For FSM
    localparam [4-1:0] IDLE_STATE               = 4'b0000;
    localparam [4-1:0] PROGRAMMING_STATE        = 4'b0001; 
    localparam [4-1:0] READY_STATE              = 4'b0010; 
    localparam [4-1:0] STEP_MODE_RUNNING_STATE  = 4'b0011; 
    localparam [4-1:0] CONT_MODE_RUNNING_STATE  = 4'b0100; 
    localparam [4-1:0] SENDING_PC_STATE         = 4'b0101; 
    localparam [4-1:0] READING_REGFILE_STATE    = 4'b0110; 
    localparam [4-1:0] SENDING_REGFILE_STATE    = 4'b0111; 
    localparam [4-1:0] READING_DATMEM_STATE     = 4'b1000; 
    localparam [4-1:0] SENDING_DATMEM_STATE     = 4'b1001; 


  /*
        Internal Wires
    */

    /*
        Internal Registers
    */

    // For Clock
    reg regClockIgnore, regClockIgnore_next;

    // For UART
    reg [UART_DATA_LEN-1:0]     reg_data_fromDUFSMToTx,     reg_data_fromDUFSMToTx_next;
    reg [INDEX_TO_SEND_LEN-1:0] regIndexToSend1,             regIndexToSend1_next;
    reg [INDEX_TO_SEND_LEN-1:0] regIndexToSend2,             regIndexToSend2_next;
    reg                         reg_txStart_fromDUFSMToTx,  reg_txStart_fromDUFSMToTx_next;
    reg                         reg_firstPackageFlag, reg_firstPackageFlag_next;
    
    // For Instruction Memory
    reg [INSMEM_ADDR_LEN-1:0]   reg_addr_fromDUFSMToInsMem, reg_addr_fromDUFSMToInsMem_next; // Address to write
    reg [INSMEM_DAT_LEN-1:0]    reg_data_fromDUFSMToInsMem, reg_data_fromDUFSMToInsMem_next;
    reg                         reg_we_fromDUFSMToInsMem,   reg_we_fromDUFSMToInsMem_next;
    reg                         reg_muxSel_fromDUFSMToInsMemMux, reg_muxSel_fromDUFSMToInsMemMux_next;
    reg [INSMEM_ADDR_LEN-1:0]   regIndexToProgram,          regIndexToProgram_next;
    
    // For Register File
    reg [REGFILE_ADDR_LEN-1:0]  reg_addr_fromDUFSMToRegFile, reg_addr_fromDUFSMToRegFile_next;
    reg                         reg_muxSel_fromDUFSMToRegFileMux,reg_muxSel_fromDUFSMToRegFileMux_next;
  
    // For Data Memory
    reg [DATMEM_ADDR_LEN-1:0]   reg_addr_fromDUFSMToDatMem, reg_addr_fromDUFSMToDatMem_next;
    reg                         reg_muxSel_fromDUFSMToDatMemMux, reg_muxSel_fromDUFSMToDatMemMux_next;

    // For FSM
    reg [4-1:0] regCurrentState, regNextState;
    
    /*
        Continuous Assignments
    */

    // For Clock
    assign o_clockIgnore_fromDUFSMToEtapas = regClockIgnore;
    
    // For UART
    assign o_data_fromDUFSMToTx     = reg_data_fromDUFSMToTx;
    assign o_txStart_fromDUFSMToTx  = reg_txStart_fromDUFSMToTx;

    // For Instruction Memory
    assign o_addr_fromDUFSMToInsMem = reg_addr_fromDUFSMToInsMem;
    assign o_data_fromDUFSMToInsMem = reg_data_fromDUFSMToInsMem; 
    assign o_we_fromDUFSMToInsMem = reg_we_fromDUFSMToInsMem;
    assign o_muxSel_fromDUFSMToInsMemMux = reg_muxSel_fromDUFSMToInsMemMux;

    // For Register File
    assign  o_addr_fromDUFSMToRegFile  = reg_addr_fromDUFSMToRegFile;
    assign o_muxSel_fromDUFSMToRegFileMux = reg_muxSel_fromDUFSMToRegFileMux;

    // For Data Memory
    assign  o_addr_fromDUFSMToDatMem  = reg_addr_fromDUFSMToDatMem ;
    assign o_muxSel_fromDUFSMToDatMemMux = reg_muxSel_fromDUFSMToDatMemMux;
    
    /*
        Procedural Blocks
    */

   always@( posedge i_globalClock, posedge i_globalReset) begin

        if(i_globalReset)begin

            // For Clocks
            regClockIgnore          <= HIGH;

            // For UART
            reg_data_fromDUFSMToTx <= {UART_DATA_LEN{ZERO}};
            reg_txStart_fromDUFSMToTx <=  LOW;
            regIndexToSend1          <= {INDEX_TO_SEND_LEN{ZERO}};
            regIndexToSend2          <= {INDEX_TO_SEND_LEN{ZERO}};
            reg_firstPackageFlag     <= HIGH;

            // For Instruction Memory
            reg_addr_fromDUFSMToInsMem  <= {INSMEM_ADDR_LEN{ZERO}};
            reg_data_fromDUFSMToInsMem  <= {INSMEM_DAT_LEN{ZERO}};
            reg_muxSel_fromDUFSMToInsMemMux <= LOW;
            reg_we_fromDUFSMToInsMem  <= LOW;
            regIndexToProgram       <= {INSMEM_ADDR_LEN{ZERO}};

            // For Register File
            reg_addr_fromDUFSMToRegFile <= {REGFILE_ADDR_LEN{ZERO}};
            reg_muxSel_fromDUFSMToRegFileMux <= LOW;// Should be low

            // For Data Memory
            reg_addr_fromDUFSMToDatMem <= {DATMEM_ADDR_LEN{ZERO}};
            reg_muxSel_fromDUFSMToDatMemMux <= LOW;

            // For FSM
            regCurrentState         <= IDLE_STATE;  

        end
        else begin

            // For Clock
            regClockIgnore = regClockIgnore_next;

            // For UART
            reg_data_fromDUFSMToTx      <= reg_data_fromDUFSMToTx_next;  
            reg_txStart_fromDUFSMToTx   <= reg_txStart_fromDUFSMToTx_next;       
            regIndexToSend1             <= regIndexToSend1_next;   
            regIndexToSend2             <= regIndexToSend2_next;
            reg_firstPackageFlag        <= reg_firstPackageFlag_next;

            // For Instruction Memory
            reg_addr_fromDUFSMToInsMem <= reg_addr_fromDUFSMToInsMem_next ;
            reg_data_fromDUFSMToInsMem <= reg_data_fromDUFSMToInsMem_next;
            regIndexToProgram        <= regIndexToProgram_next;
            reg_we_fromDUFSMToInsMem <= reg_we_fromDUFSMToInsMem_next;
            reg_muxSel_fromDUFSMToInsMemMux <= reg_muxSel_fromDUFSMToInsMemMux_next;

            // For Register File
            reg_addr_fromDUFSMToRegFile <= reg_addr_fromDUFSMToRegFile_next;
            reg_muxSel_fromDUFSMToRegFileMux <= reg_muxSel_fromDUFSMToRegFileMux_next;

            // For Data Memory
            reg_addr_fromDUFSMToDatMem <= reg_addr_fromDUFSMToDatMem_next;
            reg_muxSel_fromDUFSMToDatMemMux <= reg_muxSel_fromDUFSMToDatMemMux_next;

            // For FSM
            regCurrentState          <= regNextState;
        end
    end
    
    always@(*) begin

        // For Clock
        regClockIgnore_next = regClockIgnore;

        // For UART
        reg_data_fromDUFSMToTx_next = reg_data_fromDUFSMToTx;
        reg_txStart_fromDUFSMToTx_next  = LOW; 
        regIndexToSend1_next         = regIndexToSend1;
        regIndexToSend2_next         = regIndexToSend2;
        reg_firstPackageFlag_next   = reg_firstPackageFlag;

        //For Instruction Memory
        reg_addr_fromDUFSMToInsMem_next = reg_addr_fromDUFSMToInsMem;
        reg_data_fromDUFSMToInsMem_next = reg_data_fromDUFSMToInsMem;
        reg_we_fromDUFSMToInsMem_next   = LOW;//reg_we_fromDUFSMToInsMem;     
        regIndexToProgram_next      =  regIndexToProgram;
        reg_muxSel_fromDUFSMToInsMemMux_next = reg_muxSel_fromDUFSMToInsMemMux;

        // For Register File
        reg_addr_fromDUFSMToRegFile_next = reg_addr_fromDUFSMToRegFile;
        reg_muxSel_fromDUFSMToRegFileMux_next = reg_muxSel_fromDUFSMToRegFileMux;

        // For Data Memory
        reg_addr_fromDUFSMToDatMem_next = reg_addr_fromDUFSMToDatMem;
        reg_muxSel_fromDUFSMToDatMemMux_next = reg_muxSel_fromDUFSMToDatMemMux;

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
                    regClockIgnore_next = LOW;                    
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
                regClockIgnore_next = HIGH; 
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
                    regClockIgnore_next = LOW;
                end else begin   
                    regClockIgnore_next = HIGH;
                end
                regNextState = SENDING_PC_STATE;
            end 
            CONT_MODE_RUNNING_STATE: begin
                if (~i_halt_fromCUToDUFSM )begin
                    regClockIgnore_next = LOW;
                end else begin
                    regNextState = SENDING_PC_STATE; 
                end
            end
            SENDING_PC_STATE: begin
                if (reg_firstPackageFlag) begin  
                    regClockIgnore_next = HIGH;
                    reg_data_fromDUFSMToTx_next = i_pc_fromPcToDUFSM[UART_DATA_LEN-1:0];
                    reg_txStart_fromDUFSMToTx_next = HIGH;                    
                    reg_firstPackageFlag_next = LOW;
                    regIndexToSend1_next = regIndexToSend1 + 1 ;
                end else begin
                    if (i_txDone_fromTxToDUFSM) begin
                        if (regIndexToSend1 < (INS_LEN/8)) begin 
                            reg_data_fromDUFSMToTx_next = i_pc_fromPcToDUFSM[ regIndexToSend1 * UART_DATA_LEN  +: UART_DATA_LEN ];                            
                            reg_txStart_fromDUFSMToTx_next = HIGH;
                            regIndexToSend1_next = regIndexToSend1 + 1 ;
                        end else begin                             
                            regIndexToSend1_next = {INDEX_TO_SEND_LEN{ZERO}};
                            reg_firstPackageFlag_next = HIGH;
                            regNextState = READING_REGFILE_STATE;
                        end
                    end
                end
            end
            READING_REGFILE_STATE: begin
                if (regIndexToSend1 < REGFILE_DEPTH) begin 
                    regClockIgnore_next = LOW;
                    reg_muxSel_fromDUFSMToRegFileMux_next = HIGH;
                    reg_addr_fromDUFSMToRegFile_next = regIndexToSend1;
                    regIndexToSend1_next = regIndexToSend1 + 1 ;
                    regNextState = SENDING_REGFILE_STATE;
                end else begin  
                    reg_muxSel_fromDUFSMToRegFileMux_next = LOW;
                    regIndexToSend1_next = {INDEX_TO_SEND_LEN{ZERO}};
                    regNextState = READING_DATMEM_STATE;
                end                    
            end
            SENDING_REGFILE_STATE: begin
                if (reg_firstPackageFlag) begin
                    reg_data_fromDUFSMToTx_next = i_data_fromRegFileToDUFSM[UART_DATA_LEN-1:0];
                    reg_txStart_fromDUFSMToTx_next = HIGH;    
                    reg_firstPackageFlag_next = LOW; 
                    regIndexToSend2_next = regIndexToSend2 + 1 ;
                end else begin
                    if (i_txDone_fromTxToDUFSM) begin
                        if (regIndexToSend2 < (INS_LEN/8)) begin 
                            reg_data_fromDUFSMToTx_next = i_data_fromRegFileToDUFSM[regIndexToSend2 * UART_DATA_LEN  +: UART_DATA_LEN]; 
                            reg_txStart_fromDUFSMToTx_next = HIGH;  
                            regIndexToSend2_next = regIndexToSend2 + 1 ;
                        end else begin 
                            regIndexToSend2_next = {INDEX_TO_SEND_LEN{ZERO}};
                            reg_firstPackageFlag_next = HIGH; 
                            regNextState = READING_REGFILE_STATE;
                        end
                    end   
                end
            end
            READING_DATMEM_STATE: begin
                if (regIndexToSend1 < DATMEM_DEPTH) begin 
                    regClockIgnore_next = LOW;
                    reg_muxSel_fromDUFSMToDatMemMux_next = HIGH;
                    reg_addr_fromDUFSMToDatMem_next = regIndexToSend1;
                    regIndexToSend1_next = regIndexToSend1 + 1 ;
                    regNextState = SENDING_DATMEM_STATE;
                end else begin  
                    reg_muxSel_fromDUFSMToDatMemMux_next = LOW;
                    regIndexToSend1_next = {INDEX_TO_SEND_LEN{ZERO}};
                    regNextState = READY_STATE;
                end 
            end
            SENDING_DATMEM_STATE: begin
                if (reg_firstPackageFlag) begin
                    reg_data_fromDUFSMToTx_next = i_data_fromDatMemToDUFSM[UART_DATA_LEN-1:0];
                    reg_txStart_fromDUFSMToTx_next = HIGH;    
                    reg_firstPackageFlag_next = LOW; 
                    regIndexToSend2_next = regIndexToSend2 + 1 ;
                end else begin
                    if (i_txDone_fromTxToDUFSM) begin
                        if (regIndexToSend2 < (INS_LEN/8)) begin 
                            reg_data_fromDUFSMToTx_next = i_data_fromDatMemToDUFSM[regIndexToSend2 * UART_DATA_LEN  +: UART_DATA_LEN]; 
                            reg_txStart_fromDUFSMToTx_next = HIGH;  
                            regIndexToSend2_next = regIndexToSend2 + 1 ;
                        end else begin 
                            regIndexToSend2_next = {INDEX_TO_SEND_LEN{ZERO}};
                            reg_firstPackageFlag_next = HIGH; 
                            regNextState = READING_DATMEM_STATE;
                        end
                    end   
                end
            end
        endcase  
    end
endmodule
