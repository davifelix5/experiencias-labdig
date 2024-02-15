/* --------------------------------------------------------------------
 * Arquivo   : circuito_exp6_tb.v
 * Projeto   : Experiencia 6 - Desenvolvimento de Projeto de 
 *             Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : testbench Verilog para circuito da Experiencia 6
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                          Descricao
 *     14/02/2024  2.0     Caio Dourado, Davi Félix, Vinicius Batista     versao inicial
 * --------------------------------------------------------------------
*/

`timescale 1ns/1ns

module circuito_exp6_tb;

  // Sinais para conectar com o DUT
  // valores iniciais para fins de simulacao (ModelSim)
  reg        clock_in;
  reg        reset_in;
  reg        iniciar_in;
  reg  [3:0] botoes_in;
  reg        nivel_jogadas_in; 
  reg        nivel_tempo_in;
  reg  [3:0] valores [0:15];
  reg  [7:0] resultados [0:12];

  wire       ganhou_out;
  wire       perdeu_out;
  wire       pronto_out;
  wire       vez_jogador_out;
  wire [3:0] leds_out;

  wire       db_jogada_correta;
  wire [6:0] db_contagem;
  wire [6:0] db_memoria;
  wire [6:0] db_estado;
  wire [6:0] db_jogada;
  wire       db_nivel_jogadas;
  wire       db_nivel_tempo;
  wire       db_clock;
  wire       db_enderecoIgualRodada;
  wire       db_timeout;
  wire [6:0] db_rodada;

  //Recupera valores da memória
  initial begin
    $readmemh("valores.dat", valores, 4'b0, 4'hF); 
  end 

  // Configuração do clock
  parameter clockPeriod = 20; // in ns, f=50MHz

  // Identificacao do caso de teste
  integer caso = 0;
  integer cenario = 0;

  // Gerador de clock
  always #((clockPeriod / 2)) clock_in = ~clock_in;

  // instanciacao do DUT (Device Under Test)
  circuito_exp6 DUT (
    .clock            (clock_in),
    .reset            (reset_in),
    .iniciar          (iniciar_in),
    .botoes           (botoes_in),
    .nivel_jogadas    (nivel_jogadas_in), 
    .nivel_tempo      (nivel_tempo_in),

    .ganhou           (ganhou_out),
    .perdeu           (perdeu_out),
    .pronto           (pronto_out),
	  .vez_jogador      (vez_jogador_out),
    .leds             (leds_out),

    .db_jogada_correta      (db_jogada_correta),
    .db_contagem            (db_contagem),
    .db_memoria             (db_memoria),
    .db_estado              (db_estado),
    .db_jogada              (db_jogada),
    .db_rodada              (db_rodada),
    .db_nivel_jogadas       (db_nivel_jogadas),
    .db_nivel_tempo         (db_nivel_tempo),
    .db_clock               (db_clock),
    .db_enderecoIgualRodada (db_enderecoIgualRodada),
    .db_timeout             (db_timeout)
  );

  /*
    Atualiza os resultados a serem comparados
  */
  task atualiza_resultado;
  begin
    resultados[0] = hexa(db_contagem);
    resultados[1] = hexa(db_memoria);
    resultados[2] = hexa(db_estado);
    resultados[3] = hexa(db_jogada);
    resultados[4] = hexa(db_rodada);
    resultados[5] = db_jogada_correta;
    resultados[6] = db_nivel_jogadas;
    resultados[7] = db_nivel_tempo;
    resultados[8] = db_enderecoIgualRodada;
    resultados[9] = db_timeout;
    resultados[10] = ganhou_out;
    resultados[11] = perdeu_out;
    resultados[12] = pronto_out;
  end
  endtask

  /*
    Task que mostra os valores dos sinais de output do DUT
  */
  task display_outputs;
    begin
      $display("---- Resultado cenário %2d ----", cenario);
      $display("contagem = %2h", hexa(db_contagem));
      $display("memoria = %2h", hexa(db_memoria));
      $display("estado = %2h", hexa(db_estado));
      $display("jogada = %2h", hexa(db_jogada));
      $display("rodada = %2h", hexa(db_rodada));
      $display("jogada_correta = %b", db_jogada_correta);
      $display("nivel_jogadas = %b", db_nivel_jogadas);
      $display("nivel_tempo = %b", db_nivel_tempo);
      $display("enderecoIgualRodada = %b", db_enderecoIgualRodada);
      $display("timeout = %b", db_timeout);
      $display("ganhou = %b", ganhou_out);
      $display("perdeu = %b", perdeu_out);
      $display("pronto = %b", pronto_out);

    end
  endtask 

  /*
    Task responsável por comparar os valores esperados com os resultados obtidos do circuito
  */
  task compara_resultados;
    input [7:0] contagem, estado, jogada, rodada;
    input jogada_correta, nivel_jogadas, nivel_tempo, enderecoIgualRodada, timeout, ganhou, perdeu, pronto;
    begin: corpo_task
      reg [7:0] esperado [0:12];
      integer erros, i;
      erros = 0;

      esperado[0] = contagem;
      esperado[1] = valores[esperado[0]];
      esperado[2] = estado;
      esperado[3] = jogada;
      esperado[4] = rodada;
      esperado[5] = jogada_correta;
      esperado[6] = nivel_jogadas;
      esperado[7] = nivel_tempo;
      esperado[8] = enderecoIgualRodada;
      esperado[9] = timeout;
      esperado[10] = ganhou;
      esperado[11] = perdeu;
      esperado[12] = pronto;

      display_outputs();
      atualiza_resultado();

      for (i = 0; i < 13; i = i + 1) begin
        if (esperado[i] != resultados[i]) begin
          erros = erros + 1;
          $display("ERRO! Esperado diferente do observado! Resultado index: %2h", i + 1);
          $display("Esperado: %2h Observado: %2h", esperado[i], resultados[i]);
        end
      end  
      $display("Fim cenário %2d. Obteve %2d erros.", cenario, erros);   
      $display("------------------------------\n");

    end
  endtask

  /*
    Task para apertar o botões com um valor desejado, esperando 3 períodos de clock para soltar
  */
  task press_botoes;
    input [3:0] valor;
    begin
      botoes_in = valor;
      #(3*clockPeriod);
      botoes_in = 4'b0000;
      #(3*clockPeriod);
    end
  endtask 
  
  /*
    Função para calcular a quantidade de ciclos de clock que devem ser esperados até o fim da apresentação.
    Recebe a rodada que está sendo apresentada.
  */
  function automatic integer wait_time;
  input [31:0] step;
  wait_time = (step*1000+(step-1)*502+1);
  endfunction

  /*
  Task que transforma um código de 7 segmentos em um valor em hexadecimal
  */
  function automatic integer hexa;
  input [6:0] valor_7seg;
  begin
    case (valor_7seg)
      7'b1000000: hexa = 4'h0;
      7'b1111001: hexa = 4'h1;
      7'b0100100: hexa = 4'h2;
      7'b0110000: hexa = 4'h3;
      7'b0011001: hexa = 4'h4;
      7'b0010010: hexa = 4'h5;
      7'b0000010: hexa = 4'h6;
      7'b1111000: hexa = 4'h7;
      7'b0000000: hexa = 4'h8;
      7'b0010000: hexa = 4'h9;
      7'b0001000: hexa = 4'hA;
      7'b0000011: hexa = 4'hB;
      7'b1000110: hexa = 4'hC;
      7'b0100001: hexa = 4'hD;
      7'b0000110: hexa = 4'hE;
      7'b0001110: hexa = 4'hF;
      default: hexa = 4'h0;
    endcase
  end 
  endfunction

  /*
    Task para acertar valores consecutivos em uma rodada.
    Lê os valores certos de um arquivo .dat e aperta os botões de acordo com eles.
    Recebe a quantidade de valores consecutivos que devem ser acertados.
  */
  task acerta_valores;
  input integer quantidade;
  begin: corpo_task
    integer i;
    for (i = 0; i < quantidade; i = i + 1) begin
      caso = caso + 1;
      press_botoes(valores[i]);
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
    integer i;
    for (i = 1; i <= quantidade_rodadas; i = i + 1) begin
      #(wait_time(i)*clockPeriod); // Espera a apresentação
      acerta_valores(i);
    end
  end
  endtask

  /*
    Task para realizar o processo de iniciar o circuito.
    Recebe os níveis de tempo e de jogadas que deverão ser adotados no jogo a ser iniciado. 
  */
  task iniciar_circuito;
  input nivel_jogadas, nivel_tempo;
  begin
    @(negedge clock_in)
    iniciar_in = 1;
    nivel_jogadas_in = nivel_jogadas;
    nivel_tempo_in = nivel_tempo;
    #(3.5*clockPeriod)
    iniciar_in = 0;
    nivel_jogadas_in = 0;
    nivel_tempo_in = 0;
  end
  endtask


  // geracao dos sinais de entrada (estimulos)
  initial begin
  
    $dumpfile("waveforms.vcd");
    $dumpvars(0, circuito_exp6_tb);

    $display("Inicio da simulacao");

    // condicoes iniciais
    caso             = 0;
    clock_in         = 1;
    reset_in         = 0;
    iniciar_in       = 0;
    nivel_jogadas_in = 0;
    nivel_tempo_in   = 0;
    botoes_in        = 4'b0000;
    #clockPeriod;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: acerta todas as jogadas no nível fácil de jogadas
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 1;

    // Reseta o circuito
    caso = 1;
    @(negedge clock_in);
    reset_in = 1;
    #(clockPeriod)
    reset_in = 0;

    // Inicia o circuito no nível fácil
    caso = 2;
    iniciar_circuito(0, 0);

    // Acerta as 8 primeiras rodadas, ganhando o jogo
    acerta_rodadas(8);
    compara_resultados(8'h7, 8'hA, 8'h1, 8'h7, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: erra na primeira
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 2;

    // Iniciar o circuito no nível fácil
    caso = 1;
    iniciar_circuito(0, 0);

    // Erra na primeira jogada
    caso = 2;
    #(wait_time(1)*clockPeriod); // Espera apresentação
    press_botoes(4'b1000);
    compara_resultados(8'h0, 8'he, 8'h8, 8'h0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: erra na 12º rodada, segunda jogada
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 3;

    // Inicia o circuito no nível difícil
    caso = 1;
    iniciar_circuito(1, 0);

    // Acerta 11 rodadas
    caso = 2;
    acerta_rodadas(11);

    // Erra na segunda jogada da 12ª rodada
    #(wait_time(12)*clockPeriod); // Espera apresentação
    press_botoes(4'b0001);
    press_botoes(4'b0001);// Errou
    
    compara_resultados(8'h1, 8'he, 8'h1, 8'hb, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: erra na segunda rodada, primeira jogada
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 4;

    // Iniciar circuito no nível fácil
    caso = 1;
    iniciar_circuito(0, 0);

    // Acerta primeira rodada
    caso = 2;
    #(wait_time(1)*clockPeriod); // Espera apresentação
    press_botoes(4'b0001);

    // Erra na na primeira jogada da sengunda rodada
    caso = 3;
    #(wait_time(2)*clockPeriod);
    press_botoes(4'b1000); // Errou
    press_botoes(4'b0010);

    compara_resultados(8'h0, 8'he, 8'h8, 8'h1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: timeout na segunda rodada 
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 5;

    // Iniciar o circuito no nível fácil
    caso = 1;
    iniciar_circuito(0, 0);
    
    // Apresentação da primeira rodada
    caso = 2;
    acerta_rodadas(1);
    
    // Espera o tempo de timeout
    caso = 3;
    #(wait_time(2)*clockPeriod)
    #(3100*clockPeriod);
    compara_resultados(8'h0, 8'hf, 8'hx, 8'h1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: acerta todas no nível difícil 
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 6;

    // Inicializa o circuito no nível difícil
    caso = 1;
    iniciar_circuito(1, 0);

    // Acerta as 16 rodadas
    acerta_rodadas(16);
    compara_resultados(8'hF, 8'ha, 8'hx, 8'hF, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste:erra na nona rodada, quinta jogada do nível difícil
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 7;

    // Inicializa o circuito no nível difícil
    caso = 1;
    iniciar_circuito(1, 0);

    // Acerta 8 rodadas
    acerta_rodadas(8);

    // Erra na quinta jogada da nona rodada
    #(wait_time(9)*clockPeriod) // Espera a apresentação
    acerta_valores(4); // Acerta 4 valores
    caso = caso + 1;
    press_botoes(4'b0001); // Erra na quinta jogada
    compara_resultados(8'h4, 8'he, 8'h1, 8'h8, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: timeout na rodada 13, 7 jogada, nivel tempo dificil
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 8;

    // Inicializa o circuito no nível difícil
    caso = 1;
    iniciar_circuito(1, 1);

    // Acerta 12 rodadas
    acerta_rodadas(12);

    // Erra na 7ª jogada da 13ª rodada
    #(wait_time(13)*clockPeriod) // Espera a apresentação
    acerta_valores(6); // Acerta 6 valores
    caso = caso + 1;
    #(3100*clockPeriod);
    compara_resultados(8'h6, 8'hf, 8'hx, 8'h0c, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: ganha o jogo 2 vezes, uma no fácil e outra no difícil
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 9;
    // Inicializa o circuito no nível difícil
    caso = 1;
    iniciar_circuito(0, 0);

    // Acerta todas rodadas
    acerta_rodadas(8);

    iniciar_circuito(1, 1);
    // Acerta as 16 rodadas
    acerta_rodadas(16);
    compara_resultados(8'hF, 8'ha, 8'hx, 8'hF, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1);


    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: erra na ultima rodada, ultima jogada 
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 10;
    // Inicializa o circuito no nível difícil
    caso = 1;
    iniciar_circuito(1, 1);

    // Acerta todas rodadas
    acerta_rodadas(15);
    #(wait_time(16)*clockPeriod); // Espera a apresentação
    acerta_valores(15); // Acerta 15 valores


    press_botoes(4'b0010); // Erra no último

    compara_resultados(8'hF, 8'he, 8'hx, 8'hF, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1);
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    $display("Fim da simulação");
    $stop;
  end


endmodule