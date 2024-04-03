module debounce #(parameter DEBOUNCE_TIME) (
    input clk,
    input rst,
    input real_button,
    output debounced_button
);

    // Estados possívels
    localparam WAIT_PRESS = 2'd0,
               COUNT_PRESSED = 2'd1,
               WAIT_UNPRESS = 2'd2,
               COUNT_UNPRESS = 2'd3; 

    reg[1:0] Eprox, Eatual; // Variáveis de estado
    wire timer_done; // Sinal de condição
    wire timer_reset; // Sinal de controle

    // Registrar o estado
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Eatual <= WAIT_PRESS;
        end
        else begin
            Eatual <= Eprox;
        end
    end

    // Transição de estados
    always @* begin
        case (Eatual)
            WAIT_PRESS:    Eprox = real_button ? COUNT_PRESSED : WAIT_PRESS;
            COUNT_PRESSED: Eprox = real_button ? ( timer_done ? WAIT_UNPRESS : COUNT_PRESSED) : WAIT_PRESS;
            WAIT_UNPRESS:  Eprox = real_button ? WAIT_UNPRESS : COUNT_UNPRESS;
            COUNT_UNPRESS: Eprox = real_button ? WAIT_UNPRESS : ( timer_done ? WAIT_PRESS : COUNT_UNPRESS );
            default:       Eprox = WAIT_PRESS; 
        endcase
    end

    // Sinais de controle
    assign timer_reset = ( Eatual == WAIT_PRESS )    || ( Eatual == WAIT_UNPRESS );
    
    // Timer
    contador_m  #(.M(DEBOUNCE_TIME)) timer (
        .clock   ( clk       ),
        .zera_as ( 1'b0        ),
        .zera_s  ( timer_reset ),
        .conta   ( 1'b1        ),
        .load    ( 1'b0        ),
        .data    (             ),
        .Q       (             ),
        .fim     ( timer_done  ),
        .meio    (             )
    );

    // Saida
    assign debounced_button = (Eatual == WAIT_UNPRESS) || (Eatual == COUNT_UNPRESS);



endmodule