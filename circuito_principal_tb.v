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
          right_arrow_pressed_in,
          left_arrow_pressed_in,
          enter_pressed_in;

    reg [12:0] botoes_in;
        
    wire ganhou_out,
        perdeu_out,
        vez_jogador_out,
        pulso_buzzer_out,
        db_nota_correta_out,
        db_clock_out,
        db_enderecoIgualRodada_out,
        db_estado5_out,
        db_estado4_out,
        db_tempo_correto_out,
        db_metro,
        mostra_menu_out;

    wire [12:0] leds_out;

    wire [3:0] arduino_out;
    wire [2:0] menu_sel_out;

    wire [6:0] db_estado_lsb_out,
               db_memoria_tempo_out,
               db_memoria_nota_out,
               db_modo_out,
               db_menu_out,
               db_nota_out;

    always #((CLOCK_PERIOD / 2)) clock_in = ~clock_in;

    circuito_principal #(.CLOCK_FREQ(CLOCK_FREQ)) UUT (
        .clock(clock_in),
        .reset(reset_in),
        .iniciar(iniciar_in),
        .botoes(botoes_in),
        .right_arrow_pressed(right_arrow_pressed_in),
        .left_arrow_pressed(left_arrow_pressed_in),
        .enter_pressed(enter_pressed_in),

        .ganhou(ganhou_out),
        .perdeu(perdeu_out),
        .vez_jogador(vez_jogador_out),
        .mostra_menu(mostra_menu_out),
        .leds(leds_out),
        .pulso_buzzer(pulso_buzzer_out),
        .arduino_out(arduino_out),
        .menu_sel(menu_sel_out),

        .db_tempo_correto(db_tempo_correto_out),
        .db_nota_correta(db_nota_correta_out),
        .db_memoria_nota(db_memoria_nota_out),
        .db_memoria_tempo(db_memoria_tempo_out),
        .db_estado_lsb(db_estado_lsb_out),
        .db_estado5(db_estado5_out),
        .db_estado4(db_estado4_out),
        .db_nota(db_nota_out),
        .db_metro(db_metro_out),
        .db_modo(db_modo_out),
        .db_menu(db_menu_out),
        .db_clock(db_clock_out),
        .db_enderecoIgualRodada(db_enderecoIgualRodada_out)
    );

    /*
    Task para apertar o botões com um valor desejado, esperando 3 períodos de clock para soltar
  */
  task press_botoes;
    input [3:0] valor, tempo;
    begin: corpo
      integer k;
      reg [12:0] tmp_botoes;
      #(CLOCK_PERIOD);
      for (k=0;k<13;k=k+1) begin
        if (k + 1== valor) tmp_botoes[k] = 1'b1;
        else tmp_botoes[k] = 1'b0;
      end
      botoes_in = tmp_botoes;
      #(tempo*0.5*CLOCK_FREQ*CLOCK_PERIOD);
      botoes_in = 13'b0;
      #(4*CLOCK_PERIOD);
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

  task apresenta_rodada;
  input [31:0] rodada;
  begin: corpo_apresenta_rodada
    integer k;
    #(0.5*CLOCK_FREQ*CLOCK_PERIOD);
    for (k = 0; k < rodada; k = k + 1) begin
        $display("%d %d %d", rodada, tempos[k], wait_time(tempos[k]));
        #(wait_time(tempos[k]) + 2*CLOCK_PERIOD*(rodada-1));
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
      apresenta_rodada(i);
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
        botoes_in           = 12'd0;
        right_arrow_pressed_in = 1'b0;
        left_arrow_pressed_in = 1'b0;
        enter_pressed_in       = 1'b0;

        /*//************************************************************************************************
        //    Inicia o circuito e digita todas as 16 notas certas
        //*************************************************************************************************
        cenario = 1;
        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // confirma modo
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        acerta_rodadas(16);

        #(5*CLOCK_PERIOD);
        //*/

        /*//************************************************************************************************
        //    Inicia o circuito e digita 5 notas certas, errando a sexta. Apresenta notas novamente
        //*************************************************************************************************
        cenario = 2;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // confirma modo
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        acerta_rodadas(5); // Acerta 5 rodadas
        apresenta_rodada(6); // Aprenseta os valores da sexta rodada
        acerta_valores(5); // Acerta 5 notas
        press_botoes(4'd5, 4'd4); // Erra a sexta nota

        #(5*CLOCK_PERIOD);

        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        #(5*CLOCK_FREQ*CLOCK_PERIOD);

        //*/

        /*//************************************************************************************************
        //    Inicia o circuito no modo 3 e tocar a primeira música
        //*************************************************************************************************
        
        cenario = 3;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // muda modo para 2
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // muda modo para 3
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma modo
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);
        #(100*CLOCK_PERIOD);

        acerta_valores(16);
        #(40*CLOCK_FREQ*CLOCK_PERIOD); // Passa 4 segundos
        //*/

        /*//************************************************************************************************
        //    Iniciar o circuito no modo 4 - freestyle
        //*************************************************************************************************

          cenario = 4;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // muda modo para 2
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);
        
        // muda modo para 3
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // muda modo para 4
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma modo
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);
        #(100*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        press_botoes(4'h1, 3);
        press_botoes(4'h0, 3);
        press_botoes(4'hA, 4);
        press_botoes(4'hB, 2);

        //*/

        /*//************************************************************************************************
        //    Iniciar o circuito no modo 2 - nota a nota
        //*************************************************************************************************
        
        cenario = 5;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // muda modo para 2
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma modo
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);
        #(100*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        right_arrow_pressed_in = 0;
        #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);
        #(100*CLOCK_PERIOD);

        #(5*CLOCK_PERIOD);
        #(3*0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(5*CLOCK_PERIOD);
        
        press_botoes(4'h3, 3);
        
        #(5*CLOCK_PERIOD);
        #(4*0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(5*CLOCK_PERIOD);
        
        press_botoes(4'h5, 4);

        #(5*CLOCK_PERIOD);
        #(1*0.5*CLOCK_FREQ*CLOCK_PERIOD);
        #(5*CLOCK_PERIOD);

        press_botoes(4'h9, 1);

        #(5*CLOCK_PERIOD);

         // apresenta a última
        enter_pressed_in = 1;
        #(5*CLOCK_PERIOD);
        enter_pressed_in = 0;
        #(10*CLOCK_PERIOD);
        #(100*CLOCK_PERIOD);

        #(5*CLOCK_FREQ*CLOCK_PERIOD);

        //*/

        /*//************************************************************************************************
        //    Inicia o circuito no modo de sem apresentação e digita 5 notas
        //*************************************************************************************************
        cenario = 6;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // muda modo para 2
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda modo para 3
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma modo
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        acerta_valores(5);

        #(5*CLOCK_PERIOD);

        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        #(5*CLOCK_FREQ*CLOCK_PERIOD);

        //*/

        /*//************************************************************************************************
        //    Inicia o circuito no modo de sem apresentação e digita 5 notas, errando na sexta e 
        //    apresentando última
        //*************************************************************************************************
        cenario = 7;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // muda modo para 2
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda modo para 3
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma modo
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        acerta_valores(5);

        press_botoes(4'hC, 3);

        #(5*CLOCK_PERIOD);

        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        #(5*CLOCK_FREQ*CLOCK_PERIOD);

        //*/

        /*//************************************************************************************************
        //    Inicia o circuito no modo de sem apresentação e digita 5 notas, errando na sexta e 
        //    apresentando todas
        //*************************************************************************************************
        cenario = 8;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // muda modo para 2
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda modo para 3
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma modo
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        acerta_valores(5);

        press_botoes(4'hC, 3);

        #(5*CLOCK_PERIOD);

        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        #(5*CLOCK_FREQ*CLOCK_PERIOD);

        //*/

        ///************************************************************************************************
        //    Inicia o circuito no modo de sem apresentação e digita 5 notas, errando na sexta e 
        //    tentando novamente, acertando mais 3 e errando na nona
        //*************************************************************************************************
        cenario = 9;

        @(negedge clock_in);
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        
        #(CLOCK_PERIOD);
        iniciar_in = 1;
        #(CLOCK_PERIOD);
        iniciar_in = 0;

        // muda modo para 2
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda modo para 3
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma modo
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma bpm
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma tom
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        // muda musica para 1
        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);

        // confirma musica
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        acerta_valores(5);

        press_botoes(4'hC, 3);

        #(5*CLOCK_PERIOD);

        right_arrow_pressed_in = 1; #(5*CLOCK_PERIOD); right_arrow_pressed_in = 0; #(10*CLOCK_PERIOD);
        enter_pressed_in = 1; #(5*CLOCK_PERIOD); enter_pressed_in = 0; #(10*CLOCK_PERIOD);

        acerta_valores(8);

        press_botoes(4'hC, 3);

        #(5*CLOCK_FREQ*CLOCK_PERIOD);

        //*/

        $finish;
       
    end


endmodule
