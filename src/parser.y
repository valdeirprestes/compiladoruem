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





%token error 

%right t_igual // Atribuição: x = y = z
%left t_or_logico // ||
%left t_and_logico // &&
%left t_igual_a t_diferente_de // ==, !=
%left t_maior t_maior_ou_igual t_menor t_menor_ou_igual // >, >=, <, <=
%left t_mais t_menos // +, -
%left t_asteristico t_barra // *, /


%left t_identificador
%left t_abrivetor
%left t_fechavetor
// Adicione operadores lógicos se necessário. Ex:
// %left t_and_logico
// %left t_or_logico

%nonassoc "then"
%nonassoc t_else


%type <nodo> inicio  classe tipo funcao
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
    /*if(imprimir_ast)
      printNodo(raiz);
    if(imprimir_simbolos)
      gerarTabelaSimbolosDaAST(raiz);*/
    $$ = raiz;
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
  classe {
    meudebug("Codigo linha 120");
    $$ = $1;
  }
 |funcao  {
    meudebug("Codigo linha 120");
    $$ = $1;
  }
 | declaracao t_pontovirgula{ 
  $$ = $1;
 }
 ;
  

 
parametros:
  %empty { $$ = NULL;}
	|parametro  {
      meudebug("Parametros linha 196");
      $$ = criarNodoComFilho("Parametros", TIPO_PARAMETROS, linha, coluna, $1);
  }
| parametros t_virgula parametro {
      meudebug("Parametros linha 200");
      $$= addRecursivoNodo("Parametros", TIPO_PARAMETROS, linha, coluna, $1, $3);
  }
  ;
parametro:
  tipo t_identificador {
    meudebug("Parametro linha 162");
    Nodo *p =criarNodoParametro($1,  linha, coluna);
    Nodo* id= criarNodo($2, TIPO_ID, linha, coluna);
    addFilhoaoNodo(p,id);
    if(id) id->tipo_id = $1->tipo;
    $$ = p;
  }
  |tipo  t_identificador t_abrivetor t_fechavetor
  {
    meudebug("Parametro linha 167");
    Nodo* vetor= criarNodo("Vetor", TIPO_VETOR, linha, coluna);
    Nodo *p =criarNodoParametro(vetor,  linha, coluna);
    Nodo* id= criarNodo($2, TIPO_ID, linha, coluna);
    addFilhoaoNodo(vetor,$1);
    addFilhoaoNodo(p,id);
    if(id) id->tipo_id = TIPO_VETOR;
    if(id) id->tipo_vetor = $1->tipo;
    $$ = p;
  }
  ;
tipo:
  t_int { meudebug("Tipo linha 172"); $$ = criarNodo($1, TIPO_INT, linha, coluna); }
  | t_float {meudebug("Tipo linha 173"); $$ = criarNodo($1, TIPO_FLOAT, linha, coluna); }
  | t_char  {meudebug("Tipo linha 174"); $$ = criarNodo($1, TIPO_CHAR, linha, coluna);}
  | t_identificador {meudebug("Tipo linha 175"); $$ = criarNodo($1, TIPO_IDCLASSE, linha, coluna); }
  ;
  
corpofuncao:
  t_abrichave declaracoes_comandos t_fechachave {
   meudebug("CorpoFuncao linha 180");
   $$ = $2;
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
      meudebug("Declaracao: tipo t_identificador");
      Nodo *declaracao = criarNodo("DECLARACAO", TIPO_DECLARACAO, linha, coluna);
      Nodo *id = criarNodo($2, TIPO_ID, linha, coluna);
      if(id) id->tipo_id = $1->tipo;
      addFilhoaoNodo(declaracao, $1);
      addFilhoaoNodo(declaracao, id);
      $$ = declaracao;
  }
  |tipo t_identificador t_igual expressao  {
      meudebug("Declaracao: tipo t_identificador t_igual expressao");
      Nodo *declaracao = criarNodo("DECLARACAO", TIPO_DECLARACAO, linha, coluna);
      Nodo *id = criarNodo($2, TIPO_ID, linha, coluna);
      if(id) id->tipo_id = $1->tipo;
      addFilhoaoNodo(declaracao, $1);
      addFilhoaoNodo(declaracao, id);
      addFilhoaoNodo(id, $4);
      $$ = declaracao;
  }
  |tipo  t_identificador t_abrivetor t_fechavetor {
      meudebug("Declaracao: tipo  t_identificador t_abrivetor t_fechavetor");
      Nodo *declaracao = criarNodo("DECLARACAO", TIPO_DECLARACAO, linha, coluna);
      Nodo *vetor = criarNodo($2, TIPO_VETOR, linha, coluna);
      Nodo *id = criarNodo($2, TIPO_ID, linha, coluna);
      if(id) id->tipo_id = TIPO_VETOR;
      if(id) id->tipo_vetor = $1->tipo;
      addFilhoaoNodo(declaracao, vetor);
      addFilhoaoNodo(declaracao, id);
      addFilhoaoNodo(vetor, $1);
      $$ = declaracao;
  }
  |acesso_vetor t_igual expressao  {
      meudebug("Declaracao: acesso_vetor t_igual expressao");
      //printf("acesso_vetor %s expressao %s ", $1->nome, $3->nome );
      $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  |acesso_vetor t_igual acesso_vetor {
    meudebug("Declaracao: acesso_vetor t_igual acesso_vetor");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | t_identificador t_igual expressao {
      meudebug("Declaracao: t_identificador t_igual expressao");
      Nodo *id = criarNodo($1, TIPO_ID, linha, coluna);
      addFilhoaoNodo(id, $3);
      $$ = id;
  }
  | t_identificador t_igual acesso_vetor {
      meudebug("Declaracao: t_identificador t_igual acesso_vetor");
      Nodo *id = criarNodo($1, TIPO_ID, linha, coluna);
      addFilhoaoNodo(id, $3);
      $$ = id;
  }
 ;

 funcao:
  tipo t_identificador t_abriparentes parametros t_fechaparentes corpofuncao {
      meudebug("Funcao linha 147");
      Nodo *declaracao = criarNodoDeclaracao($1, linha, coluna);
      Nodo *id = criarNodoFuncao($2, $1, $4, $6 ,linha, coluna);
      if(id) id->tipo_id = $1->tipo;
      addFilhoaoNodo(declaracao, id);
      $$ = declaracao;

  };
  |tipo t_abrivetor t_fechavetor t_identificador t_abriparentes parametros t_fechaparentes corpofuncao {
      meudebug("Funcao linha 147");
      Nodo *id = criarNodoFuncao($4, $1, $6, $8 ,linha, coluna);
      if(id) {
        id->tipo_id = TIPO_VETOR;
        id->tipo_vetor=$1->tipo;
      }
      Nodo *declaracao = criarNodoDeclaracao($1, linha, coluna);
      addFilhoaoNodo(declaracao, id);
      $$ = declaracao;
  };
  
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
      $$ = criarNodoComFilho("Argumentos", TIPO_ID, linha, coluna, $1);
  }
  | argumentos t_virgula argumento {
      meudebug("Argumentos linha 338");
      $$ = addRecursivoNodo("Argumentos", TIPO_ID,  linha,  coluna, $1, $3);
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
  | declaracao { $$ = $1;}
  ;

  
parte2for:
  condicao { meudebug("Parte2For condicao linha 179"); $$ = $1;}
  ;

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
    meudebug("Expressap: expressao t_mais expressao");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }; 
  | expressao t_menos expressao {
    meudebug("Expressap: expressao t_menos expressao");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | expressao t_asteristico expressao {
    meudebug("Expressap: expressao t_asteristico expressao");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | expressao t_barra expressao {
    meudebug("Expressap: expressao t_barra expressao");
    $$ = criarExpOperador( $2, $1, $3, linha, coluna );
  }
  | t_abriparentes expressao t_fechaparentes { 
      meudebug("Expressap: t_abriparentes expressao t_fechaparentes");
      $$ = $2;  
    }
  |t_identificador 
  {
    meudebug(" Expressao: t_identificador");
    Tipo tipo = TIPO_ID;
    Nodo *n = criarNodo($1, tipo, linha, coluna);
    $$ = n;
  }
  | t_decimal
  {
    meudebug(" Expressao: t_decimal");
    Tipo tipo = TIPO_DECIMAL;
    Nodo *n = criarNodo(
      $1, tipo, linha, coluna);
    $$ = n;
  } 
  | t_num 
  {
    meudebug(" Expressao: t_num");
    Tipo tipo = TIPO_INTEIRO;
    /*printf("tnum = %s\n", $1);*/
    Nodo *n = criarNodo($1, tipo, linha, coluna);
    $$ = n;
  }
  | t_string
  {
    meudebug(" Expressao: t_string");
    Tipo tipo = TIPO_STRING;
    Nodo *n = criarNodo(
      $1, tipo, linha, coluna);
    $$ = n;
  }
  | chamada_funcao { $$ = $1; };
  | chamada_metodo { $$ = $1;} ;
  ;
acesso_vetor:
  t_identificador t_abrivetor expressao t_fechavetor
  {
    meudebug(" Acesso_vetor: t_identificador t_abrivetor expressao t_fechavetor ");
    Nodo *vetor = criarNodo($1, TIPO_ID_VETOR, linha, coluna);
    Nodo *indice= criarNodo($1, TIPO_INDICE_VETOR, linha, coluna);
    addFilhoaoNodo(vetor, indice);
    addFilhoaoNodo(indice, $3);
    $$ = vetor;
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
    Nodo *tipo = criarNodo("Modelo", TIPO_CLASSE , linha, coluna);
    Nodo *declara = criarNodoDeclaracao(tipo, linha, coluna);
    Nodo *id = criarNodo($2, TIPO_CLASSE , linha, coluna);
    if(id) id->tipo_id = TIPO_CLASSE;
    addFilhoaoNodo(declara, id);
    addFilhoaoNodo(id, $4);
    $$ = declara;
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
    Nodo *declara = criarNodoDeclaracao($2, linha, coluna);  
    Nodo *id = criarNodo($3, TIPO_ID, linha, coluna);
    if(id) id->tipo_id = $2->tipo;
    addFilhoaoNodo(declara, id);
    addFilhoaoNodo(nodo, declara);
    $$ = nodo;
  }
  | corpoclasse tipo t_identificador t_abrivetor t_fechavetor   t_pontovirgula{
    meudebug("linha 740");
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo("CorpoClasse", TIPO_BLOCO, linha, coluna);  
    Nodo *vetor = criarNodo("Vetor", TIPO_VETOR, linha, coluna);
    Nodo *declara = criarNodoDeclaracao(vetor, linha, coluna);
    Nodo *id = criarNodo($3, TIPO_ID, linha, coluna);
    if(id && $2) id->tipo_id = TIPO_VETOR;
    if(id && $2) id->tipo_vetor = $2->tipo;
    addFilhoaoNodo(declara, id);
    addFilhoaoNodo(vetor, $2);
    addFilhoaoNodo(nodo, declara);
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
    Nodo *id = criarNodo($3 , TIPO_ID , linha, coluna);
    if(id) id->tipo_id = $2->tipo;
    Nodo *declara = criarNodoDeclaracao($2, linha, coluna);
    addFilhoaoNodo(declara, id);
    addFilhoaoNodo(id, $2);
    addFilhoaoNodo(id, $5);
    addFilhoaoNodo(nodo,declara);
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
    if(n) n->tipo_id = $2->tipo;
    Nodo *n2 = criarNodo("Vetor" , TIPO_VETOR , linha, coluna);
    addFilhoaoNodo(nodo, n);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, $7);
    addFilhoaoNodo(n2, $10);
    $$ = nodo;
  }
  ;
