module buzzer (
    input clock, // 1kHz
    input conta,
    input reset,

    input[3:0] seletor,

    output pulso  // Frequência da nota a ser tocada
);

    wire pulso_500hz, pulso_250hz, pulso_125hz, pulso_333hz;

    reg[1:0] seletor_final;

    /* Contadores para redução de clock */
    // 500Hz
    contador_m #(.M(2), .N(1)) cont_500Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_500hz ),
        .meio    (             )
    );

    // 250Hz
    contador_m #(.M(4), .N(2)) cont_250Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_250hz ),
        .meio    (             )
    );

    // 125Hz
    contador_m #(.M(8), .N(3)) cont_125Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( conta       ),
        .Q       (             ),
        .fim     ( pulso_125hz ),
        .meio    (             )
    );

    // 333Hz
    contador_m #(.M(3), .N(2)) cont_333Hz ( 
        .clock   ( clock       ), 
        .zera_s  ( reset       ), 
        .zera_as (             ), 
        .conta   ( 1'b1        ),
        .Q       (             ),
        .fim     ( pulso_333hz ),
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
            0001: 125Hz
            0010: 250Hz
            0100: 333Hz
            1000: 500Hz
    */
    assign pulso = !conta ? 1'b0 : (
        seletor_final[1] ? 
            ( seletor_final[0] ? pulso_500hz : pulso_333hz )
        :
            (seletor_final [0] ? pulso_250hz : pulso_125hz)
    );


endmodule