
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

/******************************************************************************
                                For Design
******************************************************************************/

// For UART
`define UART_DATA_LEN 8
// Uart Keyword Commands
// IMPORTANTE: Una vez definido un Opcode, hay que ajustar las keywords con los bits que sobren
`define PROG_KW      8'h50 // P Ascii - To Program 
`define TORUN_KW     8'h52 // R Ascii - To Run
`define STEPMOD_KW   8'h53 // S Ascii - To Select Step by Step Mode
`define CONTMOD_KW   8'h44 // C Ascii - To Select Continuous Mod

// For Instruction Memory
`define INSMEM_DEPTH    16 // Instruction Memory Depth
`define INSMEM_ADDR_LEN 32// Instruction Address Length
`define INSMEM_DAT_LEN  `UART_DATA_LEN
`define INS_LEN         32   // Instruction Legth


// For IF/ID Pipeline Register 
`define IFID_REG_LEN    64

// For Register File
`define REGFILE_DEPTH       32 // Register File Amountw
`define REGFILE_ADDR_LEN    5 // Register File Address Lenghtw
`define REGFILE_LEN         32 // Register File Lenghtw

// For ID/EX Pipeline Register
//`define IDEX_REG_LEN       128

// For EX/MEM Pipeline Register
//`define EXMEM_REG_LEN      97

// For Data Memory
`define DATMEM_DEPTH       4 // Data Memory Depth
`define DATMEM_ADDR_LEN    32   // Data Address Length
`define DAT_LEN            32   // Instruction Legth

// For MEM/WB Pipeline Registerss
//`define MEMWB_REG_LEN      64
  
// Others
//`define CYCLE_COUNTER_LEN 16