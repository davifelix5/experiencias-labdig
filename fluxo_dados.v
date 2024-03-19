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


module fluxo_dados #(
    parameter CLOCK_FREQ,
              MODO       = 4,
              BPM        = 2,
              TOM        = 4,
              MUSICA     = 16,
              ERRO       = 3
) (
    // Entradas
    input clock,
    input [3:0] botoes_encoded,
    input right_arrow_pressed,
    input left_arrow_pressed,
    input enter_pressed,

    // Sinais de controle
    input       zeraR,
    input       registraR,
    input       zeraC,
    input       contaC,
    input       contaTempo,
    input       zeraCR,
    input       zeraTempo,
    input       contaCR,
    input       zeraTF,
    input       contaTF,
    input       leds_mem,
    input       ativa_leds,
    input       toca,
    input       gravaM,
    input       zeraMetro,
    input       contaMetro,
    input [2:0] menu_sel,
    input       inicia_menu,
    input       registra_modo,
    input       registra_bpm,
    input       registra_tom,
    input       registra_musicas,
    
    // Sinais de codição
    output                nota_correta,
    output                tempo_correto,
    output                tempo_correto_baixo,
    output                nota_feita,
    output                meioCR,
    output                fimTempo,
    output                meioTempo,
    output                enderecoIgualRodada,
    output                fimCR,
    output                fimTF,
    output                pulso_buzzer,
    output                fim_musica,
    output [ERRO - 1:0]   erros,
    output [MODO - 1:0]   modos_reg,
    output                press_enter,

    // Sinais de saída
    output [11:0] leds,
    output [3:0]  arduino_out,

    // Sinais de depuração
    output       db_metro,
    output [3:0] db_nota  ,
    output [3:0] db_memoria_nota,
    output [3:0] db_memoria_tempo
);

    parameter TEMPO_MOSTRA = 2, TIMEOUT=5, // s
              TEMPO_FEEDBACK = CLOCK_FREQ/2;

    // Sinais internos
    wire tem_nota, metro, meio_metro, nota_apertada_pulso;
    wire [3:0] s_memoria_nota, s_memoria_tempo, 
               s_nota, tempo, leds_encoded;
    wire [4:0] s_endereco, s_rodada;
    wire metro120, metro60, meio_metro120, meio_metro60;
    wire metro_120BPM;


    // Seleções do menu
    wire [BPM - 1:0]    bpms;
    wire [MODO - 1:0]   modos;
    wire [$clog2(TOM) - 1:0]    toms;
    wire [$clog2(MUSICA) - 1:0] musicas; 

    wire [$clog2(TOM) - 1:0]    tom_reg;
    wire [$clog2(MUSICA) - 1:0] musica_reg; 
    
    // OR dos botoes
    assign nota_feita    = |botoes_encoded;

    // Sinais de depuração
    assign db_metro           = meio_metro;
    assign db_contagem        = s_endereco[3:0];
    assign db_nota            = s_nota;
    assign db_memoria_nota    = s_memoria_nota;
    assign db_memoria_tempo   = s_memoria_tempo;
    assign db_rodada          = s_rodada[3:0];
    
    // Menu para interação com o display
    menu #(
        .MODO(MODO),
        .TOM(TOM),
        .BPM(BPM),
        .MUSICA(MUSICA),
        .ERRO(ERRO)
    ) menu_display (
        .clock               ( clock ),
        .reset               ( reset ),
        .right_arrow_pressed ( right_arrow_pressed ),
        .left_arrow_pressed  ( left_arrow_pressed  ),
        .load_initial        ( inicia_menu         ),
        .menu_sel            ( menu_sel            ),

        .erros               ( erros               ),

        .modos               ( modos               ),
        .bpms                ( bpms                ),
        .toms                ( toms                ),
        .musicas             ( musicas             ),

        .arduino_out         ( arduino_out         )
    );

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
    buzzer #(.CLOCK_FREQ(CLOCK_FREQ), .TOM(TOM)) BuzzerLeds (
        .clock   ( clock ),
        .toca    ( toca ),
        .reset   ( zeraR ),

        .seletor ( leds_encoded ),
        .tom     ( tom_reg      ),

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

    //Edge Detector para a nota escolhida
    edge_detector EdgeDetectorNota (
        .clock( clock               ),
        .reset( 1'b0                ), 
        .sinal( nota_feita          ), 
        .pulso( nota_apertada_pulso )
    );

    //Edge Detector para o enter
    edge_detector EdgeDetector (
        .clock( clock         ),
        .reset( 1'b0          ), 
        .sinal( enter_pressed ), 
        .pulso( press_enter   )
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
        .musica     ( musica_reg      ),
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

    //Registrador do valor da nota
    registrador_n #(.SIZE(4)) RegChv (
        .D      ( botoes_encoded                    ),
        .clear  ( zeraR                             ),
        .clock  ( clock                             ),
        .enable ( registraR & nota_apertada_pulso   ),
        .Q      ( s_nota                            )
    );

    // Registrador do valor de tom selecionardo
    registrador_n #(.SIZE($clog2(TOM))) RegTom (
        .D      ( toms                              ),
        .clear  ( zeraR                             ),
        .clock  ( clock                             ),
        .enable ( registra_tom                      ),
        .Q      ( tom_reg                           )
    );

    // Registrador do valor de música selecionado
    registrador_n #(.SIZE($clog2(MUSICA))) RegMusica (
        .D      ( musicas          ),
        .clear  ( zeraR            ),
        .clock  ( clock            ),
        .enable ( registra_musicas ),
        .Q      ( musica_reg       )
    );

    // Registrador do valor de bpm selecionado
    registrador_n #(.SIZE(1)) Reg120BPM (
        .D      ( bpms[1]      ),
        .clear  ( zeraR        ),
        .clock  ( clock        ),
        .enable ( registra_bpm ),
        .Q      ( metro_120BPM )
    );

    // Registrador do valor de modo selecionado
    registrador_n #(.SIZE(4)) RegModo (
        .D      ( modos         ),
        .clear  ( zeraR         ),
        .clock  ( clock         ),
        .enable ( registra_modo ),
        .Q      ( modos_reg     )
    );

    
endmodule
