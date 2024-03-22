#define LIMIAR 30


//Variaveis que armazenam o valor lido dos pinos touch
int botoes[13];
int botoes_dig[13];
int i;

int vetorParaValor(int vetor[], int tamanho) {
  int valor = 0;
  for(int i = 0; i < tamanho; i++)
    if(vetor[i]) valor = i +1;
  return valor;
}


void setup() 
{
  Serial.begin(115200);

  pinMode(25, INPUT); // Arduino
  pinMode(26, INPUT); // Arduino
  pinMode(34, INPUT); // Arduino
  pinMode(35, INPUT); // Arduino
  pinMode(2, INPUT); // Arduino

  pinMode(5, OUTPUT); //FPGA
  pinMode(18, OUTPUT); //FPGA
  pinMode(19, OUTPUT); //FPGA
  pinMode(21, OUTPUT); //FPGA


}

void loop() 
{
  //Leitura dos pinos touch
  botoes[0] = touchRead(13); //13
  botoes[1] = touchRead(12); //12
  botoes[2] = touchRead(14); //14
  botoes[3] = touchRead(27); //27
  botoes[4] = touchRead(33); //33
  botoes[5] = touchRead(32); //32
  botoes[6] = touchRead(15); //15
  botoes[7] = touchRead(4); //4
  botoes[8] = digitalRead(25); //25 = 40 arduino
  botoes[9] = digitalRead(26); //26 = 42 arduino
  botoes[10] = digitalRead(34); //34 = 44 arduino
  botoes[11] = digitalRead(35); //35 = 46 arduino
  botoes[12] = digitalRead(2); //35 = 46 arduino


for(i = 0; i < 8; i++){
  if(botoes[i] < LIMIAR) botoes_dig[i] = 1;
  else botoes_dig[i] = 0;
}
for(i = 8; i < 13; i++){
  if(botoes[i]) botoes_dig[i] = 1;
  else botoes_dig[i] = 0;
}

int valor = vetorParaValor(botoes_dig, 13);

switch (valor){
  case 0: 
    digitalWrite(5, LOW);
    digitalWrite(18, LOW);
    digitalWrite(19, LOW);
    digitalWrite(21, LOW);
    Serial.println("0000");
    break;
   case 1: 
    digitalWrite(5, HIGH);
    digitalWrite(18, LOW);
    digitalWrite(19, LOW);
    digitalWrite(21, LOW);
    Serial.println("0001");
    break;
    case 2: 
    digitalWrite(5, LOW);
    digitalWrite(18, HIGH);
    digitalWrite(19, LOW);
    digitalWrite(21, LOW);
    Serial.println("0010");
    break;
    case 3: 
    digitalWrite(5, HIGH);
    digitalWrite(18, HIGH);
    digitalWrite(19, LOW);
    digitalWrite(21, LOW);
    Serial.println("0011");
    break;
    case 4: 
    digitalWrite(5, LOW);
    digitalWrite(18, LOW);
    digitalWrite(19, HIGH);
    digitalWrite(21, LOW);
    Serial.println("0100");
    break;
    case 5: 
    digitalWrite(5, HIGH);
    digitalWrite(18, LOW);
    digitalWrite(19, HIGH);
    digitalWrite(21, LOW);
    Serial.println("0101");
    break;
    case 6: 
    digitalWrite(5, LOW);
    digitalWrite(18, HIGH);
    digitalWrite(19, HIGH);
    digitalWrite(21, LOW);
    Serial.println("0110");
    break;
    case 7: 
    digitalWrite(5, HIGH);
    digitalWrite(18, HIGH);
    digitalWrite(19, HIGH);
    digitalWrite(21, LOW);
    Serial.println("0111");
    break;
    case 8: 
    digitalWrite(5, LOW);
    digitalWrite(18, LOW);
    digitalWrite(19, LOW);
    digitalWrite(21, HIGH);
    Serial.println("1000");
    break;
    case 9: 
    digitalWrite(5, HIGH);
    digitalWrite(18, LOW);
    digitalWrite(19, LOW);
    digitalWrite(21, HIGH);
    Serial.println("1001");
    break;
    case 10: 
    digitalWrite(5, LOW);
    digitalWrite(18, HIGH);
    digitalWrite(19, LOW);
    digitalWrite(21, HIGH);
    Serial.println("1010");
    break;
    case 11: 
    digitalWrite(5, HIGH);
    digitalWrite(18, HIGH);
    digitalWrite(19, LOW);
    digitalWrite(21, HIGH);
    Serial.println("1011");
    break;
    case 12: 
    digitalWrite(5, LOW);
    digitalWrite(18, LOW);
    digitalWrite(19, HIGH);
    digitalWrite(21, HIGH);
    Serial.println("1100");
    break;
    case 13: 
    digitalWrite(5, HIGH);
    digitalWrite(18, LOW);
    digitalWrite(19, HIGH);
    digitalWrite(21, HIGH);
    Serial.println("1101");
    break;
    default:
    digitalWrite(5, LOW);
    digitalWrite(18, LOW);
    digitalWrite(19, LOW);
    digitalWrite(21, LOW);
    Serial.println("0000");
    break;
}
/*
for(int z = 0; z <13; z++){
  Serial.println(botoes_dig[z]);
}*/
  delayMicroseconds(1);
}
