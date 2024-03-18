module circuito_principal #(
    parameter CLOCK_FREQ = 50000000,
              MODO       = 4,
              BPM        = 2,
              TOM        = 4,
              MUSICA     = 16,
              ERRO       = 2
) (
    input         clock,
    input         reset,
    input         iniciar,
    input [3:0]   botoes_encoded,
    input         right_arrow_pressed, left_arrow_pressed,

    output        ganhou,
    output        perdeu,
	output        vez_jogador,
    output [11:0] leds,
    output        pulso_buzzer,
    output [3:0]  arduino_out,

    output        db_nota_correta,
    output        db_tempo_correto,
    output        db_metro,
    output [6:0]  db_contagem,
    output [6:0]  db_memoria_nota,
    output [6:0]  db_memoria_tempo,
    output [6:0]  db_estado_lsb,
    output        db_estado_msb,
    output [6:0]  db_nota,
    output [6:0]  db_rodada,
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
    wire registra_modo, registra_bpm, registra_tom, registra_musicas;
    wire [1:0] menu_sel;

    wire [MODO - 1:0] modos;

    // Sinais de condição
    wire fimCR, fimTF, fimTempo, meioCR, meioTempo; 
    wire enderecoIgualRodada, nota_feita, nota_correta;
    
    // Sinais de depuração
    wire [3:0] s_db_contagem,  s_db_rodada, s_db_memoria_nota,
               s_db_memoria_tempo, s_db_nota; // Valores que entram nos displays
    wire [4:0] s_db_estado;

    // Setando sinais de depuração
    assign db_clock               = clock;
	assign db_nota_correta      = nota_correta;
    assign db_enderecoIgualRodada = enderecoIgualRodada;
    assign db_estado_msb = s_db_estado[4];
    assign db_tempo_correto = tempo_correto;

    //Fluxo de Dados
    fluxo_dados #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .MODO(MODO),
        .TOM(TOM),
        .BPM(BPM),
        .MUSICA(MUSICA),
        .ERRO(ERRO)
    ) fluxo_dados (
        // Sinais de entrada
        .clock               ( clock               ),
        .botoes_encoded      ( botoes_encoded      ),
        .right_arrow_pressed ( right_arrow_pressed ),
        .left_arrow_pressed  ( left_arrow_pressed_in ),
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
        .tentar_dnv_rep      ( tentar_dnv_rep      ),
        .tentar_dnv          ( tentar_dnv          ),
        .apresenta_ultima    ( apresenta_ultima    ),
        .modos_reg           ( modos               ),
        // Sinais de saída
        .leds                ( leds                ),
        .pulso_buzzer        ( pulso_buzzer        ),
        .arduino_out         ( arduino_out         ),
        // Sinais de depuração
        .db_metro            ( db_metro            ),
        .db_contagem         ( s_db_contagem       ),
        .db_nota             ( s_db_nota           ),
        .db_memoria_nota     ( s_db_memoria_nota   ),
        .db_memoria_tempo    ( s_db_memoria_tempo  ),
        .db_rodada           ( s_db_rodada         )
    );

    //Unidade de controle
    modo1_unidade_controle #(
        .MODO(MODO)
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
        .apresenta_ultima    ( apresenta_ultima    ),
        .tentar_dnv_rep      ( tentar_dnv_rep      ),
        .tentar_dnv          ( tentar_dnv          ),
        .fim_musica          ( fim_musica          ),
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
        // Sinais de depuração
        .db_estado           ( s_db_estado         )    
    );

    /* Displays */

    //Contagem
    hexa7seg display_contagem (
        .hexa    ( s_db_contagem),
        .display ( db_contagem  )
    );

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
		
	 //Estado primeiros bits
    hexa7seg display_estado_prim (
        .hexa    ( s_db_estado[3:0] ),
        .display ( db_estado_lsb   )
    );

    /* eu */

     //Jogada
    hexa7seg display_nota (
        .hexa    ( s_db_nota ),
        .display ( db_nota   )
    );

     //Rodada
    hexa7seg display_rodada (
        .hexa    ( s_db_rodada ),
        .display ( db_rodada   )
    );

	 
endmodule