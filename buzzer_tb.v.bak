`timescale 1ns/1ns

module buzzer_tb;

    reg       clock;
    reg       conta;
    reg       reset;
    reg [3:0] seletor;

    wire pulso;

    integer caso;
    // Criação do clock de 1kHz
    integer clockPeriod = 20; 
    always  #((clockPeriod / 2)) clock = ~clock;

    buzzer UUT (
        .clock   ( clock ),
        .conta   ( conta ),
        .reset   ( reset ),

        .seletor ( seletor ),

        .pulso   ( pulso )
    );

    initial begin
        // Condições iniciais
        caso = 0;
        clock = 0;
        reset = 0;
        conta = 0;
        seletor = 4'b0000;
        
        caso = 1;
        // Reseta os pulsos
        reset = 1;
        #(clockPeriod)
        reset = 0;

        caso = 2;
        // Teste sem habilitar o clock
        conta = 0;
        #(50*clockPeriod);

        caso = 3;
        // Conta com 500Hz
        conta = 1;
        seletor = 4'b1000;
        #(50*clockPeriod);

        caso = 4;
        // Conta com 500Hz
        conta = 1;
        seletor = 4'b0001;
        #(50*clockPeriod);

        caso = 5;
        // Conta com 500Hz
        conta = 1;
        seletor = 4'b0100;
        #(50*clockPeriod);

        caso = 7;
        // Conta com 500Hz
        conta = 1;
        seletor = 4'b0010;
        #(50*clockPeriod);

        $stop;

    end

endmodule