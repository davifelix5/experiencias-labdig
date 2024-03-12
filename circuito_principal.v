module circuito_exp7 #(parameter CLOCK_FREQ = 5000) // 50MHz 
(
    input        clock,
    input        reset,
    input        iniciar,
    input [3:0]  botoes,
    input        nivel_jogadas, 
    input        nivel_tempo,
    input        modo2,

    output       ganhou,
    output       perdeu,
    output       pronto,
	output       vez_jogador,
    output [3:0] leds,
    output       pulso_buzzer,

    output       db_jogada_correta,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_estado_lsb,
    output [6:0] db_estado_msb,
    output [6:0] db_jogada,
    output [6:0] db_rodada,
    output       db_clock,
    output       db_enderecoIgualRodada
);

    // Sinais de controle
    wire contaC, contaTempo, contaTM, contaCR, registraR, registraN;
    wire zeraC, zeraR, zeraCR, zeraTM, zeraTempo;
    wire ativa_leds_mem, ativa_leds_jog, toca;
    wire gravaM;
    // Sinais de condição
    wire fimCR, fimTM, meioTM, fimTempo, meioCR, meioTempo; 
    wire enderecoIgualRodada, jogada_feita, jogada_correta;
    // Sinais de depuração
    wire [3:0] s_db_contagem, s_db_jogada, s_db_memoria, s_db_rodada;
    wire [4:0] s_db_estado;
    // Setando sinais de depuração
    assign db_clock               = clock;
	assign db_jogada_correta      = jogada_correta;
    assign db_enderecoIgualRodada = enderecoIgualRodada;

    //Fluxo de Dados
    exp7_fluxo_dados #(.CLOCK_FREQ(CLOCK_FREQ)) fluxo_dados (
        // Sinais de entrada
        .clock               ( clock               ),
        .botoes              ( botoes              ),
        // Sinais de controle 
        .zeraR               ( zeraR               ),
        .registraR           ( registraR           ),
        .zeraC               ( zeraC               ),
        .contaC              ( contaC              ),
        .registraN           ( registraN           ),
        .zeraTempo           ( zeraTempo           ),
        .contaTempo          ( contaTempo          ),
        .contaCR             ( contaCR             ),
        .zeraCR              ( zeraCR              ),
        .contaTM             ( contaTM             ),
        .zeraTM              ( zeraTM              ),
        .ativa_leds_mem      ( ativa_leds_mem      ),
        .ativa_leds_jog      ( ativa_leds_jog      ),
        .toca                ( toca                ),
        .gravaM              ( gravaM              ),
        // Sinais de condição
        .jogada_correta      ( jogada_correta      ),
        .jogada_feita        ( jogada_feita        ),
        .meioCR              ( meioCR              ),
        .fimTempo            ( fimTempo            ),
        .meioTempo           ( meioTempo           ),
        .fimCR               ( fimCR               ),
        .fimTF               ( fimTF               ),
        .enderecoIgualRodada ( enderecoIgualRodada ),
        // Sinais de saída
        .leds                ( leds                ),
        .pulso_buzzer        ( pulso_buzzer        ),
        // Sinais de depuração
        .db_contagem         ( s_db_contagem       ),
        .db_jogada           ( s_db_jogada         ),
        .db_memoria          ( s_db_memoria        ),
        .db_rodada           ( s_db_rodada         )
    );

    //Unidade de controle
    exp7_unidade_controle unidade_controle (
        // Sinais de entrada
        .clock               ( clock               ),
        .reset               ( reset               ),
        .iniciar             ( iniciar             ),
        // Sinais de condição
        .fimTempo            ( fimTempo            ),
        .meioTempo           ( meioTempo           ),
        .meioCR              ( meioCR              ),
        .fimCR               ( fimCR               ),
        .fimTF               ( fimTF              ),
        .jogada_feita        ( jogada_feita        ),
        .jogada_correta      ( jogada_correta      ),
        .enderecoIgualRodada ( enderecoIgualRodada ),
        // Sinais de controle
        .zeraC               ( zeraC               ),
        .contaC              ( contaC              ),
        .zeraTM              ( zeraTM              ),
        .contaTM             ( contaTM             ),
        .zeraCR              ( zeraCR              ),
        .contaCR             ( contaCR             ),
        .zeraR               ( zeraR               ),
        .registraR           ( registraR           ),
        .registraN           ( registraN           ),
        .contaTempo          ( contaTempo          ),
        .zeraTempo           ( zeraTempo           ),
        .ativa_leds_mem      ( ativa_leds_mem      ),
        .ativa_leds_jog      ( ativa_leds_jog      ),
        .toca                ( toca                ),
        .gravaM              ( gravaM              ),
        // Sinais de saída
        .ganhou              ( ganhou              ),
        .perdeu              ( perdeu              ),
        .pronto              ( pronto              ),
		.vez_jogador         ( vez_jogador         ),
        // Sinais de depuração
        .db_estado           ( s_db_estado         ),
        .db_timeout          ( db_timeout          )
    
    );

    /* Displays */

    //Contagem
    hexa7seg display_contagem (
        .hexa    ( s_db_contagem),
        .display ( db_contagem  )
    );

    //Memoria
    hexa7seg display_memoria (
        .hexa    ( s_db_memoria ),
        .display ( db_memoria   )
    );
		
	 //Estado primeiros bits
    hexa7seg display_estado_prim (
        .hexa    ( s_db_estado[3:0] ),
        .display ( db_estado_lsb   )
    );

     //Estado ultimos bits
    hexa7seg display_estado_ult (
        .hexa    ({3'b0, s_db_estado[4]}),
        .display ( db_estado_msb   )
    );

     //Jogada
    hexa7seg display_jogada (
        .hexa    ( s_db_jogada ),
        .display ( db_jogada   )
    );

     //Rodada
    hexa7seg display_rodada (
        .hexa    ( s_db_rodada ),
        .display ( db_rodada   )
    );

	 
endmodule