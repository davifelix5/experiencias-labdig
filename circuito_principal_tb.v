`timescale 100us/100us

module circuito_principal_tb;

    parameter CLOCK_FREQ = 5000, // Hz
              CLOCK_PERIOD = 2;  //s

    reg[4:0] valores[0:31];
    reg[4:0] tempos[0:31];
    
    initial begin
        $readmemh("ram_init/ram_init_notas_1.txt", valores);
        $readmemh("ram_init/ram_init_tempos_1.txt", tempos);
    end
 
    integer cenario;

    reg  clock_in,
          reset_in,
          iniciar_in,
          apresenta_ultima_in,
          tentar_dnv_rep_in,
          tentar_dnv_in,
          metronomo_120BPM_in,
          apresenta_todas_as_notas_in;

    reg [3:0] botoes_encoded_in;
        
    wire ganhou_out,
        perdeu_out,
        vez_jogador_out,
        pulso_buzzer_out,
        db_nota_correta_out,
        db_clock_out,
        db_enderecoIgualRodada_out,
        db_estado_msb_out,
        db_tempo_correto_out,
        db_metro;

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
        .botoes_encoded(botoes_encoded_in),
        .apresenta_ultima(apresenta_ultima_in),
        .tentar_dnv_rep(tentar_dnv_rep_in),
        .tentar_dnv(tentar_dnv_in),
        .metronomo_120BPM(metronomo_120BPM_in),
        .apresenta_todas_as_notas(apresenta_todas_as_notas_in),

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
        .db_metro(db_metro_out),
        .db_clock(db_clock_out),
        .db_enderecoIgualRodada(db_enderecoIgualRodada_out)
    );

    /*
    Task para apertar o botões com um valor desejado, esperando 3 períodos de clock para soltar
  */
  task press_botoes;
    input [3:0] valor, tempo;
    begin
      #(2*CLOCK_PERIOD);
      botoes_encoded_in = valor;
      #(tempo*0.5*CLOCK_FREQ*CLOCK_PERIOD);
      botoes_encoded_in = 4'b0000;
      #(2*CLOCK_PERIOD);
    end
  endtask 
  
  /*
    Função para calcular a quantidade de ciclos de clock que devem ser esperados até o fim da apresentação.
    Recebe a rodada que está sendo apresentada.
  */
  function automatic integer wait_time;
  input [31:0] tempo;
  wait_time = CLOCK_PERIOD*(tempo*0.5*CLOCK_FREQ);
  endfunction

  /*
    Task para acertar valores consecutivos em uma rodada.
    Lê os valores certos de um arquivo .dat e aperta os botões de acordo com eles.
    Recebe a quantidade de valores consecutivos que devem ser acertados.
  */
  task acerta_valores;
  input integer quantidade;
  begin: corpo_task
    integer j;
    for (j = 0; j < quantidade; j = j + 1) begin
        press_botoes(valores[j], tempos[j]);
    end
  end
  endtask

  /*
    Task para acertar rodadas consecutivamente.
    Recebe a quantidade de rodadas a serem acertadas.
  */
  task acerta_rodadas;
  input integer quantidade_rodadas;
  begin: corpo_acerta_rodadas
    integer i, k;
    
    for (i = 1; i <= quantidade_rodadas; i = i + 1) begin
      // Espera o tempo de aprensetação da rodada
      #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
      for (k = 0; k < i; k = k + 1) begin
        $display("%d %d %d", i, tempos[k], wait_time(tempos[k]));
        #(wait_time(tempos[k]) + 2*CLOCK_PERIOD*(i-1));
      end
      // Acerta os valores
      acerta_valores(i);
    end
  end
  endtask

  /*
    Task para realizar o processo de iniciar o circuito.
    Recebe os níveis de tempo e de jogadas que deverão ser adotados no jogo a ser iniciado. 
  */
  task iniciar_circuito;
  begin
    @(negedge clock_in)
    iniciar_in = 1;
    #(3.5*CLOCK_PERIOD)
    iniciar_in = 0;
  end
  endtask
    

    initial begin
        $dumpfile("./waveforms.vcd");
        $dumpvars(0, circuito_principal_tb);

        /************************************************************************************************
            Condições iniciais 
        *************************************************************************************************/
        clock_in            = 1'b0;
        reset_in            = 1'b0;
        iniciar_in          = 1'b0;
        botoes_encoded_in           = 4'd0;
        apresenta_ultima_in = 1'b0;
        tentar_dnv_rep_in   = 1'b0;
        tentar_dnv_in       = 1'b0;
        metronomo_120BPM_in = 1'b0;
        apresenta_todas_as_notas_in = 1'b0;

        ///************************************************************************************************
        //    Inicia o circuito e digita uma nota certa
        //*************************************************************************************************
        iniciar_circuito();

        acerta_rodadas(16);

        #(5*CLOCK_PERIOD);
        //*/
        
        $finish;
       
    end


endmodule