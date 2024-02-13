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
  reg  [3:0] chaves_in;
  reg        nivel_jogadas_in; 
  reg        nivel_tempo_in;

  wire       acertou_out;
  wire       errou_out;
  wire       pronto_out;
  wire       vez_jogador_out;
  wire       timeout_out;
  wire [3:0] leds_out;

  wire       db_igual;
  wire [6:0] db_contagem;
  wire [6:0] db_memoria;
  wire [6:0] db_estado;
  wire [6:0] db_jogada;
  wire       db_nivel_jogadas;
  wire       db_nivel_tempo;
  wire       db_clock;
  wire       db_iniciar;
  wire       db_tem_jogada;

  // Configuração do clock
  parameter clockPeriod = 20; // in ns, f=50MHz

  // Identificacao do caso de teste
  reg [31:0] caso = 0;

  // Gerador de clock
  always #((clockPeriod / 2)) clock_in = ~clock_in;

  // instanciacao do DUT (Device Under Test)
  circuito_exp6 DUT (
    .clock            (clock_in),
    .reset            (reset_in),
    .iniciar          (iniciar_in),
    .chaves           (chaves_in),
    .nivel_jogadas    (nivel_jogadas_in), 
    .nivel_tempo      (nivel_tempo_in),

    .acertou          (acertou_out),
    .errou            (errou_out),
    .pronto           (pronto_out),
	  .vez_jogador      (vez_jogador_out),
    .timeout          (timeout_out),
    .leds             (leds_out),

    .db_igual         (db_igual),
    .db_contagem      (db_contagem),
    .db_memoria       (db_memoria),
    .db_estado        (db_estado),
    .db_jogada        (db_jogada),
    .db_nivel_jogadas (db_nivel_jogadas),
    .db_nivel_tempo   (db_nivel_tempo),
    .db_clock         (db_clock),
    .db_iniciar       (db_iniciar),
    .db_tem_jogada    (db_tem_jogada)
  );

  task pressChaves;
    input [3:0] valor;
    begin
      chaves_in = valor;
      #(3*clockPeriod);
      chaves_in = 4'b0000;
      #(3*clockPeriod);
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
    chaves_in        = 4'b0000;
    #clockPeriod;

    /*
      * Cenario de Teste: acerta todas as jogadas no nível difícil
    */

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
    #(1002*clockPeriod);
    pressChaves(4'b0001);
    
    // Apresenta segunda jogada
    caso = 2;
    #(2020*clockPeriod);
    pressChaves(4'b0001);
    pressChaves(4'b0010);

    // Apresentando a terceira jogada
    caso = 3;
    #(3020*clockPeriod);
    pressChaves(4'b0001);
    pressChaves(4'b0010);
    pressChaves(4'b0001); // Errou
    #(10*clockPeriod);
    

    $display("Fim da simulação");
    $stop;
  end
endmodule