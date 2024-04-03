module botoes_debouncer #(parameter DEBOUNCE_TIME) (
    input clock,
    input reset,
    input [12:0] botoes,
    output [12:0] botoes_debounced
);

    genvar i;
    
    generate
        for (i=0;i<13;i=i+1) begin: DEBOUNCERS
            debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debounce_n (
                .clk(clock),
                .rst(reset),
                .real_button(botoes[i]),
                .debounced_button(botoes_debounced[i])
            );
        end
    endgenerate


endmodule