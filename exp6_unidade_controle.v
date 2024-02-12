//------------------------------------------------------------------
// Arquivo   : exp5_unidade_controle.v
// Projeto   : Experiencia 5 - Projeto de uma Unidade de Controle
//------------------------------------------------------------------
// Descricao : Unidade de controle          
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor                                        Descricao
//     02/01/2024  1.0     Caio Dourado, Davi Félix, Vinicius Batista   versao inicial
//------------------------------------------------------------------
//
module exp6_unidade_controle (
    input        clock,
    input        reset,
    input        iniciar,
    
    /* Sinais de condição */
    input        fimC,
    input        fimTM,
    input        fimCR,
    input        meio,

    input        jogada_feita,
    input        jogada_correta,
    
    input        enderecoIgualRodada,
    
    input        nivel_tempo,
    input        nivel_jogadas,
    
    input        fimTempo,
    input        meioTempo,

    /* Sinais de controle */
    output reg   zeraC,
    output reg   contaC,

    output reg   zeraTM,
    output reg   contaTM,
    
    output reg   contaCR,
    output reg   zeraCR,

    output reg   contaTempo,
    output reg   zeraTempo,

    output reg   registraR,
    output reg   zeraR,

    output reg   registraN,

    /* Saídas */
    output       acertou,
    output       errou,
    output       pronto,
    output       timeout,
    output       vez_jogador,

    output [3:0] db_estado
);

    // Define estados
    localparam  inicial  = 4'h0,
                inicializa_elementos = 4'h1,
                inicio_rodada = 4'h2,
                mostra = 4'h3,
                espera_mostra = 4'h4,
                mostra_proximo = 4'h5,
                inicio_jogada = 4'h6,
                espera_jogada = 4'h7,
                registra = 4'h8,
                compara = 4'h9,
                ganhou = 4'hA,
                proxima_jogada = 4'hB,
                proxima_rodada = 4'hC,
                perdeu = 4'hE,
                estado_timeout = 4'hF;
	 
    // Variaveis de estado
    reg [3:0] Eatual, Eprox;

    // Depuração do estado
    assign db_estado = Eatual;

    // Memoria de estado
    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    // Logica de proximo estado
    always @* begin
        case (Eatual)
            inicial:                  Eprox = iniciar ? inicializa_elementos : inicial;
            inicializa_elementos:     Eprox = inicio_rodada;
            inicio_rodada:            Eprox = mostra;
            mostra:                   Eprox = enderecoIgualRodada ? inicio_jogada : espera_mostra;
            espera_mostra:            Eprox = fimTM ? mostra_proximo : espera_mostra;
            mostra_proximo:           Eprox = mostra;
            inicio_jogada:            Eprox = espera_jogada;
            espera_jogada:            Eprox = fimTempo ? estado_timeout : (jogada_feita ? registra : espera_jogada);
            registra:                 Eprox = compara;
            compara:                  Eprox = jogada_correta ? 
                                        (
                                            enderecoIgualRodada ? 
                                                (fimCR  ? ganhou  : proxima_rodada) 
                                                : 
                                                proxima_jogada
                                        ) 
                                        : perdeu;
            proxima_rodada:           Eprox = inicio_rodada;
            ganhou:                   Eprox = iniciar ? inicializa_elementos : ganhou;
            perdeu:                   Eprox = iniciar ? inicializa_elementos : perdeu;
            estado_timeout:           Eprox = iniciar ? inicializa_elementos : estado_timeout; 
            default:                  Eprox = inicial; 
        endcase
    end

    // Logica de saida (maquina Moore)
    assign zeraR        = Eatual == inicial;
    assign zeraCR       = Eatual == inicializa_elementos;
    assign zeraC        = Eatual == inicio_jogada || Eatual == inicio_rodada;
    assign zeraTempo    = Eatual == inicializa_elementos || Eatual == proxima_jogada;
    assign zeraTM       = Eatual == mostra;
    assign contaTM      = Eatual == espera_mostra;
    assign contaC       = Eatual == mostra_proximo || Eatual == proxima_jogada;
    assign contaTempo   = Eatual == espera_jogada;
    assign vezJogadador = Eatual == espera_jogada;
    assign registraR    = Eatual == registra;
    assign contaCR      = Eatual == proxima_jogada;
    assign timeout      = Eatual == estado_timeout;
    assign errou        = Eatual == perdeu;
    assign acertou      = Eatual == ganhou;
    assign pronto       = (Eatual == perdeu) || (Eatual == ganhou) || (Eatual == timeout); 


endmodule