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

module circuito_exp5_tb;

  // Sinais para conectar com o DUT
  // valores iniciais para fins de simulacao (ModelSim)
  reg        clock_in         = 1;
  reg        reset_in         = 0;
  reg        iniciar_in       = 0;
  reg  [3:0] chaves_in        = 4'b0000;
  reg        nivel_jogadas_in = 1;
  reg        nivel_tempo_in   = 0;

  wire       acertou_out;
  wire       errou_out  ;
  wire       pronto_out ;
  wire       timeout_out;
  wire [3:0] leds_out   ;

  wire       db_igual      ;
  wire [6:0] db_contagem   ;
  wire [6:0] db_memoria    ;
  wire [6:0] db_estado     ;
  wire       db_clock      ;
  wire       db_iniciar    ;
  wire       db_tem_jogada ;
  wire       db_nivel      ;
  wire       db_meioTempo  ;
  wire       db_fimTempo   ;

  // Configuração do clock
  parameter clockPeriod = 20; // in ns, f=50MHz

  // Identificacao do caso de teste
  reg [31:0] caso = 0;

  // Gerador de clock
  always #((clockPeriod / 2)) clock_in = ~clock_in;

  // instanciacao do DUT (Device Under Test)
  circuito_exp5 DUT (
    .clock          ( clock_in    ),
    .reset          ( reset_in    ),
    .iniciar        ( iniciar_in  ),
    .nivel_jogadas  ( nivel_jogadas_in ),
    .nivel_tempo    ( nivel_tempo_in   ),
    .chaves         ( chaves_in   ),
    .acertou        ( acertou_out ),
    .errou          ( errou_out   ),
    .pronto         ( pronto_out  ),
    .leds           ( leds_out    ),
    .timeout        ( timeout_out ),
    .db_igual       ( db_igual       ),
    .db_contagem    ( db_contagem    ),
    .db_memoria     ( db_memoria     ),
    .db_estado      ( db_estado      ),
    .db_clock       ( db_clock       ),
    .db_nivel       ( db_nivel       ),
    .db_iniciar     ( db_iniciar     ),    
    .db_tem_jogada  ( db_tem_jogada  ),
    .db_meioTempo   ( db_meioTempo   ),
    .db_fimTempo    ( db_fimTempo    )
  );

  // geracao dos sinais de entrada (estimulos)
  initial begin
  
    $dumpfile("waveforms.vcd");
    $dumpvars(0, circuito_exp5_tb);
    
    $display("Inicio da simulacao");

    // condicoes iniciais
    caso       = 0;
    clock_in   = 1;
    reset_in   = 0;
    iniciar_in = 0;
    nivel_jogadas_in   = 0;
    chaves_in  = 4'b0000;
    #clockPeriod;

    /*
      * Cenario de Teste 1 - erra na 9a jogada com o nível difícil
      */

    // Teste 1. resetar circuito
    caso = 1;
    // gera pulso de reset
    @(negedge clock_in);
    reset_in = 1;
    #(clockPeriod);
    reset_in = 0;
    // espera
    #(10*clockPeriod);

    // Teste 2. iniciar=1 por 5 periodos de clock
    caso = 2;
    iniciar_in = 1;
    nivel_jogadas_in   = 1;
    #(5*clockPeriod);
    iniciar_in = 0;
    // espera
    #(10*clockPeriod);

    // Teste 3. jogada #1 (ajustar chaves para 0001 por 10 periodos de clock
    caso = 3;
    chaves_in = 4'b0001;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 4. jogada #2 (ajustar chaves para 0010 por 10 periodos de clock
    caso = 4;
    chaves_in = 4'b0010;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 5. jogada #3 (ajustar chaves para 0100 por 10 periodos de clock
    caso = 5;
    chaves_in = 4'b0100;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 6. jogada #4 (ajustar chaves para 1000 por 10 periodos de clock
    caso = 6;
    chaves_in = 4'b1000;  	// jogada certa = 4'b1000
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 7. jogada #5 errada (ajustar chaves para 0001 por 5 periodos de clock
    caso = 7;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 8. jogada #6 errada (ajustar chaves para 0001 por 5 periodos de clock
    caso = 8;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 9. jogada #7 errada (ajustar chaves para 0001 por 5 periodos de clock
    caso = 9;
    chaves_in = 4'b0001;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 10. jogada #8 errada (ajustar chaves para 0001 por 5 periodos de clock
    caso = 10;
    chaves_in = 4'b0001;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 11. jogada #9 errada (ajustar chaves para 0001 por 5 periodos de clock
    caso = 11;
    chaves_in = 4'b1000;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod); //nada era pra acontecer

    
    /*
      * Cenario de Teste 2 - acerta as 16 jogadas
      */

    // Teste 2. iniciar=1 por 5 periodos de clock
    caso = 13;
    iniciar_in = 1;
    nivel_jogadas_in = 1;
    #(5*clockPeriod);
    iniciar_in = 0;
    // espera
    #(10*clockPeriod);

    // Teste 3. jogada #1 (ajustar chaves para 0001 por 10 periodos de clock
    caso = 14;
    chaves_in = 4'b0001;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 4. jogada #2 (ajustar chaves para 0010 por 10 periodos de clock
    caso = 15;
    chaves_in = 4'b0010;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 5. jogada #3 (ajustar chaves para 0100 por 10 periodos de clock
    caso = 16;
    chaves_in = 4'b0100;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 6. jogada #4 (ajustar chaves para 1000 por 10 periodos de clock
    caso = 17;
    chaves_in = 4'b1000;
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 7. jogada #5 (ajustar chaves para 0100 por 10 periodos de clock
    caso = 18;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 8. jogada #6 (ajustar chaves para 0010 por 10 periodos de clock
    caso = 19;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 9. jogada #7 (ajustar chaves para 0001 por 10 periodos de clock
    caso = 20;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 10. jogada #8 (ajustar chaves para 0001 por 10 periodos de clock
    caso = 21;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 11. jogada #9 (ajustar chaves para 0010 por 10 periodos de clock
    caso = 22;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 12. jogada #10 (ajustar chaves para 0010 por 10 periodos de clock
    caso = 23;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 13. jogada #11 (ajustar chaves para 0100 por 10 periodos de clock
    caso = 24;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 14. jogada #12 (ajustar chaves para 0100 por 10 periodos de clock
    caso = 25;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 15. jogada #13 (ajustar chaves para 1000 por 10 periodos de clock
    caso = 26;
    chaves_in = 4'b1000; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 16. jogada #14 (ajustar chaves para 1000 por 10 periodos de clock
    caso = 27;
    chaves_in = 4'b1000; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 17. jogada #15 (ajustar chaves para 0001 por 10 periodos de clock
    caso = 28;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // Teste 18. jogada #16 (ajustar chaves para 0100 por 10 periodos de clock
    caso = 29;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);


    /*
      * Cenario de Teste 3 - acerta as 8 jogadas no nível fácil
    */

    caso = 30;
    // iniciar muda o nível do jogo
    iniciar_in = 1;
    nivel_jogadas_in = 0;
    #(clockPeriod);
    iniciar_in = 0;
    // espera
    #(10*clockPeriod);

    // jogada #1: ajusta chaves para 0001 e acerta
    caso = 31;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #2: ajusta chaves para 0010 e acerta
    caso = 32;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);
    
    // jogada #3: ajusta chaves para 0100 e acerta
    caso = 33;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #4: ajusta chaves para 1000 e acerta
    caso = 34;
    chaves_in = 4'b1000; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #5: ajusta chaves para 0100 e acerta
    caso = 35;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #6: ajusta chaves para 0010 e acerta
    caso = 36;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #7: ajusta chaves para 0001 e acerta
    caso = 37;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #8: ajusta chaves para 0001 e acerta
    caso = 38;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    #(20*clockPeriod);

    /*
      * Cenario de Teste 4 - Troca de nível depois do fim do jogo com reset
    */

    caso = 39;
    // iniciar muda o nível do jogo
    reset_in = 1;
    #(clockPeriod);
    reset_in = 0;
    iniciar_in = 1;
    nivel_jogadas_in = 1;
    #(3*clockPeriod);
    iniciar_in = 0;
    nivel_jogadas_in = 0; // testar se registrou
    // espera
    #(10*clockPeriod);

    // jogada #1: ajusta chaves para 0001 e acerta
    caso = 40;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #2: ajusta chaves para 0010 e acerta
    caso = 41;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);
    
    // jogada #3: ajusta chaves para 0100 e acerta
    caso = 42;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #4: ajusta chaves para 1000 e acerta
    caso = 43;
    chaves_in = 4'b1000; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #5: ajusta chaves para 0100 e acerta
    caso = 44;
    chaves_in = 4'b0100; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #6: ajusta chaves para 0010 e acerta
    caso = 45;
    chaves_in = 4'b0010; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #7: ajusta chaves para 0001 e acerta
    caso = 46;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    // espera entre jogadas
    #(10*clockPeriod);

    // jogada #8: ajusta chaves para 0001 e acerta
    caso = 47;
    chaves_in = 4'b0001; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    #(10*clockPeriod);

    // jogada #9: ajusta chaves para 1000 e tem que errar, pois está no difícil
    caso = 48;
    chaves_in = 4'b1000; 
    #(3*clockPeriod);
    chaves_in = 4'b0000;
    #(20*clockPeriod);
    
     /*  
      * 	  TESTE DO DESAFIO
      * 
      *    Um contador que conta até 5000 (clicos de clock) que funciona como timer do circuito. 
      *    Quando o contador chega ao seu fim, ele dispara um sinal que joga o estado do circuito para o fim_erro.
      *    Temos um  sinal de depuração para o fim do contador (5000 contagens) e para  o seu meio (2500 contagens).
      *    o TB consiste em acertar uma jogada e esperar 5000 ciclos para ver a modificação dos sinais.
      *
    */

      // Reseta o circuito
      caso = 49;
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod)
      reset_in = 0;
      #(10*clockPeriod);

      // Iniciar o circuito
      caso = 50;
      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(10*clockPeriod);

      // jogada #1 (ajustar chaves para 0001 por 10 periodos de clock e esperar 5000 clocks (timer))
      caso = 51;
      chaves_in = 4'b0001;
      #(3*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(5000*clockPeriod); 

      // Check se há mudança no circuito
      caso = 52;
      chaves_in = 4'b0010;
      #(3*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod); //
      // final dos casos de teste da simulacao

      // resetar circuito e verificar se ele permanece reiniciado mesmo com o timer rolando
      caso = 53;
      // gera pulso de reset
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      reset_in = 0;
      // espera
      #(5010*clockPeriod);

      // Iniciar o circuito e esperar o timer acabar
      caso = 54;
      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(5010*clockPeriod);

      caso = 99;
      #100;

    $display("Fim da simulação");
    $finish;
  end
endmodule