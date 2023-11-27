`include "Macros.v"

module GenericMux2to1
    #(
        parameter LEN = 32
    )
    (
        input wire [LEN-1:0] i_bus0,
        input wire [LEN-1:0] i_bus1,
        output reg [LEN-1:0] o_bus,
        input wire i_muxSel
    );

    always @(*) begin
        if(i_muxSel) begin 
            o_bus = i_bus1;
        end 
        else begin 
            o_bus = i_bus0;
        end
    end
    
endmodule