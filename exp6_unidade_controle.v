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
    input        meioCR,

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
    output reg   acertou,
    output reg   errou,
    output reg   pronto,
    output reg   timeout,
    output reg   vez_jogador,

    output [3:0] db_estado
);

    // Define estados
    parameter   inicial  = 4'h0,
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
            espera_jogada:            Eprox = ((nivel_tempo & fimTempo) || (!nivel_tempo & meioTempo)) ? estado_timeout : (jogada_feita ? registra : espera_jogada);
            registra:                 Eprox = compara;
            compara: begin
                if (jogada_correta) begin
                    if (enderecoIgualRodada) begin
                        if ((!nivel_jogadas & meioCR) || (nivel_jogadas && fimCR))
                            Eprox = ganhou;
                        else
                            Eprox = proxima_rodada;                
                    end 
                    else
                        Eprox = proxima_jogada;
                end
                else begin
                    Eprox = perdeu;
                end
            end
            proxima_rodada:           Eprox = inicio_rodada;
            ganhou:                   Eprox = iniciar ? inicializa_elementos : ganhou;
            perdeu:                   Eprox = iniciar ? inicializa_elementos : perdeu;
            estado_timeout:           Eprox = iniciar ? inicializa_elementos : estado_timeout; 
            default:                  Eprox = inicial; 
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        zeraR         = (Eatual == inicial) ? 1'b1 : 1'b0;
        zeraCR        = (Eatual == inicializa_elementos) ? 1'b1 : 1'b0;
        zeraC         = (Eatual == inicio_jogada || Eatual == inicio_rodada) ? 1'b1 : 1'b0;
        zeraTempo     = (Eatual == inicializa_elementos || Eatual == proxima_jogada) ? 1'b1 : 1'b0;
        zeraTM        = (Eatual == mostra) ? 1'b1 : 1'b0;
        contaTM       = (Eatual == espera_mostra) ? 1'b1 : 1'b0;
        contaC        = (Eatual == mostra_proximo || Eatual == proxima_jogada) ? 1'b1 : 1'b0;
        contaTempo    = (Eatual == espera_jogada) ? 1'b1 : 1'b0;
        vez_jogador   = (Eatual == espera_jogada) ? 1'b1 : 1'b0;
        registraR     = (Eatual == registra) ? 1'b1 : 1'b0;
        contaCR       = (Eatual == proxima_jogada) ? 1'b1 : 1'b0;
        timeout       = (Eatual == estado_timeout) ? 1'b1 : 1'b0;
        errou         = (Eatual == perdeu) ? 1'b1 : 1'b0;
        acertou       = (Eatual == ganhou) ? 1'b1 : 1'b0;
        pronto        = ((Eatual == perdeu) || (Eatual == ganhou) || (Eatual == timeout)) ? 1'b1 : 1'b0; 
        registraN     = (Eatual == inicializa_elementos) ? 1'b1 : 1'b0;
    end


endmodule