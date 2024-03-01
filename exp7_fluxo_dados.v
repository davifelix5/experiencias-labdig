/* --------------------------------------------------------------------
 * Arquivo   : exp6_fluxo_dados.v
 * Projeto   : Experiencia 6 - Desenvolvimento de Projeto de 
 *             Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : Fluxo de dados Verilog para circuito da Experiencia 6
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                            Descricao
 *     14/02/2024  1.0     Caio Dourado, Davi Félix e Vinicius Batista      versao inicial
 * --------------------------------------------------------------------
*/


module exp7_fluxo_dados (
    // Entradas
    input clock,
    input [3:0] botoes,
    input nivel_jogadas, nivel_tempo, modo2,

    // Sinais de controle
    input zeraR,
    input registraR,
    input zeraC,
    input contaC,
    input registraN,
    input contaTempo,
    input zeraCR,
    input zeraTempo,
    input contaCR,
    input zeraTM,
    input contaTM,
    input ativa_leds_mem,
    input ativa_leds_jog,
    input toca,
    input gravaM,
    
    // Sinais de codição
    output jogada_correta,
    output jogada_feita,
    output nivel_jogadas_reg,
    output nivel_tempo_reg,
    output modo2_reg,
    output meioCR,
    output fimTempo,
    output meioTempo,
    output enderecoIgualRodada,
    output fimCR,
    output fimTM,
    output meioTM,
    output pulso_buzzer,

    // Sinais de saída
    output [3:0] leds,

    // Sinais de depuração
    output [3:0] db_contagem,
    output [3:0] db_jogada,
    output [3:0] db_memoria,
    output [3:0] db_rodada
);

    parameter CLOCK_FREQ = 5000, // Hz
              TEMPO_MOSTRA = 2, TIMEOUT=3, // s
              TEMPO_FEEDBACK = 2500;

    // Sinais internos
    wire tem_jogada;
    wire[3:0] s_memoria, s_endereco, s_rodada, s_jogada;

    // OR dos botoes
    assign tem_jogada    = |botoes;

    // Sinais de saída
    assign leds = ativa_leds_mem ? s_memoria : (ativa_leds_jog ? s_jogada : 4'b0);

    // Sinais de depuração
    assign db_contagem   = s_endereco;
    assign db_jogada     = s_jogada;
    assign db_memoria    = s_memoria;
    assign db_rodada     = s_rodada;

    //Buzzer para jogadas
    buzzer BuzzerLeds (
        .clock   ( clock ),
        .conta   ( toca ),
        .reset   ( zeraR ),

        .seletor ( leds ),

        .pulso   ( pulso_buzzer )  // Frequência da nota a ser tocada
    );

    // Registrdor no nível de jogadas
    registrador_n #(.SIZE(1)) RegNvlJog (
        .D      ( nivel_jogadas     ),
        .Q      ( nivel_jogadas_reg ),
        .clear  ( zeraR             ),
        .clock  ( clock             ),
        .enable ( registraN         )
    );

    // Registrdor no nível de tempo
    registrador_n #(.SIZE(1)) RegNvlTime (
        .D      ( nivel_tempo     ),
        .Q      ( nivel_tempo_reg ),
        .clear  ( zeraR           ),
        .clock  ( clock           ),
        .enable ( registraN       )
    );

    // Registrdor no modo de jogo
    registrador_n #(.SIZE(1)) RegMdJogo (
        .D      ( modo2     ),
        .Q      ( modo2_reg ),
        .clear  ( zeraR     ),
        .clock  ( clock     ),
        .enable ( registraN )
    );

    //Edge Detector
    edge_detector EdgeDetector (
        .clock( clock        ),
        .reset( 1'b0         ), 
        .sinal( tem_jogada   ), 
        .pulso( jogada_feita )
    );

    //Contador para a jogada atual
    contador_163 ContEnd (
        .clock ( clock      ), 
        .clr   ( ~zeraC     ),
        .ent   ( 1'b1       ), 
        .enp   ( contaC     ), 
        .Q     ( s_endereco ),
        .rco   (            ),
        .ld    ( 1'b1       ),
        .D     (            )
    );

    // Contador para a rodada atual
    contador_m #(.M(16), .N(4)) ContRod (
        .clock   ( clock    ), 
        .zera_s  ( zeraCR   ), 
        .zera_as (  ), 
        .conta   ( contaCR  ),
        .Q       ( s_rodada ),
        .fim     ( fimCR    ),
        .meio    ( meioCR )
    );

    // Contador (timer) COM 0.5s para sinalizar o feedback de led apertada
    contador_m #(.M(TEMPO_FEEDBACK), .N($clog2(TEMPO_FEEDBACK)) ) ContMostra (
        .clock   ( clock   ), 
        .zera_as ( 1'b0    ), 
        .zera_s  ( zeraTM  ), 
        .conta   ( contaTM ), 
        .fim     (  meioTM ),
        .Q       (         ),
        .meio    (         )
    );

    // Contador (timer) COM 2s para sinalizar a apresentação de jogada
    contador_m #(.M(TEMPO_MOSTRA*CLOCK_FREQ), .N($clog2(TEMPO_MOSTRA*CLOCK_FREQ)) ) ContFeedback (
        .clock   ( clock   ), 
        .zera_as ( 1'b0    ), 
        .zera_s  ( zeraTM  ), 
        .conta   ( contaTM ), 
        .fim     ( fimTM   ),
        .Q       (         ),
        .meio    (         )
    );

    // Contador (timer) de 3s para sinalizar timeout 
    contador_m  # ( .M(TIMEOUT*CLOCK_FREQ), .N($clog2(TIMEOUT*CLOCK_FREQ)) ) TimerTimeout (
        .clock   ( clock        ),
        .zera_as ( jogada_feita ),
        .zera_s  ( zeraTempo    ),
        .conta   ( contaTempo   ),
        .Q       (              ),
        .fim     ( fimTempo     ),
        .meio    ( meioTempo    )
    );
        
    //Memoria ROM sincrona 16 palavras de 4 bits
    sync_ram_16x4_file MemJog (
        .clk      ( clock      ), 
        .addr     ( s_endereco ), 
        .q        ( s_memoria  ),
        .we       ( gravaM     ),
        .data     ( botoes     )
    );

    //Comparador para a jogada atual
    comparador_85 CompJog (
        .AEBi ( 1'b1           ), 
        .AGBi ( 1'b0           ), 
        .ALBi ( 1'b0           ), 
        .A    ( s_memoria      ), 
        .B    ( s_jogada       ), 
        .AEBo ( jogada_correta ),
        .AGBo (                ),
        .ALBo (                )
    );

    //Comparador para a rodada atual
    comparador_85 CompEnd (
        .AEBi ( 1'b1                ), 
        .AGBi ( 1'b0                ), 
        .ALBi ( 1'b0                ), 
        .A    ( s_rodada            ),  
        .B    ( s_endereco          ), 
        .AEBo ( enderecoIgualRodada ),
        .AGBo (                     ),
        .ALBo (                     )
    );

    //Registrador 4 bits
    registrador_n #(.SIZE(4)) RegChv (
        .D      ( botoes      ),
        .clear  ( zeraR       ),
        .clock  ( clock       ),
        .enable ( registraR   ),
        .Q      ( s_jogada    )
    );
    
endmodule
