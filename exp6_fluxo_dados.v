/* --------------------------------------------------------------------
 * Arquivo   : exp5_fluxo_dados.v
 * Projeto   : Experiencia 5 - Desenvolvimento de Projeto de 
 *             Circuitos Digitais em FPGA
 * --------------------------------------------------------------------
 * Descricao : Fluxo de dados Verilog para circuito da Experiencia 5 
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                            Descricao
 *     02/01/2024  1.0     Caio Dourado, Davi Félix e Vinicius Batista      versao inicial
 * --------------------------------------------------------------------
*/


module exp6_fluxo_dados (
    // Entradas
    input clock,
    input [3:0] botoes,
    input nivel_jogadas, nivel_tempo,

    // Sinais de controle
    input zeraR,
    input registraR,
    input zeraC,
    input contaC,
    input registraN,
    input contaTempo,
    input zeraCR,
    input zeraTempo,
    input contaCR,
    input zeraTM,
    input contaTM,
    input ativa_leds,
    
    // Sinais de codição
    output jogada_correta,
    output jogada_feita,
    output nivel_jogadas_reg,
    output nivel_tempo_reg,
    output fimC,
    output meioCR,
    output fimTempo,
    output meioTempo,
    output enderecoIgualRodada,
    output fimCR,
    output fimTM,
    output meioTM,

    // Sinais de saída
    output [3:0] leds,

    // Sinais de depuração
    output [3:0] db_contagem,
    output [3:0] db_jogada,
    output [3:0] db_memoria,
    output [3:0] db_rodada
);

    // Sinais internos
    wire tem_jogada;
    wire[3:0] s_memoria, s_endereco, s_rodada, s_jogada;

    // OR dos botoes
    assign tem_jogada    = |botoes;

    // Sinais de saída
    assign leds = ativa_leds ? s_memoria : 4'b0;

    // Sinais de depuração
    assign db_contagem   = s_endereco;
    assign db_jogada     = s_jogada;
    assign db_memoria    = s_memoria;
    assign db_rodada     = s_rodada;

    // Registrdor no nível de jogadas
    registrador_n #(.SIZE(1)) RegNvlJog (
        .D      ( nivel_jogadas     ),
        .Q      ( nivel_jogadas_reg ),
        .clear  ( zeraR             ),
        .clock  ( clock             ),
        .enable ( registraN         )
    );

    // Registrdor no nível de tempo
    registrador_n #(.SIZE(1)) RegNvlTime (
        .D      ( nivel_tempo     ),
        .Q      ( nivel_tempo_reg ),
        .clear  ( zeraR           ),
        .clock  ( clock           ),
        .enable ( registraN       )
    );

    //Edge Detector
    edge_detector EdgeDetector (
        .clock( clock        ),
        .reset( 1'b0         ), 
        .sinal( tem_jogada   ), 
        .pulso( jogada_feita )
    );

    //Contador para a jogada atual
    contador_163 ContEnd (
        .clock ( clock      ), 
        .clr   ( ~zeraC     ),
        .ent   ( 1'b1       ), 
        .enp   ( contaC     ), 
        .Q     ( s_endereco ),
        .rco   ( fimC       ),
        .ld    (            ),
        .D     (            )
    );

    // Contador para a rodada atual
    contador_m #(.M(16), .N(4)) ContRod (
        .clock   ( clock    ), 
        .zera_s  ( zeraCR  ), 
        .zera_as (  ), 
        .conta   ( contaCR  ),
        .Q       ( s_rodada ),
        .fim     ( fimCR    ),
        .meio    ( meioCR )
    );

    // Contador (timer) de módulo 1000 (1s) para sinalizar o tempo entre a mostragem de jogadas 
    contador_m #(.M(1000), .N(10)) ContMostra (
        .clock   ( clock   ), 
        .zera_as ( 1'b0    ), 
        .zera_s  ( zeraTM  ), 
        .conta   ( contaTM ), 
        .fim     ( fimTM   ),
        .Q       (         ),
        .meio    ( meioTM  )
    );

    // Contador (timer) de módulo 3000 (3s) para sinalizar timeout 
    contador_m  # ( .M(3000), .N(12) ) TimerTimeout (
        .clock   ( clock        ),
        .zera_as ( jogada_feita ),
        .zera_s  ( zeraTempo    ),
        .conta   ( contaTempo   ),
        .Q       (              ),
        .fim     ( fimTempo     ),
        .meio    ( meioTempo    )
    );
        
    //Memoria ROM sincrona 16 palavras de 4 bits
    sync_rom_16x4 MemJog (
        .clock    ( clock      ), 
        .address  ( s_endereco ), 
        .data_out ( s_memoria  )
    );

    //Comparador para a jogada atual
    comparador_85 CompJog (
        .AEBi ( 1'b1           ), 
        .AGBi ( 1'b0           ), 
        .ALBi ( 1'b0           ), 
        .A    ( s_memoria      ), 
        .B    ( s_jogada       ), 
        .AEBo ( jogada_correta ),
        .AGBo (                ),
        .ALBo (                )
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
        .D      ( botoes      ),
        .clear  ( zeraR       ),
        .clock  ( clock       ),
        .enable ( registraR   ),
        .Q      ( s_jogada    )
    );
    
endmodule
