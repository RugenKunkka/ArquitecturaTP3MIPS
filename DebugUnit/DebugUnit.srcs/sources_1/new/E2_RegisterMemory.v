`include "Macros.v"

module E2_RegisterMemory
#(
        parameter REGFILE_LEN   = `REGFILE_LEN,
        parameter REGFILE_DEPTH = `REGFILE_DEPTH,
        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN
    )
    (
        input wire i_globalClock,
        input wire i_globalReset,
        
        input wire [REGFILE_ADDR_LEN-1:0] i_AddressLecturaA,
        input wire [REGFILE_ADDR_LEN-1:0] i_AddressLecturaB,
        input wire [REGFILE_ADDR_LEN-1:0] i_AddressEscritura,
        input wire [REGFILE_LEN-1:0] i_DatoAEscribir,

        output reg [REGFILE_LEN-1:0] o_dataA,
        output reg [REGFILE_LEN-1:0] o_dataB,
    
        input wire i_RegWrite_fromControl,
        input wire i_clockIgnore_fromDU
        
    );

    localparam ZERO = 1'b0;
    localparam HIGH = 1'b1;

    reg [REGFILE_DEPTH-1:0] registers [REGFILE_LEN-1:0];

    integer i;
    
    always @(posedge i_globalClock) begin
        if (i_globalReset) begin 
//          for (i = 0; i < REGFILE_DEPTH; i = i + 1) begin
//              registers[i] = {REGFILE_LEN{ZERO} };
//          end
            for (i = 0; i < REGFILE_DEPTH; i = i + 1) begin
                registers[i] = 32'h22334455;
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

    always @(negedge i_globalClock) begin
        if (i_globalReset) begin 
            o_dataA <= {REGFILE_LEN{ZERO}};
            o_dataB <= {REGFILE_LEN{ZERO}};
        end else begin 
            if (~i_clockIgnore_fromDU) begin
                o_dataA <= registers[i_AddressLecturaA];
                o_dataB <= registers[i_AddressLecturaB];
            end
        end 
    end
       
endmodule
