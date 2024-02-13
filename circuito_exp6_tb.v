/* --------------------------------------------------------------------
 * Arquivo   : circuito_exp5_tb.v
 * Projeto   : Experiencia 5 - Desenvolvimento de Projeto de 
 *             Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : testbench Verilog para circuito da Experiencia 5 
 *
 *             1) Plano de teste com 4 jogadas certas  
 *                e erro na quinta jogada.
 *
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                          Descricao
 *     02/01/2024  1.0     Caio Dourado, Davi Félix, Vinicius Batista     versao inicial
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
  wire       timeout_out;
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
  wire       db_rodada;

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
    .timeout          (timeout_out),
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
    .db_enderecoIgualRodada ( db_enderecoIgualRodada)
  );

  task press_botoes;
    input [3:0] valor;
    begin
      botoes_in = valor;
      #(3*clockPeriod);
      botoes_in = 4'b0000;
      #(3*clockPeriod);
    end
  endtask 

  function automatic integer wait_time;
  input [31:0] step;
  wait_time = (step*1000+(step-1)*502+1);
  endfunction

  task acerta_valores;
  input [3:0] quantidade;
  begin: corpo_task
    reg [3:0] valores [0:15];
    integer i;
    $readmemh("valores.dat", valores, 4'b0, 4'hF); 
    for (i = 0; i < quantidade; i = i + 1) begin
        press_botoes(valores[i]);
    end
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
      * Cenario de Teste: acerta todas as jogadas no nível fácil de jogadas
    */
    cenario = 1;

    // Reseta o circuito
    @(negedge clock_in);
    reset_in = 1;
    #(clockPeriod)
    reset_in = 0;

    // Apresenta primeira jogada
    caso = 1;
    iniciar_in = 1;
    #(4*clockPeriod);
    iniciar_in = 0;
    #(wait_time(1)*clockPeriod);
    press_botoes(4'b0001);
    
    // Apresenta segunda jogada
    caso = 2;
    #(wait_time(2)*clockPeriod);
    acerta_valores(2);

    // Apresentando a terceira jogada
    caso = 3;
    #(wait_time(3)*clockPeriod);
    acerta_valores(3);

    // Apresenta quarta jogada
    caso = 4;
    #(wait_time(4)*clockPeriod);
    acerta_valores(4);
    
    caso = 5;
    #(wait_time(5)*clockPeriod);
    acerta_valores(5);

    caso = 6;
    #(wait_time(6)*clockPeriod);
    acerta_valores(6);

    caso = 7;
    #(wait_time(7)*clockPeriod);
    acerta_valores(7);

    caso = 8;
    #(wait_time(8)*clockPeriod);
    acerta_valores(8);

    /*
      * Cenario de Teste: erra na primeira
    */
    cenario = 2;

    caso = 9;
    @(negedge clock_in);
    iniciar_in = 1;
    #(clockPeriod);
    iniciar_in = 0;

    caso = 10;
    #(1005*clockPeriod);
    press_botoes(4'b1000);

    /*
      * Cenario de Teste: erra na segunda rodada, segunda jogada
    */
    cenario = 3;

    caso = 11;
    @(negedge clock_in);
    iniciar_in = 1;
    #(clockPeriod);
    iniciar_in = 0;

    caso = 12;
    #(1005*clockPeriod);
    press_botoes(4'b0001);

    caso = 13;
    #(2505*clockPeriod);
    press_botoes(4'b0001);
    press_botoes(4'b1000); // Errou

    /*
      * Cenario de Teste: erra na segunda rodada, primeira jogada
    */
    cenario = 4;

    caso = 14;
    @(negedge clock_in);
    iniciar_in = 1;
    #(clockPeriod);
    iniciar_in = 0;

    caso = 15;
    #(1005*clockPeriod);
    press_botoes(4'b0001);

    caso = 16;
    #(2505*clockPeriod);
    press_botoes(4'b1000); // Errou
    press_botoes(4'b0010);

    /*Cenário de teste: timeout */
    cenario = 5;

    caso = 17;
    @(negedge clock_in);
    iniciar_in = 1;
    #(clockPeriod);
    iniciar_in = 0;

    caso = 18;
    #(1005*clockPeriod);
    #(3500*clockPeriod);


    $display("Fim da simulação");
    $stop;
  end
endmodule