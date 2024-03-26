module encoder_nota ( 
    input [12:0]      nota,   
    input             enable, 
    output reg [3:0]  valor
); 
        
    always @* begin
        if (!enable) begin
            valor = 4'b0;
        end
        else begin
            case (nota)
                13'b0000000000001: valor = 4'd1;
                13'b0000000000010: valor = 4'd2;
                13'b0000000000100: valor = 4'd3;
                13'b0000000001000: valor = 4'd4;
                13'b0000000010000: valor = 4'd5;
                13'b0000000100000: valor = 4'd6;
                13'b0000001000000: valor = 4'd7;
                13'b0000010000000: valor = 4'd8;
                13'b0000100000000: valor = 4'd9;
                13'b0001000000000: valor = 4'd10;
                13'b0010000000000: valor = 4'd11;
                13'b0100000000000: valor = 4'd12;
                13'b1000000000000: valor = 4'd13;
                default:           valor = 4'b0;
            endcase
        end
    end
 
endmodule