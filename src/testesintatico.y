%{
  #include <stdio.h>
  int yylex (void);
  void yyerror (char const *);
  extern FILE *yyout;

  long linha=1;
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
%token <texto> t_palavra t_palavranum 
%token <numero_decimal> t_decimal 
%token <texto> t_nomevariavel t_string

/* Tokens de repetição e condicionais */
%token <texto> t_for t_while t_if t_else t_switch t_case t_default t_break t_abrichave t_fechachave t_abriparentes t_fechaparentes
%token <texto> t_pontovirgula t_virgula t_doispontos t_interrogacao  

/* Tokens classe e função */
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_main

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha

%start programa
%type <texto> programa  mainfuncao 

/* Generate the parser description file. */
%verbose
/* Enable run-time traces (yydebug). */
/*%define parse.trace*/
/*%printer { fprintf (yyo, "%s", $$); } t_main;
%printer { fprintf (yyo, "%s", $$); } t_abriparentes;*/




%% /* Gramática deste ponto para baixo*/
programa:
	mainfuncao | mainfuncao error {printf("Ocorreu um erro\n");}
mainfuncao:
	tipo t_main t_abriparentes parametros t_fechaparentes corpofuncao { printf("função main ok\n");}
parametros:
	%empty
corpofuncao:
	t_abrichave codigo t_fechachave
tipo:
	t_int | t_float | t_char
codigo:
	%empty
%%

#ifdef YYDEBUG
  yydebug = 1;
#endif