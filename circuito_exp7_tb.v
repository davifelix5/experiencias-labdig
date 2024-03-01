/* --------------------------------------------------------------------
 * Arquivo   : circuito_exp6_tb.v
 * Projeto   : Experiencia 6 - Desenvolvimento de Projeto de 
 *             Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : testbench Verilog para o desafio do circuito da Experiencia 6
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                          Descricao
 *     21/02/2024  2.0     Caio Dourado, Davi Félix, Vinicius Batista     versao inicial
 * --------------------------------------------------------------------
*/

`timescale 1ns/1ns

module circuito_exp7_tb;

  // Sinais para conectar com o DUT
  // valores iniciais para fins de simulacao (ModelSim)
  reg        clock_in;
  reg        reset_in;
  reg        iniciar_in;
  reg  [3:0] botoes_in;
  reg        nivel_jogadas_in; 
  reg        nivel_tempo_in;
  reg        modo2_in;
  reg  [3:0] valores [0:15];
  reg  [7:0] resultados [0:12];

  wire       ganhou_out;
  wire       perdeu_out;
  wire       pronto_out;
  wire       vez_jogador_out;
  wire       nova_jogada_out;
  wire [3:0] leds_out;
  wire       pulso_buzzer_out;

  wire       db_jogada_correta;
  wire [6:0] db_contagem;
  wire [6:0] db_memoria;
  wire [6:0] db_estado_lsb_out;
  wire [6:0] db_estado_msb_out;
  wire [6:0] db_jogada;
  wire       db_nivel_jogadas;
  wire       db_nivel_tempo;
  wire       db_clock;
  wire       db_enderecoIgualRodada;
  wire       db_timeout;
  wire       db_meioTM;
  wire       db_fimTM;
  wire       db_modo2;
  wire       db_gravaM;
  wire [6:0] db_rodada;

  parameter clock_freq = 5000; // Hz
  parameter MOSTRA     = 2500; // Hz
  parameter APRESENTA  = 2; // s
  parameter TIMEOUT    = 3; // s

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
  circuito_exp7 DUT (
    .clock            (clock_in),
    .reset            (reset_in),
    .iniciar          (iniciar_in),
    .botoes           (botoes_in),
    .nivel_jogadas    (nivel_jogadas_in), 
    .nivel_tempo      (nivel_tempo_in),
    .modo2            (modo2_in),

    .ganhou           (ganhou_out),
    .perdeu           (perdeu_out),
    .pronto           (pronto_out),
    .vez_jogador      (vez_jogador_out),
    .nova_jogada      (nova_jogada_out),
    .leds             (leds_out),
    .pulso_buzzer     (pulso_buzzer_out),

    .db_jogada_correta      (db_jogada_correta),
    .db_contagem            (db_contagem),
    .db_memoria             (db_memoria),
    .db_estado_lsb          (db_estado_lsb_out),
    .db_estado_msb          (db_estado_msb_out),
    .db_jogada              (db_jogada),
    .db_rodada              (db_rodada),
    .db_nivel_jogadas       (db_nivel_jogadas),
    .db_nivel_tempo         (db_nivel_tempo),
    .db_clock               (db_clock),
    .db_enderecoIgualRodada (db_enderecoIgualRodada),
    .db_timeout             (db_timeout),
    .db_meioTM              (db_meioTM),
    .db_fimTM               (db_fimTM),
    .db_modo2               (db_modo2),
    .db_gravaM              (db_gravaM)
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
      #((MOSTRA + 3)*clockPeriod);
    end
  endtask 
  
  /*
    Função para calcular a quantidade de ciclos de clock que devem ser esperados até o fim da apresentação.
    Recebe a rodada que está sendo apresentada.
  */
  function automatic integer wait_time;
  input [31:0] step;
  wait_time = (step*APRESENTA*clock_freq+(step-1)*(MOSTRA + 2)+MOSTRA + 1);
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
      caso = caso + 1;
        press_botoes(valores[j]);
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
      if (modo2_in == 0 || (modo2_in == 1 && i == 1)) begin
        #(wait_time(i)*clockPeriod); // Espera a apresentação
      end
      acerta_valores(i);
      // Grava
      if (modo2_in == 1)
        press_botoes(valores[i]);
    end
  end
  endtask

  /*
    Task para realizar o processo de iniciar o circuito.
    Recebe os níveis de tempo e de jogadas que deverão ser adotados no jogo a ser iniciado. 
  */
  task iniciar_circuito;
  input nivel_jogadas, nivel_tempo, modo2;
  begin
    @(negedge clock_in)
    iniciar_in = 1;
    nivel_jogadas_in = nivel_jogadas;
    nivel_tempo_in = nivel_tempo;
    modo2_in = modo2;
    #(3.5*clockPeriod)
    iniciar_in = 0;
    nivel_jogadas_in = 0;
    nivel_tempo_in = 0;
  end
  endtask


  // geracao dos sinais de entrada (estimulos)
  initial begin
  
    $dumpfile("waveforms.vcd");
    $dumpvars(0, circuito_exp7_tb);

    $display("Inicio da simulacao");

    // condicoes iniciais
    caso             = 0;
    clock_in         = 1;
    reset_in         = 0;
    iniciar_in       = 0;
    nivel_jogadas_in = 0;
    modo2_in         = 0;
    nivel_tempo_in   = 0;
    botoes_in        = 4'b0000;
    #clockPeriod;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: acerta todas as jogadas no nível difícil de jogadas e fácil de tempo, modo 2
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 1;
    iniciar_circuito(1, 0, 1);
    acerta_rodadas(16);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: erra na primeira rodada, primeira jogada, nível difícil de jogadas e fácil de tempo, modo 2
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 2;
    iniciar_circuito(1, 0, 1);
    #(wait_time(1)*clockPeriod);
    press_botoes(4'b1000);

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: erra na última rodada, última jogada, nível difícil de jogadas e fácil de tempo, modo 2
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 3;
    iniciar_circuito(1, 0, 1);
    acerta_rodadas(15);
    acerta_valores(15);
    press_botoes(4'b1000);

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: erra na sexta rodada, quinta jogada, nível difícil de jogadas e fácil de tempo, modo 2
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 4;
    iniciar_circuito(1, 0, 1);
    acerta_rodadas(5);
    acerta_valores(4);
    press_botoes(4'b1000);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: timeout na primeira rodada, nível difícil de jogadas e fácil de tempo, modo 2
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 5;
    iniciar_circuito(1, 0, 1);
    #(wait_time(1)*clockPeriod);
    #(TIMEOUT*clock_freq*clockPeriod);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: timeout na terceira rodada, segunda jogada, nível difícil de jogadas e fácil de tempo, modo 2 
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 6;
    iniciar_circuito(1, 0, 1);
    acerta_rodadas(2);
    acerta_valores(1);
    #(TIMEOUT*clock_freq*clockPeriod);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: acerta tudo no nível dífícil de jogadas, fácil de tempo, modo1
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 7;
    iniciar_circuito(1, 0, 0);
    acerta_rodadas(16);    
    $stop;
  end


endmodule