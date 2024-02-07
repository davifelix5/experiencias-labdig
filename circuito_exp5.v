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

module circuito_exp5(
    input        clock,
    input        reset,
    input        iniciar,
    input [3:0]  chaves,
    input        nivel,

    output       acertou,
    output       errou,
    output       pronto,
    output [3:0] leds,
    output       timeout,

    output db_igual,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_estado,
    output db_nivel,
    output db_clock,
    output db_iniciar,
    output db_tem_jogada,
    output db_meioTempo,
    output db_fimTempo
);

    // Sinais de controle
    wire contaC, registraR, registraN, zeraC, zeraR, contaTempo;

    // Sinais de condição
    wire fimC, igual, jogada_feita, nivel_reg, meioC, fimTempo, meioTempo;

    // Sinais de saída
    wire[3:0] s_jogada;


    // Sinais de depuração
    wire [3:0] s_db_contagem, s_db_memoria, s_db_jogada;
    wire [3:0] s_db_estado;

    // Setando sinais de depuração
    assign db_iniciar   = iniciar;
    assign db_clock     = clock;
	assign db_igual     = igual;
    assign db_nivel     = nivel_reg;
    assign db_fimTempo  = fimTempo;
    assign db_meioTempo = meioTempo;
	 
    // Setando sinais de saída
	assign leds = s_jogada;

    //Fluxo de Dados
    exp5_fluxo_dados exp5_fluxo_dados (
        // Sinais de entrada
        .clock        ( clock  ),
        .chaves       ( chaves ),
        .nivel        ( nivel  ),

        // Sinais de controle
        .zeraR        ( zeraR      ),
        .registraR    ( registraR  ),
        .zeraC        ( zeraC      ),
        .contaC       ( contaC     ),
        .registraN    ( registraN  ),
        .contaTempo   ( contaTempo ),

        // Sinais de condição
        .igual        ( igual        ),
        .jogada_feita ( jogada_feita ),
        .nivel_reg    ( nivel_reg    ),
        .fimC         ( fimC         ),
        .meioC        ( meioC        ),
        .fimTempo     ( fimTempo     ),
        .meioTempo    ( meioTempo    ),

        // Sinais de saída
        .jogada       ( s_jogada ),

        // Sinais de depuração
        .db_tem_jogada    ( db_tem_jogada ),
        .db_memoria       ( s_db_memoria  ),
        .db_contagem      ( s_db_contagem )
    );

    //Unidade de controle
    exp5_unidade_controle exp5_unidade_controle(
        .clock     ( clock     ),
        .reset     ( reset     ),
        .iniciar   ( iniciar   ),
        .nivel     ( nivel_reg ),

        .fim       ( fimC         ),
        .jogada    ( jogada_feita ),
        .igual     ( igual        ),
        .meio      ( meioC        ),
        .fimTempo  ( fimTempo     ),
        .meioTempo ( meioTempo),

        .zeraC     ( zeraC     ),
        .contaC    ( contaC    ),
        .zeraR     ( zeraR     ),
        .registraR ( registraR ),
        .registraN ( registraN ),
        .contaTempo( contaTempo ),

        .acertou  ( acertou ),
        .errou    ( errou   ),
        .pronto   ( pronto  ),
        .timeout  ( timeout ),
        .db_estado( s_db_estado )
    );

    //Displays

    //Contagem
    hexa7seg HEX0 (
        .hexa   ( s_db_contagem),
        .display( db_contagem  )
    );

    //Memoria
    hexa7seg HEX1 (
        .hexa   ( s_db_memoria ),
        .display( db_memoria   )
    );
		
	 //Estado
    hexa7seg HEX3 (
        .hexa   ( s_db_estado ),
        .display( db_estado   )
    );

	 
endmodule