`include "Macros.v"

module E2_RegisterMemory
#(
        parameter REGFILE_LEN   = `REGFILE_LEN,
        parameter REGFILE_DEPTH = `REGFILE_DEPTH,
        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN
    )
    (   
        input wire i_clock,
        input wire i_reset,
        
        input wire [REGFILE_ADDR_LEN-1:0] i_AddressLecturaA,
        input wire [REGFILE_ADDR_LEN-1:0] i_AddressLecturaB,
        input wire [REGFILE_ADDR_LEN-1:0] i_AddressEscritura,
        input wire [REGFILE_LEN-1:0] i_DatoAEscribir,

        output reg [REGFILE_LEN-1:0] o_dataA,
        output reg [REGFILE_LEN-1:0] o_dataB,
        
        output reg [REGFILE_LEN-1:0] o_dataACombinational,
    
        input wire i_RegWrite_fromControl,
        input wire i_clockIgnore_fromDU
        
    );

    localparam ZERO = `ZERO;
    localparam HIGH = `HIGH;

    reg [REGFILE_DEPTH-1:0] registers [REGFILE_LEN-1:0];

    integer i;
    
    always @(posedge i_clock) begin
        if (i_reset) begin 
            for (i = 0; i < REGFILE_DEPTH; i = i + 1) begin
              registers[i] = {REGFILE_LEN{ZERO}};
            end
        end else begin
            if (~i_clockIgnore_fromDU) begin
                if( i_RegWrite_fromControl  ==  HIGH && 
                    i_AddressEscritura      !=  {REGFILE_ADDR_LEN{ZERO}}) begin
                        registers[i_AddressEscritura] <= i_DatoAEscribir;
                end
            end
        end        
	end

    always @(negedge i_clock) begin
        if (i_reset) begin 
            o_dataA <= {REGFILE_LEN{ZERO}};
            o_dataB <= {REGFILE_LEN{ZERO}};
        end else begin 
            if (~i_clockIgnore_fromDU) begin
                o_dataA <= registers[i_AddressLecturaA];
                o_dataB <= registers[i_AddressLecturaB];
            end
        end 
    end
    always @(*) begin
        o_dataACombinational=registers[i_AddressLecturaA];
    end
       
endmodule
