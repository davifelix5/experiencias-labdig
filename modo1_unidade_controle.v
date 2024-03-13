/* --------------------------------------------------------------------
 * Arquivo   : fluxo_dados.v
 * Projeto   : FPGAudio - Piano didático com FPGA
//------------------------------------------------------------------
// Descricao : Unidade de controle          
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor                                        Descricao
//     11/03/2024  1.0     Caio Dourado, Davi Félix, Vinicius Batista   versao inicial
//------------------------------------------------------------------
*/

module modo1_unidade_controle (
    input     clock,
    input     reset,
    input     iniciar,
    
    /* Sinais de condição */
    input     fimTF,
    input     fimCR,
    input     meioCR,

    input     nota_feita,
    input     nota_correta,
    input     tempo_correto,
    input     tempo_correto_baixo,
    input     tentar_dnv_rep,
    input     tentar_dnv,
    input     apresenta_ultima,
    
    input     enderecoIgualRodada,
    
    input     fimTempo,
    input     meioTempo,

    /* Sinais de controle */
    output    zeraC,
    output    contaC,

    output    zeraTF,
    output    contaTF,
    
    output    contaCR,
    output    zeraCR,

    output    contaMetro,
    output    zeraMetro,

    output    contaTempo,
    output    zeraTempo,

    output    registraR,
    output    zeraR,

    output    leds_mem,
    output    ativa_leds,
    output    toca,
    output    metro_120BPM,
    output    gravaM,

    /* Saídas */
    output    ganhou,
    output    perdeu,
    output    vez_jogador,

    output [4:0] db_estado
);

    // Define estados
    parameter   inicial                 = 5'h00,
                inicializa_elementos    = 5'h01,
                inicio_rodada           = 5'h02,
                mostra                  = 5'h03,
                espera_mostra           = 5'h04,
                apaga_mostra            = 5'h0D,
                mostra_proximo          = 5'h05,
                inicio_nota             = 5'h06,
                espera_nota             = 5'h07,
                compara                 = 5'h09,
                acertou                 = 5'h0A,
                proxima_nota            = 5'h0B,
                proxima_rodada          = 5'h13,
                errou_nota              = 5'h14,
                errou_tempo             = 5'h15,
                toca_nota               = 5'h17,
                espera_mostra2          = 5'h18;

    

    // Variaveis de estado
    reg [4:0] Eatual, Eprox;

    // Depuração do estado
    assign db_estado  = Eatual;

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
            inicio_rodada:            Eprox = fimTF ? mostra : inicio_rodada;
            mostra:                   Eprox = espera_mostra;
            espera_mostra:            Eprox = tempo_correto_baixo ? (enderecoIgualRodada ? inicio_nota : apaga_mostra) : espera_mostra;
            apaga_mostra:             Eprox = fimTF ? mostra_proximo : apaga_mostra;
            mostra_proximo:           Eprox = mostra;
            inicio_nota:              Eprox = espera_nota;
            espera_nota:              Eprox = fimTempo ? errou_tempo : (nota_feita ? toca_nota : espera_nota);
            toca_nota:                Eprox = nota_feita ? toca_nota : compara; 
            compara: begin
                if (!nota_correta) begin
                    Eprox = errou_nota;
                end
                else begin // Nota está correta
                    if (!tempo_correto) begin // Nota está correta e tempo não
                        Eprox = errou_tempo;
                    end // Nota e tempo estão corretos
                    else begin
                        if (enderecoIgualRodada) begin
                            Eprox = fimCR ? acertou : proxima_rodada;
                        end
                        else begin
                            Eprox = proxima_nota;
                        end
                    end
                end
            end
            errou_tempo, errou_nota:  Eprox = tentar_dnv_rep ? inicio_rodada : (tentar_dnv ? inicio_nota : (apresenta_ultima ? espera_mostra2 : Eatual));
            proxima_nota:             Eprox = espera_nota;
            acertou:                  Eprox = iniciar ? inicializa_elementos : acertou;
            proxima_rodada:           Eprox = inicio_rodada;
            espera_mostra2:           Eprox = tempo_correto_baixo ? espera_nota : espera_mostra2;
            default:                  Eprox = inicial; 
        endcase
    end

    // Logica de saida (maquina Moore)
    assign zeraR          = (Eatual == inicial);
    assign zeraCR         = (Eatual == inicializa_elementos);
    assign zeraC          = (Eatual == inicio_nota || Eatual == inicio_rodada);
    assign zeraTempo      = (Eatual == proxima_nota || Eatual == inicio_nota || Eatual == inicializa_elementos || Eatual == errou_tempo || Eatual == errou_nota);
    assign zeraTF         = (Eatual == mostra || Eatual == inicializa_elementos || Eatual == inicio_nota);
    assign contaTF        = (Eatual == apaga_mostra || Eatual == inicio_rodada);
    assign contaC         = (Eatual == mostra_proximo || Eatual == proxima_nota);
    assign contaTempo     = (Eatual == espera_nota);
    assign vez_jogador    = (Eatual == espera_nota);
    assign registraR      = (Eatual == toca_nota);
    assign contaCR        = (Eatual == proxima_rodada);
    assign ganhou         = (Eatual == acertou);
    assign perdeu         = (Eatual == errou_tempo || Eatual == errou_nota);
    assign leds_mem       = (Eatual == espera_mostra || Eatual == espera_mostra2);
    assign ativa_leds     = (Eatual == toca_nota || Eatual == espera_mostra || Eatual == espera_mostra2);
    assign toca           = (Eatual == espera_mostra || Eatual == espera_mostra2 || Eatual == toca_nota);
    assign contaMetro     = (Eatual == espera_mostra2 || Eatual == espera_mostra || Eatual == toca_nota);
    assign zeraMetro      = (Eatual == proxima_nota || Eatual == mostra || Eatual == errou_tempo || Eatual == inicio_nota || Eatual == errou_nota || Eatual == inicializa_elementos);
    assign metro_120BPM   = 1'b0;
    assign gravaM         = 1'b0;


endmodule