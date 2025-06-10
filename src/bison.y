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
%token <texto> t_igual t_mais t_menos t_asteristico t_barra

/* tipos */
%token <texto> t_vetorabri t_vetorfecha

%token <numero_inteiro> t_int 
%token <numero_decimal> t_float 
%token <texto> t_char 


/* valores de atribuição para tipos*/
%token <numero_inteiro> t_num 
%token <texto> t_palavra t_palavranum 
%token <numero_decimal> t_decimal 
%token <texto> t_varname 

/* Tokens de repetição e condicionais */
%token <texto> t_for t_while t_if t_else t_chaveabri t_chavefecha t_parentesabri t_parentesfecha t_pontvirgula 

/* Tokens classe e função */
%token <texto> t_class t_func t_variavel

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha

%start inicio
%type <texto> programa  operadores tipos controle classefuncao valorespermitidos




%% /* Gramática deste ponto para baixo*/
inicio:
  %empty| inicio programa 
programa:
  operadores   {fprintf(yyout, "[%d] Achou um operador (%s)\n", linha, $1);} |
  tipos   {fprintf(yyout, "[%d] Achou um tipo (%g)\n", linha, $1);} | 
  t_int  {fprintf(yyout, "[%d] Achou um t_int (%s)\n", linha, $1);}|
  t_float {fprintf(yyout, "[%d] Achou um t_float (%s)\n", linha, $1);} |
  t_num {fprintf(yyout, "[%d] Achou um t_float (%s)\n", linha, $1);}|
  t_decimal {fprintf(yyout, "[%d] Achou um t_float (%s)\n", linha, $1);}|
  valorespermitidos   {fprintf(yyout, "[%d] Achou um valorespermitidos (%s)\n", linha, $1);}| 
  controle  {fprintf(yyout, "[%d] Achou um controle (%s)\n", linha, $1);} | 
  classefuncao  {fprintf(yyout, "[%d] Achou um classefuncao_outras (%s)\n", linha, $1);}
operadores:
  t_igual | t_mais | t_menos | t_asteristico | t_barra 
tipos:
  t_char | t_vetorabri | t_vetorfecha 
valorespermitidos:
  t_palavra | t_palavranum |  t_varname 
controle:
  t_for | t_while | t_if | t_else | t_chaveabri | t_chavefecha | t_parentesabri | t_parentesfecha | t_pontvirgula 
classefuncao:
  t_class | t_func | t_variavel
%%

