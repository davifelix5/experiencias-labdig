module buzzer #(parameter CLOCK_FREQ, TOM=4) (
    input clock, // Clock do circuito
    input toca,
    input reset,

    input[3:0] seletor,
    input[$clog2(TOM) - 1:0]  tom,

    output pulso  // Frequência da nota a ser tocada
);

    genvar i;
    wire [1:13] pulsos[0:3];
    wire [3:0]  seletor_pulso;
    
    localparam N = 13, SIZE = 14;
    // Array de frequências
    localparam [(N*SIZE-1):0] frequencias1 = {
        14'd523, 14'd554, 14'd587, 
        14'd622, 14'd659, 14'd698, 
        14'd734, 14'd783, 14'd830, 
        14'd880, 14'd932, 14'd988, 14'd1046
    };

    localparam [(N*SIZE-1):0] frequencias2 = {
        14'd1046, 14'd1108, 14'd1174, 
        14'd1244, 14'd1318, 14'd1397, 
        14'd1480, 14'd1568, 14'd1661, 
        14'd1760, 14'd1864, 14'd1975, 14'd2093
    };
    localparam [(N*SIZE-1):0] frequencias3 = {
        14'd2093, 14'd2217, 14'd2349, 
        14'd2489, 14'd2637, 14'd2793, 
        14'd2960, 14'd3136, 14'd3322, 
        14'd3502, 14'd3729, 14'd3951, 14'd4186
    };
    localparam [(N*SIZE-1):0] frequencias4 = {
        14'd4186, 14'd4435, 14'd4698, 
        14'd4978, 14'd5274, 14'd5587, 
        14'd5919, 14'd6271, 14'd6645, 
        14'd7040, 14'd7438, 14'd7902, 14'd8273
    };

    generate
        for (i=1; i <= 13; i = i + 1) begin: GENERATE_PULSES
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias1[(i-1)*SIZE+:SIZE])) ) cont_1 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[0][i]  )
            );
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias2[(i-1)*SIZE+:SIZE])) ) cont_2 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[1][i]  )
            );
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias3[(i-1)*SIZE+:SIZE])) ) cont_3 ( 
                .clock   ( clock         ), 
                .zera_s  ( reset         ), 
                .zera_as (               ), 
                .conta   ( toca          ),
                .Q       (               ),
                .fim     (               ),
                .meio    ( pulsos[2][i]  )
            );
            gerador_pwm #( .M(CLOCK_FREQ/(frequencias4[(i-1)*SIZE+:SIZE])) ) cont_4 ( 
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

    assign pulso = (toca & |seletor) ? pulsos[tom][seletor] : 1'b0;

endmodule