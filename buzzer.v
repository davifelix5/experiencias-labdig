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
    
    parameter N = 12, SIZE = 13;
    // Array de frequências
    parameter [(N*SIZE-1):0] frequencias1 = {
        13'd523, 13'd554, 13'd587, 
        13'd622, 13'd659, 13'd698, 
        13'd734, 13'd783, 13'd830, 
        13'd880, 13'd932, 13'd988
    };

    parameter [(N*SIZE-1):0] frequencias2 = {
        13'd1046, 13'd1108, 13'd1174, 
        13'd1244, 13'd1318, 13'd1397, 
        13'd1480, 13'd1568, 13'd1661, 
        13'd1760, 13'd1864, 13'd1975
    };
    parameter [(N*SIZE-1):0] frequencias3 = {
        13'd2093, 13'd2217, 13'd2349, 
        13'd2489, 13'd2637, 13'd2793, 
        13'd2960, 13'd3136, 13'd3322, 
        13'd3502, 13'd3729, 13'd3951
    };
    parameter [(N*SIZE-1):0] frequencias4 = {
        13'd4186, 13'd4435, 13'd4698, 
        13'd4978, 13'd5274, 13'd5587, 
        13'd5919, 13'd6271, 13'd6645, 
        13'd7040, 13'd7438, 13'd7902
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