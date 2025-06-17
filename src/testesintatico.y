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
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_main

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




%% /* Gramática deste ponto para baixo*/
programa:
  codigos 
codigos:
  %empty |
  codigo codigos |   
  codigo error { yyerror; printf("erro de sintaxe\n");} 
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
tipo:
  t_int | t_float | t_char
corpofuncao:
  %empty | 
	t_abrichave declaracoes comandos t_fechachave
declaracoes:
  %empty |
  declaracao t_pontovirgula | declaracao  t_virgula declaracoes
declaracao:
  tipo t_identificador | tipo  t_abrivetor t_fechavetor t_identificador
comandos:
  %empty
classe:
  t_class t_identificador t_abrichave corpoclasse t_fechachave
corpoclasse:
  %empty