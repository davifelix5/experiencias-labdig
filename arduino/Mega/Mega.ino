
#include <LiquidCrystal.h>
#define LIMIAR 500
#define MODOS 6
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

char *modos[] = {"Modo Genius", "Modo Nota a Nota", "Modo Sem apresentar", "Modo Reprodutor", "Modo Freestyle", "Modo Gravacao"};
char *bpms[] = {"60 BPM", "120 BPM" };
char *musicas[] = {
  "Musica A", "Hino Nacional", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica C", 
  "Musica A", "Musica B", "Musica C", "Musica ULITMA"
}; 
char *grava[] = {"Finaliza", "Toca Preview", "Grava"};
char *tons[] = { "Grave", "Meio grave", "Meio agudo", "Agudo" };
char *erros[] = {"Apresenta a ultima", "Sem apresentar", "Apresenta tudo novamente"};

int Li          = 16;
int Lii         = 0; 
int Ri          = -1;
int Rii         = -1;
//----------------------------------
String Scroll_LCD_Left(String StrDisplay){
  String result;
  String StrProcess = "                " + StrDisplay + "                ";
  result = StrProcess.substring(Li,Lii);
  Li++;
  Lii++;
  if (Li>StrProcess.length()){
    Li=16;
    Lii=0;
  }
  return result;
}


void Clear_Scroll_LCD_Left(){
  Li=16;
  Lii=0;
}
int binToInt(int bin[], int tamanho) {
  int valor = 0;
  for(int i = 0; i < tamanho; i++) {

    int inc = 1;
    for (int j = 0; j<i; j++) inc *= 2;
    if(bin[i]) valor += inc;

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
  pinMode(47, INPUT); //menu_sel0
  pinMode(49, INPUT); //menu_sel1
  pinMode(51, INPUT); //menu_sel2
  
  // Seletores da opção
  pinMode(29, INPUT); //option_sel0
  pinMode(27, INPUT); //option_sel1
  pinMode(25, INPUT); //option_sel2
  pinMode(23, INPUT); //option_sel3
  pinMode(45, INPUT); //mostraMenu
  pinMode(43, INPUT); //errou_nota
  
  
}
 
void loop()
{
  // Lendo o seletor de menu
  menu_sel[0] = digitalRead(47); 
  menu_sel[1] = digitalRead(49); 
  menu_sel[2] = digitalRead(51);
  int menu = binToInt(menu_sel, 3);
  int menuOld = -1;

  // Lendo as opções
  option_sel[0] = digitalRead(29); 
  option_sel[1] = digitalRead(27); 
  option_sel[2] = digitalRead(25); 
  option_sel[3] = digitalRead(23); 
  int vetor = binToInt(option_sel, 4);
  int vetorOld = -1;
  int mostraMenu = digitalRead(45);
  int errou_nota = digitalRead(43);
  int mostraMenuOld = -1;

  Serial.print("Veotor: ");
  Serial.print(vetor);
  Serial.print("; Opção: ");
  Serial.println(menu);
  Serial.println();
  delay(10);
/*
    Serial.print("Mostra Menu: ");
    Serial.print(mostraMenu);
    Serial.print(mostraMenuOld);
    Serial.print("\n");
    Serial.print("Menu: ");
    Serial.print(menu);
    Serial.print(menuOld);
    Serial.print("\n");
    Serial.print("Vetor: ");
    Serial.print(vetor);
    Serial.print(vetorOld);
    */
  if (menuOld != menu || vetorOld != vetor || mostraMenuOld != mostraMenu) {
    menuOld = menu;
    Clear_Scroll_LCD_Left();
    vetorOld = vetor;
    mostraMenuOld = mostraMenu;
    if (!mostraMenu) {  
        
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("FPGAudio");

      lcd.setCursor(0, 1);
       lcd.print(Scroll_LCD_Left("Integrantes: Caio, Davi e Vinicius"));
       
        delay(300);
      }
   else{
      if (menu == 0 ){
      lcd.clear();   
      lcd.setCursor(0, 0);
      lcd.print("Selecione o modo");

      lcd.setCursor(0, 1);
      
      lcd.print(modos[vetor]);
        delay(300);

    
  }

    if (menu == 1 ){ //seleciona modo
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Selecione o BPM");


      lcd.setCursor(0, 1);

      lcd.print(bpms[vetor]);
        delay(300);
    }

    if (menu == 2 ){ //seleciona modo
      lcd.clear();   
      lcd.setCursor(0, 0);
      lcd.print("Selecione o TOM");


        lcd.setCursor(0, 1);

        lcd.print(tons[vetor]);
        delay(300);
    }


    if (menu == 3 ){ //seleciona modo
        lcd.clear();   
      lcd.setCursor(0, 0);
      lcd.print("Musica");


      lcd.setCursor(0, 1);
      lcd.print(Scroll_LCD_Left(musicas[vetor]));
        delay(300);
    }

    if (menu == 4 ){ //seleciona modo
      lcd.setCursor(0, 0);
      if (errou_nota) {
        lcd.print("Errou uma nota!");
      }
      else {
        lcd.print("Errou o tempo!");
      }

      lcd.setCursor(0, 1);
      lcd.print(Scroll_LCD_Left(erros[vetor]));
        delay(300);
    }

    if (menu == 5 ){ //seleciona modo
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Pausa na gravação");

      lcd.setCursor(0, 1);
      lcd.print(grava[vetor]);
      delay(300);
    }

  }
  }

}