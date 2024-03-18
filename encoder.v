// Módulo encoder parametrizável
module encoder #(
	parameter SIZE = 4
) (
  input [SIZE - 1:0] data_i, 
  output reg [($clog2(SIZE)) - 1:0] data_o 
);
integer i;

	always @* begin
		data_o = {SIZE*(1'b0)};
    for (i = 0; i < SIZE; i = i + 1)
      if (data_i[i]) data_o = i;
  end

endmodule