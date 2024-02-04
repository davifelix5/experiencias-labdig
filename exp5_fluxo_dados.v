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
    
    // Sinais de codição
    output igual,
    output jogada_feita,
    output nivel_reg,
    output fimC,
    output meioC,

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


endmodule
