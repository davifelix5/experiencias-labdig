module menu #(
    parameter MODO = 3,
              BPM = 2,
              TOM = 4,
              MUSICA = 16,
              ERRO = 3
) (
    input right_arrow_pressed, left_arrow_pressed,
    input reset,
    input clock,
    input load_initial,
    input [1:0] menu_sel,
    output tentar_dnv_rep,
    output tentar_dnv,
    output apresenta_ultima,
    output [MODO - 1:0] modos,
    output [BPM - 1:0] bpms,
    output [TOM - 1:0] toms,
    output [MUSICA - 1:0] musicas,
    output [$clog2(MUSICA) - 1:0] arduino_out
);
parameter SIZE = 2;

wire [ERRO - 1:0] erros;
wire [MUSICA - 1:0] arduino_signal;
wire right_arrow_pulse, left_arrow_pulse;
wire shift;

assign shift = right_arrow_pulse | left_arrow_pulse;

assign {tentar_dnv_rep, tentar_dnv, apresenta_ultima} = erros;


//Edge Detector
    edge_detector EdgeDetectorRight (
        .clock( clock               ),
        .reset( 1'b0                ), 
        .sinal( right_arrow_pressed ), 
        .pulso( right_arrow_pulse   )
    );

//Edge Detector
    edge_detector EdgeDetectorLeft (
        .clock( clock               ),
        .reset( 1'b0                ), 
        .sinal( left_arrow_pressed  ), 
        .pulso( left_arrow_pulse    )
    );


/////////////////////////////////////////////////////////////////////////
//Seleciona qual dos One-Hot irá ser codificado e ir para o arduino
/////////////////////////////////////////////////////////////////////////
mux4_1 #(.SIZE(MUSICA)) mux_arduino (
        .sel    (menu_sel),
        .i0     ({{(MUSICA - MODO){1'b0}} , modos}),
        .i1     ({{(MUSICA - BPM){1'b0}} , bpms}),
        .i2     ({{(MUSICA - TOM){1'b0}},toms}),
        .i3     (musicas),
        .data_o (arduino_signal)
    );

encoder #(.SIZE(MUSICA)) arduino_value (
    .data_i (arduino_signal),
    .data_o (arduino_out)
);

/////////////////////////////////////////////////////////////////////////
//Shifters que selecionam configurações do menu
/////////////////////////////////////////////////////////////////////////

shift_register #(.SIZE(MODO)) modo_sr(
    .clock      (clock),
    .load_value ({{(MODO - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift),
    .value      (modos)
); 

shift_register #(.SIZE(BPM)) bpm_sr(
    .clock      (clock),
    .load_value ({{(BPM - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift),
    .value      (bpms)
); 

shift_register #(.SIZE(TOM)) tom_sr(
    .clock      (clock),
    .load_value ({{(TOM - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift),
    .value      (toms)
); 

shift_register #(.SIZE(MUSICA)) musica_sr(
    .clock      (clock),
    .load_value ({{(MUSICA - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift),
    .value      (musicas)
); 

shift_register #(.SIZE(ERRO)) erro_sr(
    .clock      (clock),
    .load_value ({{(ERRO - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift),
    .value      (erros)
); 

endmodule
