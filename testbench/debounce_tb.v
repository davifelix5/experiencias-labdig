`timescale 100us/100us

module debounce_tb;

    localparam CLOCK_FREQ = 5000;
    localparam CLOCK_PERIOD = 2;

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
        #(2*CLOCK_PERIOD);
        real_button_in = 0;
        #(CLOCK_PERIOD);
        real_button_in = 1;
        #(CLOCK_PERIOD);
        real_button_in = 0;
        #(CLOCK_PERIOD);
        real_button_in = 1;
        #(5*CLOCK_PERIOD);
        real_button_in = 0;
        #(CLOCK_PERIOD);
        real_button_in = 1;
        #(105*CLOCK_PERIOD);

        $finish;
        
    end


endmodule