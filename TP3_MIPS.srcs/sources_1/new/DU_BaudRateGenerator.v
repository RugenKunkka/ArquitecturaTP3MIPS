`include "Macros.v"

module DU_BaudRateGenerator
    #(
        parameter BAUD_RATE    = `BAUDRATE,
        parameter CLOCK_FREQUENCY_MHZ  = 100.0,//60.0,
        parameter MHZ_TO_HZ_CONVERSION_FACTOR  = 1000000
    )
    (
        input wire i_clock,
        input wire i_reset,
        output wire o_tick
    );
    
    localparam integer  NUMBER_OF_STEPS = (CLOCK_FREQUENCY_MHZ * MHZ_TO_HZ_CONVERSION_FACTOR) / (BAUD_RATE * 16);
    
    reg [$clog2(NUMBER_OF_STEPS)-1:0] reg_pulseCounter;
    reg o_reg_tick;
    
    always@( posedge i_clock) begin
        if(i_reset) begin
            reg_pulseCounter<=0;
        end 
        else begin
            reg_pulseCounter <= reg_pulseCounter+1;
            if(reg_pulseCounter>=NUMBER_OF_STEPS) begin
                o_reg_tick<=1;
                reg_pulseCounter<=0;
            end
            else begin 
                o_reg_tick<=0;
            end 

        end
    end
assign o_tick=o_reg_tick;
    
endmodule