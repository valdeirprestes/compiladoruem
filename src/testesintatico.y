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
  VetorNodo *vetor_nodos;
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
%type <vetor_nodos> declaracao comando declaracoes comandos
%start inicio
%% /* Gramática deste ponto para baixo*/
inicio:
codigos { 
    extern Nodo *raiz; 
    raiz= criarNodoRegraInicio($1);
    printNodo(raiz);
    $$ = raiz;
  }
codigos:
  %empty { $$ = NULL ; }
  | codigo codigos{
    $$ = criarNodoRegraCodigos($1 , $2);
  }
  | codigo error {
      yyerror; 
      printf("Foi encontrado %d erro(s) de sintaxe no codigo\n", errossintatico);
    } 
codigo:
  funcao { 
    $$ = $1;
    }
  | classe
funcao:
	tipofunc t_identificador t_abriparentes parametrosfunc t_fechaparentes corpofuncao {
    $$ = criaNodoRegraFuncao( $2, $1 , $4, $6 );
  }
tipofunc:
  tipo { $$ = $1; }
  |tipo t_abrivetor t_fechavetor { $$ = $1;}
parametrosfunc:
	parametro { 
      $$ = criarNodoRegraParametrosFunc($1 , NULL);
  }  
  | parametro t_virgula parametros { 
      $$ = criarNodoRegraParametrosFunc($1 , $3);
  }
parametros:
	parametro  { $$ = criarNodoRegraParametrosFunc($1 , NULL); }
| parametro t_virgula parametros {
    $$ = criarNodoRegraParametrosFunc($1 , $3);
  }
parametro:
  %empty { $$ = NULL;}
  |tipo t_identificador {
    $$ = criarNodoRegraParametro($1, $2 , TIPO_IDENTIFICADOR);
  }
  |tipo t_abrivetor t_fechavetor t_identificador
  {
    $$ = criarNodoRegraParametro($1, $2 , TIPO_VETOR );
  }
tipo:
  t_int { $$ =valorNodo(TIPO_INT , $1, NULL ); }
  | t_float { $$ =valorNodo(TIPO_FLOAT , $1, NULL ); }
  | t_char  { $$ =valorNodo(TIPO_CHAR , $1 , NULL); }
  | t_identificador { $$ =valorNodo( TIPO_IDENTIFICADOR , $1, NULL ); }
corpofuncao:
  t_abrichave declaracoes_comandos t_fechachave {
   $$ = criarNodoRegraCorpoFuncao( $2);
  }
declaracoes_comandos:
  %empty { $$ = NULL;}
  | declaracao t_pontovirgula {
    //$$ = criarNodoRegraDeclaracoesComandos($1, NULL);
    $$ = converterVetorParaNodo($1, "DECLARACAO_COMANDO1", TIPO_REGRA);
    //$$ = concactenaNodosFilhos($1, NULL, "DECLARACAO_COMANDO1", TIPO_REGRA);
  }
  | declaracao t_pontovirgula declaracoes {
    //$$ = criarNodoRegraDeclaracoesComandos($1, $3); 
    VetorNodo *v = concactenarVetorNodo($1, $3);
    //$$ = concactenaNodosFilhos($1, $3, "DECLARACAO_COMANDO2", TIPO_REGRA);
    $$ = converterVetorParaNodo($1, "DECLARACAO_COMANDO2", TIPO_REGRA);
  }
  | declaracao t_pontovirgula comandos{
        //$$ = criarNodoRegraDeclaracoesComandos($1, $3); 
    VetorNodo *v = concactenarVetorNodo($1, $3);
    //$$ = concactenaNodosFilhos($1, $3, "DECLARACAO_COMANDO2", TIPO_REGRA);
    $$ = converterVetorParaNodo($1, "DECLARACAO_COMANDO3", TIPO_REGRA);
  }
  | comando {
    //$$ = criarNodoRegraDeclaracoesComandos($1, NULL);
    //$$ = concactenaNodosFilhos($1, NULL, "DECLARACAO_COMANDO3", TIPO_REGRA);
    $$ = converterVetorParaNodo($1, "DECLARACAO_COMANDO4", TIPO_REGRA);
  } 
  | comando declaracoes{
      VetorNodo *v = concactenarVetorNodo($1, $2);
      $$ = converterVetorParaNodo(v, "DECLARACAO_COMANDO5", TIPO_REGRA);
      //$$ = criarNodoRegNodoraDeclaracoesComandos($1, $2);
  }
  | comando comandos {
      VetorNodo *v = concactenarVetorNodo($1, $2);
      $$ = converterVetorParaNodo(v, "DECLARACAO_COMANDO6", TIPO_REGRA);
  }
declaracoes:
  declaracao t_pontovirgula {
      $$ = $1;
  }
  |declaracao t_pontovirgula  comandos{
      VetorNodo *v = concactenarVetorNodo($1, $3);
      $$ = v;
  }
  |declaracao t_pontovirgula declaracoes{
      VetorNodo *v = concactenarVetorNodo($1, $3);
      $$ = v;
  }
declaracao:
  tipo t_identificador {
    Nodo *declaracao = criarNodoRegraDeclaracao($1, $2, TIPO_IDENTIFICADOR, NULL);
    VetorNodo *v = novoVetorNodo(1);
    adicionarNodoaVetorNodo(v, declaracao);
    $$ = v;
  }
  |tipo t_identificador t_igual expressao
  |tipo  t_abrivetor t_fechavetor t_identificador
comandos:
  comando {
    $$ = $1;
  }
  | comando comandos {
      Nodo *n = criarNodoRegraDeclaracoesComandos($1, $2);
      VetorNodo *v = novoVetorNodo(1);
      adicionarNodoaVetorNodo(v, n);
      $$ = v;
  }
  | comando declaracoes {
      $$ = criarNodoRegraDeclaracoesComandos($1, $2);
  }
  | comando error {

  }
comando:
  comandoif {
    $$ = criarIF( $1);
  }
  | comandoswitch
  | forcomando 
  | whilecomando 
  | atribuicao t_pontovirgula
  | t_return expressao t_pontovirgula {  
      Nodo *n = criarNodo();
      n->nome = strdup("RETURN");
      n->tipo = TIPO_RETURN;
      n->filhos = criaVetorNodo(1);
      n->nfilhos=1;
      n->filhos[0]= $2;
      VetorNodo *v = novoVetorNodo(2);
      adicionarNodoaVetorNodo
      $$ = n;
  }
  | t_break t_pontovirgula
comandoswitch:
  t_switch t_abriparentes atributo t_fechaparentes  t_abrichave corposwitch t_fechachave
corposwitch:
  cases
  | cases defaultswitch
cases:
  case
  |case cases
case:
  t_case atributo t_doispontos comandos
  |t_case atributo t_doispontos t_abrichave comandos t_fechachave

defaultswitch:
  t_default  t_doispontos comandos
  |t_default  t_doispontos t_abrichave comandos t_fechachave
comandoif:
  t_if t_abriparentes testeboleano t_fechaparentes  corpoloop %prec "then" {
    Nodo *n = criarNodo();
    n->filhos[0] = $5;
    $$ = n;
  }
  | t_if t_abriparentes testeboleano t_fechaparentes  corpoloop t_else corpoloop{
    Nodo *n = criarNodo();
    Nodo *n2 = criarNodo();
    n2->filhos[0] = $5;
    n->filhos[0] = $3;
    n->filhos[0] = n2;
    n->filhos[1] = criarNodo();
    n->filhos[1]->nome="ELSE";
    n->filhos[1]->tipo = TIPO_ELSE;
    n->filhos[1]->filhos[0] = $5;
    $$ = n;
  }

argumentos:
  %empty
  | argumento
  | argumento t_virgula argumentos
argumento:
  atributo
  | tipo atributo
forcomando:
  t_for t_abriparentes parte1for t_pontovirgula parte2for t_pontovirgula parte3for t_fechaparentes corpofor
parte1for:
  %empty
  | tipo t_identificador t_igual atributo
  | t_identificador t_igual atributo
atribuicao:
  t_identificador t_igual expressao 
  | expressao
   
atributo:
  t_identificador 
  {
    Tipo tipo = TIPO_IDENTIFICADOR;
    Nodo *n = valorNodo(tipo , $1, NULL );
    $$ = n;
  }
  | t_decimal
  {
    Tipo tipo = TIPO_DECIMAL;
    Nodo *n = valorNodo(tipo , $1 , NULL);
    $$ = n;
  } 
  | t_num 
  {
    Tipo tipo = TIPO_INTEIRO;
    Nodo *n = valorNodo(tipo , $1 , NULL);
    $$ = n;
  }
  | t_string
  {
    Tipo tipo = TIPO_STRING;
    Nodo *n = valorNodo(tipo , $1 , NULL);
    $$ = n;
  }
  | chamada_funcao 
  | chamada_metodo
parte2for:
  %empty
  | testeboleano
testeboleano:
  atributo t_igual_a atributo
  | atributo t_diferente_de atributo
  | atributo t_maior_ou_igual atributo
  | atributo t_menor_ou_igual atributo
  | atributo t_maior atributo
  | atributo t_menor atributo
  | t_exclamacao atributo
  | t_abriparentes atributo t_fechaparentes
  | atributo
parte3for:
  t_identificador t_igual atributo t_mais atributo
  | t_identificador t_igual atributo t_menos atributo
  | t_identificador t_igual atributo t_barra atributo
  | t_identificador t_igual atributo t_asteristico atributo
corpofor:
  corpoloop
corpoloop:
  comando
  | t_abrichave comandos t_fechachave
chamada_funcao:
  t_identificador t_abriparentes argumentos t_fechaparentes { ; }
  | t_identificador t_abriparentes argumentos t_fechaparentes error { printf("ERRO em chamada_funcao");}
chamada_metodo:
  t_identificadorclasse t_abriparentes argumentos t_fechaparentes {}

whilecomando:
  t_while t_abriparentes expressao t_fechaparentes corpowhile
corpowhile:
  corpoloop
  | error {
      errossintatico += 1; 
      yyerror; printf("ERRO: corpo do while incorreto\n");
    }
expressao:
  expressao t_mais expressao
  | expressao t_menos expressao
  | expressao t_asteristico expressao
  | expressao t_barra expressao
  | expressao t_igual_a expressao
  | expressao t_diferente_de expressao
  | expressao t_maior expressao
  | expressao t_maior_ou_igual expressao
  | expressao t_menor
  | expressao t_menor_ou_igual
  | t_abriparentes expressao t_fechaparentes
  | atributo { $$ = $1;}

classe:
  t_class t_identificador t_abrichave corpoclasse t_fechachave {  }
corpoclasse:
  %empty
  | tipo t_identificador t_pontovirgula corpoclasse
  | tipo t_abrivetor t_fechavetor t_identificador  t_pontovirgula corpoclasse
  | tipo t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave corpoclasse
  | tipo t_abrivetor t_fechavetor t_identificador t_abriparentes parametros t_fechaparentes t_abrichave declaracoes_comandos t_fechachave corpoclasse

