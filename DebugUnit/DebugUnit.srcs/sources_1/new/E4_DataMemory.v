`include "Macros.v"

module E4_DataMemory
    #(
        parameter DATMEM_DEPTH    = `DATMEM_DEPTH, 
        parameter DATMEM_ADDR_LEN = `DATMEM_ADDR_LEN, 
        parameter DAT_LEN         = `DAT_LEN         
    )
    (
        input wire i_globalClock,
        input wire i_globalReset,

        input wire [DATMEM_ADDR_LEN-1:0]    i_address, // Address to read or write
        input wire [DAT_LEN-1:0]            i_data,
        input wire                          i_MemWrite_fromControl,
        input wire                          i_clockIgnore_fromDU,
        output reg [DAT_LEN-1:0]            o_data
    );
    localparam ZERO = 1'b0;
    localparam HIGH = 1'b1;
    localparam LOW = 1'b0;

    reg [DAT_LEN-1:0] reg_memory[DATMEM_DEPTH-1:0];

    integer i;

    always @(negedge i_globalClock) begin 
        if (i_globalReset) begin 
//        for(i=0; i < DATMEM_DEPTH; i = i+1) begin
//            reg_memory[i] <= {DAT_LEN{ZERO}};
//        end
            for(i=0; i < DATMEM_DEPTH; i = i+1) begin
                reg_memory[i] <= 32'h99887766;
            end
            o_data <= {DAT_LEN{ZERO}};
        end else begin 
            if (~i_clockIgnore_fromDU) begin  
                if( i_MemWrite_fromControl ==  HIGH) begin
                    reg_memory[i_address] <= i_data;
                end else begin 
                    o_data <= reg_memory[i_address];
                end
            end
        end

    end



endmodule
