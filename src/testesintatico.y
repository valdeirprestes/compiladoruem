%{
  #include <stdio.h>
  #include <stdlib.h>
  int yylex (void);
  void yyerror (char const *);
  extern FILE *yyout;
  #ifdef YYDEBUG
    yydebug = 1;
  #endif
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
%token <texto> t_nomevariavel t_string

/* Tokens de repetição e condicionais */
%token <texto> t_for t_while t_if t_else t_switch t_case t_default t_break t_abrichave t_fechachave t_abriparentes t_fechaparentes
%token <texto> t_pontovirgula t_virgula t_doispontos t_interrogacao

/* Tokens classe e função */
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_this

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha 
%token <texto> t_eof  

%start programa
%type programa codigo 
%type funcao parametrosfunc parametro  

/* Generate the parser description file. */
%verbose
/* Enable run-time traces (yydebug). */
/*%define parse.trace*/
/*%printer { fprintf (yyo, "%s", $$); } t_main;
%printer { fprintf (yyo, "%s", $$); } t_abriparentes;*/

%left t_igual_a
%left t_maior
%left t_maior_ou_igual
%left t_menor
%left t_menor_ou_igual
%left t_diferente_de
%left t_mais
%left t_menos
%left t_asteristico
%left t_barra



%% /* Gramática deste ponto para baixo*/
programa:
  codigos 
codigos:
  %empty |
  codigo codigos |   
  codigo error { yyerror; printf("erro de sintaxe\n");} 
codigo:
  funcao
funcao:
	tipofunc t_identificador t_abriparentes parametrosfunc t_fechaparentes corpofuncao 
tipofunc:
  tipo | 
  tipo t_abrivetor t_fechavetor
parametrosfunc:
	parametro  | parametro t_virgula parametros 
parametros:
	parametro  | parametro t_virgula parametros 
parametro:
  %empty |
	tipo t_identificador
tipo:
  t_int | t_float | t_char
corpofuncao:
  %empty | 
	t_abrichave declaracoes comandos t_fechachave
declaracoes:
  %empty |
  declaracao t_pontovirgula | declaracao  t_virgula declaracoes t_pontovirgula
declaracao:
  tipo t_identificador
  |tipo t_identificador t_igual expressoes t_pontovirgula
  | tipo  t_abrivetor t_fechavetor t_identificador t_pontovirgula
comandos:
  %empty
  | comando 
comando:
  forcomando | whilecomando | atribuicao
forcomando:
  t_for t_abriparentes parte1for t_pontovirgula parte2for t_pontovirgula parte3for t_fechaparentes corpofor
parte1for:
  %empty
  | tipo t_identificador t_igual atributo
  | t_identificador t_igual atributo
atribuicao:
  t_identificador t_igual atributo t_pontovirgula  
atributo:
  t_identificador | t_decimal | t_num | t_float
parte2for:
  %empty
  | testeboleano
testeboleano:
  atributo t_igual_a atributo
  | atributo t_diferente_de atributo
  | atributo t_maior_ou_igual atributo
  | atributo t_menor_ou_igual atributo
  | atributo t_maior atributo
  | atributo t_menor atributo
  | t_exclamacao atributo
  | t_abriparentes atributo t_fechaparentes
  | atributo
parte3for:
  t_identificador t_igual atributo t_mais atributo
  | t_identificador t_igual atributo t_menos atributo
  | t_identificador t_igual atributo t_barra atributo
  | t_identificador t_igual atributo t_asteristico atributo
corpofor:
  atributo t_igual atributo t_pontovirgula
  |atributo t_menos atributo t_pontovirgula
  |atributo t_barra atributo t_pontovirgula
  |atributo t_asteristico atributo t_pontovirgula
  | t_abrichave comandos t_fechachave
whilecomando:
  t_while t_abriparentes testeboleano t_fechaparentes corpowhile
corpowhile:
  comando t_pontovirgula
  | t_abrichave comandos t_fechachave
  | error { yyerror; printf("corpo do while incorreto\n");}
expressoes:
  %empty
  |expressao t_pontovirgula expressoes
expressao:
  expressao t_mais expressao
  | expressao t_menos expressao
  | expressao t_asteristico expressao
  | expressao t_barra expressao
  | expressao t_igual_a expressao
  | expressao t_diferente_de expressao
  | expressao t_maior expressao
  | expressao t_maior_ou_igual expressao
  | expressao t_menor
  | expressao t_menor_ou_igual
  | t_abriparentes expressao t_fechaparentes
  | atributo





