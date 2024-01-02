
/******************************************************************************
                                For Simulation
******************************************************************************/

//For the Clock
`define CLK_FREQ        100_000_000
`define STEPS_PER_CYCLE 10
`define NS_PER_STEP     1
`timescale 1 ns / 1ps 
`define HALF_CLK_CYCLE  5  
`define ONE_CLK_CYCLE  `STEPS_PER_CYCLE  

// For the Program.hex
`define PROG_FILE   "C:\\Users\\UserTest1\\College\\CompArq\\DebugUnit\\DebugUnit.srcs\\sim_1\\new\\Program.hex"
`define PROG_LEN    32
`define PROG_DEPTH  4 // Number of lines of Program.hex

`define BAUDRATE            9600
`define UART_BIT_TIME       ((`CLK_FREQ * `STEPS_PER_CYCLE) / `BAUDRATE)
`define UART_DATAFRAME_LEN  10
`define UART_PKT_DELAY      (`UART_BIT_TIME * 2)

`define INIT_DELAY  50000 // A ojo
`define PULSE_DELAY 50000 // A ojo

`define BSTOP 1'b1
`define BSTART 1'b0

/******************************************************************************
                                For Design
******************************************************************************/

/*****************
    Debug Unit
******************/

// For UART
`define UART_DATA_LEN   8
`define BAUDRATE        9600


// Uart Keyword Commands
// IMPORTANTE: Una vez definido un Opcode, hay que ajustar las keywords con los bits que sobren
`define PROG_KW      8'h50 // P Ascii - To Program 
`define TORUN_KW     8'h52 // R Ascii - To Run
`define STEPMOD_KW   8'h53 // S Ascii - To Select Step by Step Mode
`define CONTMOD_KW   8'h44 // C Ascii - To Select Continuous Mod

/******************
    Etapa 1:
******************/

// For Instruction Memory
`define INSMEM_DEPTH    16  // Instruction Memory Depth <----
`define INSMEM_ADDR_LEN 32  // Instruction Address Length
`define INSMEM_DAT_LEN  8   // Entry Length
`define INS_LEN         32  // Instruction Length

/******************
    Etapa 2:
******************/

// For Register File
`define REGFILE_DEPTH       32 // Register File Amountw
`define REGFILE_ADDR_LEN    5 // Register File Address Lenghtw
`define REGFILE_LEN         32 // Register File Lenghtw

/******************
    Etapa 3:
******************/

// For ALU
`define ALU_LEN 32
`define OPERATORS_INPUT_SIZE 6


/******************
    Etapa 4
******************/

// For Data Memory

`define WORD_LEN 32
`define HALF_LEN 16
`define BYTE_LEN 8

`define DATMEM_DEPTH       12 // Data Memory Depth (IMPORTANT: Must be multiples of 4)
`define DATMEM_ADDR_LEN    32   // Data Address Length
`define DAT_LEN            32   
`define DAT_ENTRY_LEN      8   

/******************
    Commons
******************/


// Others
`define LOW     1'b0
`define HIGH    1'b1
`define ZERO    1'b0
`define ONE     1'b1

// Zero Extender Default
`define ZEXT_IN_LEN 16
`define ZEXT_OUT_LEN 32

// Sign Extender Default
`define SIGNEXT_IN_LEN 28
`define SIGNEXT_OUT_LEN 32