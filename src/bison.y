%{
  #include <stdio.h>
  int yylex (void);
  void yyerror (char const *);
  extern FILE *yyout;
%}
/* operadores lógicos */
%token t_igual t_mais t_menos t_asteristico t_barra

/* tipos */
%token t_int t_float t_char t_vetorabri t_vetorfecha

/* valores de atribuição para tipos*/
%token t_num t_palavra t_palavranum t_decimal t_varname 

/* Tokens de repetição e condicionais */
%token t_for t_while t_if t_else t_chaveabri t_chavefecha t_parentesabri t_parentesfecha t_pontvirgula t_novalinha

/* Tokens classe e função */
%token t_class t_func

%% /* Gramática deste ponto para baixo*/
inicio:
  %empty| inicio programa 
programa:
  operadores t_novalinha  {fprintf(yyout, "Achou um operador\n");} |
  tipos t_novalinha  {fprintf(yyout, "Achou um tipo\n");} | 
  valorespermitidos t_novalinha  {fprintf(yyout, "Achou um valorespermitidos\n");}| 
  controle t_novalinha {fprintf(yyout, "Achou um controle\n");} | 
  classefuncao t_novalinha {fprintf(yyout, "Achou um clasefuncao\n");}
operadores:
  t_igual | t_mais | t_menos | t_asteristico | t_barra 
tipos:
  t_int | t_float  | t_char | t_vetorabri | t_vetorfecha 
valorespermitidos:
  t_num | t_palavra | t_palavranum | t_decimal | t_varname 
controle:
  t_for | t_while | t_if | t_else | t_chaveabri | t_chavefecha | t_parentesabri | t_parentesfecha | t_pontvirgula | t_novalinha 
classefuncao:
  t_class | t_func 
%%

