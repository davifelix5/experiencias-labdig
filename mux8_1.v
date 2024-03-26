/* Módulo que representa um multiplexador parametrizáel de 4 entradas de "SIZE" bits */
module mux8_1 #(
    parameter SIZE = 64 
) (
  input [2:0] sel, // seletor do multiplexador
  input [SIZE - 1:0] i0, i1, i2, i3, i4, i5, i6, i7, // entradas
  output reg [SIZE - 1:0] data_o // saída
);

  //Com base no seletor "sel", escolhe qual valor de entra será direcionado para a saída data_o
  always @(*) begin
    case (sel)
      3'b00: data_o = i0; 
      3'b01: data_o = i1; 
      3'b10: data_o = i2; 
      3'b11: data_o = i3; 
      3'b100: data_o = i4; 
      3'b101: data_o = i5; 
      3'b110: data_o = i6; 
      3'b111: data_o = i7; 
    endcase
  end

endmodule