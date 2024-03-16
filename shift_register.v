module shift_register #(
    parameter SIZE=4
) (
    input clock,
    input [SIZE - 1:0] load_value,
    input load,
    input dir, 
    input reset,
    input shift,
    output reg [SIZE - 1:0] value
);
    always @(posedge clock) begin
        if (reset)
            value <=  {SIZE*(1'b0)};
        else begin
            if (load) value <= load_value;
            else if (shift)
                case (dir)
                    1: value = {value[SIZE - 2:0], value[SIZE - 1]};
                    0: value = {value[0], value[SIZE - 1:1]};
                    default: value <= value;
                endcase
            else 
                value <= value;
        end
    end

endmodule