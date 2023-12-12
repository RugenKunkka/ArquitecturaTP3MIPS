`include "Macros.v"

module E4_DataMemory
    #(
        parameter DATMEM_DEPTH = `DATMEM_DEPTH,
        parameter DAT_ENTRY_LEN = `DAT_ENTRY_LEN,
        parameter DAT_LEN = `DAT_LEN,
        parameter DATMEM_ADDR_LEN = `DATMEM_ADDR_LEN
    )
    (
        input wire i_clock,
        input wire i_reset,
        input wire i_clockIgnore_fromDU,

        input  wire [32-1:0]     i_addr_forWordMode,     
        input  wire [32-1:0]     i_data_forWordMode,   
        output reg  [32-1:0]     o_data_forWordMode,
        input  wire              i_writeEnable_forWordMode,  
        input  wire              i_readEnable_forWordMode,  

        input  wire [32-1:0]     i_addr_forHalfMode,     
        input  wire [16-1:0]     i_data_forHalfMode,   
        output reg  [16-1:0]     o_data_forHalfMode,
        input  wire              i_writeEnable_forHalfMode,  
        input  wire              i_readEnable_forHalfMode,  

        input  wire [32-1:0]     i_addr_forByteMode,     
        input  wire [8-1:0]      i_data_forByteMode,   
        output reg  [8-1:0]      o_data_forByteMode,
        input  wire              i_writeEnable_forByteMode,  
        input  wire              i_readEnable_forByteMode

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
                if (i_writeEnable_forWordMode == HIGH) begin
                    reg_data_memory[i_addr_forWordMode + 0] <= i_data_forWordMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forWordMode + 1] <= i_data_forWordMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forWordMode + 2] <= i_data_forWordMode[ 2 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forWordMode + 3] <= i_data_forWordMode[ 3 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 

                end else if(i_readEnable_forWordMode == HIGH) begin
                    o_data_forWordMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 0];
                    o_data_forWordMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 1];
                    o_data_forWordMode[ 2 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 2];
                    o_data_forWordMode[ 3 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forWordMode + 3];

                end else if (i_writeEnable_forHalfMode == HIGH) begin
                    reg_data_memory[i_addr_forHalfMode + 0] <= i_data_forHalfMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    reg_data_memory[i_addr_forHalfMode + 1] <= i_data_forHalfMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]    ; 

                end else if(i_readEnable_forHalfMode == HIGH) begin
                    o_data_forHalfMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forHalfMode + 0];
                    o_data_forHalfMode[ 1 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forHalfMode + 1];

                end else if(i_writeEnable_forByteMode == HIGH) begin
                    reg_data_memory[i_addr_forByteMode + 0] <= i_data_forByteMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ]; 
                    
                end else if(i_readEnable_forByteMode == HIGH) begin
                    o_data_forByteMode[ 0 * DAT_ENTRY_LEN  +: DAT_ENTRY_LEN ] <= reg_data_memory[i_addr_forByteMode + 0];
                end
            end 
        end
    end
endmodule
