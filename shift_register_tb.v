`timescale 100us/100us

module shift_register_tb;
parameter SIZE = 4;
reg               clock_in;
reg [SIZE - 1:0]  load_value, expected_value;
reg               load, dir, reset, shift;
wire [SIZE - 1:0] value;
integer errors, i;

// Configuração do clock
parameter clockPeriod = 2; // in ns, f=5kHz

// instanciacao do DUT (Device Under Test)
shift_register #(.SIZE(SIZE)) DUT (
        .clock      (clock_in),
        .load_value (load_value),
        .load       (load),
        .dir        (dir),
        .reset      (reset),
        .shift      (shift),
        .value      (value)
);

    task verify_load;
    input [SIZE - 1:0]value_expected;
    begin
        if (value_expected !== value) begin 
        $display ("Error load! load_value: %b expected: %b; got value: %b",  load_value, value_expected, value);
        errors = errors + 1;
    end
    end  
    endtask

    task verify_shift;
    input [SIZE - 1:0]value_expected;
    begin
        if (value_expected !== value) begin 
        $display ("Error shift! prior value: %b expected: %b; got value: %b",  load_value, value_expected, value);
        errors = errors + 1;
    end
    end  
    endtask


  // Gerador de clock
  always #((clockPeriod / 2)) clock_in = ~clock_in;

initial begin
    // condicoes iniciais
    load_value = {SIZE*(1'b0)};
    clock_in = 1;
    load = 1'b0;
    dir = 1'b0;
    reset = 1'b0;
    shift = 1'b0;
    errors = 0;
    #clockPeriod;

    // Teste loads
    for (i = 0; i < 10; i = i + 1) begin
        load_value = $urandom;
        load = 1'b1;
        #clockPeriod;
        verify_load(load_value);
    end

    
    for (i = 0; i < 10; i = i + 1) begin
        load_value = $urandom;
        load = 1'b1;
        #clockPeriod;
        load = 1'b0;
        expected_value = load_value;
        dir = $urandom;
        shift = 1'b1;
        case (dir)
            1 : expected_value = {expected_value[SIZE - 2:0], expected_value[SIZE - 1]};
            0 : expected_value = {expected_value[0],   expected_value[SIZE - 1:1]};
        endcase 
        #clockPeriod;
        $display ("dir: %b; prior value: %b; output value: %b", dir, load_value, expected_value);
        verify_shift(expected_value);
    end

    $display ("Finished, got %d errors", errors);
    $stop;
end


endmodule