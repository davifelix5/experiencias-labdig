`timescale 100us/100us

module buzzer_tb;

    reg       clock;
    reg       conta;
    reg       reset;
    reg [3:0] seletor;

    wire pulso;

    integer caso;
    parameter CLOCK_FREQ = 5000;
    // Criação do clock de 50MHz
    integer clockPeriod = 2; 
    always  #((clockPeriod / 2)) clock = ~clock;

    buzzer #(.CLOCK_FREQ(CLOCK_FREQ)) UUT (
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
        conta = 1;
        seletor = 4'b1000;
        #(2*CLOCK_FREQ*clockPeriod);

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