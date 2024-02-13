/* --------------------------------------------------------------------
 * Arquivo   : circuito_exp5.v
 * Projeto   : Experiencia 5 - Desenvolvimento de Projeto de 
 *             Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : Circuito em Verilog para a Experiencia 5 
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                            Descricao
 *     02/01/2024  1.0     Caio Dourado, Davi Félix e Vinicius Batista      versao inicial
 * --------------------------------------------------------------------
*/

module circuito_exp6 (
    input        clock,
    input        reset,
    input        iniciar,
    input [3:0]  botoes,
    input        nivel_jogadas, 
    input        nivel_tempo,

    output       ganhou,
    output       perdeu,
    output       pronto,
    output       timeout,
	output       vez_jogador,
    output [3:0] leds,

    output       db_igual,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_estado,
    output [6:0] db_jogada,
    output       db_nivel_jogadas,
    output       db_nivel_tempo,
    output       db_clock,
    output       db_iniciar,
    output       db_tem_jogada
);

    // Sinais de controle
    wire contaC, contaTempo, contaTM, contaCR, registraR, registraN;
    wire zeraC, zeraR, zeraCR, zeraTM, zeraTempo;
    wire ativa_leds;
    // Sinais de condição
    wire fimC, fimCR, fimTM, meioTM, fimTempo, meioCR, meioTempo; 
    wire enderecoIgualRodada, jogada_feita, jogada_correta;
    wire nivel_jogadas_reg, nivel_tempo_reg;
    // Sinais de depuração
    wire [3:0] s_db_contagem, s_db_jogada, s_db_memoria;
    wire [3:0] s_db_estado;
    // Setando sinais de depuração
    assign     db_iniciar       = iniciar;
    assign     db_clock         = clock;
	assign     db_igual         = jogada_correta;
    assign     db_nivel_jogadas = nivel_jogadas_reg;
    assign     db_nivel_tempo   = nivel_tempo_reg;

    //Fluxo de Dados
    exp6_fluxo_dados fluxo_dados (
        // Sinais de entrada
        .clock               ( clock               ),
        .botoes              ( botoes              ),
        .nivel_jogadas       ( nivel_jogadas       ),
        .nivel_tempo         ( nivel_tempo         ),
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
        .ativa_leds          ( ativa_leds          ),
        // Sinais de condição
        .jogada_correta      ( jogada_correta      ),
        .jogada_feita        ( jogada_feita        ),
        .fimC                ( fimC                ),
        .meioCR              ( meioCR              ),
        .fimTempo            ( fimTempo            ),
        .meioTempo           ( meioTempo           ),
        .fimCR               ( fimCR               ),
        .fimTM               ( fimTM               ),
        .meioTM              ( meioTM              ),
        .enderecoIgualRodada ( enderecoIgualRodada ),
        .nivel_jogadas_reg   ( nivel_jogadas_reg   ),
        .nivel_tempo_reg     ( nivel_tempo_reg     ),
        // Sinais de saída
        .leds                ( leds                ),
        // Sinais de depuração
        .db_tem_jogada       ( db_tem_jogada       ),
        .db_contagem         ( s_db_contagem       ),
        .db_jogada           ( s_db_jogada         ),
        .db_memoria          ( s_db_memoria        )
    );

    //Unidade de controle
    exp6_unidade_controle unidade_controle (
        // Sinais de entrada
        .clock               ( clock               ),
        .reset               ( reset               ),
        .iniciar             ( iniciar             ),
        .nivel_jogadas       ( nivel_jogadas_reg   ),
        .nivel_tempo         ( nivel_tempo_reg     ),
        // Sinais de condição
        .fimTempo            ( fimTempo            ),
        .meioTempo           ( meioTempo           ),
        .fimC                ( fimC                ),
        .meioCR              ( meioCR              ),
        .fimCR               ( fimCR               ),
        .fimTM               ( fimTM               ),
        .meioTM              ( meioTM              ),
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
        .ativa_leds          ( ativa_leds          ),
        // Sinais de saída
        .ganhou              ( ganhou              ),
        .perdeu              ( perdeu              ),
        .pronto              ( pronto              ),
        .timeout             ( timeout             ),
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
    hexa7seg display_memoria (
        .hexa    ( s_db_memoria ),
        .display ( db_memoria   )
    );
		
	 //Estado
    hexa7seg display_estado (
        .hexa    ( s_db_estado ),
        .display ( db_estado   )
    );

     //Jogada
    hexa7seg display_jogada (
        .hexa    ( s_db_jogada ),
        .display ( db_jogada   )
    );

	 
endmodule