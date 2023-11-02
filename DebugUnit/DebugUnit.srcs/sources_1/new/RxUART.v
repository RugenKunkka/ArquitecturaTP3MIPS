`include "Macros.v"

module RxUART
    #(
        parameter DATA_LENGTH = `UART_DATA_LEN
    )
    (
        input wire i_rxData,//recievedData recibe el bit de informaci?n
        input wire i_clock,
        input wire i_tick,
        input wire i_reset,
        
        output wire [DATA_LENGTH-1:0] o_data,
        output reg o_rxDone
    );
    
    reg [DATA_LENGTH-1:0] o_reg_data,o_reg_nextData;//b_reg, b_next
    //reg o_reg_rxDone;
    reg o_reg_fail;
       
    
    localparam [2:0] IDLE_STATE        = 3'b000;
    localparam [2:0] START_STATE       = 3'b001;
    localparam [2:0] READ_DATA_STATE   = 3'b010;
    localparam [2:0] STOP_STATE        = 3'b011;
    localparam [2:0] REESTARTING_STATE = 3'b100;
    
    reg [2:0] reg_actualState, reg_nextActualState;//state_reg y state_next
    reg [4-1:0] reg_ticksCounter,reg_nextTicksCounter;//cuenta 1ro hasta 7 y dsps hasta 15 s_reg y s_next
    reg [4-1:0] reg_bitsRxCounter,reg_nextBitsRxCounter;//n_reg, n_next
    
    assign o_data=o_reg_data;     
    
    always@( posedge i_clock, posedge i_reset) begin
        if(i_reset)begin
            reg_actualState<=IDLE_STATE;
            reg_ticksCounter<=0;//s_reg
            reg_bitsRxCounter<=0;
            o_reg_data<=0;
        end
        else begin
           reg_actualState<=reg_nextActualState;
           reg_ticksCounter<=reg_nextTicksCounter;
           reg_bitsRxCounter<=reg_nextBitsRxCounter;
           o_reg_data<=o_reg_nextData;
        end
    end
    
    always@( *) begin
        reg_nextActualState=reg_actualState;
        o_rxDone=0;
        reg_nextTicksCounter=reg_ticksCounter;
        reg_nextBitsRxCounter=reg_bitsRxCounter;
        o_reg_nextData=o_reg_data;
        
        if(reg_actualState == IDLE_STATE) begin
           if(i_rxData==0/* && i_tick*/) begin
                reg_nextActualState=START_STATE;
                reg_nextTicksCounter=0;
                reg_nextBitsRxCounter=0;
                //o_reg_nextData=0;
                //o_reg_data<=0;
                //o_reg_fail<=0;
           end
        end
        else if(reg_actualState == START_STATE) begin
        //cuento 7 ticks antes de pasar al siguiente estado para posicionarme en el centro del diente de sierra para poder tener un margen de error de 1/16
            if(i_tick)
                if(reg_ticksCounter==7) begin
                    reg_nextTicksCounter=0;
                    reg_nextBitsRxCounter=0;
                    reg_nextActualState = READ_DATA_STATE;
                end
                else begin
                    reg_nextTicksCounter=reg_ticksCounter+1;
                end
        end
        else if(reg_actualState == READ_DATA_STATE) begin
        //espero a tener 16 pulsos para poder ler el siguiente bit e ir conformando el dato
            if(i_tick)//stefano ojo que aca hiciste lo que quisiste XD jajajaj
                if(reg_ticksCounter==15) begin
                    reg_nextTicksCounter=0;
                    o_reg_nextData = {i_rxData, o_reg_data[7:1]};
                    
                    if(reg_bitsRxCounter==DATA_LENGTH-1)begin
                        reg_nextActualState=STOP_STATE;
                        reg_nextTicksCounter=0;// 
                        reg_nextBitsRxCounter=0;//
                    end 
                    else begin 
                        reg_nextBitsRxCounter=reg_bitsRxCounter+1;
                    end
                    //AGREGO EL BIT
                    
                end
                else begin
                    reg_nextTicksCounter=reg_ticksCounter+1; 
                end
            
            
        end
        else if(reg_actualState == STOP_STATE) begin
        //recibo el bit de verificaci?n 
            if(i_tick) begin 
                if(reg_ticksCounter==15)begin
                    if(i_rxData==1) begin
                         o_rxDone=1;
                         reg_nextActualState=IDLE_STATE;
                         reg_nextTicksCounter=0;
                    end
                    else begin
                        o_rxDone=0;
                        reg_nextActualState=IDLE_STATE;
                        reg_nextTicksCounter=0;
                    end
                end
                else begin
                    reg_nextTicksCounter=reg_ticksCounter+1;
                end
            end            
        end
        //cuenta 7 ticks antes de pasar a idle porque acordate que va a estar parado en la mitad del dato del bit de stop que es el cero
        //y si pasa al idle, al toque va a pasar a start y va a tomar el bit que no corresponde!!!
        else if (reg_actualState == REESTARTING_STATE) begin
            if(i_tick) begin
                o_rxDone=0;
                if(reg_ticksCounter==8)begin
                    reg_nextActualState=IDLE_STATE;
                end 
                else begin
                    reg_nextTicksCounter=reg_ticksCounter+1;
                end
            end
        end
        
    end
//assign o_rxDone= o_reg_rxDone;

    
endmodule