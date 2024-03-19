module decoder_2x4(
    input[1:0] in,
    input enable,
    output[3:0] out
);

    assign out[0] = enable & ~in[1] & ~in[0];
    assign out[1] = enable & ~in[1] & in[0];
    assign out[2] = enable & in[1] & ~in[0];
    assign out[3] = enable & in[1] & in[0];


endmodule