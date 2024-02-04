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
    input clock,
    input [3:0] chaves,
    input zeraR,
    input registraR,
    input zeraC,
    input contaC,

    output [3:0] db_contagem,
    output [3:0] db_memoria,
    output [3:0] db_jogada,
    output igual,
    output jogada_feita,
    output db_tem_jogada,
    output fimC
    );

    wire or_chaves;
    wire [3:0] out_Q, out_memory, out_reg;

    assign or_chaves = |chaves;
    assign db_tem_jogada = or_chaves;
    assign db_memoria = out_memory;
    assign db_jogada = out_reg;
	assign db_contagem = out_Q;

//Edge Detector
    edge_detector edge_detector (
        .clock(clock),
        .reset(1'b0), 
        .sinal(or_chaves), 
        .pulso(jogada_feita)
        );

//Contador 74163
    contador_163 contador_163 (
        .clock(clock), 
        .clr(~zeraC), 
        .enp(contaC), 
        .ent(1'b1), 
        .ld(1'b1), 
        .D(4'b0000), 
        .Q(out_Q),
        .rco(fimC)
        );
        
//Memoria ROM sincrona 16 palavras de 4 bits
    sync_rom_16x4 sync_rom_16x4 (
        .clock(clock), 
        .address(out_Q), 
        .data_out(out_memory)
        );

//Comparador 7485
    comparador_85 comparador_85 (
        .AEBi(1'b1), 
        .AGBi(1'b0), 
        .ALBi(1'b0), 
        .A(out_memory), 
        .B(out_reg), 
        .AEBo(igual),
        .AGBo(),
        .ALBo()
        );

//Registrador 4 bits
    registrador_4 registrador_4 (
        .D(chaves),
        .clear(zeraR),
        .clock(clock),
        .enable(registraR),
        .Q(out_reg)
        );


endmodule