`timescale 100us/100us

module circuito_principal_tb;

    parameter CLOCK_FREQ = 5000, // Hz
              CLOCK_PERIOD = 2;  //s

    integer cenario;

    reg  clock_in,
          reset_in,
          iniciar_in,
          apresenta_ultima_in,
          tentar_dnv_rep_in,
          tentar_dnv_in;

    reg [11:0] botoes_in;
        
    wire ganhou_out,
        perdeu_out,
        vez_jogador_out,
        pulso_buzzer_out,
        db_nota_correta_out,
        db_clock_out,
        db_enderecoIgualRodada_out,
        db_estado_msb_out,
        db_tempo_correto_out;

    wire [11:0] leds_out;

    wire [6:0] db_estado_lsb_out,
               db_memoria_tempo_out,
               db_memoria_nota_out,
               db_rodada_out,
               db_contagem_out,
               db_nota_out;

    always #((CLOCK_PERIOD / 2)) clock_in = ~clock_in;

    circuito_principal #(.CLOCK_FREQ(CLOCK_FREQ)) UUT (
        .clock(clock_in),
        .reset(reset_in),
        .iniciar(iniciar_in),
        .botoes(botoes_in),
        .apresenta_ultima(apresenta_ultima_in),
        .tentar_dnv_rep(tentar_dnv_rep_in),
        .tentar_dnv(tentar_dnv_in),

        .ganhou(ganhou_out),
        .perdeu(perdeu_out),
        .vez_jogador(vez_jogador_out),
        .leds(leds_out),
        .pulso_buzzer(pulso_buzzer_out),

        .db_tempo_correto(db_tempo_correto_out),
        .db_nota_correta(db_nota_correta_out),
        .db_contagem(db_contagem_out),
        .db_memoria_nota(db_memoria_nota_out),
        .db_memoria_tempo(db_memoria_tempo_out),
        .db_estado_lsb(db_estado_lsb_out),
        .db_estado_msb(db_estado_msb_out),
        .db_nota(db_nota_out),
        .db_rodada(db_rodada_out),
        .db_clock(db_clock_out),
        .db_enderecoIgualRodada(db_enderecoIgualRodada_out)
    );
    

    initial begin
        $dumpfile("./waveforms.vcd");
        $dumpvars(0, circuito_principal_tb);

        /************************************************************************************************
            Condições iniciais 
        *************************************************************************************************/
        clock_in            = 1'b0;
        reset_in            = 1'b0;
        iniciar_in          = 1'b0;
        botoes_in           = 12'b0;
        apresenta_ultima_in = 1'b0;
        tentar_dnv_rep_in   = 1'b0;
        tentar_dnv_in       = 1'b0;

        /************************************************************************************************
            Inicia o circuito e digita uma nota certa
        *************************************************************************************************/
        cenario = 1;
        @(negedge clock_in);
        iniciar_in = 1;
        #(CLOCK_PERIOD)
        iniciar_in = 0;
        
        // Apresenta a primeira nota
        #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(CLOCK_PERIOD);
        #(1.5*CLOCK_FREQ*CLOCK_PERIOD); // Aperta por 1,5s
        #(10*CLOCK_PERIOD);

        // Aciona a primeira nota
        botoes_in = 12'b000000000100;
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b0;
        #(10*CLOCK_PERIOD);

        /************************************************************************************************
            Inicia o circuito e digita uma nota no tempo errado e fora da tolerância
        *************************************************************************************************/
        cenario = 2;
        // Reseta o circuito
        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        #(CLOCK_PERIOD);

        // Inicia o circuito
        iniciar_in = 1;
        #(CLOCK_PERIOD)
        iniciar_in = 0;
        
        // Apresenta a primeira nota
        #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(CLOCK_PERIOD);
        #(1.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(10*CLOCK_PERIOD);

        // Aciona a primeira nota
        botoes_in = 12'b000000000100;
        #(3000*CLOCK_PERIOD); // Aperta por pouco tempo 
        botoes_in = 12'b0;
        #(10*CLOCK_PERIOD);

        /************************************************************************************************
            Inicia o circuito e digita uma nota no tempo errado, mas dentro da tolerância para baixo
        *************************************************************************************************/
        cenario = 3;
        // Reseta o circuito
        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        #(CLOCK_PERIOD);

        // Inicia o circuito
        iniciar_in = 1;
        #(CLOCK_PERIOD)
        iniciar_in = 0;
        
        // Apresenta a primeira nota
        #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(CLOCK_PERIOD);
        #(1.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(10*CLOCK_PERIOD);

        // Aciona a primeira nota
        botoes_in = 12'b000000000100;
        #(7120*CLOCK_PERIOD); // Aperta por pouco tempo 
        botoes_in = 12'b0;
        #(10*CLOCK_PERIOD);

        /************************************************************************************************
            Inicia o circuito e digita uma nota no tempo errado, mas dentro da tolerância para cima
        *************************************************************************************************/
        cenario = 4;
        // Reseta o circuito
        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        #(CLOCK_PERIOD);

        // Inicia o circuito
        iniciar_in = 1;
        #(CLOCK_PERIOD)
        iniciar_in = 0;
        
        // Apresenta a primeira nota
        #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(CLOCK_PERIOD);
        #(1.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(10*CLOCK_PERIOD);

        // Aciona a primeira nota
        botoes_in = 12'b000000000100;
        #(8500*CLOCK_PERIOD); // Aperta por muito tempo 
        botoes_in = 12'b0;
        #(10*CLOCK_PERIOD);

        /************************************************************************************************
            Erro o tempo e joga novamente sem repetir
        *************************************************************************************************/
        cenario = 5;
        // Reseta o circuito
        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        #(CLOCK_PERIOD);

        // Inicia o circuito
        iniciar_in = 1;
        #(CLOCK_PERIOD)
        iniciar_in = 0;
        
        // Apresenta a primeira nota
        #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(CLOCK_PERIOD);
        #(1.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(10*CLOCK_PERIOD);

            
        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        
        
        #((2500 + 7500 + 10000 + 10 + 2500)*CLOCK_PERIOD); // Apresentação da segunda rodada

        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        botoes_in = 12'b000000010000; // Segunda nota
        #(13100*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        tentar_dnv_in = 1;
        #(5*CLOCK_PERIOD);
        tentar_dnv_in = 0;

        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        botoes_in = 12'b000000010000; // Segunda nota
        #(10000*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        /************************************************************************************************
            Erro o tempo e mostra novamente repetindo
        *************************************************************************************************/
        cenario = 6;
        // Reseta o circuito
        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        #(CLOCK_PERIOD);

        // Inicia o circuito
        iniciar_in = 1;
        #(CLOCK_PERIOD)
        iniciar_in = 0;
        
        // Apresenta a primeira nota
        #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(CLOCK_PERIOD);
        #(1.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(10*CLOCK_PERIOD);

            
        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        
        
        #((2500 + 7500 + 10000 + 10 + 2500)*CLOCK_PERIOD); // Apresentação da segunda rodada

        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        botoes_in = 12'b000000010000; // Segunda nota
        #(13100*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        tentar_dnv_rep_in = 1;
        #(5*CLOCK_PERIOD);
        tentar_dnv_rep_in = 0;

        #((2500 + 7500 + 10000 + 10 + 2500)*CLOCK_PERIOD); // Apresentação da segunda rodada

        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        botoes_in = 12'b000000010000; // Segunda nota
        #(10000*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);


        /************************************************************************************************
            Erro o tempo e mostra a última novamente
        *************************************************************************************************/
        cenario = 7;
        // Reseta o circuito
        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        #(CLOCK_PERIOD);

        // Inicia o circuito
        iniciar_in = 1;
        #(CLOCK_PERIOD)
        iniciar_in = 0;
        
        // Apresenta a primeira nota
        #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(CLOCK_PERIOD);
        #(1.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(10*CLOCK_PERIOD);

            
        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        
        
        #((2500 + 7500 + 10000 + 10 + 2500)*CLOCK_PERIOD); // Apresentação da segunda rodada

        botoes_in = 12'b000000000100; // Primeira nota
        #(7500*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        botoes_in = 12'b000000010000; // Segunda nota
        #(13100*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        apresenta_ultima_in = 1;
        #(5*CLOCK_PERIOD);
        apresenta_ultima_in = 0;

        #((10000)*CLOCK_PERIOD); // Apresentação da segunda jogada
        #(5*CLOCK_PERIOD);

        botoes_in = 12'b000000010000; // Segunda nota
        #(10000*CLOCK_PERIOD);
        botoes_in = 12'b000000000000;
        #(10*CLOCK_PERIOD);

        


        $finish;

    end


endmodule