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

module unidade_controle #(
    parameter MODO       = 4,
              ERRO       = 3,
              GRAVA_OPS  = 3
) (
    input     clock,
    input     reset,
    input     iniciar,
    
    /* Sinais de condição */
    input                fimTF,
    input                fimCR,
    input                meioCR,

    input                nota_feita,
    input                nota_correta,
    input                tempo_correto,
    input                tempo_correto_baixo,
    
    input                enderecoIgualRodada,
    
    input                fimTempo,
    input                meioTempo,

    input [MODO - 1:0]   modos,
    input [ERRO - 1:0]   erros,
    input [GRAVA_OPS-1:0] grava_ops,

    input fim_musica,

    input press_enter,

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
    output    zeraOP,

    output    leds_mem,
    output    ativa_leds,
    output    toca,
    output    gravaM,

    output    registra_modo,
    output    registra_bpm,
    output    registra_tom,
    output    registra_musicas,
    output    [2:0] menu_sel,
    output    inicia_menu,
    output    registra_erro,
    output    volta_contador,

    /* Saídas */
    output    mostra_menu,
    output    ganhou,
    output    perdeu,
    output    vez_jogador,

    output [5:0] db_estado
);

    // Define estados
    localparam   inicial                 = 6'h00,
                inicializa_elementos    = 6'h01,
                inicio_rodada           = 6'h02,
                mostra                  = 6'h03,
                espera_mostra           = 6'h04,
                mostra_proximo          = 6'h05,
                inicio_nota             = 6'h06,
                espera_nota             = 6'h07,
                compara                 = 6'h09,
                acertou                 = 6'h0A,
                proxima_nota            = 6'h0B,
                incrementa_nota         = 6'h13,
                errou_nota              = 6'h14,
                errou_tempo             = 6'h15,
                toca_nota               = 6'h17,
                mostra_ultima           = 6'h18,
                proxima_rodada          = 6'h19,
                verifica_fim            = 6'h1A,
                registra                = 6'h1B,
                iniciar_menu            = 6'h1C,
                espera_modo             = 6'h1D,
                espera_bpm              = 6'h1E,
                espera_tom              = 6'h1F,
                espera_musica           = 6'h20,
                iniciar_menu_erro       = 6'h21,
                menu_erro               = 6'h22,
                espera_livre            = 6'h23,
                prepara_nota            = 6'h24,
                espera_toca             = 6'h25,
                inicia_sem_mostra       = 6'h26,
                proxima_nota_e_roda     = 6'h27,
                prepara_finaliza        = 6'h28,
                menu_grava              = 6'h29,
                fim_grava               = 6'h2A,
                decrementa              = 6'h2B,
                grava                   = 6'h2C,
                inicio_grava            = 6'h2D;

    

    // Variaveis de estado
    reg [5:0] Eatual, Eprox;

    // Depuração do estado
    assign db_estado  = Eatual;

    wire modo_grava, modo_sem_apresenta, modo_fresstyle, modo_reprodutor, 
                modo_nota_a_nota, modo_genius, rollback, tocar_preview, finaliza;
    wire tentar_dnv_rep, tentar_dnv, apresenta_ultima;

    assign { rollback, tocar_preview, finaliza } = grava_ops;

    assign { modo_grava, modo_fresstyle, modo_reprodutor, modo_sem_apresenta, 
                modo_nota_a_nota, modo_genius } = modos;

    assign {tentar_dnv_rep, tentar_dnv, apresenta_ultima} = erros;


    // Memoria de estado
    always @(posedge clock or posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end


    // Logica de proximo estado
    always @* begin
        if (Eatual == inicial || Eatual == iniciar_menu || Eatual == espera_modo || Eatual == espera_bpm ||
                Eatual == espera_tom || Eatual == espera_musica) begin
            case (Eatual)
                inicial:                  Eprox = iniciar ? iniciar_menu : inicial;
                /* MENU */
                iniciar_menu:             Eprox = espera_modo;
                espera_modo:              Eprox = press_enter ? espera_bpm : espera_modo;
                espera_bpm:               Eprox = press_enter ? espera_tom : espera_bpm;
                espera_tom:               Eprox = press_enter ? (modo_fresstyle ? inicializa_elementos : espera_musica) : espera_tom;
                espera_musica:            Eprox = press_enter ? inicializa_elementos : espera_musica;
                default:                  Eprox = inicializa_elementos;
            endcase
        end
        else begin 
        if (modo_genius) begin
            case (Eatual)
                inicializa_elementos:     Eprox = inicio_rodada;
                inicio_rodada:            Eprox = fimTF ? mostra : inicio_rodada;
                mostra:                   Eprox = espera_mostra;
                espera_mostra:            Eprox = tempo_correto_baixo ? (enderecoIgualRodada ? inicio_nota : mostra_proximo) : espera_mostra;
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
                                Eprox = (fimCR) ? acertou : incrementa_nota;
                            end
                            else begin
                                Eprox = proxima_nota;
                            end
                        end
                    end
                end
                errou_tempo, errou_nota:  Eprox = iniciar_menu_erro;
                iniciar_menu_erro:        Eprox = menu_erro;
                menu_erro:                Eprox = !press_enter ? menu_erro : 
                                                    (tentar_dnv_rep ? inicio_rodada : (tentar_dnv ? inicio_nota : (apresenta_ultima ? mostra_ultima : menu_erro)));
                proxima_nota:             Eprox = espera_nota;
                incrementa_nota:          Eprox = registra;
                registra:                 Eprox = verifica_fim;
                verifica_fim:             Eprox = fim_musica ? acertou : proxima_rodada;
                acertou:                  Eprox = iniciar ? inicializa_elementos : acertou;
                proxima_rodada:           Eprox = inicio_rodada;
                mostra_ultima:            Eprox = tempo_correto_baixo ? espera_nota : mostra_ultima;
                default:                  Eprox = inicial; 
            endcase
        end else if (modo_nota_a_nota) begin
            case(Eatual)
                inicializa_elementos:     Eprox = inicio_rodada;
                inicio_rodada:            Eprox = mostra;
                mostra:                   Eprox = espera_mostra;
                espera_mostra:            Eprox = tempo_correto_baixo ? prepara_nota : espera_mostra;
                prepara_nota:             Eprox = espera_nota;
                espera_nota:              Eprox = nota_feita ? toca_nota : espera_nota;
                toca_nota:                Eprox = nota_feita ? toca_nota : compara;
                compara:                  Eprox = !tempo_correto ? errou_tempo : (!nota_correta ? errou_nota : incrementa_nota);
                errou_tempo, errou_nota:  Eprox = iniciar_menu_erro;
                iniciar_menu_erro:        Eprox = menu_erro;
                menu_erro:                Eprox = !press_enter ? menu_erro : 
                                                    (tentar_dnv_rep ? inicio_rodada : (tentar_dnv ? prepara_nota : (apresenta_ultima ? mostra_ultima : menu_erro)));
                incrementa_nota:          Eprox = registra;
                registra:                 Eprox = verifica_fim;
                verifica_fim:             Eprox = fim_musica ? acertou : espera_mostra;
                mostra_ultima:            Eprox = tempo_correto_baixo ? espera_nota : mostra_ultima;
                mostra_proximo:           Eprox = espera_mostra;
                default:                  Eprox = inicial;
            endcase
        end else if (modo_reprodutor) begin
            case(Eatual)
                inicializa_elementos:     Eprox = inicio_rodada;
                inicio_rodada:            Eprox = fimTF ? mostra : inicio_rodada;
                mostra:                   Eprox = espera_toca;
                espera_toca:              Eprox = tempo_correto_baixo ? mostra_proximo : espera_toca;
                mostra_proximo:           Eprox = registra;
                registra:                 Eprox = verifica_fim;
                verifica_fim:             Eprox = fim_musica ? inicio_rodada : espera_toca;
                default:                  Eprox = inicial;
            endcase
        end else if (modo_sem_apresenta) begin
            case (Eatual)
                inicializa_elementos:     Eprox = inicia_sem_mostra;
                inicia_sem_mostra:        Eprox = espera_nota;
                inicio_rodada:            Eprox = fimTF ? mostra : inicio_rodada;
                mostra:                   Eprox = espera_mostra;
                espera_mostra:            Eprox = tempo_correto_baixo ? (enderecoIgualRodada ? inicio_nota : mostra_proximo) : espera_mostra;
                mostra_proximo:           Eprox = mostra;
                inicio_nota:              Eprox = espera_nota;
                espera_nota:              Eprox = fimTempo ? errou_tempo : (nota_feita ? toca_nota : espera_nota);
                toca_nota:                Eprox = nota_feita ? toca_nota : compara; 
                compara:                  Eprox = !nota_correta ? errou_nota : (!tempo_correto ? errou_tempo : proxima_nota_e_roda);
                errou_tempo, errou_nota:  Eprox = iniciar_menu_erro;
                iniciar_menu_erro:        Eprox = menu_erro;
                menu_erro:                Eprox = !press_enter ? menu_erro : 
                                                    (tentar_dnv_rep ? inicio_rodada : (tentar_dnv ? inicio_nota : (apresenta_ultima ? mostra_ultima : menu_erro)));
                proxima_nota_e_roda:      Eprox = registra;
                registra:                 Eprox = verifica_fim;
                verifica_fim:             Eprox = fim_musica ? acertou : espera_nota;
                acertou:                  Eprox = iniciar ? inicializa_elementos : acertou;
                mostra_ultima:            Eprox = tempo_correto_baixo ? espera_nota : mostra_ultima;
                default:                  Eprox = inicial; 
            endcase
        end else if (modo_grava) begin
            case (Eatual) 
                inicializa_elementos: Eprox = inicio_rodada;
                inicio_rodada:        Eprox = espera_nota;
                espera_nota:          Eprox = nota_feita ? toca_nota : (press_enter ? prepara_finaliza : espera_nota);
                toca_nota:            Eprox = nota_feita ? toca_nota : grava;
                grava:                Eprox = proxima_nota_e_roda;
                proxima_nota_e_roda:  Eprox = espera_nota;
				iniciar_menu_erro:    Eprox = menu_grava;
                menu_grava:           Eprox = !press_enter ? menu_grava : (finaliza ? inicial : 
                                                (tocar_preview ? inicio_grava : 
                                                (rollback ? decrementa : menu_grava)));
                prepara_finaliza:     Eprox = fim_grava;
                fim_grava:            Eprox = iniciar_menu_erro;
                decrementa:           Eprox = espera_nota;
                inicio_grava:         Eprox = fimTF ? mostra : inicio_grava;
                mostra:               Eprox = espera_mostra;
                espera_mostra:        Eprox = tempo_correto_baixo ? (fim_musica ? menu_grava : mostra_proximo) : espera_mostra;
                mostra_proximo:       Eprox = mostra;
                default:              Eprox = inicial;
            endcase
        end else if (modo_fresstyle) begin
            case (Eatual) 
                inicializa_elementos:     Eprox = espera_livre; 
                espera_livre:             Eprox = nota_feita ? toca_nota : espera_livre;
                toca_nota:                Eprox = nota_feita ? toca_nota : espera_livre;
                default:                  Eprox = espera_livre;
            endcase
        end
        else begin
            Eprox = inicial;
        end
    end
    end

    // Logica de saida (maquina Moore)
    assign zeraR            = (Eatual == inicial || 
                               Eatual == prepara_finaliza);

    assign zeraOP           = (Eatual == inicial);

    assign zeraCR           = (Eatual == inicializa_elementos);

    assign zeraC            = (Eatual == inicio_nota ||
                               Eatual == inicio_rodada ||
                               Eatual == inicio_grava ||
                               Eatual == inicia_sem_mostra);

    assign zeraTempo        = (Eatual == proxima_nota || 
                               Eatual == inicio_nota || 
                               Eatual == inicializa_elementos || 
                               Eatual == errou_tempo || 
                               Eatual == errou_nota || 
                               Eatual == verifica_fim ||
                               Eatual == prepara_nota);

    assign zeraTF           = (Eatual == mostra || 
                               Eatual == inicializa_elementos || 
                               Eatual == inicio_nota ||
                               Eatual == prepara_nota);

    assign contaTF          = (Eatual == inicio_rodada ||
                               Eatual == inicio_grava);

    assign contaC           = (Eatual == incrementa_nota || 
                               Eatual == mostra_proximo || 
                               Eatual == proxima_nota || 
                               Eatual == proxima_nota ||
                               Eatual == proxima_nota_e_roda ||
                               Eatual == prepara_finaliza);

    assign contaTempo       = (Eatual == espera_nota);

    assign vez_jogador      = (Eatual == espera_nota);

    assign registraR        = (Eatual == toca_nota);

    assign contaCR          = (Eatual == proxima_rodada ||
                               Eatual == proxima_nota_e_roda);

    assign ganhou           = (Eatual == acertou);

    assign perdeu           = (Eatual == errou_tempo || 
                               Eatual == errou_nota);

    assign leds_mem         = (Eatual == espera_mostra || 
                               Eatual == mostra_ultima ||
                               Eatual == espera_toca);

    assign ativa_leds       = (Eatual == toca_nota || 
                               Eatual == espera_mostra || 
                               Eatual == mostra_ultima || 
                               Eatual == espera_toca);

    assign toca             = (Eatual == toca_nota || 
                               Eatual == espera_toca);

    assign contaMetro       = (Eatual == mostra_ultima || 
                               Eatual == espera_mostra || 
                               Eatual == toca_nota ||
                               Eatual == espera_livre || 
                               Eatual == espera_toca);

    assign zeraMetro        = (Eatual == mostra || 
                               Eatual == errou_tempo || 
                               Eatual == espera_nota || 
                               Eatual == errou_nota || 
                               Eatual == inicializa_elementos || 
                               Eatual == verifica_fim ||
                               Eatual == prepara_finaliza);

    assign gravaM           = (Eatual == fim_grava ||
                               Eatual == grava);

    assign inicia_menu      = (Eatual == iniciar_menu || 
                               Eatual == iniciar_menu_erro);

    assign menu_sel[0]      = (Eatual == espera_bpm || 
                               Eatual == espera_musica ||
										 Eatual == menu_grava);

    assign menu_sel[1]      = (Eatual == espera_tom || 
                               Eatual == espera_musica);

    assign menu_sel[2]      = (Eatual == menu_erro || Eatual == menu_grava);

    assign registra_bpm     = (Eatual == espera_bpm);

    assign registra_modo    = (Eatual == espera_modo);

    assign registra_tom     = (Eatual == espera_tom);

    assign registra_musicas = (Eatual == espera_musica);

    assign mostra_menu      = (Eatual == espera_musica ||
                               Eatual == espera_bpm ||
                               Eatual == espera_tom ||
                               Eatual == espera_modo ||
                               Eatual == menu_erro || 
                               Eatual == menu_grava);

    assign registra_erro    = ( Eatual == compara );

    assign volta_contador   = ( Eatual == decrementa );

endmodule