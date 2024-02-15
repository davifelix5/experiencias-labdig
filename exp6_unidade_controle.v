//------------------------------------------------------------------
// Arquivo   : exp6_unidade_controle.v
// Projeto   : Experiencia 6 - Projeto de uma Unidade de Controle
//------------------------------------------------------------------
// Descricao : Unidade de controle          
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor                                        Descricao
//     14/02/2024  1.0     Caio Dourado, Davi Félix, Vinicius Batista   versao inicial
//------------------------------------------------------------------
//
module exp6_unidade_controle (
    input     clock,
    input     reset,
    input     iniciar,
    
    /* Sinais de condição */
    input     fimC,
    input     fimTM,
    input     meioTM,
    input     fimCR,
    input     meioCR,

    input     jogada_feita,
    input     jogada_correta,
    
    input     enderecoIgualRodada,
    
    input     nivel_tempo,
    input     nivel_jogadas,
    
    input     fimTempo,
    input     meioTempo,

    /* Sinais de controle */
    output    zeraC,
    output    contaC,

    output    zeraTM,
    output    contaTM,
    
    output    contaCR,
    output    zeraCR,

    output    contaTempo,
    output    zeraTempo,

    output    registraR,
    output    zeraR,

    output    registraN,

    output    ativa_leds,

    /* Saídas */
    output    ganhou,
    output    perdeu,
    output    pronto,
    output    vez_jogador,

    output       db_timeout,
    output [3:0] db_estado
);

    // Define estados
    parameter   inicial              = 4'h0,
                inicializa_elementos = 4'h1,
                inicio_rodada        = 4'h2,
                mostra               = 4'h3,
                espera_mostra        = 4'h4,
                apaga_mostra         = 4'hD,
                mostra_proximo       = 4'h5,
                inicio_jogada        = 4'h6,
                espera_jogada        = 4'h7,
                registra             = 4'h8,
                compara              = 4'h9,
                acertou               = 4'hA,
                proxima_jogada       = 4'hB,
                proxima_rodada       = 4'hC,
                errou               = 4'hE,
                estado_timeout       = 4'hF;
	 
    // Variaveis de estado
    reg [3:0] Eatual, Eprox;

    // Depuração do estado
    assign db_estado  = Eatual;
    assign db_timeout = (Eatual == estado_timeout);

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
            mostra:                   Eprox = espera_mostra;
            espera_mostra:            Eprox = fimTM ? (enderecoIgualRodada ? inicio_jogada : apaga_mostra) : espera_mostra;
            apaga_mostra:             Eprox = meioTM ? mostra_proximo : apaga_mostra;
            mostra_proximo:           Eprox = mostra;
            inicio_jogada:            Eprox = espera_jogada;
            espera_jogada:            Eprox = ((!nivel_tempo & fimTempo) || (nivel_tempo & meioTempo)) ? estado_timeout : (jogada_feita ? registra : espera_jogada);
            registra:                 Eprox = compara;
            compara: begin
                if (jogada_correta) begin
                    if (enderecoIgualRodada) begin
                        if ((!nivel_jogadas & meioCR) | (nivel_jogadas & fimCR))
                            Eprox = acertou;
                        else
                            Eprox = proxima_rodada;                
                    end 
                    else
                        Eprox = proxima_jogada;
                end
                else begin
                    Eprox = errou;
                end
            end
            proxima_rodada:           Eprox = inicio_rodada;
            proxima_jogada:           Eprox = espera_jogada;
            acertou:                   Eprox = iniciar ? inicializa_elementos : acertou;
            errou:                   Eprox = iniciar ? inicializa_elementos : errou;
            estado_timeout:           Eprox = iniciar ? inicializa_elementos : estado_timeout; 
            default:                  Eprox = inicial; 
        endcase
    end

    // Logica de saida (maquina Moore)
    assign zeraR         = (Eatual == inicial);
    assign zeraCR        = (Eatual == inicializa_elementos);
    assign zeraC         = (Eatual == inicio_jogada || Eatual == inicio_rodada);
    assign zeraTempo     = (Eatual == inicializa_elementos || Eatual == proxima_jogada);
    assign zeraTM        = (Eatual == mostra);
    assign contaTM       = (Eatual == espera_mostra || Eatual == apaga_mostra);
    assign contaC        = (Eatual == mostra_proximo || Eatual == proxima_jogada);
    assign contaTempo    = (Eatual == espera_jogada);
    assign vez_jogador   = (Eatual == espera_jogada);
    assign registraR     = (Eatual == registra);
    assign contaCR       = (Eatual == proxima_rodada);
    assign ganhou        = (Eatual == acertou);
    assign perdeu        = (Eatual == errou || Eatual == estado_timeout);
    assign pronto        = ((Eatual == errou) || (Eatual == acertou) || (Eatual == estado_timeout)); 
    assign registraN     = (Eatual == inicializa_elementos);
    assign ativa_leds    = (Eatual == espera_mostra);


endmodule