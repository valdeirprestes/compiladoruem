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
%token t_for t_while t_if t_else t_chaveabri t_chavefecha t_parentesabri t_parentesfecha t_pontvirgula 

/* Tokens classe e função */
%token t_class t_func t_variavel

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco 






%% /* Gramática deste ponto para baixo*/
inicio:
  %empty| inicio programa 
programa:
  t_espaco | meustokens t_espaco
meustokens:
  operadores   {fprintf(yyout, "Achou um operador\n");} |
  tipos   {fprintf(yyout, "Achou um tipo\n");} | 
  valorespermitidos   {fprintf(yyout, "Achou um valorespermitidos\n");}| 
  controle  {fprintf(yyout, "Achou um controle\n");} | 
  classefuncao  {fprintf(yyout, "Achou um classefuncao_outras\n");}
operadores:
  t_igual | t_mais | t_menos | t_asteristico | t_barra 
tipos:
  t_int | t_float  | t_char | t_vetorabri | t_vetorfecha 
valorespermitidos:
  t_num | t_palavra | t_palavranum | t_decimal | t_varname 
controle:
  t_for | t_while | t_if | t_else | t_chaveabri | t_chavefecha | t_parentesabri | t_parentesfecha | t_pontvirgula 
classefuncao:
  t_class | t_func | t_variavel
%%

