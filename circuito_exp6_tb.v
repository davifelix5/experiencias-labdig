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

    .db_jogada_correta (db_jogada_correta),
    .db_contagem      (db_contagem),
    .db_memoria       (db_memoria),
    .db_estado        (db_estado),
    .db_jogada        (db_jogada),
    .db_rodada        (db_rodada),
    .db_nivel_jogadas (db_nivel_jogadas),
    .db_nivel_tempo   (db_nivel_tempo),
    .db_clock         (db_clock),
    .db_enderecoIgualRodada (db_enderecoIgualRodada),
    .db_timeout               (db_timeout)
  );

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
    Task para acertar valores consecutivos em uma rodada.
    Lê os valores certos de um arquivo .dat e aperta os botões de acordo com eles.
    Recebe a quantidade de valores consecutivos que devem ser acertados.
  */
  task acerta_valores;
  input integer quantidade;
  begin: corpo_task
    reg [3:0] valores [0:15];
    integer i;
    $readmemh("valores.dat", valores, 4'b0, 4'hF); 
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
      #(clockPeriod);
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
    #(4*clockPeriod)
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

    /*
      Cenario de Teste: acerta todas as jogadas no nível fácil de jogadas
    */
    cenario = 1;

    // Reseta o circuito
    caso = 1;
    @(negedge clock_in);
    reset_in = 1;
    #(clockPeriod)
    reset_in = 0;

    // Iniciar o circuito no nível fácil
    caso = 2;
    iniciar_circuito(0, 0);

    // Acerta as 8 primeiras rodadas, ganhando o jogo
    acerta_rodadas(8);

    /*
      Cenario de Teste: erra na primeira
    */

    cenario = 2;

    // Iniciar o circuito no nível fácil
    caso = 1;
    iniciar_circuito(0, 0);

    // Erra na primeira jogada
    caso = 2;
    #(wait_time(1)*clockPeriod); // Espera apresentação
    press_botoes(4'b1000);

    /*
      Cenario de Teste: erra na segunda rodada, segunda jogada
    */
    cenario = 3;

    // Inicia o circuito no nível fácil
    caso = 1;
    iniciar_circuito(0, 0);

    // Acerta primeira rodada
    caso = 2;
    #(wait_time(1)*clockPeriod); // Espera apresentação
    press_botoes(4'b0001);

    // Erra na segunda jogada da segunda rodada
    caso = 3;
    #(wait_time(2)*clockPeriod); // Espera apresentação
    press_botoes(4'b0001);
    press_botoes(4'b1000); // Errou

    /*
      Cenario de Teste: erra na segunda rodada, primeira jogada
    */
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

    /*
      Cenário de teste: timeout na segunda rodada 
    */
    cenario = 5;

    // Iniciar o circuito no nível fácil
    caso = 1;
    iniciar_circuito(0, 0);
    
    // Apresentação da primeira rodada
    caso = 2;
    #(wait_time(1)*clockPeriod);
    
    // Espera o tempo de timeout
    caso = 3;
    #(3100*clockPeriod);

    /* 
      Cenário de teste: acerta todas no nível difícil 
    */
    cenario = 6;

    // Inicializa o circuito no nível difícil
    caso = 1;
    iniciar_circuito(1, 0);

    // Acerta as 16 rodadas
    acerta_rodadas(16);

    /* Cenário de teste: erra na nona rodada, quinta jogada do nível difícil */ 
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

    $display("Fim da simulação");
    $stop;
  end
endmodule