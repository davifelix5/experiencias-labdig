module decoder_nota_valor ( 
    input [11:0]      nota,   
    input             enable, 
    output reg [3:0]  valor
); 
        
    always @* begin
        if (!enable) begin
            valor = 4'b0;
        end
        else begin
            case (nota)
                12'b000000000001: valor = 4'd0;
                12'b000000000010: valor = 4'd1;
                12'b000000000100: valor = 4'd2;
                12'b000000001000: valor = 4'd3;
                12'b000000010000: valor = 4'd4;
                12'b000000100000: valor = 4'd5;
                12'b000001000000: valor = 4'd6;
                12'b000010000000: valor = 4'd7;
                12'b000100000000: valor = 4'd8;
                12'b001000000000: valor = 4'd9;
                12'b010000000000: valor = 4'd10;
                12'b100000000000: valor = 4'd11;
                default:          valor = 4'bx;
            endcase
        end
    end
 
endmodule