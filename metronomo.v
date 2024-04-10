module metronomo #(parameter CLOCK_FREQ) 
(
    input  clock,
    input  zeraMetro,
    input  reset,
    input  contaMetro,
    input metro_120BPM,
    
    output metro60,
    output metro120,
    output meio_metro120,
    output meio_metro60
);

    localparam METRO_60BPM = CLOCK_FREQ/2, METRO_120BPM = CLOCK_FREQ/4;

    // Metronomo 60BPM para a rodada atual
    gerador_pwm #(.M(METRO_60BPM)) Metro60 (
        .clock   ( clock        ), 
        .zera_s  (    zeraMetro      ), 
        .zera_as ( reset    ),
        .conta   ( contaMetro   ),
        .Q       (              ),
        .fim     ( metro60      ),
        .meio    ( meio_metro60 )
    );

    // Metronomo 120BPM para a rodada atual
    gerador_pwm #(.M(METRO_120BPM)) Metro120 (
        .clock   ( clock         ), 
        .zera_s  (      zeraMetro    ),  
        .zera_as ( reset      ), 
        .conta   ( contaMetro    ),
        .Q       (               ),
        .fim     ( metro120      ),
        .meio    ( meio_metro120 )
    );

endmodule