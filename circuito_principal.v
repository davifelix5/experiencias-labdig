module circuito_principal #(
    parameter CLOCK_FREQ = 50000000,
              MODO       = 6,
              BPM        = 2,
              TOM        = 4,
              MUSICA     = 16,
              ERRO       = 3,
              GRAVA_OPS  = 3,

              DEBOUNCE_TIME = 5
) (
    input         clock,
    input         reset,
    input         iniciar,
    input [12:0]  botoes,
    input         right_arrow_pressed, left_arrow_pressed, enter_pressed,

    output        ganhou,
    output        perdeu,
	output        vez_jogador,
    output [12:0] leds,
    output        pulso_buzzer,
    output [3:0]  arduino_out,
    output [2:0]  menu_sel,
    output        mostra_menu,

    output        db_nota_correta,
    output        db_tempo_correto,
    output        db_metro,
    output [6:0]  db_memoria_nota,
    output [6:0]  db_memoria_tempo,
    output [6:0]  db_estado_lsb,
    output        db_estado5,
    output        db_estado4,
    output [6:0]  db_nota,
    output [6:0]  db_menu,
    output [6:0]  db_modo,
    output        db_clock,
    output        db_enderecoIgualRodada
);

    // Sinais de controle
    wire contaC, contaTempo, contaTF, contaCR, registraR;
    wire zeraC, zeraR, zeraCR, zeraTF, zeraTempo, zeraMetro, contaMetro;
    wire fim_musica, tempo_correto, tempo_correto_baixo, inicia_menu;
    wire leds_mem, ativa_leds, toca;
    wire gravaM;
    wire apresenta_ultima, tentar_dnv_rep, tentar_dnv;
    wire press_enter;
    wire registra_modo, registra_bpm, registra_tom, registra_musicas;

    wire [MODO - 1:0] modos;
    wire [$clog2(MODO)-1:0] modos_display;
    wire [ERRO - 1:0] erros;
    wire [GRAVA_OPS - 1:0] grava_ops;

    // Sinais de condição
    wire fimCR, fimTF, fimTempo, meioCR, meioTempo; 
    wire enderecoIgualRodada, nota_feita, nota_correta;
    
    // Sinais de depuração
    wire [3:0] s_db_memoria_nota,
               s_db_memoria_tempo, s_db_nota; // Valores que entram nos displays
    wire [5:0] s_db_estado;

    // Setando sinais de depuração
    assign db_clock               = clock;
	 assign db_nota_correta      = nota_correta;
    assign db_enderecoIgualRodada = enderecoIgualRodada;
    assign db_estado5 = s_db_estado[5];
    assign db_estado4 = s_db_estado[4];
    assign db_tempo_correto = tempo_correto;

    //Fluxo de Dados
    fluxo_dados #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .MODO(MODO),
        .TOM(TOM),
        .BPM(BPM),
        .MUSICA(MUSICA),
        .ERRO(ERRO),
        .GRAVA_OPS(GRAVA_OPS),

        .DEBOUNCE_TIME(DEBOUNCE_TIME)
    ) fluxo_dados (
        // Sinais de entrada
        .clock               ( clock               ),
        .reset               ( reset               ),
        .botoes              ( botoes      ),
        .right_arrow_pressed ( right_arrow_pressed ),
        .left_arrow_pressed  ( left_arrow_pressed ),
        .enter_pressed       ( enter_pressed       ),
        // Sinais de controle 
        .zeraR               ( zeraR               ),
        .registraR           ( registraR           ),
        .zeraC               ( zeraC               ),
        .contaC              ( contaC              ),
        .zeraTempo           ( zeraTempo           ),
        .contaTempo          ( contaTempo          ),
        .contaCR             ( contaCR             ),
        .zeraCR              ( zeraCR              ),
        .contaTF             ( contaTF             ),
        .zeraTF              ( zeraTF              ),
        .leds_mem            ( leds_mem            ),
        .ativa_leds          ( ativa_leds          ),
        .toca                ( toca                ),
        .gravaM              ( gravaM              ),
        .zeraMetro           ( zeraMetro           ),          
        .contaMetro          ( contaMetro          ),  
        .menu_sel            ( menu_sel            ),
        .inicia_menu         ( inicia_menu         ),
        .registra_modo       ( registra_modo       ),
        .registra_bpm        ( registra_bpm        ),
        .registra_tom        ( registra_tom        ),
        .registra_musicas    ( registra_musicas    ),           
        // Sinais de condição
        .nota_correta        ( nota_correta        ),
        .tempo_correto       ( tempo_correto       ),
        .tempo_correto_baixo ( tempo_correto_baixo ),
        .nota_feita          ( nota_feita          ),
        .meioCR              ( meioCR              ),
        .fimTempo            ( fimTempo            ),
        .meioTempo           ( meioTempo           ),
        .fimCR               ( fimCR               ),
        .fimTF               ( fimTF               ),
        .enderecoIgualRodada ( enderecoIgualRodada ),
        .fim_musica          ( fim_musica          ),
        .erros               ( erros               ),
        .grava_ops           ( grava_ops           ),
        .modos_reg           ( modos               ),
        .press_enter         ( press_enter         ),
        // Sinais de saída
        .leds                ( leds                ),
        .pulso_buzzer        ( pulso_buzzer        ),
        .arduino_out         ( arduino_out         ),
        // Sinais de depuração
        .db_metro            ( db_metro            ),
        .db_nota             ( s_db_nota           ),
        .db_memoria_nota     ( s_db_memoria_nota   ),
        .db_memoria_tempo    ( s_db_memoria_tempo  )
    );

    //Unidade de controle
    unidade_controle #(
        .MODO(MODO),
        .ERRO(ERRO),
        .GRAVA_OPS(GRAVA_OPS)
    ) unidade_controle (
        // Sinais de entrada
        .clock               ( clock               ),
        .reset               ( reset               ),
        .iniciar             ( iniciar             ),
        // Sinais de condição
        .fimTempo            ( fimTempo            ),
        .meioTempo           ( meioTempo           ),
        .meioCR              ( meioCR              ),
        .fimCR               ( fimCR               ),
        .fimTF               ( fimTF               ),
        .nota_feita          ( nota_feita          ),
        .nota_correta        ( nota_correta        ),
        .tempo_correto       ( tempo_correto       ),
        .tempo_correto_baixo ( tempo_correto_baixo ),
        .enderecoIgualRodada ( enderecoIgualRodada ),
        .erros               ( erros               ),
        .fim_musica          ( fim_musica          ),
        .press_enter         ( press_enter         ),
        // Sinais de controle
        .zeraC               ( zeraC               ),
        .contaC              ( contaC              ),
        .zeraTF              ( zeraTF              ),
        .contaTF             ( contaTF             ),
        .zeraCR              ( zeraCR              ),
        .contaCR             ( contaCR             ),
        .zeraR               ( zeraR               ),
        .registraR           ( registraR           ),
        .contaTempo          ( contaTempo          ),
        .zeraTempo           ( zeraTempo           ),
        .leds_mem            ( leds_mem            ),
        .ativa_leds          ( ativa_leds          ),
        .toca                ( toca                ),
        .gravaM              ( gravaM              ),
        .zeraMetro           ( zeraMetro           ),
        .menu_sel            ( menu_sel            ),
        .modos               ( modos               ),
        .grava_ops           ( grava_ops           ),
        .inicia_menu         ( inicia_menu         ),
        .registra_modo       ( registra_modo       ),
        .registra_bpm        ( registra_bpm        ),
        .registra_tom        ( registra_tom        ),
        .registra_musicas    ( registra_musicas    ),          
        .contaMetro          ( contaMetro          ),  
        // Sinais de saída
        .ganhou              ( ganhou              ),
        .perdeu              ( perdeu              ),
		.vez_jogador         ( vez_jogador         ),
        .mostra_menu         ( mostra_menu         ),
        // Sinais de depuração
        .db_estado           ( s_db_estado         )    
    );

    /* Displays */

    //Memoria
    hexa7seg display_memoria_nota (
        .hexa    ( s_db_memoria_nota ),
        .display ( db_memoria_nota   )
    );

    //Memoria
    hexa7seg display_memoria_tempo (
        .hexa    ( s_db_memoria_tempo ),
        .display ( db_memoria_tempo   )
    );

    // Display da nota
    hexa7seg display_nota (
        .hexa    ( s_db_nota ),
        .display ( db_nota )
    );
		
	 //Estado primeiros bits
    hexa7seg display_estado_prim (
        .hexa    ( s_db_estado[3:0] ),
        .display ( db_estado_lsb   )
    );

     //Jogada
    hexa7seg display_menu (
        .hexa    ( arduino_out ),
        .display ( db_menu   )
    );

    encoder #(.SIZE(MODO)) encoder_modo (
        .data_i(modos),
        .data_o(modos_display)
    );

     //Modos
    hexa7seg display_modo (
        .hexa    ( {{(4-$clog2(MODO)){1'b0}}, modos_display}   ),
        .display ( db_modo )
    );

	 
endmodule