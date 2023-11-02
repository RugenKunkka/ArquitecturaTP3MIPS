`include "Macros.v"

module E1_PC
    #(
        parameter INS_LEN = `INS_LEN
    )
    (
        input                   i_globalClock,
        input                   i_globalReset,
        input [INS_LEN-1:0]      i_pcAddressIn,
        output reg [INS_LEN-1:0] o_pcAddressOut,
        input wire              i_clockIgnore_fromDU
    );
    localparam ZERO = 1'b0;

    always @(negedge i_globalClock) begin
        if (i_globalReset) begin 
            //o_pcAddressOut <= {INS_LEN{ZERO}};
            o_pcAddressOut <= 32'hDDCC_BBAA;
        end else begin
            if (~i_clockIgnore_fromDU) begin
                o_pcAddressOut <= i_pcAddressIn;
            end
        end
    end

endmodule