`include "Macros.v"

module E4_Reg_MEM_WB 
    #(
        parameter DAT_LEN =`DAT_LEN,

        parameter REGFILE_ADDR_LEN = `REGFILE_ADDR_LEN 
        
    )(
        input wire                          i_controlRegWrite,
        input wire [DAT_LEN-1:0]            i_data_fromDatMemToE5,
        input wire [REGFILE_ADDR_LEN-1:0]   i_rdToWrite_fromE3ToE4,
        

        output reg                          o_controlRegWrite,
        output reg [DAT_LEN-1:0]            o_data_fromDatMemToE5,
        output reg [REGFILE_ADDR_LEN-1:0]   o_rdToWrite_fromE4ToE5,
        
        // For Debug Unit
        input wire i_clockIgnore_fromDU,

        input wire i_clock,
        input wire i_reset

    );
    localparam  ZERO = `ZERO;

    always @(posedge i_clock) begin
        if(i_reset) begin
            o_controlRegWrite       <= ZERO;
            o_data_fromDatMemToE5   <= {DAT_LEN{ZERO}};
            o_rdToWrite_fromE4ToE5  <= ZERO;
        end
        else begin            
            if (~i_clockIgnore_fromDU) begin
                o_controlRegWrite       <= i_controlRegWrite;
                o_data_fromDatMemToE5   <= i_data_fromDatMemToE5;
                o_rdToWrite_fromE4ToE5  <= i_rdToWrite_fromE3ToE4;
            end
        end
    end
    

endmodule
