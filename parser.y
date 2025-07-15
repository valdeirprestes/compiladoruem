%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "AST.h"
  #include "simbolo.h"
  #include "parser.tab.h"
  # define YYLTYPE_IS_DECLARED 1
  


  int yylex (YYSTYPE *lval, YYLTYPE *lloc);
  void yyerror ( YYLTYPE *locp, char const *s);
  YYLTYPE yylloc;
	YYSTYPE yylval;
  extern FILE *yyout;
  char **source;
  long coluna_tmp = 0;
  long utoken_linha=0; /* guarda o ultimo linha com token válido -> para erros */
  long utoken_coluna=0;/*guarda a ultima linha com token válido  -> para erros*/
  long linha=1; /* guarda a linha do token atual  -> para erros*/
  long coluna=1;/*guarda a coluna do token atual  -> para erros*/
  int errossintatico = 0;
  long imprimir_ast =0;
  int imprimir_simbolos;
  Nodo *raiz;
  void printErrorsrc(char **source, int linha, int coluna);
  void meudebug(char *texto);
  int debug = 0;
  extern Simbolo *tabelaSimbolos;
	extern char *escopoAtual;
%}


%locations
%define api.location.type {YYLTYPE}
%define parse.error verbose
%define api.pure full
%define parse.lac full

%code requires {
  typedef struct YYLTYPE {
        int first_line;
        int first_column;
        int last_line;
        int last_column;
    } YYLTYPE;
}

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
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_this t_identificadorclasse

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha 

%token <texto> t_and_logico // Para &&
%token <texto> t_or_logico  // Para ||
%token <texto> t_not_logico // Para ! (se não for t_exclamacao)
%token t_global

%token error 

%right t_igual // Atribuição: x = y = z
%left t_or_logico // ||
%left t_and_logico // &&
%left t_igual_a t_diferente_de // ==, !=
%left t_maior t_maior_ou_igual t_menor t_menor_ou_igual // >, >=, <, <=
%left t_mais t_menos // +, -
%left t_asteristico t_barra // *, /

// Adicione operadores lógicos se necessário. Ex:
// %left t_and_logico
// %left t_or_logico

%nonassoc "then"
%nonassoc t_else


%type <nodo> inicio  funcao classe tipofunc tipo
%type <nodo> codigos codigo
%type <nodo> expressao  
%type <nodo> chamada_funcao chamada_metodo corpofuncao 
%type <nodo> parametro parametros 
%type <nodo> declaracoes_comandos 
%type <nodo> blococodigo  comandoif 
%type <nodo> declaracao  comando comandos
%type <nodo> forcomando  parte1for parte2for parte3for blocofor 
%type <nodo> whilecomando blocowhile
%type <nodo> argumento argumentos
%type <nodo> corpoclasse
%type <nodo> comandoswitch corposwitch cases case defaultswitch condicao acesso_vetor
%type <texto> operador_aritmetico_relacional 


%start inicio
%% /* Gramática deste ponto para baixo*/
inicio:
  codigos {
    meudebug("Inicio linha 96"); 
    raiz = $1;
    if(imprimir_ast)
      printNodo(raiz);
    if(imprimir_simbolos)
      gerarTabelaSimbolosDaAST(raiz);
    $$ = raiz;
  }
  | error  {
    meudebug("blococodigo linha 125");
    yyerror(&yylloc, "Erro de sintaxe: o codigo acabou inesperadamente");
    //yyerrok;
    yyclearin;
  }
  ;
codigos:
  codigo{
    meudebug("Codigo linha 105");
    $$ = criarNodoComFilho("CODIGO", TIPO_REGRA, linha, coluna, $1 );
  }
  |codigos codigo{
    meudebug("Codigos Codigo linha 109");
    addFilhoaoNodo($1, $2);
    $$ = $1;
  }
  ;
codigo:
  funcao { 
    meudebug("Codigo linha 116");
    $$ = criarNodoDeclaracao($1, linha, coluna);
    }
  | classe {
    meudebug("Codigo linha 120");
    $$ = criarNodoDeclaracao($1, linha, coluna);
    }
  | t_global declaracao t_pontovirgula{
    meudebug("Codigo linha 120");
    $$ = $2; //criarNodoDeclaracao($2, linha, coluna);
    }
  ;

funcao:
	tipofunc t_identificador t_abriparentes parametros t_fechaparentes corpofuncao {
      meudebug("Funcao linha 147");
      $$ = criarNodoFuncao($2, $1, $4, $6 ,linha, coluna);
  }
  | t_identificador error {
    meudebug("Funcao linha 151");
    //--yyerrstatus;
    yyerror(&yylloc, "Erro de sintaxe: esperava tipagem da funcao");
    yyclearin;
  }
  | t_abrivetor error {
    meudebug("Funcao linha 157");
    //--yyerrstatus;
    yyerror(&yylloc, "Erro de sintaxe: esperava tipagem da funcao");
    //yyerrok;
    yyclearin;
  }
  
  | tipofunc t_identificador parametros error t_fechachave {
    meudebug("Funcao linha 170");
    yyerror(&yylloc, "Erro de sintaxe: esperava \'(\' na declaração anterior ");
    //yyerrok;
    yyclearin;
  }
  | tipofunc t_identificador t_abriparentes t_identificador error  {
    meudebug("Funcao linha 176");
    yyerror(&yylloc, "Erro de sintaxe: esperava tipo do parametro ");
    //yyerrok;
    yyclearin;
  }
  | tipofunc t_identificador t_abriparentes parametros t_abrichave error t_fechaparentes  {
    meudebug("Funcao linha 179");
    yyerror(&yylloc, "Erro de sintaxe: esperava tipo \')\' ");
    //yyerrok;
    yyclearin;
  }
  | tipofunc t_identificador t_abriparentes parametros t_abrichave error t_fechachave  {
    meudebug("Funcao linha 185");
    yyerror(&yylloc, "Erro de sintaxe: declaracao incompleta, um \'}\' inesperado");
    //yyerrok;
    yyclearin;
  }
 ;
tipofunc:
  tipo {
    meudebug("TipoFunc linha 139");
    $$ = $1; 
  }
  |tipo t_abrivetor t_fechavetor { meudebug("TipoFunc linha 141"); $$ = $1;}
  ;
 
parametros:
  %empty { $$ = NULL;}
	|parametro  {
      meudebug("Parametros linha 196");
      Nodo *p =criarNodoDeclaracao($1,  linha, coluna);
      $$ = criarNodoComFilho("Parametros", TIPO_PARAMETROS, linha, coluna, p);
  }
| parametros t_virgula parametro {
      meudebug("Parametros linha 200");
      Nodo *p =criarNodoDeclaracao($3,  linha, coluna);
      $$= addRecursivoNodo("Parametros", TIPO_PARAMETROS, linha, coluna, $1, p);
  }
  | parametros error t_virgula {
    meudebug("Parametros linha 204");
    yyerror(&yylloc, "Erro de sintaxe: esperava tipo \';\' ");
    //yyerrok;
    yyclearin;
  }
  ;
parametro:
  tipo t_identificador {
    meudebug("Parametro linha 162");
    //$$ = criarNodoComFilho($2, TIPO_IDENTIFICADOR, linha, coluna,$1);
    $$ = criarNodoIdentificador($2, TIPO_IDENTIFICADOR, linha, coluna, $1);
  }
  |tipo  t_identificador t_abrivetor t_fechavetor
  {
    meudebug("Parametro linha 167");
    $$ = criarNodoComFilho($4, TIPO_IDENTIFICADOR, linha, coluna, $1);
  }
  ;
tipo:
  t_int { meudebug("Tipo linha 172"); $$ = criarNodo($1, TIPO_INT, linha, coluna); }
  | t_float {meudebug("Tipo linha 173"); $$ = criarNodo($1, TIPO_FLOAT, linha, coluna); }
  | t_char  {meudebug("Tipo linha 174"); $$ = criarNodo($1, TIPO_CHAR, linha, coluna);}
  | t_identificador {meudebug("Tipo linha 175"); $$ = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna); }
  ;
  
corpofuncao:
  t_abrichave declaracoes_comandos t_fechachave {
   meudebug("CorpoFuncao linha 180");
   $$ = $2;
  }
  |t_abrichave declaracoes_comandos t_pontovirgula  error t_fechachave {
    meudebug("CorpoFuncao linha 234");
    yyerror(&yylloc, "Erro de sintaxe: caractere \'}\' inesperado ");
    //yyerrok;
    yyclearin;
  }
  |t_abrichave declaracoes_comandos  error t_fechachave {
    meudebug("CorpoFuncao linha 252");
    yyerror(&yylloc, "Erro de sintaxe: faltou um \'{\' ou teve um tem \'}\' excedente");
    //yyerrok;
    yyclearin;
  }
  ;
declaracoes_comandos:
  %empty { 
      meudebug("Declaracoes_comandos vazio linha 201");
      $$ = NULL; 
  }
  | declaracoes_comandos declaracao t_pontovirgula {
      meudebug("Declaracoes_comandos declaracao linha 204");
      $$ = addRecursivoNodo("Bloco", TIPO_BLOCO, linha, coluna, $1, $2);
  }
  | declaracoes_comandos comando {
      meudebug("Declaracoes_comandos comando linha 215");
      $$ = addRecursivoNodo("Bloco", TIPO_BLOCO, linha, coluna, $1, $2);
  }
  |declaracoes_comandos  error t_pontovirgula {
    meudebug("Declaracoes_comandos error t_pontovirgula linha 272");
    yyerror(&yylloc, "Erro de sintaxe:  faltou declaracao, pois veio um \';\' inesperado");
    yyclearin;
  }
  |declaracoes_comandos  t_while error {
    meudebug("Declaracoes_comandos t_while error linha 277");
    yyerror(&yylloc, "Erro de sintaxe:  while mal declarado");
    yyclearin;
    //yyerrok;
   }
   |declaracoes_comandos  t_for error {
    meudebug("Declaracoes_comandos t_for error linha 283");
    yyerror(&yylloc, "Erro de sintaxe:  for mal declarado");
    yyclearin;
    //yyerrok;
   }
;



comandos:
    comandos comando 
    {
      meudebug("Comandos linha 213");
      addFilhoaoNodo($1, $2);
      $$ = $1;
    }
  | comando {
      meudebug("Comandos linha 218");
      $$ = criarNodoComFilho("Comandos", TIPO_BLOCO, linha, coluna, $1);
    }
;

declaracao: 
  tipo t_identificador {
      meudebug("Declaracao: tipo t_identificador linha 225");
      Nodo *n = criarNodoIdentificador($2, TIPO_IDENTIFICADOR, linha, coluna, $1);
      $$ = criarNodoDeclaracao(n, linha, coluna);
      

  }
  |tipo t_identificador t_igual expressao {
      meudebug("Declaracao: tipo t_identificador t_igual expressao linha 229");
      Nodo *n = criarNodo($2, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo($1, $4);
      $$ = criarExpOperador( $3, n, $1, linha, coluna );
      //$$ = criarNodoDeclaracao(n, linha, coluna);
      
  }
  | t_identificador t_igual expressao {
      meudebug("Declaracao: t_identificador t_igual expressao linha 229");
      Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
      $$ = criarExpOperador( $2, n, $3, linha, coluna );
  }
  |tipo  t_identificador t_abrivetor t_fechavetor {
      meudebug("Declaracao linha 236");
      $$ = criarNodoComFilho($2, TIPO_IDENTIFICADOR, linha, coluna, $1);
  }
  |acesso_vetor t_igual expressao {
      meudebug("Declaracao: tipo t_identificador t_igual expressao linha 229");
      $$ = criarExpOperador( $2, $1, $1, linha, coluna );
  }
  |acesso_vetor t_igual acesso_vetor {
    meudebug("Declaracao: tipo t_identificador t_igual expressao linha 229");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  |t_identificador t_igual acesso_vetor {
      meudebug("Declaracao: tipo t_identificador t_igual expressao linha 229");
      Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
      $$ = criarExpOperador( $2, n, $3, linha, coluna );
  }
  ;
  
comando:
  comandoif {
    meudebug("Comando linha 283");
    $$ = $1;
  }
  | comandoswitch { meudebug("Comando linha 247"); $$ = $1; }
  | forcomando { meudebug("Comando linha 248"); $$ = $1;} 
  | whilecomando {meudebug("Comando linha 249");$$ = $1;} 
  | expressao t_pontovirgula { meudebug("Comando linha 250");
    $$ = $1;
  }
  | t_return expressao t_pontovirgula {  
      meudebug("Comando linha 254");
      $$ = criarNodoComFilho("Expressao", TIPO_RETURN , linha, coluna, $2);
  }
  | t_break t_pontovirgula {
      meudebug("Comando linha 258");
      $$ = criarNodo($1 , TIPO_BREAK , linha, coluna);
  }
  ;
comandoswitch:
  t_switch t_abriparentes expressao t_fechaparentes  t_abrichave corposwitch t_fechachave{
      meudebug("ComandoSwitch linha 264");
      Nodo *n = criarNodo($1 , TIPO_SWICTH , linha, coluna);
      addFilhoaoNodo(n, $3);
      addFilhoaoNodo($3, $6);
      $$ = n;
  }
  ;
corposwitch:
  cases { meudebug("CorpoSwitchlinha 272"); $$ =  $1; };
  | cases defaultswitch {
    meudebug("CorpoSwitch linha 274");
    $$ = addRecursivoNodo("BlocoCase", TIPO_BLOCO, linha, coluna, $1, $2);
  };
  ;
cases:
  case {
    meudebug("Cases linha 280");
    $$ = criarNodoComFilho("BlocoCase" , TIPO_BLOCO , linha, coluna, $1);
  }
  |cases case {
    meudebug("Cases case linha 284");
    $$ = addRecursivoNodo("BlocoCase", TIPO_BLOCO, linha, coluna, $1, $2);
  }
  ;
case:
  t_case expressao t_doispontos comandos {
    meudebug("Case linha 290");
    Nodo *n = criarNodo($1 , TIPO_CASE , linha, coluna);
    addFilhoaoNodo(n, $2);
    addFilhoaoNodo(n, $4);
    $$ = n;
  };
  |t_case expressao t_doispontos t_abrichave comandos t_fechachave {
    meudebug("Case linha 297");
    Nodo *n = criarNodo($1 , TIPO_CASE , linha, coluna);
    addFilhoaoNodo(n, $2);
    addFilhoaoNodo(n, $5);
    $$ = n;
  }
  ;
defaultswitch:
  t_default  t_doispontos comandos {
    meudebug("DefaultSwitch linha 306");
    $$ = criarNodoComFilho($1 , TIPO_DEFAULT , linha, coluna, $3);
  };
  |t_default  t_doispontos t_abrichave comandos t_fechachave {
    meudebug("DefaultSwitch linha 306");
    $$ = criarNodoComFilho($1 , TIPO_DEFAULT , linha, coluna,$4);
  };
comandoif:
  t_if t_abriparentes condicao t_fechaparentes  blococodigo %prec "then" {
    meudebug("Comandoif linha 315");
    Nodo *n = criarNodo($1 , TIPO_IF, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  }
  | t_if t_abriparentes condicao t_fechaparentes  blococodigo t_else blococodigo{
    meudebug("Comandoif linha 322");
    Nodo *n = criarNodo("ifelse" , TIPO_IFELSE, linha, coluna);
    Nodo *n1 = criarNodo($1 , TIPO_IFELSE, linha, coluna);
    Nodo *n2 = criarNodo($6 , TIPO_IFELSE, linha, coluna);
    addFilhoaoNodo(n, $5);
    addFilhoaoNodo(n, $7);
    $$ = n;
  }
  |t_if t_abriparentes t_fechaparentes  error t_fechachave {
    meudebug("comandoif linha 395");
    yyerror(&yylloc, "Erro de sintaxe: esperava argumentos ");
    //yyerrok;
    yyclearin;
  }
  ;
argumentos:
  %empty { $$ = NULL;}
  | argumento {
      meudebug("Argumentos linha 393");
      $$ = criarNodoComFilho("Argumentos", TIPO_IDENTIFICADOR, linha, coluna, $1);
  }
  | argumentos t_virgula argumento {
      meudebug("Argumentos linha 338");
      $$ = addRecursivoNodo("Argumentos", TIPO_IDENTIFICADOR,  linha,  coluna, $1, $3);
  }
  ;
argumento:
  expressao {
    meudebug("Argumento linha 344");
    $$ = $1;
  }
  ;
forcomando:
  t_for t_abriparentes parte1for t_pontovirgula parte2for t_pontovirgula parte3for t_fechaparentes blocofor{
    meudebug("ForComando linha 354");
    Nodo *n = criarNodo($1, TIPO_FOR, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    addFilhoaoNodo(n, $7);
    addFilhoaoNodo(n, $9);
    $$ = n;
  }
  |t_for t_abriparentes parte1for t_pontovirgula parte2for t_pontovirgula parte3for t_fechaparentes  error  {
    meudebug("blococodigo linha 510");
    yyerror(&yylloc, "Erro de sintaxe: esperava tipo \'}\' ");
    //yyerrok;
    yyclearin;
  }
  ;

parte1for:
  %empty {meudebug("Parte1For linha 392"); $$ = NULL;}
  | t_identificador t_igual expressao { 
    meudebug("Parte1For linha 394");
    $$ = criarNodoComFilho($1, TIPO_IDENTIFICADOR, linha, coluna, $3);
  } 
  | tipo t_identificador t_igual expressao { 
    meudebug("Parte1For linha 394");
    $$ = criarNodoComFilho($2, TIPO_IDENTIFICADOR, linha, coluna, $4);
    addFilhoaoNodo($4, $1);
  } 
  ;

  
parte2for:
  condicao { meudebug("Parte2For condicao linha 179"); $$ = $1;}
  |error t_identificador{
    meudebug("Parte2For error t_identificador linha 179");
    yyerror(&yylloc, "Erro de sintaxe: esperava um variavel \')\' ");
  };

parte3for:
  declaracao{meudebug("parte3For declaracao linha 179"); $$ = $1;}
  |comando {meudebug("parte3For declaracao linha 179"); $$= $1;}
;
blocofor:
  t_pontovirgula {$$=NULL;}
  |blococodigo { meudebug("BlocoFor blococodigo linha 487"); $$ = $1;}
  ;
blococodigo:
  comando  {
      meudebug("blococodigo comando linha 449");
      //printf("479 Corpo while simples -> %s line %d\n", $1->nome, $1->linha);
      $$ = criarNodoComFilho("BLOCO", TIPO_BLOCO, linha, coluna, $1);
  }
  |declaracao t_pontovirgula{
      meudebug("blococodigo declaracao linha 449");
      //printf("479 Corpo while simples -> %s line %d\n", $1->nome, $1->linha);
      $$ = criarNodoComFilho("BLOCO", TIPO_BLOCO, linha, coluna, $1);
  }
  | t_abrichave declaracoes_comandos t_fechachave {
    meudebug("blococodigo t_abrichave declaracoes_comandos t_fechachave  linha 456");
    Nodo *n = criarNodo("BLOCO", TIPO_BLOCO, linha, coluna);
    addFilhoaoNodo(n, $2);
    $$ = n;
  }
  ;
chamada_funcao:
  t_identificador t_abriparentes argumentos t_fechaparentes {
    meudebug("Chamada_funcao linha 464");
    Nodo *n = criarNodo($1 , TIPO_CHAMADA_FUNCAO, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  | t_identificador t_abriparentes argumentos  error { printf("ERRO em chamada_funcao");}
  ;
chamada_metodo:
  t_identificadorclasse t_abriparentes argumentos t_fechaparentes { 
    meudebug("ChamadaMetodo linha 473");
    Nodo *n = criarNodo($1 , TIPO_CHAMADA_METODO, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  ;
whilecomando:
  t_while t_abriparentes condicao t_fechaparentes blocowhile{
    meudebug("WhileComando linha 481");
    Nodo *n = criarNodo($1, TIPO_WHILE, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  }
  | t_while error t_fechaparentes {
    meudebug("Funcao linha 179");
    yyerror(&yylloc, "Erro de sintaxe: faltou definir corretamente a condicao da while ");
    yyclearin;
    //yyerrok;
  };
  ;
blocowhile:
  t_pontovirgula { $$ = NULL;}
  |blococodigo { $$ = $1;}
operador_aritmetico_relacional:
   t_igual_a
  | t_diferente_de
  | t_maior
  | t_maior_ou_igual
  | t_menor
  | t_menor_ou_igual

;
expressao:
  expressao t_mais expressao {
    meudebug("Condicao linha 521");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }; 
  | expressao t_menos expressao {
    meudebug("Condicao linha 521");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | expressao t_asteristico expressao {
    meudebug("Condicao linha 521");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | expressao t_barra expressao {
    meudebug("Condicao linha 521");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | t_abriparentes expressao t_fechaparentes { $$ = $2;  }
  |t_identificador 
  {
    meudebug(" Expressao linha 566");
    Tipo tipo = TIPO_IDENTIFICADOR;
    Nodo *n = criarNodo($1, tipo, linha, coluna);
    $$ = n;
  }
  | t_decimal
  {
    Tipo tipo = TIPO_DECIMAL;
    meudebug("Expressao linha 574");
    Nodo *n = criarNodo(
      $1, tipo, linha, coluna);
    $$ = n;
  } 
  | t_num 
  {
    Tipo tipo = TIPO_INTEIRO;
    Nodo *n = criarNodo($1, tipo, linha, coluna);
    $$ = n;
  }
  | t_string
  {
    meudebug("linha 479");
    Tipo tipo = TIPO_STRING;
    Nodo *n = criarNodo(
      $1, tipo, linha, coluna);
    $$ = n;
  }
  | chamada_funcao { $$ = $1; };
  | chamada_metodo { $$ = $1;} ;
  | t_abriparentes  t_fechaparentes error {
    meudebug("Expressao linha 650");
    yyerror(&yylloc, "Erro de sintaxe: faltou um variavel ou expressao ");
    //yyerrok;
    yyclearin;
  }
  ;
acesso_vetor:
  t_identificador t_abrivetor expressao t_abrivetor
  {
    meudebug(" Expressao linha 566");
    Nodo *vetor = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
    $$ = criarNodoComFilho($1, TIPO_IDENTIFICADOR, linha, coluna,vetor);
  }

condicao:
   expressao t_or_logico expressao {
    meudebug("Condicao expressao t_or_logico expressao linha 521");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
   }
  | expressao t_and_logico expressao {
    meudebug("Condicao expressao t_and_logico expressao linha 521");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  |expressao operador_aritmetico_relacional expressao {
    meudebug("Condicao expressao operador_aritmetico_relacional expressao linha 521");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | t_not_logico condicao { 
    meudebug("Condicao linha 731");
    $$ = criarNodoComFilho("Negacao", TIPO_OP_NEGACAO , linha, coluna, $2);
  }
  | expressao { $$ = $1; }
  ;

classe:
  t_class t_identificador t_abrichave corpoclasse t_fechachave { 
    meudebug("linha 731");
    Nodo *n = criarNodo($2, TIPO_CLASSE , linha, coluna);
    addFilhoaoNodo(n, $4);
    $$ = n;
   }
  ;
corpoclasse:
  %empty { $$ = NULL;}
  | corpoclasse tipo t_identificador t_pontovirgula  {
    meudebug("linha 740");
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo("CorpoClasse", TIPO_BLOCO, linha, coluna);  
    Nodo *n = criarNodo($3, TIPO_IDENTIFICADORCLASSE, linha, coluna);
    addFilhoaoNodo(nodo, n);
    $$ = nodo;
  }
  | corpoclasse tipo t_identificador t_abrivetor t_fechavetor   t_pontovirgula{
    meudebug("linha 751");
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo("CorpoClasse", TIPO_BLOCO, linha, coluna);

    Nodo *n = criarNodo($3, TIPO_IDENTIFICADORCLASSE, linha, coluna);
    Nodo *n2 = criarNodo("Vetor", TIPO_VETOR, linha, coluna);
    addFilhoaoNodo(nodo, n);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, $2);
    $$ = nodo;
  }
  | corpoclasse tipo t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave 
  {
    meudebug("linha 767");
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo("CorpoClasse", TIPO_BLOCO, linha, coluna);
    Nodo *n = criarNodo($3 , TIPO_METODOCLASSE , linha, coluna);
    addFilhoaoNodo(nodo, n);
    addFilhoaoNodo(n, $2);
    addFilhoaoNodo(n, $5);
    $$ = nodo;
  };
  | corpoclasse tipo t_abrivetor t_fechavetor t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave 
  {
    meudebug("linha 781");
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo("CorpoClasse", TIPO_BLOCO, linha, coluna);
    Nodo *n = criarNodo($5 , TIPO_METODOCLASSE , linha, coluna);
    Nodo *n2 = criarNodo("Vetor" , TIPO_VETOR , linha, coluna);
    addFilhoaoNodo(nodo, n);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, $7);
    addFilhoaoNodo(n2, $10);
    $$ = nodo;
  }
  ;
