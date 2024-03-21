module decoder_nota ( 
    input  [3:0]  valor, 
    input         enable, 
    output reg [12:0] nota       
); 
        
    always @* begin
        if (!enable) begin
            nota = 13'b0;
        end
        else begin 
            case (valor)
                4'd1:  nota = 13'b0000000000001; 
                4'd2:  nota = 13'b0000000000010; 
                4'd3:  nota = 13'b0000000000100; 
                4'd4:  nota = 13'b0000000001000; 
                4'd5:  nota = 13'b0000000010000; 
                4'd6:  nota = 13'b0000000100000; 
                4'd7:  nota = 13'b0000001000000; 
                4'd8:  nota = 13'b0000010000000; 
                4'd9:  nota = 13'b0000100000000; 
                4'd10: nota = 13'b0001000000000; 
                4'd11: nota = 13'b0010000000000; 
                4'd12: nota = 13'b0100000000000; 
                4'd13: nota = 13'b1000000000000; 
                default: nota = 13'b00;
            endcase
        end
    end
 
endmodule