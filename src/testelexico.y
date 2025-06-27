%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h> 
  int yylex (void);
  void yyerror (char const *);
  extern FILE *yyout;

  long linha=1;
  long coluna=1;
  long coluna_tmp = 0;
%}

%union{
  char* texto;
  long numero_inteiro;
  double numero_decimal;
}

/* operadores lógicos */
%token <texto> t_mais t_menos t_asteristico t_barra

%token <texto> t_maior t_menor t_igual t_exclamacao
%token <texto> t_igual_a t_diferente_de t_menor_ou_igual t_maior_ou_igual

/* tipos */
%token <texto> t_abrivetor t_fechavetor t_int t_float t_char


/* valores de atribuição para tipos*/
%token <numero_inteiro> t_num 
%token <texto> t_identificador
%token <numero_decimal> t_decimal 
%token <texto> t_string t_eof

/* Tokens de repetição e condicionais */
%token <texto> t_for t_while t_if t_else t_switch t_case t_default t_break t_abrichave t_fechachave t_abriparentes t_fechaparentes
%token <texto> t_pontovirgula t_virgula t_doispontos t_interrogacao  

/* Tokens classe e função */
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_this

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha 

%start inicio
%type <texto> programa  palavra_reservada atributos atributos-numeros atributos-texto




%% /* Gramática deste ponto para baixo*/
inicio:
  %empty| programa inicio
programa:
  palavra_reservada {fprintf(yyout, "[Linha %d] Achou uma palavra_reservada (%s)\n", linha, $1);} |
  atributos 
palavra_reservada:
  t_mais | t_menos | t_asteristico | t_barra |
  t_igual | t_maior | t_menor | t_exclamacao |
  t_char | t_int | t_float  | t_abrivetor | t_fechavetor |
  t_for | t_while | t_if | t_else | t_switch | t_case | t_default | t_break | t_abrichave | t_fechachave | 
  t_abriparentes | t_fechaparentes | t_pontovirgula | t_interrogacao | t_doispontos |
  t_class | t_func | t_construtor| t_destrutor | t_return | t_virgula | t_this
atributos:
  atributos-numeros | atributos-texto {fprintf(yyout, "[Linha %d] Achou uma atributos-texto (%s)\n", linha, $1);} 
atributos-numeros:
  t_num {fprintf(yyout, "[Linha %d] [Coluna:%d]  Achou um t_num (%d)\n", linha, coluna, $1);} |  
  t_decimal {fprintf(yyout, "[Linha %d] Achou um t_decimal (%f)\n", linha, $1);}
atributos-texto:
  t_identificador  | t_variavel | t_string 
%%

