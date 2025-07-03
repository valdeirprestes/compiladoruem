%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "AST.h"
  int yylex (void);
  void yyerror (char const *);
  extern FILE *yyout;

  long linha=1;
  long coluna=1;
  long coluna_tmp = 0;
  int errossintatico = 0;
%}

%union{
  char* texto;
  Nodo *nodo;
}

/* operadores lógicos */
%token <texto> t_mais t_menos t_asteristico t_barra

%token <texto> t_maior t_menor t_igual t_exclamacao
%token <texto> t_igual_a t_diferente_de t_menor_ou_igual t_maior_ou_igual

/* tipos */
%token <texto> t_abrivetor t_fechavetor t_int t_float t_char


/* valores de atribuição para tipos*/
%token <texto> t_num 
%token <texto> t_identificador
%token <texto> t_decimal 
%token <texto> t_string t_eof

/* Tokens de repetição e condicionais */
%token <texto> t_for t_while t_if t_else t_switch t_case t_default t_break t_abrichave t_fechachave t_abriparentes t_fechaparentes
%token <texto> t_pontovirgula t_virgula t_doispontos t_interrogacao  t_ponto

/* Tokens classe e função */
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_this t_variavelclasse

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha 

 

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

%nonassoc "then"
%nonassoc t_else


%type <nodo> inicio codigos codigo funcao classe tipofunc tipo parametro atributo
%start inicio
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
  t_int | t_float | t_char | t_identificador
corpofuncao:
  t_abrichave declaracoes_comandos t_fechachave
declaracoes_comandos:
  %empty
  | declaracao t_pontovirgula
  | declaracao t_pontovirgula declaracoes { printf("declaracao t_pontovirgula declaracoes linha %d coluna %d\n", linha, coluna);}
  | declaracao t_pontovirgula comandos { printf("declaracao t_pontovirgula comandos linha %d coluna %d\n", linha, coluna);}
  | comando { printf("comando  linha %d coluna %d\n", linha, coluna);}
  | comando declaracoes { printf("comando declaracoes linha %d coluna %d\n", linha, coluna);}
  | comando comandos { printf("comando comandos linha %d coluna %d\n", linha, coluna);}
declaracoes:
  declaracao t_pontovirgula
  |declaracao t_pontovirgula  comandos
  |declaracao t_pontovirgula declaracoes
declaracao:
  tipo t_identificador
  |tipo t_identificador t_igual expressao
  |tipo  t_abrivetor t_fechavetor t_identificador
comandos:
  comando { printf("{comando} comandos linha %d coluna %d\n", linha, coluna);}
  | comando comandos { printf("{comando} comandos linha %d coluna %d\n", linha, coluna);}
  | comando declaracoes
  | comando error { printf("ERROR {comando} chamada_funcao linha %d coluna %d\n", linha, coluna);}
comando:
  comandoif
  | comandoswitch
  | forcomando 
  | whilecomando 
  | atribuicao t_pontovirgula
  | t_return expressao t_pontovirgula
  | t_break t_pontovirgula
comandoswitch:
  t_switch t_abriparentes atributo t_fechaparentes  t_abrichave corposwitch t_fechachave
corposwitch:
  cases
  | cases defaultswitch
cases:
  case
  |case cases
case:
  t_case atributo t_doispontos comandos
  |t_case atributo t_doispontos t_abrichave comandos t_fechachave

defaultswitch:
  t_default  t_doispontos comandos
  |t_default  t_doispontos t_abrichave comandos t_fechachave
comandoif:
  t_if t_abriparentes testeboleano t_fechaparentes  corpoloop %prec "then"
  | t_if t_abriparentes testeboleano t_fechaparentes  corpoloop t_else corpoloop

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
  | expressao
   
atributo:
  t_identificador 
  {
    Tipo tipo = TIPO_VARIAVEL;
    Nodo *n = valorNodo(tipo , $1 );
    $$ = n;
  }
  | t_decimal
  {
    Tipo tipo = TIPO_DECIMAL;
    Nodo *n = valorNodo(tipo , $1 );
    $$ = n;
  } 
  | t_num 
  {
    Tipo tipo = TIPO_INTEIRO;
    Nodo *n = valorNodo(tipo , $1 );
    $$ = n;
  }
  | t_string
  {
    Tipo tipo = TIPO_STRING;
    Nodo *n = valorNodo(tipo , $1 );
    $$ = n;
  }
  | chamada_funcao {
    Tipo tipo = TIPO_CHAMADA_FUNCAO;
    Nodo *n = $1;
    $$ = n;
  }
  | chamada_metodo {
    Tipo tipo = TIPO_CHAMADA_METODO;
    Nodo *n = $1;
    $$ = n;
  }
  | t_identificador t_ponto t_identificador
  | t_identificador t_ponto t_identificador t_abriparentes t_fechaparentes
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
  comando
  | t_abrichave comandos t_fechachave
chamada_funcao:
  t_identificador t_abriparentes argumentos t_fechaparentes
  | t_identificador t_abriparentes argumentos t_fechaparentes error { printf("ERRO em chamada_funcao");}
chamada_metodo:
  t_variavelclasse t_abriparentes argumentos t_fechaparentes

whilecomando:
  t_while t_abriparentes expressao t_fechaparentes corpowhile
corpowhile:
  corpoloop
  | error {
      errossintatico += 1; 
      yyerror; printf("ERRO: corpo do while incorreto\n");
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

