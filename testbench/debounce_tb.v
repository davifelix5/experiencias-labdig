`timescale 1ns/1ns

module debounce_tb;

    localparam CLOCK_FREQ = 50_000_000;
    localparam CLOCK_PERIOD = 20;

    reg real_button_in, clk_in, rst_in;
    wire debounced_button_out;
    
    debounce #(.DEBOUNCE_TIME(CLOCK_FREQ/50)) UUT (
        .clk(clk_in),
        .rst(rst_in),
        .real_button(real_button_in),
        .debounced_button(debounced_button_out)
    );

    always #(CLOCK_PERIOD/2) clk_in = ~clk_in;

    initial begin
        clk_in = 1;
        rst_in = 0;
        real_button_in = 0;

        $dumpfile("waveforms_debounce.vcd");
        $dumpvars(0, UUT);

        @(negedge clk_in);
        rst_in = 1; #(CLOCK_PERIOD) rst_in = 0;

        real_button_in = 1;
        #(250_000*CLOCK_PERIOD);
        real_button_in = 0;
        #(50_000*CLOCK_PERIOD);
        real_button_in = 1;
        #(150_000*CLOCK_PERIOD);
        real_button_in = 0;
        #(20_000*CLOCK_PERIOD);
        real_button_in = 1;
        #(200_000*CLOCK_PERIOD);
        real_button_in = 0;
        #(180*CLOCK_PERIOD);
        real_button_in = 1;
        #(1_500_000*CLOCK_PERIOD);

        $finish;
        
    end


endmodule