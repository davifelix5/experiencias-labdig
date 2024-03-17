/* --------------------------------------------------------------------
 * Arquivo   : fluxo_dados.v
 * Projeto   : FPGAudio - Piano didático com FPGA
 * --------------------------------------------------------------------
 * Descricao : Fluxo de dados Verilog para circuito
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                            Descricao
 *     11/03/2024  1.0     Caio Dourado, Davi Félix e Vinicius Batista      versao inicial
 * --------------------------------------------------------------------
*/


module fluxo_dados #(parameter CLOCK_FREQ)
(
    // Entradas
    input clock,
    input [3:0] botoes_encoded,

    // Sinais de controle
    input zeraR,
    input registraR,
    input zeraC,
    input contaC,
    input contaTempo,
    input zeraCR,
    input zeraTempo,
    input contaCR,
    input zeraTF,
    input contaTF,
    input leds_mem,
    input ativa_leds,
    input toca,
    input gravaM,
    input metro_120BPM,
    input zeraMetro,
    input contaMetro,
    
    // Sinais de codição
    output nota_correta,
    output tempo_correto,
    output tempo_correto_baixo,
    output nota_feita,
    output meioCR,
    output fimTempo,
    output meioTempo,
    output enderecoIgualRodada,
    output fimCR,
    output fimTF,
    output pulso_buzzer,
    output fim_musica,

    // Sinais de saída
    output [11:0] leds,

    // Sinais de depuração
    output       db_metro,
    output [3:0] db_contagem,
    output [3:0] db_nota  ,
    output [3:0] db_memoria_nota,
    output [3:0] db_memoria_tempo,
    output [3:0] db_rodada
);

    parameter TEMPO_MOSTRA = 2, TIMEOUT=5, // s
              TEMPO_FEEDBACK = CLOCK_FREQ/2;

    // Sinais internos
    wire tem_nota, metro, meio_metro, nota_apertada_pulso;
    wire [3:0] s_memoria_nota, s_memoria_tempo, 
               s_nota, tempo, leds_encoded;
    wire [4:0] s_endereco, s_rodada;
    wire metro120, metro60, meio_metro120, meio_metro60;


    // OR dos botoes
    assign nota_feita    = |botoes_encoded;

    // Sinais de depuração
    assign db_metro           = meio_metro;
    assign db_contagem        = s_endereco[3:0];
    assign db_nota            = s_nota;
    assign db_memoria_nota    = s_memoria_nota;
    assign db_memoria_tempo   = s_memoria_tempo;
    assign db_rodada          = s_rodada[3:0];

    // Multiplexador para escolher se o valor dos leds será definido pela memória ou pelo valor
    mux_2x1 #(.SIZE(4)) mux_sinal_leds (
        .A(s_memoria_nota),
        .B(s_nota),
        .sel(leds_mem),
        .res(leds_encoded)
    );

    // Módulo para fornecer o pulso do metrônomo
    metronomo #(.CLOCK_FREQ(CLOCK_FREQ)) conta_metronomo (
        .clock        ( clock        ),
        .zeraMetro    ( zeraMetro    ),
        .contaMetro   ( contaMetro   ),
        .metro_120BPM ( metro_120BPM ),
    
        .metro        ( metro        ),
        .meio_metro   ( meio_metro   )
    );

    //Buzzer para notas
    buzzer #(.CLOCK_FREQ(CLOCK_FREQ)) BuzzerLeds (
        .clock   ( clock ),
        .toca    ( toca ),
        .reset   ( zeraR ),

        .seletor ( leds ),

        .pulso   ( pulso_buzzer )  // Frequência da nota a ser tocada
    );

    // Contador para traduzir o valor das leds para o formato em que será mostrado
    decoder_nota DeocodificaNota (
        .valor   ( leds_encoded ), 
        .enable ( ativa_leds ), 
        .nota ( leds )       
    );

    // Contador que indica o tempo a partir do metrônomo
    contador_m #(.M(16)) ContadorTempo (
        .clock   ( metro         ), 
        .zera_s  ( 1'b0          ),  
        .zera_as ( zeraMetro     ), 
        .conta   ( contaMetro    ),
        .Q       ( tempo         ),
        .fim     (               ),
        .meio    (               )
    );

    // Comparador para identificar se o tempo de música está correto
    comparador_tempo CompTempo (
        .s_memoria_tempo     ( s_memoria_tempo ),
        .tempo               ( tempo ),
        .meio_metro          ( meio_metro ),
        
        .tempo_correto_baixo ( tempo_correto_baixo ),
        .tempo_correto       ( tempo_correto )
    );

    //Edge Detector
    edge_detector EdgeDetector (
        .clock( clock               ),
        .reset( 1'b0                ), 
        .sinal( nota_feita          ), 
        .pulso( nota_apertada_pulso )
    );

    // Contador para o endereço atual
    contador_m #(.M(32)) ContEnd (
        .clock   ( clock      ), 
        .zera_s  ( zeraC      ), 
        .zera_as ( 1'b0       ), 
        .conta   ( contaC     ),
        .Q       ( s_endereco ),
        .fim     (            ),
        .meio    (            )
    );

    // Contador para a rodada atual
    contador_m #(.M(32)) ContRod (
        .clock   ( clock    ), 
        .zera_s  ( zeraCR   ), 
        .zera_as ( 1'b0     ), 
        .conta   ( contaCR  ),
        .Q       ( s_rodada ),
        .fim     ( fimCR    ),
        .meio    ( meioCR   )
    );

    // Contador (timer) COM 0.5s para sinalizar o feedback de led apertada
    contador_m #(.M(TEMPO_FEEDBACK) ) ContFeedback (
        .clock   ( clock   ), 
        .zera_as ( 1'b0    ), 
        .zera_s  ( zeraTF  ), 
        .conta   ( contaTF ), 
        .fim     (  fimTF  ),
        .Q       (         ),
        .meio    (         )
    );

    // Contador (timer) de 5s para sinalizar timeout 
    contador_m  # ( .M(TIMEOUT*CLOCK_FREQ) ) TimerTimeout (
        .clock   ( clock        ),
        .zera_as ( 1'b0         ),
        .zera_s  ( zeraTempo    ),
        .conta   ( contaTempo   ),
        .Q       (              ),
        .fim     ( fimTempo     ),
        .meio    ( meioTempo    )
    );
        
    //Memoria RAM para o tempo e notas
    sync_ram_musicas_32x4x16_file MemTempos (
        .clk        ( clock           ), 
        .addr       ( s_endereco      ), 
        .musica     ( 4'd1            ),
        .we         ( gravaM          ),
        .data_nota  (                 ),
        .data_tempo (                 ),
        .tempo      ( s_memoria_tempo ),
        .nota       ( s_memoria_nota  ),
        .fim_musica ( fim_musica      )

    );

    //Comparador para a nota atual
    comparador_85 CompJog (
        .AEBi ( 1'b1           ), 
        .AGBi ( 1'b0           ), 
        .ALBi ( 1'b0           ), 
        .A    ( s_memoria_nota ), 
        .B    ( s_nota         ), 
        .AEBo ( nota_correta ),
        .AGBo (                ),
        .ALBo (                )
    );

    //Comparador para a rodada atual
    comparador_85 #(.SIZE(5)) CompEnd (
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
        .D      ( botoes_encoded                    ),
        .clear  ( zeraR                             ),
        .clock  ( clock                             ),
        .enable ( registraR & nota_apertada_pulso   ),
        .Q      ( s_nota                            )
    );

    
endmodule
