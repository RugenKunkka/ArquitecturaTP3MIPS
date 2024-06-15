`include "Macros.v"

module E1_PC
    #(
        parameter INS_LEN = `INS_LEN
    )
    (
        input wire                  i_clock,
        input wire                  i_reset,
        
        input wire [INS_LEN-1:0] i_pcAddressIn,
        output reg [INS_LEN-1:0] o_pcAddressOut,

        input wire  i_stallPC_fromHU,
        
        input wire  i_clockIgnore_fromDU
    );
    localparam ZERO = `ZERO;

    always @(negedge i_clock) begin
        if (i_reset) begin 
            o_pcAddressOut <= {INS_LEN{ZERO}};            
        end else begin
            if (~i_clockIgnore_fromDU) begin
                if (~i_stallPC_fromHU) begin
                    o_pcAddressOut <= i_pcAddressIn;
                end
            end
        end
    end
endmodule