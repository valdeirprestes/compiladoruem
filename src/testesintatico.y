%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "AST.h"
  int yylex (void);
  void yyerror (char const *);
  extern FILE *yyout;

  long linha=1;
  long coluna=1;
  long coluna_tmp = 0;
  int errossintatico = 0;
  Nodo *raiz;
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
%verbose
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
%type <nodo> atributo chamada_funcao chamada_metodo corpofuncao 
%type <nodo> parametrosfunc parametro parametros 
%type <nodo> declaracoes_comandos 
%type <nodo> corpoloop testeboleano comandoif 
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
    raiz = $1;
    printNodo(raiz);
    $$ = raiz;
  }
  | codigos error {
      yyerror; 
      printf("Foi encontrado %d erro(s) de sintaxe no codigo\n", errossintatico);
  } 
  ;
codigos:
  codigo{
    Nodo *n = criarNodo2("CODIGO", TIPO_REGRA, linha, coluna);
    addFilhoaoNodo(n, $1);
    $$ = n;
  }
  |codigos codigo{
    addFilhoaoNodo($1, $2);
    $$ = $1;
  }
  ;
codigo:
  funcao { 
    $$ = $1;
    }
  | classe {$$ = $1;}
  ;

funcao:
	tipofunc t_identificador t_abriparentes parametrosfunc t_fechaparentes corpofuncao {
      Nodo *n = criarNodo2($2, TIPO_FUNCAO, linha, coluna);
      addFilhoaoNodo(n, $1);
      addFilhoaoNodo(n, $4);
      addFilhoaoNodo(n, $6);
      $$ = n;
  }
  ;
tipofunc:
  tipo { $$ = $1; }
  |tipo t_abrivetor t_fechavetor { $$ = $1;}
  ;
parametrosfunc:
	parametros { 
      $$ = $1;
  }
  ;  
parametros:
	parametro  {
      if($1 ){
      Nodo *n = criarNodo2("Parametros", TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
      } else NULL;
  }
| parametros t_virgula parametro {
      addFilhoaoNodo($1, $3);
      $$ = $1;
  }
  ;
parametro:
  %empty { $$ = NULL;}
  |tipo t_identificador {
      Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  |tipo t_abrivetor t_fechavetor t_identificador
  {
    $$ = criarNodoRegraParametro($1, $2 , TIPO_VETOR );
  }
  ;
tipo:
  t_int { $$ =valorNodo(TIPO_INT , $1, NULL ); }
  | t_float { $$ =valorNodo(TIPO_FLOAT , $1, NULL ); }
  | t_char  { $$ =valorNodo(TIPO_CHAR , $1 , NULL); }
  | t_identificador { $$ =valorNodo( TIPO_IDENTIFICADOR , $1, NULL ); }
  ;
corpofuncao:
  t_abrichave declaracoes_comandos t_fechachave {
   //$$ = criarNodoRegraCorpoFuncao( $2);
   $$ = $2;
  }
  ;
declaracoes_comandos:
    %empty { $$ = NULL; }
  | declaracoes_comandos declaracao t_pontovirgula {
      if ($1) {
        addFilhoaoNodo($1, $2);
        $$ = $1;
      } else {
        Nodo *n = criarNodo2("Bloco", TIPO_BLOCO, linha, coluna);
        addFilhoaoNodo(n, $2);
        $$ = n;
      }
  }
  | declaracoes_comandos comando {
      if ($1) {
        addFilhoaoNodo($1, $2);
        $$ = $1;
      } else {
        Nodo *n = criarNodo2("Bloco", TIPO_BLOCO, linha, coluna);
        addFilhoaoNodo(n, $2);
        $$ = n;
      }
  }
;



comandos:
    comandos comando {
      addFilhoaoNodo($1, $2);
      $$ = $1;
    }
  | comando {
      Nodo *n = criarNodo2("Comandos", TIPO_BLOCO, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
    }
;





declaracao:
  tipo t_identificador {
      Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  |tipo t_identificador t_igual expressao {
      Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      addFilhoaoNodo(n, $4);
      $$ = n;
  }
  |tipo  t_abrivetor t_fechavetor t_identificador{
      Nodo *n = criarNodo2($4, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  ;

  
comando:
  comandoif {
    $$ = $1;
  }
  | comandoswitch { $$ = $1; };
  | forcomando { $$ = $1;} ;
  | whilecomando {$$ = $1;} ;
  | atribuicao t_pontovirgula {
    $$ = $1;
  };
  | t_return expressao t_pontovirgula {  
      Nodo *n = criarNodo2("Expressao", TIPO_RETURN , linha, coluna);
      addFilhoaoNodo(n, $2);
      $$ = n;
  }
  | t_break t_pontovirgula {
      Nodo *n = criarNodo2($1 , TIPO_BREAK , linha, coluna);
      $$ = n; 
  }
  ;
comandoswitch:
  t_switch t_abriparentes atributo t_fechaparentes  t_abrichave corposwitch t_fechachave{
      Nodo *n = criarNodo2($1 , TIPO_SWICTH , linha, coluna);
      addFilhoaoNodo(n, $3);
      addFilhoaoNodo($3, $6);
      $$ = n;
  }
  ;
corposwitch:
  cases { $$ =  $1; };
  | cases defaultswitch {
    {
      if($1){
        addFilhoaoNodo($1, $2);
        $$ = $1;
      }else if($2){
        Nodo *n = criarNodo2("BlocoCase" , TIPO_BLOCO , linha, coluna);
        addFilhoaoNodo(n, $1);
        $$ = n;
      }else $$ = NULL;
    }
  };
  ;
cases:
  case {
    Nodo *n = criarNodo2("BlocoCase" , TIPO_BLOCO , linha, coluna);
    addFilhoaoNodo(n, $1);
    $$ = n;
  };
  |cases case {
    if($1){
    addFilhoaoNodo($1, $2);
    $$ = $1;
    }else{
      Nodo *n = criarNodo2("BlocoCase" , TIPO_BLOCO , linha, coluna);
      addFilhoaoNodo(n, $2);
      $$ = n;
    }
  }
  ;
case:
  t_case atributo t_doispontos comandos {
    Nodo *n = criarNodo2($1 , TIPO_CASE , linha, coluna);
    addFilhoaoNodo(n, $2);
    addFilhoaoNodo(n, $4);
    $$ = n;
  };
  |t_case atributo t_doispontos t_abrichave comandos t_fechachave {
    Nodo *n = criarNodo2($1 , TIPO_CASE , linha, coluna);
    addFilhoaoNodo(n, $2);
    addFilhoaoNodo(n, $5);
    $$ = n;
  }
  ;
defaultswitch:
  t_default  t_doispontos comandos {
    Nodo *n = criarNodo2($1 , TIPO_DEFAULT , linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  |t_default  t_doispontos t_abrichave comandos t_fechachave {
    Nodo *n = criarNodo2($1 , TIPO_DEFAULT , linha, coluna);
    addFilhoaoNodo(n, $4);
    $$ = n;
  };
comandoif:
  t_if t_abriparentes testeboleano t_fechaparentes  corpoloop %prec "then" {
    Nodo *n = criarNodo2($1 , TIPO_IF, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  }
  | t_if t_abriparentes testeboleano t_fechaparentes  corpoloop t_else corpoloop{
    Nodo *n = criarNodo2("ifelse" , TIPO_IFELSE, linha, coluna);
    Nodo *n1 = criarNodo2($1 , TIPO_IFELSE, linha, coluna);
    Nodo *n2 = criarNodo2($6 , TIPO_IFELSE, linha, coluna);
    addFilhoaoNodo(n, $5);
    addFilhoaoNodo(n, $7);
    $$ = n;
  }
  ;
argumentos:
  %empty { $$ = NULL;}
  | argumento {
    if($1){
      Nodo *n = criarNodo2("Argumentos", TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
    }else $$ = NULL;
  }
  | argumentos t_virgula argumento {
      if($1)
      {
        addFilhoaoNodo($1, $3);
        $$ = $1;
      }
      else if($2){
        Nodo *n = criarNodo2("Argumentos", TIPO_IDENTIFICADOR, linha, coluna);
        addFilhoaoNodo(n, $3);
        $$ = n;
      }else
      $$ = NULL;
  }
  ;
argumento:
  atributo
  | tipo atributo
  ;
forcomando:
  t_for t_abriparentes parte1for t_pontovirgula parte2for t_pontovirgula parte3for t_fechaparentes corpofor{
    Nodo *n = criarNodo2($1, TIPO_FOR, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    addFilhoaoNodo(n, $7);
    addFilhoaoNodo(n, $9);
    $$ = n;
  }
  ;
parte1for:
  %empty { $$ = NULL;}
  | tipo t_identificador t_igual atributo {
    Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $4);
    $$ = n;
  }
  | t_identificador t_igual atributo {
    Nodo *n = criarNodo2($1, TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  ;
atribuicao:
  t_identificador t_igual expressao {
    Nodo *n = criarNodo2($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo2($1, TIPO_ATRIBUICAO, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, $3);
    $$ = n;};
  | expressao { $$ = $1; }
   ;
atributo:
  t_identificador 
  {
    Tipo tipo = TIPO_IDENTIFICADOR;
    Nodo *n = criarNodo2($1, tipo, linha, coluna);
    $$ = n;
  }
  | t_decimal
  {
    Tipo tipo = TIPO_DECIMAL;
    Nodo *n = criarNodo2($1, tipo, linha, coluna);
    $$ = n;
  } 
  | t_num 
  {
    Tipo tipo = TIPO_INTEIRO;
    Nodo *n = criarNodo2($1, tipo, linha, coluna);
    $$ = n;
  }
  | t_string
  {
    Tipo tipo = TIPO_STRING;
    Nodo *n = criarNodo2($1, tipo, linha, coluna);
    $$ = n;
  }
  | chamada_funcao { $$ = $1; };
  | chamada_metodo { $$ = $1;} ;
  ;
parte2for:
  %empty { $$ = NULL;}
  | testeboleano { $$ = $1;}
  ;
testeboleano:
  atributo t_igual_a atributo {
    Nodo *n = criarNodo2("ComparacaoIgualdade", TIPO_TESTE_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  | atributo t_diferente_de atributo {
    Nodo *n = criarNodo2("Diferente", TIPO_TESTE_DIFERENTE, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  | atributo t_maior_ou_igual atributo {
    {
    Nodo *n = criarNodo2("MaiorOuIgual", TIPO_TESTE_MAIORIGUAL, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | atributo t_menor_ou_igual atributo {
    {
    Nodo *n = criarNodo2("MenorOuIgual", TIPO_TESTE_MENOR_IGUAL, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | atributo t_maior atributo {
    {
    Nodo *n = criarNodo2("ComparacaoMaior", TIPO_TESTE_MAIOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | atributo t_menor atributo {
    {
    Nodo *n = criarNodo2("ComparacaoMenor", TIPO_TESTE_MENOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | t_exclamacao atributo { 
    Nodo *n = criarNodo2("NegacaoAtributo", TIPO_OP_NEGACAO, linha, coluna);
    addFilhoaoNodo(n, $2);
    $$ = n;
  }
  | t_abriparentes atributo t_fechaparentes { $$ = $2;}
  | atributo {
      Nodo *n = criarNodo2("Verificacao", TIPO_TESTEBOLEAN, linha, coluna); 
      addFilhoaoNodo(n, $1);
      $$ = n;
    }
  ;
parte3for:
  t_identificador t_igual atributo t_mais atributo {
    Nodo *n = criarNodo2($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo2("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo2("+", TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, n3);
    addFilhoaoNodo(n3, $3);
    addFilhoaoNodo(n3, $5);
    $$ = n;
  }
  | t_identificador t_igual atributo t_menos atributo {
    Nodo *n = criarNodo2($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo2("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo2("-", TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, n3);
    addFilhoaoNodo(n3, $3);
    addFilhoaoNodo(n3, $5);
    $$ = n;
  }
  | t_identificador t_igual atributo t_barra atributo {
    Nodo *n = criarNodo2($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo2("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo2("/", TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, n3);
    addFilhoaoNodo(n3, $3);
    addFilhoaoNodo(n3, $5);
    $$ = n;
  }
  | t_identificador t_igual atributo t_asteristico atributo {
    Nodo *n = criarNodo2($1, TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n2 = criarNodo2("=", TIPO_IDENTIFICADOR, linha, coluna);
    Nodo *n3 = criarNodo2("*", TIPO_IDENTIFICADOR, linha, coluna);
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
      //printf("479 Corpo while simples -> %s line %d\n", $1->nome, $1->linha);
      Nodo *n = criarNodo2("BLOCO", TIPO_BLOCO, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  | t_abrichave comandos t_fechachave {
    Nodo *n = criarNodo2("BLOCO", TIPO_BLOCO, linha, coluna);
    addFilhoaoNodo(n, $2);
    $$ = n;
  }
  ;
chamada_funcao:
  t_identificador t_abriparentes argumentos t_fechaparentes {
    Nodo *n = criarNodo2($1 , TIPO_CHAMADA_FUNCAO, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | t_identificador t_abriparentes argumentos t_fechaparentes error { printf("ERRO em chamada_funcao");}
  ;
chamada_metodo:
  t_identificadorclasse t_abriparentes argumentos t_fechaparentes { 
    Nodo *n = criarNodo2($1 , TIPO_CHAMADA_METODO, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  ;
whilecomando:
  t_while t_abriparentes testeboleano t_fechaparentes corpowhile{
    Nodo *n = criarNodo2($1, TIPO_WHILE, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  };
corpowhile:
  corpoloop { $$ = $1;}
  | error {
      errossintatico += 1; 
      yyerror; printf("ERRO: corpo do while incorreto\n");
    }
    ;
expressao:
  expressao t_mais expressao {
    Nodo *n = criarNodo2("Soma", TIPO_SOMA , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };

  | expressao t_menos expressao {
    Nodo *n = criarNodo2("Subtracao", TIPO_SUBTRACAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_asteristico expressao {
    {
    Nodo *n = criarNodo2("Multiplicacao", TIPO_MULTIPLICACAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  }
  | expressao t_barra expressao {
    Nodo *n = criarNodo2("Divisao", TIPO_DIVISAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_igual_a expressao {
    Nodo *n = criarNodo2("Atribuicao", TIPO_TESTE_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_diferente_de expressao {
    Nodo *n = criarNodo2("TesteDiferente", TIPO_TESTE_DIFERENTE , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_maior expressao {
    Nodo *n = criarNodo2("TesteMaior", TIPO_TESTE_MAIOR , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_maior_ou_igual expressao {
    Nodo *n = criarNodo2("TesteMaiorIgual", TIPO_TESTE_MAIORIGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_menor expressao {
    Nodo *n = criarNodo2("TesteMenor", TIPO_TESTE_MENOR , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_menor_ou_igual expressao{
    Nodo *n = criarNodo2("TesteMenorIgual", TIPO_TESTE_MENOR_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | t_abriparentes expressao t_fechaparentes { $$ = $2;  };
  | atributo { $$ = $1;}
  ;
classe:
  t_class t_identificador t_abrichave corpoclasse t_fechachave { 
    Nodo *n = criarNodo2($2, TIPO_CLASSE , linha, coluna);
    addFilhoaoNodo(n, $4);
    $$ = n;
   }
  ;
corpoclasse:
  %empty { $$ = NULL;}
  | corpoclasse tipo t_identificador t_pontovirgula  {
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo2("CorpoClasse", TIPO_BLOCO, linha, coluna);  
    Nodo *n = criarNodo2($3, TIPO_IDENTIFICADORCLASSE, linha, coluna);
    addFilhoaoNodo(nodo, n);
    $$ = nodo;
  }
  | corpoclasse tipo t_abrivetor t_fechavetor t_identificador  t_pontovirgula{
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo2("CorpoClasse", TIPO_BLOCO, linha, coluna);

    Nodo *n = criarNodo2($5, TIPO_IDENTIFICADORCLASSE, linha, coluna);
    Nodo *n2 = criarNodo2("Vetor", TIPO_VETOR, linha, coluna);
    addFilhoaoNodo(nodo, n);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, $2);
    $$ = nodo;
  }
  | corpoclasse tipo t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave 
  {
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo2("CorpoClasse", TIPO_BLOCO, linha, coluna);
    Nodo *n = criarNodo2($3 , TIPO_METODOCLASSE , linha, coluna);
    addFilhoaoNodo(nodo, n);
    addFilhoaoNodo(n, $2);
    addFilhoaoNodo(n, $5);
    $$ = nodo;
  };
  | corpoclasse tipo t_abrivetor t_fechavetor t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave 
  {
    Nodo *nodo;
    if($1)
      nodo = $1;
    else
      nodo = criarNodo2("CorpoClasse", TIPO_BLOCO, linha, coluna);
    Nodo *n = criarNodo2($5 , TIPO_METODOCLASSE , linha, coluna);
    Nodo *n2 = criarNodo2("Vetor" , TIPO_VETOR , linha, coluna);
    addFilhoaoNodo(nodo, n);
    addFilhoaoNodo(n, n2);
    addFilhoaoNodo(n2, $7);
    addFilhoaoNodo(n2, $10);
    $$ = nodo;
  }
  ;
