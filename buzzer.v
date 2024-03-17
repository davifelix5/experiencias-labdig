module buzzer #(parameter CLOCK_FREQ) (
    input clock, // Clock do circuito
    input toca,
    input reset,

    input[11:0] seletor,

    output pulso  // Frequência da nota a ser tocada
);

    genvar i;
    wire [0:11] pulsos;
    wire [3:0]  seletor_pulso;
    
    parameter N = 16, SIZE = 12;
    // Array de frequências
    parameter [0:(N*SIZE-1)] frequencias = {12'd264, 12'd297, 12'd330, 
    12'd352, 12'd396, 12'd440, 
    12'd495, 12'd528, 12'd201, 
    12'd201, 12'd201, 12'd201,
    12'd201, 12'd201, 12'd201, 12'd201  };

    generate
        for (i=0; i <12; i = i + 1) begin: GENERATE_PULSES
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias[i*SIZE+:SIZE])) ) cont_2 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[i]     )
            );
        end
    endgenerate

    encoder_nota CodificaNota (
        .nota   ( seletor ),
        .enable (1'b1),
        .valor  (seletor_pulso)
    );

    assign pulso = toca ? pulsos[seletor_pulso] : 0;

endmodule