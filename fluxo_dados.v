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
    input [11:0] botoes,

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

    // Sinais de saída
    output [11:0] leds,

    // Sinais de depuração
    output [3:0] db_contagem,
    output [3:0] db_nota  ,
    output [3:0] db_memoria_nota,
    output [3:0] db_memoria_tempo,
    output [3:0] db_rodada
);

    parameter TEMPO_MOSTRA = 2, TIMEOUT=5, // s
              TEMPO_FEEDBACK = CLOCK_FREQ/2,
              METRO_60BPM = CLOCK_FREQ/2, METRO_120BPM = CLOCK_FREQ/4;

    // Sinais internos
    wire tem_nota, metro, meio_metro, nota_apertada_pulso;
    wire [3:0] s_memoria_nota, s_memoria_tempo, s_endereco, 
               s_rodada, s_nota, nota_reg_in, tempo;
    wire metro120, metro60, meio_metro120, meio_metro60;
    wire tempo_correto_cima;


    // OR dos botoes
    assign nota_feita    = |botoes;

    // Seleção do metrônomo: 1 para 120BPM e 0 para 60BPM
    assign metro      = metro_120BPM ? metro120      : metro60;
    assign meio_metro = metro_120BPM ? meio_metro120 : meio_metro60; 

    // Computa a tolerância do tempo
    assign tempo_correto = tempo_correto_baixo | (tempo_correto_cima & meio_metro);

    // Sinais de depuração
    assign db_contagem        = s_endereco;
    assign db_nota            = s_nota;
    assign db_memoria_nota    = s_memoria_nota;
    assign db_memoria_tempo   = s_memoria_tempo;
    assign db_rodada          = s_rodada;

    //Buzzer para notas
    buzzer #(.CLOCK_FREQ(CLOCK_FREQ)) BuzzerLeds (
        .clock   ( clock ),
        .conta   ( toca ),
        .reset   ( zeraR ),

        .seletor ( leds ),

        .pulso   ( pulso_buzzer )  // Frequência da nota a ser tocada
    );

    //Edge Detector
    edge_detector EdgeDetector (
        .clock( clock               ),
        .reset( 1'b0                ), 
        .sinal( nota_feita          ), 
        .pulso( nota_apertada_pulso )
    );

    //Contador para a nota atual
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

    // Metronomo 60BPM para a rodada atual
    contador_m #(.M(METRO_60BPM)) Metro60 (
        .clock   ( clock        ), 
        .zera_s  ( zeraMetro    ), 
        .zera_as ( 1'b0         ),
        .conta   ( contaMetro   ),
        .Q       (              ),
        .fim     ( metro60      ),
        .meio    ( meio_metro60 )
    );

    // Metronomo 120BPM para a rodada atual
    contador_m #(.M(METRO_120BPM)) Metro120 (
        .clock   ( clock         ), 
        .zera_s  ( zeraMetro     ),  
        .zera_as ( 1'b0          ), 
        .conta   ( contaMetro    ),
        .Q       (               ),
        .fim     ( metro120      ),
        .meio    ( meio_metro120 )
    );

    contador_163 ContadorTempo (
        .clock ( metro      ), 
        .clr   ( ~zeraMetro ),
        .ent   ( 1'b1       ), 
        .enp   ( contaMetro ), 
        .Q     ( tempo      ),
        .rco   (            ),
        .ld    ( 1'b1       ),
        .D     (            )
    );

    // Contador para a rodada atual
    contador_m #(.M(16)) ContRod (
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
        
    //Memoria RAM para as notas
    sync_ram_16x4_file #(.HEXFILE("notas_init.txt")) MemNotas (
        .clk      ( clock      ), 
        .addr     ( s_endereco ), 
        .q        ( s_memoria_nota ),
        .we       ( gravaM     ),
        .data     (            )
    );

    //Memoria RAM para o tempo
    sync_ram_16x4_file #(.HEXFILE("tempo_init.txt")) MemTempos (
        .clk      ( clock           ), 
        .addr     ( s_endereco      ), 
        .q        ( s_memoria_tempo ),
        .we       ( gravaM          ),
        .data     (                 )
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

    // Comparador para o tempo atual (tolerância de errar para cima)
    comparador_85 CompTempoBaixo (
        .AEBi ( 1'b1                ), 
        .AGBi ( 1'b0                ), 
        .ALBi ( 1'b0                ), 
        .A    ( s_memoria_tempo     ), 
        .B    ( tempo               ), 
        .AEBo ( tempo_correto_baixo ),
        .AGBo (                     ),
        .ALBo (                     )
    );

    comparador_85 CompTempoAlto (
        .AEBi ( 1'b1                  ), 
        .AGBi ( 1'b0                  ), 
        .ALBi ( 1'b0                  ), 
        .A    ( s_memoria_tempo - 4'b1 ), 
        .B    ( tempo                 ), 
        .AEBo ( tempo_correto_cima    ),
        .AGBo (                       ),
        .ALBo (                       )
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
        .D      ( nota_reg_in                       ),
        .clear  ( zeraR                             ),
        .clock  ( clock                             ),
        .enable ( registraR & nota_apertada_pulso   ),
        .Q      ( s_nota                            )
    );

    decoder_valor_nota DeocodificaNota (
        .valor   ( leds_mem ? s_memoria_nota : s_nota ), 
        .enable ( ativa_leds ), 
        .nota ( leds )       
    );

    decoder_nota_valor CodificaNota (
        .nota  ( botoes ),
        .enable (1'b1),
        .valor  (nota_reg_in)
    );


    
endmodule
