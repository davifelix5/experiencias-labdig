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

module circuito_exp6_desafio_tb;

  // Sinais para conectar com o DUT
  // valores iniciais para fins de simulacao (ModelSim)
  reg        clock_in;
  reg        reset_in;
  reg        iniciar_in;
  reg  [3:0] botoes_in;
  reg        nivel_jogadas_in; 
  reg        nivel_tempo_in;
  reg  [3:0] valores [0:15];
  reg  [3:0] novos_valores[0:15];
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
  wire [6:0] db_rodada;

  parameter clock_freq = 5000;

  //Recupera valores da memória
  initial begin
    $readmemh("valores.dat", valores, 4'b0, 4'hF); 
    $readmemh("novos_valores.dat", novos_valores, 4'h0, 4'hF);
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
    .db_timeout             (db_timeout)
  );

  /*
    Atualiza os resultados a serem comparados
  */
  task atualiza_resultado;
  begin
    resultados[0] = hexa(db_contagem);
    resultados[1] = hexa(db_memoria);
    resultados[2] = hexa(db_estado_lsb_out);
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
      $display("estado = %2h", hexa(db_estado_lsb_out));
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
      #(2503*clockPeriod);
    end
  endtask 
  
  /*
    Função para calcular a quantidade de ciclos de clock que devem ser esperados até o fim da apresentação.
    Recebe a rodada que está sendo apresentada.
  */
  function automatic integer wait_time;
  input [31:0] step;
  wait_time = (step*clock_freq+(step-1)*(clock_freq/2 + 2)+2501);
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
    integer j;
    for (j = 0; j < quantidade; j = j + 1) begin
      caso = caso + 1;
      if (j == 0)
        press_botoes(valores[j]);
      else begin
        press_botoes(novos_valores[j-1]);
      end
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
      if (i == 1) begin
        #(wait_time(i)*clockPeriod); // Espera a apresentação
      end
      acerta_valores(i);
      // Grava
      press_botoes(novos_valores[i-1]);
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
    $dumpvars(0, circuito_exp6_desafio_tb);

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
    iniciar_circuito(0, 0);
    acerta_rodadas(8);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Cenario de Teste: acerta todas as jogadas no nível difícil de jogadas
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    cenario = 1;
    iniciar_circuito(1, 0);
    acerta_rodadas(16);
    
    $stop;
  end


endmodule