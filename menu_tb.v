`timescale 100us/100us

module menu_tb;
parameter MODO = 4,
          BPM = 2,
          TOM = 4,
          MUSICA = 16,
          ERRO = 3;
reg right_arrow_pressed, left_arrow_pressed ;
reg reset;
reg clock_in;
reg load_initial;
reg [1:0] menu_sel;
wire tentar_dnv_rep;
wire tentar_dnv;
wire apresenta_ultima;
wire [MODO - 1:0] modos;
wire [BPM - 1:0] bpms;
wire [$clog2(TOM) - 1:0] toms;
wire [$clog2(MUSICA) - 1:0] musicas;
wire [$clog2(MUSICA) - 1:0] arduino_out;

integer errors, i;

// Configuração do clock
parameter clockPeriod = 2; // in ns, f=5kHz

// Gerador de clock
always #((clockPeriod / 2)) clock_in = ~clock_in;

menu #(
    .MODO   (MODO),
    .BPM    (BPM),
    .TOM    (TOM),
    .MUSICA (MUSICA),
    .ERRO   (ERRO)
) UUT (
    .right_arrow_pressed (right_arrow_pressed),
    .left_arrow_pressed  (left_arrow_pressed),
    .reset               (reset),
    .clock               (clock_in),
    .load_initial        (load_initial),
    .menu_sel            (menu_sel),
    .tentar_dnv_rep      (tentar_dnv_rep),
    .tentar_dnv          (tentar_dnv),
    .apresenta_ultima    (apresenta_ultima),
    .modos               (modos),
    .bpms                (bpms),
    .toms                (toms),
    .musicas             (musicas),
    .arduino_out         (arduino_out)
);

task mostrar_saidas;
begin 
    $display("////////////////////");
    case (menu_sel)
        2'b00: begin 
            $display("Menu: MODO");
            $display("Modo selecionado: %b", modos);
        end
        2'b01: begin
            $display("Menu: BPM");
            $display("BPM selecionado: %b", bpms);
        end
        2'b10: begin
            $display("Menu: TOM");
            $display("TOM selecionado: %b", toms);
        end
        2'b11: begin 
            $display("Menu: MUSICA");
            $display("MUSICA selecionada: %b", musicas);
        end
    endcase 
    $display("Saida arduino: %d", arduino_out);
    $display("tentar_dnv_rep : %d", tentar_dnv_rep);
    $display("tentar_dnv : %d", tentar_dnv);
    $display("apresenta_ultima : %d \n", apresenta_ultima);


end
endtask

initial begin
    clock_in = 1'b0;
    right_arrow_pressed = 1'b0;
    left_arrow_pressed = 1'b0;
    reset = 1'b0;
    load_initial = 1'b0;
    menu_sel = 4'b0;
    errors = 0;

    #clockPeriod;

    //Inicio de um menu -> carrega carrega valor inicial
    load_initial = 1'b1;
    #clockPeriod;
    load_initial = 1'b0;
    #clockPeriod;

    //Seleciona menu que irá para o arduino
    menu_sel = 2'b0;
    #clockPeriod;
    mostrar_saidas();

    //Seta para direita
    right_arrow_pressed = 1'b1;
    #(30*clockPeriod);
    mostrar_saidas();
    
    //Seta para esquerda
    right_arrow_pressed = 1'b0; // solta botão
    left_arrow_pressed = 1'b1;
    #(30*clockPeriod);
    mostrar_saidas();

    //Seta para esquerda
    left_arrow_pressed = 1'b0; // solta botão
    #clockPeriod;
    left_arrow_pressed = 1'b1;
    #(30*clockPeriod);
    mostrar_saidas();

    //Muda menu
    left_arrow_pressed = 1'b0; // solta botão

    load_initial = 1'b1; //UC reinicia menu toda vez que ele se altera
    #clockPeriod;
    load_initial = 1'b0;
    #clockPeriod;

    menu_sel = 2'b10;
    #clockPeriod;
    mostrar_saidas();

    //Seta para direita 3 vezes
    right_arrow_pressed = 1'b1;
    #(30*clockPeriod);
    right_arrow_pressed = 1'b0;
    #clockPeriod;
    right_arrow_pressed = 1'b1;
    #(30*clockPeriod);
    right_arrow_pressed = 1'b0;
    #clockPeriod;
    right_arrow_pressed = 1'b1;
    #(30*clockPeriod);
    right_arrow_pressed = 1'b0;
    #clockPeriod;
    mostrar_saidas();

    $display("Finished! Got %d errors", errors);
    $stop;
end

endmodule