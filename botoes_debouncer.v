module botoes_debouncer #(parameter DEBOUNCE_TIME) (
    input clock,
    input reset,
    input [12:0] botoes,
    output [12:0] botoes_debounced,
    output [12:0] button_posedges
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

            edge_detector button_edge_n (
                .clock(clock),
                .reset(reset),
                .sinal(botoes_debounced[i]),
                .pulso(button_posedges[i])
            );
        end

    endgenerate


endmodule