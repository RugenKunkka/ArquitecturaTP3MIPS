`include "Macros.v"

module E4_DataMemory
    #(
        parameter DATMEM_DEPTH = `DATMEM_DEPTH,
        parameter DAT_ENTRY_LEN = `DAT_ENTRY_LEN,
        parameter DAT_LEN = `DAT_LEN,
        parameter DATMEM_ADDR_LEN = `DATMEM_ADDR_LEN,
        parameter WORD_LEN = `WORD_LEN,
        parameter HALF_LEN = `HALF_LEN,
        parameter BYTE_LEN = `BYTE_LEN
    )
    (
        input wire i_clock,
        input wire i_reset,
        input wire i_clockIgnore_fromDU,

        input  wire [DATMEM_ADDR_LEN-1:0]   i_addr_forWordMode,     
        input  wire [WORD_LEN-1:0]          i_data_forWordMode,   
        output reg  [WORD_LEN-1:0]          o_data_forWordMode,
        input  wire                         i_writeEnable_forWordMode,  
        input  wire                         i_readEnable_forWordMode,  

        input  wire [DATMEM_ADDR_LEN-1:0]   i_addr_forHalfMode,     
        input  wire [HALF_LEN-1:0]          i_data_forHalfMode,   
        output reg  [HALF_LEN-1:0]          o_data_forHalfMode,
        input  wire                         i_writeEnable_forHalfMode,  
        input  wire                         i_readEnable_forHalfMode,  

        input  wire [DATMEM_ADDR_LEN-1:0]   i_addr_forByteMode,     
        input  wire [BYTE_LEN-1:0]          i_data_forByteMode,   
        output reg  [BYTE_LEN-1:0]          o_data_forByteMode,
        input  wire                         i_writeEnable_forByteMode,  
        input  wire                         i_readEnable_forByteMode

    );
    reg [DAT_ENTRY_LEN-1:0] reg_data_memory[DATMEM_DEPTH-1:0];

    localparam ZERO = `ZERO;
    localparam HIGH = `HIGH;

    integer i; // To itarate during reset

    always @(negedge i_clock) begin 
        if (i_reset) begin 
            for(i=0; i < DATMEM_DEPTH; i = i+1) begin
                reg_data_memory[i] <= {DAT_ENTRY_LEN{ZERO}};
            end
        end else begin 
            if (~i_clockIgnore_fromDU) begin  
                if (i_writeEnable_forWordMode == HIGH) begin // SW
                    reg_data_memory[i_addr_forWordMode + 0] <= i_data_forWordMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forWordMode + 1] <= i_data_forWordMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forWordMode + 2] <= i_data_forWordMode[ 2 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forWordMode + 3] <= i_data_forWordMode[ 3 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 

                end else if(i_readEnable_forWordMode == HIGH) begin // LW, LWU
                    o_data_forWordMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 0];
                    o_data_forWordMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 1];
                    o_data_forWordMode[ 2 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 2];
                    o_data_forWordMode[ 3 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 3];

                end else if (i_writeEnable_forHalfMode == HIGH) begin // SH
                    reg_data_memory[i_addr_forHalfMode + 0] <= i_data_forHalfMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forHalfMode + 1] <= i_data_forHalfMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]    ; 

                end else if(i_readEnable_forHalfMode == HIGH) begin // LH, LHU
                    o_data_forHalfMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forHalfMode + 0];
                    o_data_forHalfMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forHalfMode + 1];

                end else if(i_writeEnable_forByteMode == HIGH) begin // SB
                    reg_data_memory[i_addr_forByteMode + 0] <= i_data_forByteMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    
                end else if(i_readEnable_forByteMode == HIGH) begin // LB, LBU
                    o_data_forByteMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forByteMode + 0];
                end
            end 
        end
    end
endmodule
