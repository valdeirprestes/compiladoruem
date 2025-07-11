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
    meudebug("linha 92"); 
    raiz = $1;
    if(imprimir_ast)
    printNodo(raiz);
    $$ = raiz;
  }
  ;
codigos:
  codigo{
    meudebug("linha 102");
    Nodo *n = criarNodo2("CODIGO", TIPO_REGRA, linha, coluna);
    addFilhoaoNodo(n, $1);
    $$ = n;
  }
  |codigos codigo{
    meudebug("linha 108");
    addFilhoaoNodo($1, $2);
    $$ = $1;
  }
  | error codigo {
    yyerrok;
  }
  ;
codigo:
  funcao { 
    meudebug("linha 115");
    $$ = $1;
    }
  | classe {
    meudebug("linha 119");
    $$ = $1;
    }
  ;

funcao:
	tipofunc t_identificador t_abriparentes parametrosfunc t_fechaparentes corpofuncao {
      meudebug("linha 126");
      Nodo *n = criarNodo2($2, TIPO_FUNCAO, linha, coluna);
      addFilhoaoNodo(n, $1);
      addFilhoaoNodo(n, $4);
      addFilhoaoNodo(n, $6);
      $$ = n;
  }
  | tipofunc t_identificador t_abriparentes parametrosfunc error t_abrichave {
    meudebug("linha 226");
    //yyerror;
    printErrorsrc(source, linha, coluna);
    printf("->>> Esperava ) na linha %d coluna %d\n", linha, coluna);
    yyerrok;
    $$ = $1;
  }
  | error t_identificador t_abriparentes parametrosfunc t_fechaparentes corpofuncao {
    meudebug("linha 226");
    //yyerror;
    printErrorsrc(source, linha, coluna);
    printf("->>> Esperava tipo na linha %d coluna %d\n", linha, coluna);
    yyerrok;
    $$ = $2;
  }
  ;
tipofunc:
  tipo {
    meudebug("linha 119");
     $$ = $1; }
  |tipo t_abrivetor t_fechavetor { $$ = $1;}
  ;
parametrosfunc:
	parametros { 
    meudebug("linha 142");
      $$ = $1;
  }
  ;  
parametros:
	parametro  {
      meudebug("linha 148");
      if($1 ){
      Nodo *n = criarNodo2("Parametros", TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
      } else NULL;
  }
| parametros t_virgula parametro {
      meudebug("linha 156");
      addFilhoaoNodo($1, $3);
      $$ = $1;
  }
  ;
parametro:
  %empty { 
    meudebug("linha 163");
    $$ = NULL;
    }
  |tipo t_identificador {
    meudebug("linha 167");
    Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    $$ = n;
  }
  |tipo t_abrivetor t_fechavetor t_identificador
  {
    meudebug("linha 174");
    $$ = criarNodoRegraParametro($1, $2 , TIPO_VETOR );
  }
  ;
tipo:
  t_int { meudebug("linha 179");  $$ =valorNodo(TIPO_INT , $1, NULL ); }
  | t_float {meudebug("linha 180"); $$ =valorNodo(TIPO_FLOAT , $1, NULL ); }
  | t_char  {meudebug("linha 181"); $$ =valorNodo(TIPO_CHAR , $1 , NULL); }
  | t_identificador {meudebug("linha 182"); $$ =valorNodo( TIPO_IDENTIFICADOR , $1, NULL ); }
  ;
corpofuncao:
  t_abrichave declaracoes_comandos t_fechachave {
   //$$ = criarNodoRegraCorpoFuncao( $2);
   meudebug("linha 187");
   $$ = $2;
  }
  |t_abrichave declaracoes_comandos t_fechachave error{
    meudebug("linha 191");
    yyerror;
    printErrorsrc(source, linha, coluna);
    printf("->>> Esperava um }, linha %d\n", linha, coluna);
    //yyerrok;
    //$$ = $2;
  }
  ;
declaracoes_comandos:
    %empty { 
      meudebug("linha 201");
      $$ = NULL; }
  | declaracoes_comandos declaracao t_pontovirgula {
      meudebug("linha 204");
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
      meudebug("linha 215");
      if ($1) {
        addFilhoaoNodo($1, $2);
        $$ = $1;
      } else {
        Nodo *n = criarNodo2("Bloco", TIPO_BLOCO, linha, coluna);
        addFilhoaoNodo(n, $2);
        $$ = n;
      }
  }
   | declaracoes_comandos error   {
    meudebug("linha 226");
    //yyerror;
    printErrorsrc(source, linha, coluna);
    printf("->>> Esperava ; e acabou o codigo no escopo, linha %d coluna %d\n", linha, coluna);
    //yyerrok;
    $$ = $1;

   }
;



comandos:
    comandos comando 
    {
      meudebug("linha 241");
      printf("linha 220\n");
      addFilhoaoNodo($1, $2);
      $$ = $1;
    }
  | comando {
      meudebug("linha 247");
      Nodo *n = criarNodo2("Comandos", TIPO_BLOCO, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
    }
;





declaracao:
  tipo t_identificador {
      meudebug("linha 260");
      Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  |tipo t_identificador t_igual expressao {
      meudebug("linha 266");
      Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      addFilhoaoNodo(n, $4);
      $$ = n;
  }
  |tipo  t_abrivetor t_fechavetor t_identificador{
      meudebug("linha 273");
      Nodo *n = criarNodo2($4, TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  ;

  
comando:
  comandoif {
    meudebug("linha 283");
    $$ = $1;
  }
  | comandoswitch { $$ = $1; };
  | forcomando { $$ = $1;} ;
  | whilecomando {$$ = $1;} ;
  | atribuicao t_pontovirgula {
    $$ = $1;
  };
  | t_return expressao t_pontovirgula {  
      meudebug("linha 293");
      Nodo *n = criarNodo2("Expressao", TIPO_RETURN , linha, coluna);
      addFilhoaoNodo(n, $2);
      $$ = n;
  }
  | t_break t_pontovirgula {
      meudebug("linha 299");
      Nodo *n = criarNodo2($1 , TIPO_BREAK , linha, coluna);
      $$ = n; 
  }
  ;
comandoswitch:
  t_switch t_abriparentes atributo t_fechaparentes  t_abrichave corposwitch t_fechachave{
      meudebug("linha 306");
      Nodo *n = criarNodo2($1 , TIPO_SWICTH , linha, coluna);
      addFilhoaoNodo(n, $3);
      addFilhoaoNodo($3, $6);
      $$ = n;
  }
  ;
corposwitch:
  cases { meudebug("linha 314"); $$ =  $1; };
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
    meudebug("linha 361");
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
    meudebug("linha 373");
    Nodo *n = criarNodo2($1 , TIPO_IF, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  }
  | t_if t_abriparentes testeboleano t_fechaparentes  corpoloop t_else corpoloop{
    meudebug("linha 380");
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
      meudebug("linha 393");
      Nodo *n = criarNodo2("Argumentos", TIPO_IDENTIFICADOR, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
    }else $$ = NULL;
  }
  | argumentos t_virgula argumento {
      if($1)
      {
        meudebug("linha 402");
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
    meudebug("linha 420");
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
    meudebug("linha 432");
    Nodo *n = criarNodo2($2, TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $4);
    $$ = n;
  }
  | t_identificador t_igual atributo {
    meudebug("linha 439");
    Nodo *n = criarNodo2($1, TIPO_IDENTIFICADOR, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  ;
atribuicao:
  t_identificador t_igual expressao {
    meudebug("linha 447");
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
    meudebug("linha 458");
    Tipo tipo = TIPO_IDENTIFICADOR;
    Nodo *n = criarNodo2($1, tipo, linha, coluna);
    $$ = n;
  }
  | t_decimal
  {
    Tipo tipo = TIPO_DECIMAL;
    meudebug("linha 466");
    Nodo *n = criarNodo2(
      $1, tipo, linha, coluna);
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
    meudebug("linha 479");
    Tipo tipo = TIPO_STRING;
    Nodo *n = criarNodo2(
      $1, tipo, linha, coluna);
    $$ = n;
  }
  | chamada_funcao { $$ = $1; };
  | chamada_metodo { $$ = $1;} ;
  ;
parte2for:
  %empty { $$ = NULL;}
  | testeboleano { 
    meudebug("linha 491");
    $$ = $1;}
  ;
testeboleano:
  atributo t_igual_a atributo {
    meudebug("linha 496");
    Nodo *n = criarNodo2("ComparacaoIgualdade", TIPO_TESTE_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  | atributo t_diferente_de atributo {
    meudebug("linha 503");
    Nodo *n = criarNodo2("Diferente", TIPO_TESTE_DIFERENTE, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  | atributo t_maior_ou_igual atributo {
    {
    meudebug("linha 511");
    Nodo *n = criarNodo2("MaiorOuIgual", TIPO_TESTE_MAIORIGUAL, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | atributo t_menor_ou_igual atributo {
    {
    meudebug("linha 520");
    Nodo *n = criarNodo2("MenorOuIgual", TIPO_TESTE_MENOR_IGUAL, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | atributo t_maior atributo {
    {
    meudebug("linha 529");
    Nodo *n = criarNodo2("ComparacaoMaior", TIPO_TESTE_MAIOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | atributo t_menor atributo {
    {
    meudebug("linha 538");
    Nodo *n = criarNodo2("ComparacaoMenor", TIPO_TESTE_MENOR, linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n; 
  }
  }
  | t_exclamacao atributo { 
    meudebug("linha 546");
    Nodo *n = criarNodo2("NegacaoAtributo", TIPO_OP_NEGACAO, linha, coluna);
    addFilhoaoNodo(n, $2);
    $$ = n;
  }
  | t_abriparentes atributo t_fechaparentes { $$ = $2;}
  | atributo {
      meudebug("linha 553");
      Nodo *n = criarNodo2("Verificacao", TIPO_TESTEBOLEAN, linha, coluna); 
      addFilhoaoNodo(n, $1);
      $$ = n;
    }
  ;
parte3for:
  t_identificador t_igual atributo t_mais atributo {
    meudebug("linha 561");
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
    meudebug("linha 572");
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
    meudebug("linha 583");
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
    meudebug("linha 594");
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
      meudebug("linha 610");
      //printf("479 Corpo while simples -> %s line %d\n", $1->nome, $1->linha);
      Nodo *n = criarNodo2("BLOCO", TIPO_BLOCO, linha, coluna);
      addFilhoaoNodo(n, $1);
      $$ = n;
  }
  | t_abrichave comandos t_fechachave {
    meudebug("linha 617");
    Nodo *n = criarNodo2("BLOCO", TIPO_BLOCO, linha, coluna);
    addFilhoaoNodo(n, $2);
    $$ = n;
  }
  ;
chamada_funcao:
  t_identificador t_abriparentes argumentos t_fechaparentes {
    meudebug("linha 625");
    Nodo *n = criarNodo2($1 , TIPO_CHAMADA_FUNCAO, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  | t_identificador t_abriparentes argumentos  error { printf("ERRO em chamada_funcao");}
  ;
chamada_metodo:
  t_identificadorclasse t_abriparentes argumentos t_fechaparentes { 
    meudebug("linha 634");
    Nodo *n = criarNodo2($1 , TIPO_CHAMADA_METODO, linha, coluna);
    addFilhoaoNodo(n, $3);
    $$ = n;
  }
  ;
whilecomando:
  t_while t_abriparentes testeboleano t_fechaparentes corpowhile{
    meudebug("linha 642");
    Nodo *n = criarNodo2($1, TIPO_WHILE, linha, coluna);
    addFilhoaoNodo(n, $3);
    addFilhoaoNodo(n, $5);
    $$ = n;
  };
corpowhile:
  corpoloop { $$ = $1;}
expressao:
  expressao t_mais expressao {
    meudebug("linha 652");
    Nodo *n = criarNodo2("Soma", TIPO_SOMA , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };

  | expressao t_menos expressao {
    meudebug("linha 660");
    Nodo *n = criarNodo2("Subtracao", TIPO_SUBTRACAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_asteristico expressao {
    {
    meudebug("linha 668");
    Nodo *n = criarNodo2("Multiplicacao", TIPO_MULTIPLICACAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  }
  | expressao t_barra expressao {
    meudebug("linha 676");
    Nodo *n = criarNodo2("Divisao", TIPO_DIVISAO , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_igual_a expressao {
    meudebug("linha 683");
    Nodo *n = criarNodo2("Atribuicao", TIPO_TESTE_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_diferente_de expressao {
    meudebug("linha 690");
    Nodo *n = criarNodo2("TesteDiferente", TIPO_TESTE_DIFERENTE , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_maior expressao {
    meudebug("linha 697");
    Nodo *n = criarNodo2("TesteMaior", TIPO_TESTE_MAIOR , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_maior_ou_igual expressao {
    meudebug("linha 704");
    Nodo *n = criarNodo2("TesteMaiorIgual", TIPO_TESTE_MAIORIGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_menor expressao {
    meudebug("linha 711");
    Nodo *n = criarNodo2("TesteMenor", TIPO_TESTE_MENOR , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | expressao t_menor_ou_igual expressao{
    meudebug("linha 718");
    Nodo *n = criarNodo2("TesteMenorIgual", TIPO_TESTE_MENOR_IGUAL , linha, coluna);
    addFilhoaoNodo(n, $1);
    addFilhoaoNodo(n, $3);
    $$ = n;
  };
  | t_abriparentes expressao t_fechaparentes { $$ = $2;  };
  | atributo { 
    meudebug("linha 726");
    $$ = $1;}
  ;
classe:
  t_class t_identificador t_abrichave corpoclasse t_fechachave { 
    meudebug("linha 731");
    Nodo *n = criarNodo2($2, TIPO_CLASSE , linha, coluna);
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
      nodo = criarNodo2("CorpoClasse", TIPO_BLOCO, linha, coluna);  
    Nodo *n = criarNodo2($3, TIPO_IDENTIFICADORCLASSE, linha, coluna);
    addFilhoaoNodo(nodo, n);
    $$ = nodo;
  }
  | corpoclasse tipo t_abrivetor t_fechavetor t_identificador  t_pontovirgula{
    meudebug("linha 751");
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
    meudebug("linha 767");
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
    meudebug("linha 781");
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
