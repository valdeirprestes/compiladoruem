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
%token <texto> t_varname 

/* Tokens de repetição e condicionais */
%token <texto> t_for t_while t_if t_else t_switch t_case t_default t_break t_abrichave t_fechachave t_abriparentes t_fechaparentes
%token <texto> t_pontovirgula t_doispontos t_interrogacao  

/* Tokens classe e função */
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha

%start inicio
%type <texto> programa  operadores tipos controle classefuncao valorespermitidos comparacao




%% /* Gramática deste ponto para baixo*/
inicio:
  %empty| inicio programa 
programa:
  comparacao {fprintf(yyout, "[%d] Achou um operador (%s)\n", linha, $1);} |
  operadores   {fprintf(yyout, "[%d] Achou um operador (%s)\n", linha, $1);} |
  tipos   {fprintf(yyout, "[%d] Achou um tipo (%s)\n", linha, $1);} | 
  t_num {fprintf(yyout, "[%d] Achou um t_float (%d)\n", linha, $1);}|
  t_decimal {fprintf(yyout, "[%d] Achou um t_float (%f)\n", linha, $1);}|
  valorespermitidos   {fprintf(yyout, "[%d] Achou um valorespermitidos (%s)\n", linha, $1);}| 
  controle  {fprintf(yyout, "[%d] Achou um controle (%s)\n", linha, $1);} | 
  classefuncao  {fprintf(yyout, "[%d] Achou um classe_funcao_variavel (%s)\n", linha, $1);}
operadores:
  t_mais | t_menos | t_asteristico | t_barra
comparacao:
  t_igual | t_maior | t_menor | t_exclamacao
tipos:
  t_char | t_int | t_float  | t_abrivetor | t_fechavetor 
valorespermitidos:
  t_palavra | t_palavranum |  t_varname | t_variavel
controle:
  t_for | t_while | t_if | t_else | t_switch | t_case | t_default | t_break | t_abrichave | t_fechachave | 
  t_abriparentes | t_fechaparentes | t_pontovirgula | t_interrogacao | t_doispontos
classefuncao:
  t_class | t_func | t_construtor| t_destrutor | t_return
%%

