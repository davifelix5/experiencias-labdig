module menu #(
    parameter MODO = 4,
              BPM = 2,
              TOM = 4,
              MUSICA = 16,
              ERRO = 3,
              GRAVA_OPS = 3
) (
    input right_arrow_pressed, left_arrow_pressed,
    input reset,
    input clock,
    input load_initial,
    input [2:0] menu_sel,
    output [MODO - 1:0] modos,
    output [BPM - 1:0] bpms,
    output [GRAVA_OPS-1:0] grava_ops,
    output [$clog2(TOM) - 1:0] toms,
    output [$clog2(MUSICA) - 1:0] musicas,
    output [ERRO - 1:0] erros,
    output [$clog2(MUSICA) - 1:0] arduino_out
);
parameter SIZE = 2;

wire [MUSICA - 1:0] arduino_signal, menu_principal_o;
wire [TOM-1:0] toms_decoded;
wire [MUSICA-1:0] musicas_decoded;
wire right_arrow_pulse, left_arrow_pulse, enable_shift;
wire[3:0] shift;

assign enable_shift = right_arrow_pulse | left_arrow_pulse;

// Decodifcador para escolher qual dos registradores deve ser shiftado em uma interação com menu
decoder_2x4 decoder_shift (
    .in(menu_sel[1:0]),
    .enable(enable_shift),
    .out(shift)
);

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
//Devolvendo sinais decodificados de tom e música
/////////////////////////////////////////////////////////////////////////

encoder #(.SIZE(TOM)) tom_value (
    .data_i (toms_decoded),
    .data_o (toms)
);

encoder #(.SIZE(MUSICA)) musica_value (
    .data_i (musicas_decoded),
    .data_o (musicas)
);

/////////////////////////////////////////////////////////////////////////
//Seleciona qual dos One-Hot irá ser codificado e ir para o arduino
/////////////////////////////////////////////////////////////////////////
mux8_1 #(.SIZE(MUSICA)) mux_arduino_principal (
        .sel    (menu_sel),
        .i0     ({{(MUSICA - MODO){1'b0}} , modos}),
        .i1     ({{(MUSICA - BPM){1'b0}} , bpms}),
        .i2     ({{(MUSICA - TOM){1'b0}},toms_decoded}),
        .i3     (musicas_decoded ),
        .i4     ({{(MUSICA - ERRO){1'b0}} , erros}),
        .i5     ( {{(MUSICA - GRAVA_OPS){1'b0}} , grava_ops}),
        .i6     ( ),
        .i7     ( ),
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
    .shift      (shift[0]),
    .value      (modos)
); 

shift_register #(.SIZE(BPM)) bpm_sr(
    .clock      (clock),
    .load_value ({{(BPM - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift[1]),
    .value      (bpms)
); 

shift_register #(.SIZE(TOM)) tom_sr(
    .clock      (clock),
    .load_value ({{(TOM - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift[2]),
    .value      (toms_decoded)
); 

shift_register #(.SIZE(MUSICA)) musica_sr(
    .clock      (clock),
    .load_value ({{(MUSICA - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (shift[3]),
    .value      (musicas_decoded)
); 

shift_register #(.SIZE(ERRO)) erro_sr(
    .clock      (clock),
    .load_value ({{(ERRO - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (enable_shift & menu_sel[2]),
    .value      (erros)
); 

shift_register #(.SIZE(GRAVA_OPS)) grava_sr(
    .clock      (clock),
    .load_value ({{(GRAVA_OPS - 1){1'b0}}, 1'b1}),
    .load       (load_initial),
    .dir        (right_arrow_pressed),
    .reset      (reset),
    .shift      (enable_shift),
    .value      (grava_ops)
); 

endmodule
