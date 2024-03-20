
#include <LiquidCrystal.h>
#include <CapacitiveSensor.h>
#define LIMIAR 500
#define MODOS 4
#define BPM 2
#define TOM 4
#define MUSICA 16
#define ERRO 3
//Define os pinos que serão utilizados para ligação ao display
LiquidCrystal lcd(22, 2, 3, 24, 4, 26);
//Define pinos dos sensores capacitivos
CapacitiveSensor   Bo9 = CapacitiveSensor(31,30);                           
CapacitiveSensor   Bo10 = CapacitiveSensor(33,32);  
CapacitiveSensor   Bo11 = CapacitiveSensor(35,34);
CapacitiveSensor   Bo12 = CapacitiveSensor(37,36);  
CapacitiveSensor   Bo13 = CapacitiveSensor(39,38);  
int i, j, k, w, tocando, errou;

int menu_sel[3];
int option_sel[4];

char *modos[] = {"Modo 1", "Modo 2", "Modo 3", "Modo4"};
char *bpms[] = {"120 BPM", "120 BPM" };
char *musicas[] = {
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica C"
}; 
char *tons[] = { "Grave", "Meio grave", "Meio agudo", "Agudo" };
char *erros[] = {"Apresenta a última", "Sem apresentar", "Apresenta tudo novamente"};

int binToInt(int bin[], int tamanho) {
  int valor = 0;
  for(int i = 0; i < tamanho; i++) {
    Serial.println( bin[i]);
    if(bin[i]) valor += pow(2, i);
  }
  return valor;
}

void setup()
{
  //Define o número de colunas e linhas do LCD
  lcd.begin(16, 2);
  Serial.begin(9600);

  //Define pinos para a ESP32
  pinMode(40, OUTPUT);
  pinMode(42, OUTPUT);
  pinMode(44, OUTPUT);
  pinMode(46, OUTPUT);
  pinMode(49, OUTPUT);
  //Define os pinos dos botões
   //DIREITA

  //pinMode(52, INPUT); //ENTER
  // Seletores do menu
  pinMode(50, INPUT); //menu_sel0
  pinMode(53, INPUT); //menu_sel1
  pinMode(47, INPUT); //menu_sel2
  
  // Seletores da opção
  pinMode(29, INPUT); //option_sel0
  pinMode(27, INPUT); //option_sel1
  pinMode(25, INPUT); //option_sel2
  pinMode(23, INPUT); //option_sel3
  
  //Iniciar os sensores
  Bo9.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  Bo10.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  Bo11.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  Bo12.set_CS_AutocaL_Millis(0xFFFFFFFF); 
  Bo13.set_CS_AutocaL_Millis(0xFFFFFFFF); 
}
 
void loop()
{
  long T9 =  Bo9.capacitiveSensor(30);
  long T10 =  Bo10.capacitiveSensor(30);
  long T11 =  Bo11.capacitiveSensor(30);
  long T12 =  Bo12.capacitiveSensor(30);
  long T13 =  Bo13.capacitiveSensor(30);

  if(T9 > LIMIAR) digitalWrite(40, HIGH);
  else digitalWrite(40, LOW);
  if(T10 > LIMIAR) digitalWrite(42, HIGH);
  else digitalWrite(42, LOW);
  if(T11 > LIMIAR) digitalWrite(44, HIGH);
  else digitalWrite(44, LOW);
  if(T12 > LIMIAR) digitalWrite(46, HIGH);
  else digitalWrite(46, LOW);
  if(T13 > LIMIAR) digitalWrite(49, HIGH);
  else digitalWrite(49, LOW);

/*
  int enter = digitalRead(52);
  Serial.println(T9);
  Serial.println(T10);
  Serial.println(T11);
  Serial.println(T12);
   Serial.println(T13);
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();
   Serial.println();

   Serial.println();
   Serial.println();*/
  delay(100);

  // Lendo o seletor de menu
  menu_sel[0] = digitalRead(50); 
  menu_sel[1] = digitalRead(53); 
  menu_sel[2] = digitalRead(47);
  int menu = binToInt(menu_sel, 3);

  // Lendo as opções
  option_sel[0] = digitalRead(29); 
  option_sel[1] = digitalRead(27); 
  option_sel[2] = digitalRead(25); 
  option_sel[3] = digitalRead(23); 
  int vetor = binToInt(option_sel, 4);
  Serial.println(vetor);
  Serial.println(menu);
  lcd.clear();   

  if (menu == 0 ){

     lcd.setCursor(0, 0);
     lcd.print("Selecione o modo");

      lcd.setCursor(0, 1);
      
      lcd.print(modos[vetor]);
    
  }

  if (menu == 1 ){ //seleciona modo
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Selecione o BPM");


    lcd.setCursor(0, 1);

    lcd.print(bpms[vetor]);
  }

  if (menu == 2 ){ //seleciona modo
     lcd.clear();
     lcd.setCursor(0, 0);
     lcd.print("Selecione o TOM");


      lcd.setCursor(0, 1);

      lcd.print(tons[vetor]);
  }


  if (menu == 3 ){ //seleciona modo
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Selecione a musica");


    lcd.setCursor(0, 1);

    lcd.print(musicas[vetor]);
  }

  if (menu == 4 ){ //seleciona modo
     lcd.clear();
     lcd.setCursor(0, 0);
     lcd.print("Errou!");


    lcd.setCursor(0, 1);

    lcd.print(erros[vetor]);
  }

}
