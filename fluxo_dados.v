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
              ERRO       = 3,
              GRAVA_OPS  = 3,

              DEBOUNCE_TIME
) (
    // Entradas
    input clock,
    input reset,
    input [12:0] botoes,
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
    input       registra_erro,
    
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
    output [GRAVA_OPS - 1:0]   grava_ops,
    output                press_enter,

    // Sinais de saída
    output [12:0] leds,
    output [3:0]  arduino_out,
    output        errou_nota,

    // Sinais de depuração
    output       db_metro,
    output [3:0] db_nota  ,
    output [3:0] db_memoria_nota,
    output [3:0] db_memoria_tempo,
    output [3:0] db_tempo

);

    localparam TEMPO_MOSTRA = 2, TIMEOUT=5, // s
              TEMPO_FEEDBACK = CLOCK_FREQ/2;

    localparam NUM_NOTAS = 256;

    // Sinais internos
    wire tem_nota, metro, meio_metro, nota_apertada_pulso;
    wire [3:0] s_memoria_nota, s_memoria_tempo, 
               s_nota, tempo, leds_encoded, tempo_baixo;
	 wire [3:0] botoes_encoded;
    wire [$clog2(NUM_NOTAS) - 1:0] s_endereco, s_rodada, cont_end_data;
    wire metro_120BPM;


    // Seleções do menu
    wire [BPM - 1:0]    bpms;
    wire [MODO - 1:0]   modos;
    wire [$clog2(TOM) - 1:0]    toms;
    wire [$clog2(MUSICA) - 1:0] musicas; 

    wire [$clog2(TOM) - 1:0]    tom_reg;
    wire [$clog2(MUSICA) - 1:0] musica_reg; 
    

    // Sinais de depuração
    assign db_metro           = meio_metro;
    assign db_nota            = s_nota;
    assign db_memoria_nota    = s_memoria_nota;
    assign db_memoria_tempo   = s_memoria_tempo;
    assign db_tempo   = tempo;

    // OR dos botoes
    wire [12:0] botoes_debounced;
    assign nota_feita    = |botoes_debounced;

    botoes_debouncer #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debouncer (
        .clock(clock),
        .reset(reset),
        .botoes(botoes),
        .botoes_debounced(botoes_debounced)
    );

    debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) enter_debounce (
        .clk(clock),
        .rst(reset),
        .real_button(enter_pressed),
        .debounced_button(enter_pressed_deb)
    );

    debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) right_arrow_debounce (
        .clk(clock),
        .rst(reset),
        .real_button(right_arrow_pressed),
        .debounced_button(right_arrow_press_deb)
    );

    debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) left_arrow_debounce (
        .clk(clock),
        .rst(reset),
        .real_button(left_arrow_pressed),
        .debounced_button(left_arrow_press_deb)
    );

    // Codificador dos botões
	encoder_nota encoder_botoes (
		.nota(botoes_debounced),
		.enable(1'b1),
		.valor(botoes_encoded)
	 );
    
    // Menu para interação com o display
    menu #(
        .MODO(MODO),
        .TOM(TOM),
        .BPM(BPM),
        .MUSICA(MUSICA),
        .ERRO(ERRO),
        .GRAVA_OPS(GRAVA_OPS)
    ) menu_display (
        .clock               ( clock ),
        .reset               ( reset ),
        .right_arrow_pressed ( right_arrow_press_deb ),
        .left_arrow_pressed  ( left_arrow_press_deb  ),
        .load_initial        ( inicia_menu         ),
        .menu_sel            ( menu_sel            ),

        .erros               ( erros               ),

        .modos               ( modos               ),
        .bpms                ( bpms                ),
        .toms                ( toms                ),
        .musicas             ( musicas             ),
        .grava_ops           ( grava_ops           ),

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
        .clock   ( meio_metro    ), 
        .zera_s  ( 1'b0          ),  
        .zera_as ( zeraMetro     ), 
        .conta   ( contaMetro    ),
        .load    ( 1'b0          ),
        .data    (               ),
        .Q       ( tempo         ),
        .fim     (               ),
        .meio    (               )
    );

    contador_m #(.M(16)) ContadorTempoAlto (
        .clock   ( metro         ), 
        .zera_s  ( 1'b0          ),  
        .zera_as ( zeraMetro     ), 
        .conta   ( contaMetro    ),
        .load    ( 1'b0          ),
        .data    (               ),
        .Q       ( tempo_baixo   ),
        .fim     (               ),
        .meio    (               )
    );

    // Comparador para identificar se o tempo de música está correto
    comparador_tempo CompTempo (
        .s_memoria_tempo     ( s_memoria_tempo ),
        .tempo               ( tempo ),
        .tempo_baixo         ( tempo_baixo ),
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
        .sinal( enter_pressed_deb ), 
        .pulso( press_enter   )
    );

    // Contador para o endereço atual
    contador_m #(.M(NUM_NOTAS)) ContEnd (
        .clock   ( clock         ), 
        .zera_s  ( zeraC         ), 
        .zera_as ( 1'b0          ), 
        .conta   ( contaC        ),
        .load    (   ),
        .data    (   ),
        .Q       ( s_endereco    ),
        .fim     (               ),
        .meio    (               )
    );

    // Contador para a rodada atual
    contador_m #(.M(NUM_NOTAS)) ContRod (
        .clock   ( clock    ), 
        .zera_s  ( zeraCR   ), 
        .zera_as ( 1'b0     ), 
        .conta   ( contaCR  ),
        .load    ( 1'b0     ),
        .data    (          ),
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
        .load    ( 1'b0    ),
        .data    (         ),
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
        .load    ( 1'b0         ),
        .data    (              ),
        .Q       (              ),
        .fim     ( fimTempo     ),
        .meio    ( meioTempo    )
    );
        
    //Memoria RAM para o tempo e notas
    sync_ram_musicas_nx4x16_file #(.N(NUM_NOTAS)) MemTempos (
        .clk        ( clock           ), 
        .addr       ( s_endereco      ), 
        .musica     ( musica_reg      ),
        .we         ( gravaM          ),
        .data_nota  ( s_nota          ),
        .data_tempo ( tempo           ),
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
    comparador_85 #(.SIZE($clog2(NUM_NOTAS))) CompEnd (
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
    registrador_n #(.SIZE(MODO)) RegModo (
        .D      ( modos         ),
        .clear  ( zeraR         ),
        .clock  ( clock         ),
        .enable ( registra_modo ),
        .Q      ( modos_reg     )
    );

   registrador_n #(.SIZE(1)) RegErrouNota (
        .D      ( ~nota_correta ),
        .clear  ( zeraR         ),
        .clock  ( clock         ),
        .enable ( registra_erro ),
        .Q      ( errou_nota    )
   );
endmodule
