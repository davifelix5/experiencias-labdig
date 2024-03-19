module buzzer #(parameter CLOCK_FREQ, TOM=4) (
    input clock, // Clock do circuito
    input toca,
    input reset,

    input[3:0] seletor,
    input[$clog2(TOM) - 1:0]  tom,

    output pulso  // Frequência da nota a ser tocada
);

    genvar i;
    wire [0:11] pulsos[0:3];
    wire [3:0]  seletor_pulso;
    
    parameter N = 12, SIZE = 12;
    // Array de frequências
    parameter [0:(N*SIZE-1)] frequencias1 = {
        12'd264, 12'd297, 12'd330, 
        12'd352, 12'd396, 12'd440, 
        12'd495, 12'd528, 12'd345, 
        12'd345, 12'd345, 12'd345
    };

    parameter [0:(N*SIZE-1)] frequencias2 = {
        12'd365, 12'd297, 12'd330, 
        12'd352, 12'd396, 12'd440, 
        12'd495, 12'd528, 12'd520, 
        12'd520, 12'd520, 12'd520
    };
    parameter [0:(N*SIZE-1)] frequencias3 = {
        12'd264, 12'd297, 12'd210, 
        12'd352, 12'd396, 12'd440, 
        12'd495, 12'd528, 12'd201, 
        12'd201, 12'd201, 12'd201
    };
    parameter [0:(N*SIZE-1)] frequencias4 = {
        12'd264, 12'd297, 12'd182, 
        12'd352, 12'd396, 12'd440, 
        12'd495, 12'd528, 12'd201, 
        12'd201, 12'd201, 12'd201
    };

    generate
        for (i=0; i <12; i = i + 1) begin: GENERATE_PULSES
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias1[i*SIZE+:SIZE])) ) cont_1 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[0][i]  )
            );
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias2[i*SIZE+:SIZE])) ) cont_2 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[1][i]  )
            );
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias3[i*SIZE+:SIZE])) ) cont_3 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[2][i]  )
            );
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias4[i*SIZE+:SIZE])) ) cont_4 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[3][i]  )
            );
        end
    endgenerate

    assign pulso = toca ? pulsos[tom][seletor] : 0;

endmodule