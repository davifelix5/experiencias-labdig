module buzzer (
    input clock, // Clock do circuito
    input conta,
    input reset,

    input[3:0] seletor,

    output pulso  // Frequência da nota a ser tocada
);

    wire pulso_meio, pulso_quarto, pulso_oitavo, pulso_terco;

    reg[1:0] seletor_final;

    /* Contadores para redução de clock */
    // 500Hz
    contador_m #(.M(2), .N(1)) cont_500Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_meio ),
        .meio    (             )
    );

    // 250Hz
    contador_m #(.M(4), .N(2)) cont_250Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_quarto ),
        .meio    (             )
    );

    // 125Hz
    contador_m #(.M(8), .N(3)) cont_125Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_oitavo ),
        .meio    (             )
    );

    // 333Hz
    contador_m #(.M(3), .N(2)) cont_333Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( 1'b1        ),
        .Q       (             ),
        .fim     ( pulso_terco ),
        .meio    (             )
    );

    /* Decodificador para obter o seletor do mux */
    always @* begin
        case (seletor)
            4'b0001: seletor_final = 3'b00;
            4'b0010: seletor_final = 3'b01;
            4'b0100: seletor_final = 3'b10;
            4'b1000: seletor_final = 3'b11;
            default: seletor_final = 3'b00;
        endcase
    end

    /* 
        Multiplexador para selecionar o pulso final 
            0001: 1/8 clock
            0010: 1/4 clock
            0100: 1/3 clock
            1000: 1/2 clock
    */
    assign pulso = !conta ? 1'b0 : ( // garante a saída é 0 quando não toca
        seletor_final[1] ? 
            ( seletor_final[0] ? pulso_meio : pulso_terco )
        :
            (seletor_final [0] ? pulso_quarto : pulso_oitavo)
    );


endmodule