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
module exp5_unidade_controle (
    input      clock,
    input      reset,
    input      iniciar,
    input      fim,
    input      meio,
    input      jogada,
    input      igual,
    input      nivel,
	 
    output reg   zeraC,
    output reg   contaC,
    output reg   zeraR,
    output reg   registraR,
    output reg   registraN,
    output reg   acertou,
    output reg   errou,
    output reg   pronto,
    output [3:0] db_estado
);

    // Define estados
    parameter inicial               = 4'b0000;  // 0
    parameter inicializa_elementos  = 4'b0001;  // 1
    parameter espera_jogada         = 4'b0100;  // 4
    parameter registra              = 4'b0101;  // 5
    parameter compara               = 4'b0110;  // 6
    parameter proximo               = 4'b0111;  // 7
    parameter fim_acertos           = 4'b1100;  // C
    parameter fim_erro              = 4'b1110;  // E 

	 
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
            inicial:                Eprox = iniciar ? inicializa_elementos : inicial;
            inicializa_elementos:   Eprox = espera_jogada;
            espera_jogada:          Eprox = jogada ? registra : espera_jogada;
            registra:               Eprox = compara;
            compara:                Eprox = ~igual ? fim_erro : (((fim & nivel) || (meio & !nivel)) ? fim_acertos : proximo);
            proximo:                Eprox = espera_jogada;
            fim_acertos:            Eprox = iniciar ? inicial: fim_acertos;
            fim_erro:               Eprox = iniciar ? inicial: fim_erro;
            default:                Eprox = inicial;
        endcase
    end

    // Logica de saida (maquina Moore)
    always @* begin
        zeraC     = (Eatual == inicial || Eatual == inicializa_elementos) ? 1'b1 : 1'b0;
        zeraR     = (Eatual == inicial) ? 1'b1 : 1'b0;
        registraR = (Eatual == registra) ? 1'b1 : 1'b0;
        contaC    = (Eatual == proximo) ? 1'b1 : 1'b0;
        pronto    = (Eatual == fim_erro || Eatual == fim_acertos) ? 1'b1 : 1'b0;
        acertou   = (Eatual == fim_acertos) ? 1'b1 : 1'b0;
        errou     = (Eatual == fim_erro) ? 1'b1 : 1'b0;
        registraN = (Eatual == inicializa_elementos || Eatual == inicial) ? 1'b1 : 1'b0;
    end

endmodule