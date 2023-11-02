`include "Macros.v"

module E1_InstructionMemory
    #(
        parameter INSMEM_DEPTH      = `INSMEM_DEPTH,
        parameter INSMEM_ADDR_LEN   = `INSMEM_ADDR_LEN,
        parameter INS_LEN           = `INS_LEN,
        parameter INSMEM_DAT_LEN    = `INSMEM_DAT_LEN
    )
    (
        input wire                       i_globalClock,
        input wire                       i_globalReset,

        input wire [INSMEM_ADDR_LEN-1:0] i_address,     // Address where to read and write (Could be PC or Progra)
        output reg [INS_LEN-1:0]        o_instruction, // Instruction read
        input wire                       i_writeEnable_fromDU,
        input wire  [INSMEM_DAT_LEN-1:0] i_data_fromDU, 
        input wire                       i_clockIgnore_fromDU
    );

    localparam ZERO = 1'b0;

    reg [INSMEM_DAT_LEN-1:0] reg_memory[INSMEM_DEPTH-1:0];
    
    integer i;

    always@(posedge i_globalClock) begin
        if (i_globalReset) begin 
            for(i=0; i<INSMEM_DEPTH; i=i+1) begin
                reg_memory[i] <= {INSMEM_DAT_LEN{ZERO}};
            end
            o_instruction <= {INS_LEN{ZERO}};
        end else begin
            if (~i_clockIgnore_fromDU) begin
                if(i_writeEnable_fromDU) begin 
                    reg_memory[i_address] <= i_data_fromDU;
                end else begin
                    o_instruction[7:0]   <= reg_memory[i_address];         // + 0
                    o_instruction[15:8]  <= reg_memory[i_address + 2'b01]; // + 1 (NOTE: This memory is byte-addresseble)
                    o_instruction[23:16] <= reg_memory[i_address + 2'b10]; // + 2
                    o_instruction[31:24] <= reg_memory[i_address + 2'b11]; // + 3                                            
                end
            end
        end


    end
    
endmodule