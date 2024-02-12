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

module circuito_exp5 (
    input        clock,
    input        reset,
    input        iniciar,
    input [3:0]  chaves,
    input        nivel_jogadas, 
    input        nivel_tempo,

    output       acertou,
    output       errou,
    output       pronto,
    output       timeout,
    output [3:0] leds,

    output       db_igual,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_estado,
    output       db_nivel_jogadas,
    output       db_nivel_tempo,
    output       db_clock,
    output       db_iniciar,
    output       db_tem_jogada
);

    // Sinais de controle
    wire       contaC, registraR, registraN, zeraC, zeraR, contaTempo;
    // Sinais de condição
    wire       fimC, fimCR, fimTM, fimTempo, meioC, meioTempo; 
    wire       enderecoIgualRodada, jogada_feita, jogada_correta;
    wire       nivel_jogadas_reg, nivel_tempo_reg;
    // Sinais de saída
    wire [3:0] s_jogada;
    // Sinais de depuração
    wire [3:0] s_db_contagem, s_db_memoria, s_db_jogada;
    wire [3:0] s_db_estado;
    // Setando sinais de depuração
    assign     db_iniciar       = iniciar;
    assign     db_clock         = clock;
	assign     db_igual         = jogada_correta;
    assign     db_nivel_jogadas = nivel_jogadas_reg;
    assign     db_nivel_tempo   = nivel_tempo_reg;
	 
    // Setando sinais de saída
	assign     leds = s_jogada;

    //Fluxo de Dados
    exp5_fluxo_dados exp5_fluxo_dados (
        // Sinais de entrada
        .clock               ( clock               ),
        .chaves              ( chaves              ),
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
        .zeraRM              ( zeraTM              ),
        // Sinais de condição
        .jogada_correta      ( jogada_correta      ),
        .jogada_feita        ( jogada_feita        ),
        .fimC                ( fimC                ),
        .meioC               ( meioC               ),
        .fimTempo            ( fimTempo            ),
        .meioTempo           ( meioTempo           ),
        .fimCR               ( fimCR               ),
        .fimTM               ( fimTM               ),
        .enderecoIgualRodada ( enderecoIgualRodada ),
        .nivel_jogadas_reg   ( nivel_jogadas_reg   ),
        .nivel_tempo_reg     ( nivel_tempo_reg     ),
        // Sinais de saída
        .jogada              ( s_jogada            ),
        // Sinais de depuração
        .db_tem_jogada       ( db_tem_jogada       ),
        .db_memoria          ( s_db_memoria        ),
        .db_contagem         ( s_db_contagem       )
    );

    //Unidade de controle
    exp5_unidade_controle exp5_unidade_controle (
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
        .meioC               ( meioC               ),
        .fimCR               ( fimCR               ),
        .fimTM               ( fimTM               ),
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
        // Sinais de saída
        .acertou             ( acertou             ),
        .errou               ( errou               ),
        .pronto              ( pronto              ),
        .timeout             ( timeout             ),
        // Sinais de depuração
        .db_estado           ( s_db_estado         )
    );

    /* Displays */

    //Contagem
    hexa7seg HEX0 (
        .hexa    ( s_db_contagem),
        .display ( db_contagem  )
    );

    //Memoria
    hexa7seg HEX1 (
        .hexa    ( s_db_memoria ),
        .display ( db_memoria   )
    );
		
	 //Estado
    hexa7seg HEX3 (
        .hexa    ( s_db_estado ),
        .display ( db_estado   )
    );

	 
endmodule