`include "Macros.v"

module GenericMux3to1_2bits 
    #(
        parameter LEN=32
    )
    (
        input wire [LEN-1:0] i_bus00,
        input wire [LEN-1:0] i_bus01,
        input wire [LEN-1:0] i_bus10,
        
        input wire [2-1:0] i_muxSel,
        
        output reg [LEN-1:0] o_bus

    );
        
    always @(*) begin
        if(i_muxSel == 2'b00) begin  
            o_bus = i_bus00;
        end
        else if(i_muxSel == 2'b01) begin 
            o_bus = i_bus01;
        end 
        else if (i_muxSel == 2'b10) begin 
            o_bus = i_bus10;
        end
        else begin
            o_bus = i_bus00;
        end
        
    end
    
endmodule
