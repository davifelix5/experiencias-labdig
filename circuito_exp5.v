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
    input clock,
    input reset,
    input iniciar,
    input [3:0] chaves,

    output acertou,
    output errou,
    output pronto,
    output [3:0] leds,
    output db_igual,
    output [6:0] db_contagem,
    output [6:0] db_memoria,
    output [6:0] db_estado,
    output db_clock,
    output db_iniciar,
    output db_tem_jogada
);

//Fios que saem da UC
wire contaC, registraR, zeraC, zeraR;
wire [3:0] db_estado_wire;
//Fios que saem do FD
wire fimC, igual_wire, jogada_feita;
wire [3:0] db_contagem_wire, db_memoria_wire, db_jogada_wire;

//Fluxo de Dados
    exp5_fluxo_dados exp5_fluxo_dados (
        .clock(clock),
        .chaves(chaves),
        .zeraR(zeraR),
        .registraR(registraR),
        .zeraC(zeraC),
        .contaC(contaC),
        .db_contagem(db_contagem_wire),
        .db_memoria(db_memoria_wire),
        .db_jogada(db_jogada_wire),
        .igual(igual_wire),
        .jogada_feita(jogada_feita),
        .db_tem_jogada(db_tem_jogada),
        .fimC(fimC)
    );

//Unidade de controle
    exp5_unidade_controle exp5_unidade_controle(
        .clock(clock),
        .reset(reset),
        .iniciar(iniciar),
        .fim(fimC),
        .jogada(jogada_feita),
        .igual(igual_wire),
        .zeraC(zeraC),
        .contaC(contaC),
        .zeraR(zeraR),
        .registraR(registraR),
        .acertou(acertou),
        .errou(errou),
        .pronto(pronto),
        .db_estado(db_estado_wire)
    );

//Displays
    //Contagem
        hexa7seg HEX0 (
            .hexa(db_contagem_wire),
            .display(db_contagem)
        );

    //Memoria
        hexa7seg HEX1 (
            .hexa(db_memoria_wire),
            .display(db_memoria)
        );
		
	 //Estado
        hexa7seg HEX3 (
            .hexa(db_estado_wire),
            .display(db_estado)
        );

    assign db_iniciar = iniciar;
    assign db_clock = clock;
	assign db_igual = igual_wire;
	assign leds = db_jogada_wire;
	 
	 
endmodule