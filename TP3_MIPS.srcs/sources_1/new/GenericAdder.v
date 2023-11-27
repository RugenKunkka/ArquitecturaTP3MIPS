`include "Macros.v"

module GenericAdder // Former "Sumador"
    #(
        parameter LEN = 32
    )
    (
        input  wire [LEN-1:0] i_dataA,
        input  wire [LEN-1:0] i_dataB,
        output wire [LEN-1:0] o_result
    );
    
    assign o_result = i_dataA + i_dataB;
    
endmodule
