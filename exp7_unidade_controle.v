//------------------------------------------------------------------
// Arquivo   : exp7_unidade_controle.v
// Projeto   : Experiencia 7 - Projeto de uma Unidade de Controle
//------------------------------------------------------------------
// Descricao : Unidade de controle          
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor                                        Descricao
//     14/02/2024  1.0     Caio Dourado, Davi Félix, Vinicius Batista   versao inicial
//------------------------------------------------------------------
//
module exp7_unidade_controle (
    input     clock,
    input     reset,
    input     iniciar,
    
    /* Sinais de condição */
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

    input     modo2,
    
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

    output    ativa_leds_mem,
    output    ativa_leds_jog,
    output    toca,
    output    gravaM,

    /* Saídas */
    output    ganhou,
    output    perdeu,
    output    pronto,
    output    vez_jogador,
    output    nova_jogada,
    
    output       db_timeout,
    output [4:0] db_estado
);

    // Define estados
    parameter   inicial              = 5'h00,
                inicializa_elementos = 5'h01,
                inicio_rodada        = 5'h02,
                mostra               = 5'h03,
                espera_mostra        = 5'h04,
                apaga_mostra         = 5'h0D,
                mostra_proximo       = 5'h05,
                inicio_jogada        = 5'h06,
                espera_jogada        = 5'h07,
                registra             = 5'h08,
                compara              = 5'h09,
                acertou              = 5'h0A,
                proxima_jogada       = 5'h0B,
                grava_rodada         = 5'h0C,
                errou                = 5'h0E,
                estado_timeout       = 5'h0F,
                espera_gravacao      = 5'h10,
                incrementa_memoria   = 5'h11,
                mostra_gravacao      = 5'h12,
                proxima_rodada       = 5'h13;
            
	 
    // Variaveis de estado
    reg [4:0] Eatual, Eprox;

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
            inicio_rodada:            Eprox = meioTM ? mostra : inicio_rodada;
            mostra:                   Eprox = espera_mostra;
            espera_mostra:            Eprox = fimTM ? (enderecoIgualRodada ? inicio_jogada : apaga_mostra) : espera_mostra;
            apaga_mostra:             Eprox = meioTM ? mostra_proximo : apaga_mostra;
            mostra_proximo:           Eprox = mostra;
            inicio_jogada:            Eprox = espera_jogada;
            espera_jogada:            Eprox = ((!nivel_tempo & fimTempo) || (nivel_tempo & meioTempo)) ? estado_timeout : (jogada_feita ? registra : espera_jogada);
            registra:                 Eprox = compara;
            compara: begin
                if (meioTM) begin
                    if (jogada_correta) begin
                        if (enderecoIgualRodada) begin
                            if ((!nivel_jogadas & meioCR) | (nivel_jogadas & fimCR))
                                Eprox = acertou;
                            else
                                Eprox = modo2 ? incrementa_memoria : proxima_rodada;                
                        end 
                        else
                            Eprox = proxima_jogada;
                    end
                    else begin
                        Eprox = errou;
                    end
                end
                else begin
                    Eprox = compara;
                end
            end
            grava_rodada:           Eprox = mostra_gravacao;
            proxima_jogada:           Eprox = espera_jogada;
            espera_gravacao:          Eprox = ((nivel_tempo && meioTempo) || (!nivel_tempo && fimTempo)) ? estado_timeout : (jogada_feita ? grava_rodada : espera_gravacao);
            incrementa_memoria:       Eprox = espera_gravacao;
            mostra_gravacao:          Eprox = meioTM ? inicio_jogada : mostra_gravacao;
            acertou:                  Eprox = iniciar ? inicializa_elementos : acertou;
            errou:                    Eprox = iniciar ? inicializa_elementos : errou;
            estado_timeout:           Eprox = iniciar ? inicializa_elementos : estado_timeout; 
            proxima_rodada:           Eprox = inicio_rodada;
            default:                  Eprox = inicial; 
        endcase
    end

    // Logica de saida (maquina Moore)
    assign zeraR          = (Eatual == inicial);
    assign zeraCR         = (Eatual == inicializa_elementos);
    assign zeraC          = (Eatual == inicio_jogada || Eatual == inicio_rodada);
    assign zeraTempo      = (Eatual == inicializa_elementos || Eatual == proxima_jogada || Eatual == incrementa_memoria);
    assign zeraTM         = (Eatual == mostra || Eatual == proxima_jogada || Eatual == grava_rodada || Eatual == inicializa_elementos || Eatual == inicio_jogada || Eatual == proxima_rodada);
    assign contaTM        = (Eatual == espera_mostra || Eatual == apaga_mostra || Eatual == compara || Eatual == inicio_rodada || Eatual == mostra_gravacao);
    assign contaC         = (Eatual == mostra_proximo || Eatual == proxima_jogada || Eatual == incrementa_memoria);
    assign contaTempo     = (Eatual == espera_jogada || Eatual == espera_gravacao);
    assign vez_jogador    = (Eatual == espera_jogada);
    assign registraR      = (Eatual == registra);
    assign contaCR        = (Eatual == grava_rodada || Eatual == proxima_rodada);
    assign ganhou         = (Eatual == acertou);
    assign perdeu         = (Eatual == errou || Eatual == estado_timeout);
    assign pronto         = ((Eatual == errou) || (Eatual == acertou) || (Eatual == estado_timeout)); 
    assign registraN      = (Eatual == inicializa_elementos);
    assign ativa_leds_mem = (Eatual == espera_mostra || Eatual == mostra_gravacao);
    assign ativa_leds_jog = (Eatual == compara);
    assign toca           = (Eatual == espera_mostra || Eatual == compara || Eatual == mostra_gravacao);
    assign nova_jogada    = (Eatual == espera_gravacao);
    assign gravaM         = (Eatual == grava_rodada);


endmodule