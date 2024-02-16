module buzzer (
    input clock, // Clock do circuito
    input conta,
    input reset,

    input[3:0] seletor,

    output reg pulso  // Frequência da nota a ser tocada
);

    wire pulso_meio, pulso_quarto, pulso_oitavo, pulso_terco;

    reg[1:0] seletor_final;

    /* Contadores para redução de clock */
    // 1/2 clock
    contador_m #(.M(2), .N(1)) cont_2 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_meio ),
        .meio    (             )
    );

    // 1/4 clock
    contador_m #(.M(4), .N(2)) cont_4 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_quarto ),
        .meio    (             )
    );

    // 1/8 clock
    contador_m #(.M(8), .N(3)) cont_8 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_oitavo ),
        .meio    (             )
    );

    // 1/3 clock
    contador_m #(.M(3), .N(2)) cont_3 ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( 1'b1        ),
        .Q       (             ),
        .fim     ( pulso_terco ),
        .meio    (             )
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