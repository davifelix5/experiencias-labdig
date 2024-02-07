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


module exp5_fluxo_dados (
    // Entradas
    input clock,
    input [3:0] chaves,
    input nivel,
    
    // Sinais de controle
    input zeraR,
    input registraR,
    input zeraC,
    input contaC,
    input registraN,
    input contaTempo,
    
    // Sinais de codição
    output igual,
    output jogada_feita,
    output nivel_reg,
    output fimC,
    output meioC,
    output fimTempo,
    output meioTempo,

    // Sinais de saída
    output [3:0] jogada,

    // Sinais de depuração
    output db_tem_jogada,
    output [3:0] db_memoria,
    output [3:0] db_contagem
);

    // Sinais internos
    wire[3:0] valor_memoria, contagem;

    // OR das chaves
    assign tem_jogada = |chaves;

    // Sinais de depuração
    assign db_memoria = valor_memoria;
    assign db_contagem = contagem;
    assign db_tem_jogada = tem_jogada;

    // Registrdor no nível
    registrador_n #(.SIZE(1)) reg_nivel (
        .D     ( nivel     ),
        .Q     ( nivel_reg ),
        .clear ( zeraR     ),
        .clock ( clock     ),
        .enable( registraN )
    );

    //Edge Detector
    edge_detector edge_detector (
        .clock( clock        ),
        .reset( 1'b0         ), 
        .sinal( tem_jogada   ), 
        .pulso( jogada_feita )
    );

    //Contador com meio de módulo 15 e 4 bits
    contador_m #(.M(16), .N(4)) contador_m (
        .clock  ( clock    ), 
        .zera_as( zeraC    ), 
        .zera_s ( 1'b0     ), 
        .conta  ( contaC   ), 
        .Q      ( contagem ),
        .fim    ( fimC     ),
        .meio   ( meioC    )
    );
        
    //Memoria ROM sincrona 16 palavras de 4 bits
    sync_rom_16x4 sync_rom_16x4 (
        .clock   ( clock         ), 
        .address ( contagem      ), 
        .data_out( valor_memoria )
    );

    //Comparador 7485
    comparador_85 comparador_85 (
        .AEBi( 1'b1          ), 
        .AGBi( 1'b0          ), 
        .ALBi( 1'b0          ), 
        .A   ( valor_memoria ), 
        .B   ( jogada ), 
        .AEBo( igual  ),
        .AGBo(        ),
        .ALBo(        )
    );

    //Registrador 4 bits
    registrador_n #(.SIZE(4)) registrador_4 (
        .D     ( chaves    ),
        .clear ( zeraR     ),
        .clock ( clock     ),
        .enable( registraR ),
        .Q     ( jogada    )
    );

    /*  DESAFIO: Timer até 5000 ciclos de clock (aparentemente 0.0001 s)
   *
   *  Sinal clock                       = clock universal
   *  Sinal zera_as (zera assíncrono)   = jogada_feita, pois é a condição para que o contador reinicie
   *  Sinal zera_s  (zera síncrono)     = para começar o valor do contador de timeout
   *  Sinal conta                       = sinal de controle indica pela UC que vale 1 se o estado é o de espera_jogada
   *  Sinal Q                           = irrelevante para o circuito
   *  Sinal fim                         = fimTempo, output para a UC indicando que o contador chegou ao fim
   *  Sinal meio                        = meioTempo, idem ao fimTempo, mas para metade da contagem
   *  
   */

    //Contador (timer) de módulo 5000
    contador_m  # ( .M(3000), .N(12) ) contador_timer (
        .clock  ( clock ),
        .zera_as( jogada_feita ),
        .zera_s ( zeraC ),
        .conta  ( contaTempo ),
        .Q      (  ),
        .fim    ( fimTempo ),
        .meio   ( meioTempo )
    );


endmodule
