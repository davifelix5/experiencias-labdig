module decoder_4x16(
    input[3:0] in,
    input enable,
    output[15:0] out
);

    assign out[0] = enable & ~in[3] & ~in[2] & ~in[1] & ~in[0];
    assign out[1] = enable & ~in[3] & ~in[2] & ~in[1] & in[0];
    assign out[2] = enable & ~in[3] & ~in[2] & in[1] & ~in[0];
    assign out[3] = enable & ~in[3] & ~in[2] & in[1] & in[0];
    assign out[4] = enable & ~in[3] & in[2] & ~in[1] & ~in[0];
    assign out[5] = enable & ~in[3] & in[2] & ~in[1] & in[0];
    assign out[6] = enable & ~in[3] & in[2] & in[1] & ~in[0];
    assign out[7] = enable & ~in[3] & in[2] & in[1] & in[0];
    assign out[8] = enable & in[3] & ~in[2] & ~in[1] & ~in[0];
    assign out[9] = enable & in[3] & ~in[2] & ~in[1] & in[0];
    assign out[10] = enable & in[3] & ~in[2] & in[1] & ~in[0];
    assign out[11] = enable & in[3] & ~in[2] & in[1] & in[0];
    assign out[12] = enable & in[3] & in[2] & ~in[1] & ~in[0];
    assign out[13] = enable & in[3] & in[2] & ~in[1] & in[0];
    assign out[14] = enable & in[3] & in[2] & in[1] & ~in[0];
    assign out[15] = enable & in[3] & in[2] & in[1] & in[0];

endmodule