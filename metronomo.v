module metronomo #(parameter CLOCK_FREQ) 
(
    input  clock,
    input  reset,
    input  zeraMetro,
    input  contaMetro,
    input  metro_120BPM,
    
    output metro,
    output meio_metro
);

    localparam METRO_60BPM = CLOCK_FREQ/2, METRO_120BPM = CLOCK_FREQ/4;

    wire metro60, metro120, meio_metro60, meio_metro120;

    // Seleção do metrônomo: 1 para 120BPM e 0 para 60BPM
    assign metro      = metro_120BPM ? metro120      : metro60;
    assign meio_metro = metro_120BPM ? meio_metro120 : meio_metro60; 

    // Metronomo 60BPM para a rodada atual
    gerador_pwm #(.M(METRO_60BPM)) Metro60 (
        .clock   ( clock        ), 
        .zera_s  ( zeraMetro    ), 
        .zera_as ( 1'b0        ),
        .conta   ( contaMetro   ),
        .Q       (              ),
        .fim     ( metro60      ),
        .meio    ( meio_metro60 )
    );

    // Metronomo 120BPM para a rodada atual
    gerador_pwm #(.M(METRO_120BPM)) Metro120 (
        .clock   ( clock         ), 
        .zera_s  ( zeraMetro     ),  
        .zera_as ( 1'b0          ), 
        .conta   ( contaMetro    ),
        .Q       (               ),
        .fim     ( metro120      ),
        .meio    ( meio_metro120 )
    );

endmodule