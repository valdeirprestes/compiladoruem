%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "AST.h"
  int yylex (void);
  void yyerror (char const *);

  extern FILE *yyout;
  char **source;
  long linha=1;
  long coluna=1;
  long coluna_tmp = 0;
  int errossintatico = 0;
  long imprimir_ast =0;
  Nodo *raiz;
  void printErrorsrc(char **source, int linha, int coluna);
  void meudebug(char *texto);
  int debug = 0;
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
%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_this t_identificadorclasse

/* token de espacamento  novalinha, tabulação  e espaço em branco*/
%token t_espaco t_novalinha 

 

/* Generate the parser description file. */
/*%verbose*/
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


%type <nodo> inicio  funcao classe tipofunc tipo
%type <nodo> codigos codigo
%type <nodo> expressao  
%type <nodo> chamada_funcao chamada_metodo corpofuncao 
%type <nodo> parametrosfunc parametro parametros 
%type <nodo> declaracoes_comandos 
%type <nodo> corpoloop  comandoif 
%type <nodo> declaracao  comando comandos
%type <nodo> forcomando parte1for parte2for parte3for corpofor atribuicao
%type <nodo> whilecomando corpowhile
%type <nodo> argumento argumentos
%type <nodo> corpoclasse
%type <nodo> comandoswitch corposwitch cases case defaultswitch 


%start inicio
%% /* Gramática deste ponto para baixo*/
inicio:
  codigos {
    meudebug("Inicio linha 96"); 
    raiz = $1;
    if(imprimir_ast)
      printNodo(raiz);
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
  funcao { 
    meudebug("Codigo linha 116");
    $$ = $1;
    }
  | classe {
    meudebug("Codigo linha 120");
    $$ = $1;
    }
  ;

funcao:
	tipofunc t_identificador t_abriparentes parametrosfunc t_fechaparentes corpofuncao {
      meudebug("Funcao linha 127");
      $$ = criarNodoFuncao($2, $1, $4, $6 ,linha, coluna);
  }
  | tipofunc t_identificador t_abriparentes parametrosfunc  t_fechaparentes error  {
    meudebug("Funcao linha 131");
    yyerror("Esperava \')\'' ");
    $$ = $1;
  }
 ;
tipofunc:
  tipo {
    meudebug("TipoFunc linha 138");
    $$ = $1; 
  }
  |tipo t_abrivetor t_fechavetor { meudebug("TipoFunc linha 141"); $$ = $1;}
  ;
parametrosfunc:
	parametros { 
    meudebug("ParametrosFunc linha 145");
      $$ = $1;
  }
  ;  
parametros:
  %empty { $$ = NULL;}
	|parametro  {
      meudebug("Parametros linha 152");
      $$ = criarNodo("Parametros", TIPO_IDENTIFICADOR, linha, coluna);
  }
| parametros t_virgula parametro {
      meudebug("Parametros linha 156");
      $$= addRecursivoNodo("Parametros", TIPO_PARAMETROS, linha, coluna, $1, $3);
  }
  ;
parametro:
  tipo t_identificador {
    meudebug("Parametro linha 162");
    $$ = criarNodoComFilho($2, TIPO_IDENTIFICADOR, linha, coluna,$1);
  }
  |tipo t_abrivetor t_fechavetor t_identificador
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
  |t_abrichave declaracoes_comandos t_fechachave error{
    meudebug("CorpoFuncao linha 191");
    yyerror("Esperava um }");
  }
  ;
declaracoes_comandos:
  %empty { 
      meudebug("Declaracoes_comandos linha 201");
      $$ = NULL; 
  }
  | declaracoes_comandos declaracao t_pontovirgula {
      meudebug("Declaracoes_comandos linha 204");
      $$ = addRecursivoNodo("Bloco", TIPO_BLOCO, linha, coluna, $1, $2);
  }
  | declaracoes_comandos comando {
      meudebug("Declaracoes_comandos linha 215");
      $$ = addRecursivoNodo("Bloco", TIPO_BLOCO, linha, coluna, $1, $2);
  }
   | declaracoes_comandos error   {
    meudebug("Declaracoes_comandos linha 226");
    yyerror("Esperava ;");
    $$ = $1;
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
      meudebug("Declaracao linha 225");
      $$ = criarNodoComFilho($2, TIPO_IDENTIFICADOR, linha, coluna, $1);
  }
  |tipo t_identificador t_igual expressao {
      meudebug("Declaracao linha 229");
      Nodo *n = criarNodo($2, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      addFilhoaoNodo(n, $4);
      $$ = n;
  }
  |tipo  t_abrivetor t_fechavetor t_identificador{
      meudebug("Declaracao linha 236");
      $$ = criarNodoComFilho($4, TIPO_IDENTIFICADOR, linha, coluna, $1);
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
  | atribuicao t_pontovirgula { meudebug("Comando linha 250");
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
  t_if t_abriparentes expressao t_fechaparentes  corpoloop %prec "then" {
    meudebug("Comandoif linha 315");
    Nodo *n = criarNodo($1 , TIPO_IF, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  }
  | t_if t_abriparentes expressao t_fechaparentes  corpoloop t_else corpoloop{
    meudebug("Comandoif linha 322");
    Nodo *n = criarNodo("ifelse" , TIPO_IFELSE, linha, coluna);
    Nodo *n1 = criarNodo($1 , TIPO_IFELSE, linha, coluna);
    Nodo *n2 = criarNodo($6 , TIPO_IFELSE, linha, coluna);
    addFilhoaoNodo(n, $5);
    addFilhoaoNodo(n, $7);
    $$ = n;
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
  | tipo t_identificador {
    meudebug("Argumentos linha 348");
    $$ = criarNodoComFilho($2, TIPO_IDENTIFICADOR, linha, coluna, $1);
  }
  ;
forcomando:
  t_for t_abriparentes parte1for t_pontovirgula parte2for t_pontovirgula parte3for t_fechaparentes corpofor{
    meudebug("ForComando linha 354");
    Nodo *n = criarNodo($1, TIPO_FOR, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    addFilhoaoNodo(n, $7);
    addFilhoaoNodo(n, $9);
    $$ = n;
  }
  ;
parte1for:
  %empty { meudebug("Parte1For linha 364"); $$ = NULL;}
  | tipo t_identificador t_igual expressao {
    meudebug("Parte1For linha 366");
    Nodo *n = criarNodo($2, TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $4);
    $$ = n;
  }
  | t_identificador t_igual expressao {
    meudebug("Parte1For linha 373");
    Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  ;
atribuicao:
  t_identificador t_igual expressao {
    meudebug("Atribuicao linha 381");
    Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo($1, TIPO_ATRIBUICAO, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, $3);
    $$ = n;};
  | expressao { $$ = $1; }
   ;

  
parte2for:
  %empty {meudebug("Parte2For linha 392"); $$ = NULL;}
  | expressao { 
    meudebug("Parte2For linha 394");
    $$ = $1;}
  ;

parte3for:
  t_identificador t_igual expressao t_mais expressao {
    meudebug("Parte3For linha 561");
    Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo("+", TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, n3);
    addFilhoaoNodo(n3, $3);
    addFilhoaoNodo(n3, $5);
    $$ = n;
  }
  | t_identificador t_igual expressao t_menos expressao {
    meudebug("Parte3For linha 572");
    Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo("-", TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, n3);
    addFilhoaoNodo(n3, $3);
    addFilhoaoNodo(n3, $5);
    $$ = n;
  }
  | t_identificador t_igual expressao t_barra expressao {
    meudebug("Parte3 linha 583");
    Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo("/", TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, n3);
    addFilhoaoNodo(n3, $3);
    addFilhoaoNodo(n3, $5);
    $$ = n;
  }
  | t_identificador t_igual expressao t_asteristico expressao {
    meudebug("Parte3For linha 594");
    Nodo *n = criarNodo($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo("*", TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, n3);
    addFilhoaoNodo(n3, $3);
    addFilhoaoNodo(n3, $5);
    $$ = n;
  }
  ;
corpofor:
  corpoloop { $$ = $1;}
  ;
corpoloop:
  comando {
      meudebug("CorpoLoop linha 449");
      //printf("479 Corpo while simples -> %s line %d\n", $1->nome, $1->linha);
      Nodo *n = criarNodo("BLOCO", TIPO_BLOCO, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  | t_abrichave comandos t_fechachave {
    meudebug("CorpoLoop linha 456");
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
  t_while t_abriparentes expressao t_fechaparentes corpowhile{
    meudebug("WhileComando linha 481");
    Nodo *n = criarNodo($1, TIPO_WHILE, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  };
corpowhile:
  corpoloop { $$ = $1;}
expressao:
  expressao t_mais expressao {
    meudebug("Expressao linha 491");
    Nodo *n = criarNodo("Soma", TIPO_SOMA , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };

  | expressao t_menos expressao {
    meudebug("Expressao linha 499");
    Nodo *n = criarNodo("Subtracao", TIPO_SUBTRACAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_asteristico expressao {
    {
    meudebug("Expressao linha 507");
    Nodo *n = criarNodo("Multiplicacao", TIPO_MULTIPLICACAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  }
  | expressao t_barra expressao {
    meudebug("Expressao linha 515");
    Nodo *n = criarNodo("Divisao", TIPO_DIVISAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_igual_a expressao {
    meudebug("Expressao linha 522 ");
    Nodo *n = criarNodo("Atribuicao", TIPO_TESTE_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_diferente_de expressao {
    meudebug("Expressao linha 529");
    Nodo *n = criarNodo("TesteDiferente", TIPO_TESTE_DIFERENTE , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_maior expressao {
    meudebug("Expressao linha 536");
    Nodo *n = criarNodo("TesteMaior", TIPO_TESTE_MAIOR , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_maior_ou_igual expressao {
    meudebug("Expressao linha 543");
    Nodo *n = criarNodo("TesteMaiorIgual", TIPO_TESTE_MAIORIGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_menor expressao {
    meudebug("Expressao linha 550");
    Nodo *n = criarNodo("TesteMenor", TIPO_TESTE_MENOR , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_menor_ou_igual expressao{
    meudebug("Expressao linha 558");
    Nodo *n = criarNodo("TesteMenorIgual", TIPO_TESTE_MENOR_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | t_abriparentes expressao t_fechaparentes { $$ = $2;  };
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
  | corpoclasse tipo t_abrivetor t_fechavetor t_identificador  t_pontovirgula{
    meudebug("linha 751");
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo("CorpoClasse", TIPO_BLOCO, linha, coluna);

    Nodo *n = criarNodo($5, TIPO_IDENTIFICADORCLASSE, linha, coluna);
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
