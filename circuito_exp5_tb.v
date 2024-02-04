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
    reg        clock_in   = 1;
    reg        reset_in   = 0;
    reg        iniciar_in = 0;
    reg  [3:0] chaves_in  = 4'b0000;

    wire       acertou_out;
    wire       errou_out  ;
    wire       pronto_out ;
    wire [3:0] leds_out   ;

    wire       db_igual_out      ;
    wire [6:0] db_contagem_out   ;
    wire [6:0] db_memoria_out    ;
    wire [6:0] db_estado_out     ;
    wire       db_clock_out      ;
    wire       db_iniciar_out    ;
    wire       db_tem_jogada_out ;

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
      .chaves         ( chaves_in   ),
      .acertou        ( acertou_out ),
      .errou          ( errou_out   ),
      .pronto         ( pronto_out  ),
      .leds           ( leds_out    ),
      .db_igual       ( db_igual_out       ),
      .db_contagem    ( db_contagem_out    ),
      .db_memoria     ( db_memoria_out     ),
      .db_estado      ( db_estado_out      ),
      .db_clock       ( db_clock_out       ),
      .db_iniciar     ( db_iniciar_out     ),    
      .db_tem_jogada  ( db_tem_jogada_out  )
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
      chaves_in  = 4'b0000;
      #clockPeriod;

      /*
       * Cenario de Teste 1 - erra na 5a jogada
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
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(10*clockPeriod);

      // Teste 3. jogada #1 (ajustar chaves para 0001 por 10 periodos de clock
      caso = 3;
      @(negedge clock_in);
      chaves_in = 4'b0001;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 4. jogada #2 (ajustar chaves para 0010 por 10 periodos de clock
      caso = 4;
      @(negedge clock_in);
      chaves_in = 4'b0010;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 5. jogada #3 (ajustar chaves para 0100 por 10 periodos de clock
      caso = 5;
      @(negedge clock_in);
      chaves_in = 4'b0100;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 6. jogada #4 (ajustar chaves para 1000 por 10 periodos de clock
      caso = 6;
      @(negedge clock_in);
      chaves_in = 4'b0001;  	// jogada certa = 4'b1000
      #(5*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 7. jogada #5 errada (ajustar chaves para 0001 por 5 periodos de clock
      caso = 7;
      @(negedge clock_in);
      chaves_in = 4'b0001; 
      #(5*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod); //nada era pra acontecer


      /*
       * Cenario de Teste 2 - acerta as 16 jogadas
       */

      // Teste 1. resetar circuito
      caso = 8;
      // gera pulso de reset
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      reset_in = 0;
      // espera
      #(10*clockPeriod);

      // Teste 2. iniciar=1 por 5 periodos de clock
      caso = 9;
      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(10*clockPeriod);

      // Teste 3. jogada #1 (ajustar chaves para 0001 por 10 periodos de clock
      caso = 10;
      @(negedge clock_in);
      chaves_in = 4'b0001;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 4. jogada #2 (ajustar chaves para 0010 por 10 periodos de clock
      caso = 11;
      @(negedge clock_in);
      chaves_in = 4'b0010;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 5. jogada #3 (ajustar chaves para 0100 por 10 periodos de clock
      caso = 12;
      @(negedge clock_in);
      chaves_in = 4'b0100;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 6. jogada #4 (ajustar chaves para 1000 por 10 periodos de clock
      caso = 13;
      @(negedge clock_in);
      chaves_in = 4'b1000;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 7. jogada #5 (ajustar chaves para 0100 por 10 periodos de clock
      caso = 14;
      @(negedge clock_in);
      chaves_in = 4'b0100; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 8. jogada #6 (ajustar chaves para 0010 por 10 periodos de clock
      caso = 15;
      @(negedge clock_in);
      chaves_in = 4'b0010; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 9. jogada #7 (ajustar chaves para 0001 por 10 periodos de clock
      caso = 16;
      @(negedge clock_in);
      chaves_in = 4'b0001; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 10. jogada #8 (ajustar chaves para 0001 por 10 periodos de clock
      caso = 17;
      @(negedge clock_in);
      chaves_in = 4'b0001; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 11. jogada #9 (ajustar chaves para 0010 por 10 periodos de clock
      caso = 18;
      @(negedge clock_in);
      chaves_in = 4'b0010; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 12. jogada #10 (ajustar chaves para 0010 por 10 periodos de clock
      caso = 19;
      @(negedge clock_in);
      chaves_in = 4'b0010; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 13. jogada #11 (ajustar chaves para 0100 por 10 periodos de clock
      caso = 20;
      @(negedge clock_in);
      chaves_in = 4'b0100; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 14. jogada #12 (ajustar chaves para 0100 por 10 periodos de clock
      caso = 21;
      @(negedge clock_in);
      chaves_in = 4'b0100; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 15. jogada #13 (ajustar chaves para 1000 por 10 periodos de clock
      caso = 22;
      @(negedge clock_in);
      chaves_in = 4'b1000; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 16. jogada #14 (ajustar chaves para 1000 por 10 periodos de clock
      caso = 23;
      @(negedge clock_in);
      chaves_in = 4'b1000; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 17. jogada #15 (ajustar chaves para 0001 por 10 periodos de clock
      caso = 23;
      @(negedge clock_in);
      chaves_in = 4'b0001; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 18. jogada #16 (ajustar chaves para 0100 por 10 periodos de clock
      caso = 24;
      @(negedge clock_in);
      chaves_in = 4'b0100; 
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Teste 19. resetar circuito
      caso = 25;
      // gera pulso de reset
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      reset_in = 0;
      // espera
      #(10*clockPeriod);

      /*
       * Cenario de Teste 2 - ativa duas entradas com menos de 3 bordas de diferença
       */

      // Resetar circuito
      caso = 26;
      // gera pulso de reset
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      reset_in = 0;
      // espera
      #(10*clockPeriod);

      // Iniciar o circuito
      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(10*clockPeriod);

      // Aceitar uma jogada
      @(negedge clock_in);
      chaves_in = 4'b0001;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Aciona uma entrada e, antes de 3 bordas (2.5 períodos), aciona outra
      @(negedge clock_in);
      chaves_in = 4'b0010;
      #(2.3*clockPeriod);
      chaves_in = 4'b1010;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      #(10*clockPeriod);

       /*
       * Cenario de Teste 3 - ativa duas entradas com mais de 3 bordas de diferença
       */

      // Teste 1. resetar circuito
      caso = 27;
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      reset_in = 0;
      // espera
      #(10*clockPeriod);

      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(10*clockPeriod);

      //Ativa a primeira jogada
      @(negedge clock_in);
      chaves_in = 4'b0001;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Ativa uma entrada e, depois de 3 bordas (2.5 períodos), ativa outra
      @(negedge clock_in);
      chaves_in = 4'b0010;
      #(2.7*clockPeriod);
      chaves_in = 4'b1010;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      // Acerta jogada
      @(negedge clock_in);
      chaves_in = 4'b0100;
      #(10*clockPeriod);
      chaves_in = 4'b0000;
      // espera entre jogadas
      #(10*clockPeriod);

      /*
       * Cenario de Teste 4 - sem a borda
       */

      // Teste 1. resetar circuito
      caso = 28;
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      reset_in = 0;
      // espera
      #(10*clockPeriod);

      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(10*clockPeriod);

      chaves_in = 4'b0001; // Ativa a primeira jogada
      #(10*clockPeriod);

      // Ativa uma entrada
      chaves_in = 4'b0011; // Levanta segunda entrada sem baixar a primeira
      #(5*clockPeriod);
      chaves_in = 4'b0010; // Desativa a primeira
      #(10*clockPeriod);

      /*
       * Cenario de Teste 4 - entrada contínua
       */

      // resetar circuito
      caso = 29;
      @(negedge clock_in);
      reset_in = 1;
      #(clockPeriod);
      reset_in = 0;
      // espera
      #(10*clockPeriod);

      iniciar_in = 1;
      #(5*clockPeriod);
      iniciar_in = 0;
      // espera
      #(10*clockPeriod);

      //Ativa a primeira jogada
      chaves_in = 4'b0001;
      // espera entre jogadas
      #(10*clockPeriod);

      chaves_in = 4'b0010; // Ativa a segunda entrada sem desativar a primeira
      #(10*clockPeriod);

      // final dos casos de teste da simulacao
      caso = 99;
      #100;
      $display("Fim da simulacao");
      $stop;
    end

  endmodule
