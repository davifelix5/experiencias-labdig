
#include <LiquidCrystal.h>
#define LIMIAR 500
#define MODOS 4
#define BPM 2
#define TOM 4
#define MUSICA 16
#define ERRO 3
//Define os pinos que serão utilizados para ligação ao display
LiquidCrystal lcd(22, 2, 3, 24, 4, 26);
//Define pinos dos sensores capacitivos

int i, j, k, w, tocando, errou;

int menu_sel[3];
int option_sel[4];

char *modos[] = {"Modo 1", "Modo 2", "Modo 3", "Modo4"};
char *bpms[] = {"60 BPM", "120 BPM" };
char *musicas[] = {
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica ULITMA"
}; 
char *tons[] = { "Grave", "Meio grave", "Meio agudo", "Agudo" };
char *erros[] = {"Apresenta a última", "Sem apresentar", "Apresenta tudo novamente"};

int binToInt(int bin[], int tamanho) {
  int valor = 0;
  for(int i = 0; i < tamanho; i++) {
    Serial.print(i);
    Serial.print("  ");
    Serial.print(bin[i]);
    int inc = pow(2, i);
    if(bin[i]) valor += inc;
    Serial.print(" ");
    Serial.print(inc);
    Serial.print("  ");
    Serial.println(valor);
    Serial.println();
  }
  return valor;
}

void setup()
{
  //Define o número de colunas e linhas do LCD
  lcd.begin(16, 2);
  Serial.begin(9600);

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
  
}
 
void loop()
{

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

  Serial.print("Veotor: ");
  Serial.print(vetor);
  Serial.print("; Opção: ");
  Serial.println(menu);
  Serial.println();
  delay(10);
  if (menu == 0 ){
  lcd.clear();   
     lcd.setCursor(0, 0);
     lcd.print("Selecione o modo");

      lcd.setCursor(0, 1);
      
      lcd.print(modos[vetor]);
        delay(10);
    
  }

  if (menu == 1 ){ //seleciona modo
      lcd.clear();   
    lcd.setCursor(0, 0);
    lcd.print("Selecione o BPM");


    lcd.setCursor(0, 1);

    lcd.print(bpms[vetor]);
      delay(10);
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
      delay(10);
  }

  if (menu == 4 ){ //seleciona modo
     lcd.setCursor(0, 0);
     lcd.print("Errou!");


    lcd.setCursor(0, 1);

    lcd.print(erros[vetor]);
      delay(10);
  }

}
