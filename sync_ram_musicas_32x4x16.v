// sync_rom_32x4x16.v


/* --------------------------------------------------------------------
 * Arquivo   : sync_rom_16x32x16_file.v
 * Projeto   : FPGAudio - Piano didático com FPGA
 * --------------------------------------------------------------------
 * Descricao : Módulo com a memória que armazenará todas as músicas,
 sendo elas 16 no notal com 256 palavras de 4 bits 
 * --------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                            Descricao
 *     11/03/2024  1.0     Caio Dourado, Davi Félix e Vinicius Batista      versao inicial
 * --------------------------------------------------------------------
*/

module sync_ram_musicas_32x4x16_file #(
    parameter HEXFILE = "ram_init.txt"
)
(
    input        clk,
    input        we, // Habilitação geral de escrita
    input  [3:0] data_nota, // valor a ser salvo de nota
    input  [3:0] data_tempo, // valor a ser salvo de tempo
    input  [4:0] addr,  // Endereço do qual recuperar ou salvar o dado
    input  [3:0] musica, // Seletor que indica qual música a memória deve informar
    output       fim_musica, // Sinal que improta se uma música já acabou
    output [3:0] nota, // valor da nota
    output [3:0] tempo // valor do tempo
);

    genvar i;

    wire[3:0] notas[0:15], tempos[0:15];
    wire[15:0] we_array;

    // Função para converter o valor da genvar para ascii
    function integer convert_ascii;
    input integer i;
    begin
        convert_ascii = {48 + i/10, 48 + (i %10)};
    end
    endfunction

    decoder_4x16 decoder_we (
        .in(musica),
        .enable(we),
        .out(we_array)
    );

    generate 
        for (i=0; i<16; i = i + 1) begin: NOTAS_E_TEMPOS

            sync_ram_32x4_file #(.HEXFILE({"ram_init/ram_init_notas_", convert_ascii(i), ".txt"}))
            mem_notas 
            (
                .clk(clk),
                .we(we_array[i]),
                .data(data_nota),
                .addr(addr),
                .q(notas[i])
            );

            sync_ram_32x4_file #(.HEXFILE({"ram_init/ram_init_tempos_", convert_ascii(i), ".txt"})) 
            mem_tempos 
            (
                .clk(clk),
                .we(we_array[i]),
                .data(data_tempo),
                .addr(addr),
                .q(tempos[i])
            );
        end
    endgenerate

    assign nota       = notas[musica];
    assign tempo      = tempos[musica];
    assign fim_musica = ~|nota & ~|tempo;

endmodule
