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
%type <texto> programa  operadores tipo controle classefuncao valorespermitidos comparacao retorno






%% /* Gramática deste ponto para baixo*/
programa:
	mainfuncao | outroscodigos mainfuncao outroscodigos
mainfuncao:
	tipo t_main t_abriparentes parametros t_fechaparentes corpofuncao
codigos:
	codigo retorno | codigos codigo retorno
retorno:
	%empty | t_return valor
tipo:
  t_char | t_int | t_float 
valor:
	tipoaceito | t_nomevariavel
tipoaceito:
	t_num  | t_palavra | t_palavranum | t_decimal | t_string
codigo:
	%empty | declaracoes controles | atribuicoes
declaracoes:
	declaracao t_pontovirgula | declaracoes t_virgula declaracao t_pontovirgula
declaracao:
	%empty | tipo t_nomevariavel
controles:
	controle | controles controle
controle:
	controleif | controleternario | controlefor | controlewhile | controleswitch
controleif:
	%empty |
	t_if t_abriparentes expressaoteste t_fechaparentes corpofuncao
	t_if t_abriparentes expressaoteste t_fechaparentes codigo
expressaoteste:
	valor | comparacao
comparacao:
	t_exclamacao exp_comparacao | exp_comparacao
exp_comparacao:
	exp_comp | t_abriparentes exp_comp t_fechaparentes 
exp_comp:
	valor t_igual t_igual valor |
	valor t_maior t_igual valor |
	valor t_menor t_igual valor |
	t_exclamacao expressaoteste
controleternario:
	expressaoteste t_interrogacao valor t_doispontos valor t_pontovirgula
controlefor:
	t_for t_abriparentes declaracao t_pontovirgula expressaoteste t_pontovirgula atribuicoes codigo
	t_for t_abriparentes declaracao t_pontovirgula expressaoteste t_pontovirgula atribuicoes corpofuncao
controlewhile:
	t_while t_abriparentes expressaoteste t_fechaparentes codigo |
	t_while t_abriparentes expressaoteste t_fechaparentes corpofuncao
controleswitch:
	t_switch t_abriparentes expressaoteste t_fechaparentes t_abrichave cases t_fechachave
cases:
	casedefault | caseopt casedefault
casedefault:
	t_default valor t_doispontos 
caseopt:
	case | caseopt case
case:
	t_case valor t_doispontos valor |
	t_case valor t_doispontos codigo
atribuicoes:
	atribuicao | atribuicoes atribuicao
atribuicao:
	t_nomevariavel t_igual valor 
outroscodigos:
	outrocodigo | outroscodigos outrocodigo
outrocodigo:
	funcoes classe
funcoes:
	funcao | funcoes funcao
funcao:
	%empty | tipo t_nomevariavel t_abriparentes parametrosfunc t_fechaparentes corpofuncao
parametrosfunc:
	parametro  | parametro t_virgula parametros 
parametros:
	parametro  | parametro t_virgula parametros 
parametro:
	tipo t_nomevariavel 
corpofuncao:
	t_abrichave codigos t_fechachave
classe:
	t_class t_nomevariavel t_abrichave corpoclasse t_fechachave
corpoclasse:
	metodoconstrutor metododestrutor outrosmetodos
outrosmetodos:
	metodo | outrosmetodos metodo
metodoconstrutor:
	%empty | tipo t_nomevariavel t_abriparentes parametrosfunc t_fechaparentes corpofuncao
metododestrutor:
	%empty | tipo t_nomevariavel t_abriparentes parametrosfunc t_fechaparentes corpofuncao
metodo:
	%empty | tipo t_nomevariavel t_abriparentes parametrosfunc t_fechaparentes corpofuncao
operadores:
	t_igual | t_mais | t_menos | t_asteristico | t_barra
%%

