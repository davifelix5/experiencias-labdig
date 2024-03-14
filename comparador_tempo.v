module comparador_tempo (
    input [3:0] s_memoria_tempo,
    input [3:0] tempo,
    input       meio_metro,
    
    output tempo_correto_baixo,
    output tempo_correto
);

    wire tempo_correto_cima;

    // Computa a tolerância do tempo
    assign tempo_correto = tempo_correto_baixo | (tempo_correto_cima & meio_metro);

    // Comparador para o tempo atual (tolerância de errar para cima)
    comparador_85 CompTempoBaixo (
        .AEBi ( 1'b1                ), 
        .AGBi ( 1'b0                ), 
        .ALBi ( 1'b0                ), 
        .A    ( s_memoria_tempo     ), 
        .B    ( tempo               ), 
        .AEBo ( tempo_correto_baixo ),
        .AGBo (                     ),
        .ALBo (                     )
    );

    comparador_85 CompTempoAlto (
        .AEBi ( 1'b1                  ), 
        .AGBi ( 1'b0                  ), 
        .ALBi ( 1'b0                  ), 
        .A    ( s_memoria_tempo - 4'b1 ), 
        .B    ( tempo                 ), 
        .AEBo ( tempo_correto_cima    ),
        .AGBo (                       ),
        .ALBo (                       )
    );

endmodule