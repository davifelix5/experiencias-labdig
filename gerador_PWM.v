
/*---------------Laboratorio Digital--------------------------------------------
 * Arquivo   : gerador_pwn.v
 * Projeto   : FPGAudio - Piano didático com FPGA
 *-------------------------------------------------------------------------------
 * Descricao : módulo responsável por gerar uma onda PWM a 
               partir de uma determinada frequência informada
               a partir do módulo do contador
 *--------------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor                                        Descricao
 *     30/01/2024  1.0     Caio Dourado, Davi Félix e Vinicius Batista  criacao
 *--------------------------------------------------------------------------------
 */

module gerador_pwm #(parameter M=100)
  (
   input  wire          clock,
   input  wire          zera_as,
   input  wire          zera_s,
   input  wire          conta,
   output reg  [$clog2(M)-1:0]  Q,
   output reg           fim,
   output reg           meio
  );

  always @(posedge clock or posedge zera_as) begin
    if (zera_as) begin
      Q <= 0;
    end else if (clock) begin
      if (zera_s) begin
        Q <= 0;
      end else if (conta) begin
        if (Q == M-1) begin
          Q <= 0;
        end else begin
          Q <= Q + 1;
        end
      end
    end
  end

  // Saidas
  always @ (Q)
      if (Q == M-1)   fim = 1;
      else            fim = 0;

  always @ (Q)
      if (Q >= M/2-1) meio = 1;
      else            meio = 0;

endmodule
