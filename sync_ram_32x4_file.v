// sync_ram_16x4_file.v

//------------------------------------------------------------------
// Arquivo   : sync_ram_32x4_file.v
// Projeto   : Experiencia 7 - Projeto do Jogo do Desafio da Memória
 
//------------------------------------------------------------------
// Descricao : RAM sincrona 32x4
//
//   - conteudo inicial armazenado em arquivo .txt
//   - descricao baseada em template 'single_port_ram_with_init.v' 
//     do Intel Quartus Prime
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     02/02/2024  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//

module sync_ram_32x4_file #(
    parameter HEXFILE = "ram_init.txt"
)
(
    input        clk,
    input        we,
    input  [3:0] data,
    input  [4:0] addr,
    output [3:0] q
);

    // Variavel RAM (armazena dados)
    reg [3:0] ram[32:0];

    // Registra endereco de acesso
    reg [4:0] addr_reg;

    // Especifica conteudo inicial da RAM
    // a partir da leitura de arquivo usando $readmemb
    initial 
    begin : INICIA_RAM
        // leitura do conteudo a partir de um arquivo
        $readmemh(HEXFILE, ram);
    end 

    always @ (posedge clk)
    begin
        // Escrita da memoria
        if (we)
            ram[addr] <= data;

        addr_reg <= addr;
    end

    // Atribuicao continua retorna dado
    assign q = ram[addr_reg];

endmodule
