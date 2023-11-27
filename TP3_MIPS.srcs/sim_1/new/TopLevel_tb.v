`include "Macros.v"

/*
    IMPORTANTE: Con un clock de 100Mhz, toma 5ms cada instruccion en enviarse 
*/
module TopLevel_tb
    (
        // No need
    );
    parameter HALF_CLK_CYCLE = `HALF_CLK_CYCLE;

    parameter PROG_FILE     = `PROG_FILE;
    parameter PROG_LEN      = `PROG_LEN;
    parameter PROG_DEPTH    = `PROG_DEPTH;
    
    parameter UART_BIT_TIME         = `UART_BIT_TIME;
    parameter UART_DATA_LEN         = `UART_DATA_LEN;
    parameter UART_DATAFRAME_LEN    = `UART_DATAFRAME_LEN;
    parameter UART_PKT_DELAY        = `UART_PKT_DELAY; // Delay between packets
    
    parameter INIT_DELAY    = `INIT_DELAY;
    parameter PULSE_DELAY   = `PULSE_DELAY;

    parameter PROG_KW       = `PROG_KW; // P Ascii - To Program
    parameter TORUN_KW      = `TORUN_KW; // R Ascii - To Run
    parameter STEPMOD_KW    = `STEPMOD_KW; // S Ascii - To Select Step by Step Mode
    parameter CONTMOD_KW    = `CONTMOD_KW; // C Ascii - To Select Continuous Mode 
  
/*
    Local Paramaters
*/   
    localparam HIGH     = `HIGH;
    localparam LOW      = `LOW;
    localparam BSTOP    = `BSTOP;
    localparam BSTART   = `BSTART;
    localparam ZERO     = `ZERO;
    localparam ONE      = `ONE;
    
/*
    IO Ports (despite being reg)
*/

    reg i_clock_fromPin;
    reg i_reset_fromPin;
    reg i_rx_fromPin;
    reg i_halt_just4tb;
    wire o_tx_fromPin;
/*
    Internal Regs
*/
    reg [PROG_LEN-1:0]              regProgram [0:PROG_DEPTH-1];
    reg [UART_DATA_LEN-1:0]         regByteToSend; // 8 bits
    reg [UART_DATAFRAME_LEN-1:0]    regDataFrameToSend; // 10 bits

 /*
    Variables
 */
  integer i,j,k;
  
 /*
    Instantiation
 */ 
  
    TopLevel
    #(

    )
    TopLevel
    (
        .i_clock_fromPin(i_clock_fromPin),
        .i_reset_fromPin(i_reset_fromPin),

        .i_rx_fromPin(i_rx_fromPin),
        .o_tx_fromPin(o_tx_fromPin)
    );
 /*
    Procedural Blocks
*/   
    always 
        #HALF_CLK_CYCLE i_clock_fromPin=~i_clock_fromPin;    
    
    initial begin
        init();
        load_program();
        reset_pulse();
        send_program_keyword();
        send_program();
        #(UART_BIT_TIME*10);
        send_stepmod_kw();
        //#(HALF_CLK_CYCLE * 2 * PROG_DEPTH);
        #(UART_BIT_TIME*10*10*10);
        //send_stepmod_kw();
        //i_halt_just4tb = HIGH;
        //TopLevel.reg_halt_fromTargetToDU = HIGH;
        //#(HALF_CLK_CYCLE*2*PROG_DEPTH);
    end
 
 /*
    Tasks
*/
    task init; begin 
            i_clock_fromPin = LOW;
            i_reset_fromPin = LOW;
            i=0;
            j=0;
            k=0;
            regByteToSend       ={UART_DATA_LEN{ZERO}};
            regDataFrameToSend  ={UART_DATAFRAME_LEN{ZERO}};
            i_rx_fromPin        = HIGH; 
            //TopLevel.reg_halt_fromTargetToDU = LOW;
            //o_tx_fromPin    = LOW;
        end
    endtask

    task reset_pulse; begin
            #PULSE_DELAY;
            i_reset_fromPin = HIGH;
            #PULSE_DELAY;
            i_reset_fromPin = LOW;
            #PULSE_DELAY;
        end
    endtask

    task load_program; begin 
            $readmemh(PROG_FILE, regProgram);
        end
    endtask

    task send_program_keyword; begin
            regByteToSend = PROG_KW;
            regDataFrameToSend = {BSTOP ,regByteToSend, BSTART};
            for (k = 0; k < UART_DATAFRAME_LEN; k = k + 1) begin
                i_rx_fromPin = regDataFrameToSend[k];
                #UART_BIT_TIME;
            end
            #UART_PKT_DELAY;
            k=0;
        end
    endtask
    
    task send_program; begin 
            for (i = 0; i < PROG_DEPTH; i = i + 1) begin
                for (j = 0; j < PROG_LEN; j = j + UART_DATA_LEN) begin
                        regByteToSend = regProgram[i][j +: UART_DATA_LEN];
                        for (k = 0; k < UART_DATAFRAME_LEN; k = k + 1) begin
                              regDataFrameToSend = {BSTOP , regByteToSend , BSTART};
                              i_rx_fromPin = regDataFrameToSend[k];
                              #UART_BIT_TIME;
                        end
                    #UART_PKT_DELAY;
                end
                j=0;
            end
            i=0;
        end
    endtask
    
    task send_stepmod_kw; begin
            regByteToSend = STEPMOD_KW;
            regDataFrameToSend = {BSTOP ,regByteToSend, BSTART};
            for (k = 0; k < UART_DATAFRAME_LEN; k = k + 1) begin
                i_rx_fromPin = regDataFrameToSend[k];
                #UART_BIT_TIME;
            end
            #UART_PKT_DELAY;
            k=0;
            regByteToSend ={UART_DATA_LEN{LOW}};
            regDataFrameToSend ={UART_DATAFRAME_LEN{LOW}};
        end
    endtask
    

endmodule
