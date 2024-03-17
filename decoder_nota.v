module decoder_nota ( 
    input  [3:0]  valor, 
    input             enable, 
    output reg [11:0] nota       
); 
        
    always @* begin
        if (!enable) begin
            nota = 12'b0;
        end
        else begin 
            case (valor)
                4'd0:  nota = 12'b000000000001; 
                4'd1:  nota = 12'b000000000010; 
                4'd2:  nota = 12'b000000000100; 
                4'd3:  nota = 12'b000000001000; 
                4'd4:  nota = 12'b000000010000; 
                4'd5:  nota = 12'b000000100000; 
                4'd6:  nota = 12'b000001000000; 
                4'd7:  nota = 12'b000010000000; 
                4'd8:  nota = 12'b000100000000; 
                4'd9:  nota = 12'b001000000000; 
                4'd10: nota = 12'b010000000000; 
                4'd11: nota = 12'b100000000000; 
                default: nota = 12'b0;
            endcase
        end
    end
 
endmodule