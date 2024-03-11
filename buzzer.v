module buzzer #(parameter CLOCK_FREQ) (
    input clock, // Clock do circuito
    input conta,
    input reset,

    input[3:0] seletor,

    output reg pulso  // Frequência da nota a ser tocada
);
    
    parameter DO =  264,
              RE =  300,
              SOL = 396,
              LA =  440; // Hz

    parameter COUNT_1 = (CLOCK_FREQ/DO),
              COUNT_2 = (CLOCK_FREQ/RE),
              COUNT_3 = (CLOCK_FREQ/SOL),
              COUNT_4 = (CLOCK_FREQ/LA);

    wire pulso_meio, pulso_quarto, pulso_oitavo, pulso_terco;

    /* Contadores para redução de clock */
    // 1/2 clock
    gerador_pwm #(.M(COUNT_1), .N($clog2(COUNT_1))) cont_2 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     (             ),
        .meio    ( pulso_meio  )
    );

    // 1/4 clock
    gerador_pwm #(.M(COUNT_2), .N($clog2(COUNT_2))) cont_4 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     (             ),
        .meio    ( pulso_quarto  )
    );

    // 1/8 clock
    gerador_pwm #(.M(COUNT_3), .N($clog2(COUNT_3))) cont_8 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     (             ),
        .meio    ( pulso_oitavo  )
    );

    // 1/3 clock
    gerador_pwm #(.M(COUNT_4), .N($clog2(COUNT_4))) cont_3 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( 1'b1        ),
        .Q       (             ),
        .fim     (             ),
        .meio    ( pulso_terco  )
    );

    /* Multiplexador para selecionar o pulso final 
        0001: 1/8 clock
        0010: 1/4 clock
        0100: 1/3 clock
        1000: 1/2 clock  */
    always @* begin
        case (seletor)
            4'b0001: pulso = pulso_oitavo;
            4'b0010: pulso = pulso_quarto;
            4'b0100: pulso = pulso_terco;
            4'b1000: pulso = pulso_meio;
            4'b0000: pulso = 4'b0;
            default: pulso = 4'b0;
        endcase
    end

endmodule