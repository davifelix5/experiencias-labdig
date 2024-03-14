module mux_2x1 #(parameter SIZE=1) (
    input [SIZE-1:0] A,
    input [SIZE-1:0] B,
    input sel,
    output [SIZE-1:0] res
);
    assign res = sel ? A : B;
endmodule