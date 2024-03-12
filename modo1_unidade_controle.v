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
    
    input     enderecoIgualRodada,
    
    input     fimTempo,
    input     meioTempo,

    /* Sinais de controle */
    output    zeraC,
    output    contaC,

    output    zeraTM,
    output    contaTM,
    
    output    contaCR,
    output    zeraCR,

    output    contaMetro,
    output    zeraMetro,

    output    contaTempo,
    output    zeraTempo,

    output    registraR,
    output    zeraR,

    output    registraN,

    output    leds_mem,
    output    ativa_leds,
    output    toca,
    output    metro_120BPM,
    output    gravaM,

    /* Saídas */
    output    ganhou,
    output    perdeu,
    output    pronto,
    output    vez_jogador,

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
                inicio_nota          = 5'h06,
                espera_nota          = 5'h07,
                registra             = 5'h08,
                compara              = 5'h09,
                acertou              = 5'h0A,
                proxima_nota         = 5'h0B,
                errou                = 5'h0E,
                estado_timeout       = 5'h0F,
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
            inicio_rodada:            Eprox = fimTF ? mostra : inicio_rodada;
            mostra:                   Eprox = espera_mostra;
            espera_mostra:            Eprox = fimTF ? (enderecoIgualRodada ? inicio_nota : apaga_mostra) : espera_mostra;
            apaga_mostra:             Eprox = fimTF ? mostra_proximo : apaga_mostra;
            mostra_proximo:           Eprox = mostra;
            inicio_nota:            Eprox = espera_nota;
            espera_nota:            Eprox = fimTempo ? estado_timeout : (nota_feita ? registra : espera_nota);
            registra:                 Eprox = compara;
            compara: begin
                if (fimTF) begin
                    if (nota_correta) begin
                        if (enderecoIgualRodada) begin
                            if (fimCR)
                                Eprox = acertou;
                            else
                                Eprox = proxima_rodada;                
                        end 
                        else
                            Eprox = proxima_nota;
                    end
                    else begin
                        Eprox = errou;
                    end
                end
                else begin
                    Eprox = compara;
                end
            end
            proxima_nota:           Eprox = espera_nota;
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
    assign zeraC          = (Eatual == inicio_nota || Eatual == inicio_rodada);
    assign zeraTempo      = (Eatual == proxima_nota || Eatual == inicio_nota || Eatual == inicializa_elementos);
    assign zeraTM         = (Eatual == mostra || Eatual == proxima_nota || Eatual == inicializa_elementos || Eatual == inicio_nota || Eatual == proxima_rodada);
    assign contaTM        = (Eatual == espera_mostra || Eatual == apaga_mostra || Eatual == compara || Eatual == inicio_rodada);
    assign contaC         = (Eatual == mostra_proximo || Eatual == proxima_nota);
    assign contaTempo     = (Eatual == espera_nota);
    assign vez_jogador    = (Eatual == espera_nota);
    assign registraR      = (Eatual == registra);
    assign contaCR        = (Eatual == proxima_rodada);
    assign ganhou         = (Eatual == acertou);
    assign perdeu         = (Eatual == errou || Eatual == estado_timeout);
    assign pronto         = ((Eatual == errou) || (Eatual == acertou) || (Eatual == estado_timeout)); 
    assign registraN      = (Eatual == inicializa_elementos);
    assign leds_mem       = (Eatual == espera_mostra);
    assign ativa_leds     = (Eatual == compara || Eatual == espera_mostra);
    assign toca           = (Eatual == espera_mostra || Eatual == compara);


endmodule