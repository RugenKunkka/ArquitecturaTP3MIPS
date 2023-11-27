`include "Macros.v"

module E4_Reg_MEM_WB 
    #(
        parameter DAT_LEN =`DAT_LEN,

        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN 
        
    )(
        input wire i_clock,
        input wire i_reset,

        input wire [REGFILE_ADDR_LEN-1:0]   i_rdToWrite_fromE3ToE4, //// Registro de Escritura [4:0]
        output reg [REGFILE_ADDR_LEN-1:0]  o_rdToWrite_fromE4ToE5,  

        input wire [DAT_LEN-1:0] i_data_fromDatMemToE5, // dato_wb
        input wire [REGFILE_ADDR_LEN-1:0] i_addrToWrite_fromE3ToE5,// i_reg_esc
        input wire  i_RegWrite_fromCUToE4,// i_reg_write


        output reg [DAT_LEN-1:0] o_data_fromDatMemToE5, // o_dato_wb
        output reg [REGFILE_ADDR_LEN-1:0] o_addrToWrite_fromE3ToE5,  // o_reg_esc
        output reg  o_RegWrite_fromCUToE5 // o_reg_write

    );
    localparam  ZERO = `ZERO;

    always @(i_clock)begin
        if(i_reset) begin
            o_data_fromDatMemToE5      <= {DAT_LEN{ZERO}};
            o_addrToWrite_fromE3ToE5    <= {REGFILE_ADDR_LEN{ZERO}};
            o_RegWrite_fromCUToE5       <= ZERO;
            o_rdToWrite_fromE4ToE5      <= ZERO;
        end
        else begin
            o_data_fromDatMemToE5      <= i_data_fromDatMemToE5;
            o_addrToWrite_fromE3ToE5    <= i_addrToWrite_fromE3ToE5;
            o_RegWrite_fromCUToE5       <= i_RegWrite_fromCUToE4;
            o_rdToWrite_fromE4ToE5      <= i_rdToWrite_fromE3ToE4;

        end
    end
    

endmodule
