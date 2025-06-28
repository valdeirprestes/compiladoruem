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
  long errossintatico = 0;
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
%token <texto> t_pontovirgula t_virgula t_doispontos t_interrogacao t_ponto

/* Tokens classe e função */
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_this

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha 
%token <texto> t_eof  

%start inicio
%type inicio codigo 
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
inicio:
  codigos 
codigos:
  %empty 
  | codigo codigos 
  | codigo error { 
      yyerror; 
      printf("Foi encontrado %d erro(s) de sintaxe no codigo\n", errossintatico);
    } 
codigo:
  funcao | classe
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
  |tipo t_abrivetor t_fechavetor t_identificador
tipo:
  t_int | t_float | t_char
corpofuncao:
  t_abrichave declaracoes_comandos t_fechachave
declaracoes_comandos:
  %empty
  | declaracao t_pontovirgula
  | declaracao t_pontovirgula declaracoes
  | declaracao t_pontovirgula comandos
  | comando
  | comando declaracoes
  | comando comandos
declaracoes:
  declaracao t_pontovirgula
  |declaracao t_pontovirgula  comandos
  |declaracao t_pontovirgula declaracoes
declaracao:
  tipo t_identificador
  |tipo t_identificador t_igual expressao
  |tipo  t_abrivetor t_fechavetor t_identificador
comandos:
  comando
  | chamada_funcao t_pontovirgula 
  | chamada_metodo t_pontovirgula
  | comando comandos
  | comando declaracoes
comando:
  forcomando 
  | whilecomando 
  | atribuicao t_pontovirgula
  | t_return atributo t_pontovirgula
argumentos:
  %empty
  | argumento
  | argumento t_virgula argumentos
argumento:
  atributo
  | tipo atributo
forcomando:
  t_for t_abriparentes parte1for t_pontovirgula parte2for t_pontovirgula parte3for t_fechaparentes corpofor
parte1for:
  %empty
  | tipo t_identificador t_igual atributo
  | t_identificador t_igual atributo
atribuicao:
  t_identificador t_igual expressao 
   
atributo:
  t_identificador | t_decimal | t_num | t_string
  | chamada_funcao
  | chamada_metodo
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
  corpoloop
corpoloop:
  atributo t_igual atributo t_pontovirgula
  |atributo t_menos atributo t_pontovirgula
  |atributo t_barra atributo t_pontovirgula
  |atributo t_asteristico atributo t_pontovirgula
  | forcomando
  | whilecomando
  | t_abrichave comandos t_fechachave
chamada_funcao:
  t_identificador t_abriparentes argumentos t_fechaparentes
chamada_metodo:
  t_identificador t_ponto t_identificador t_abriparentes argumentos t_fechaparentes

whilecomando:
  t_while t_abriparentes expressao t_fechaparentes corpowhile
corpowhile:
  corpoloop
  | error {
      errossintatico += 1; 
      yyerror; printf("corpo do while incorreto\n");
    }
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

classe:
  t_class t_identificador t_abrichave corpoclasse t_fechachave
corpoclasse:
  %empty
  | tipo t_identificador t_pontovirgula corpoclasse
  | tipo t_abrivetor t_fechavetor t_identificador  t_pontovirgula corpoclasse
  | tipo t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave corpoclasse
  | tipo t_abrivetor t_fechavetor t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave corpoclasse

