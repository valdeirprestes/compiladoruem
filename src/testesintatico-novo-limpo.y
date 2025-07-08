%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "AST.h"
  int yylex(void);
  void yyerror(char const *);
  extern FILE *yyout;

  long linha = 1;
  long coluna = 1;
  long coluna_tmp = 0;
  int errossintatico = 0;
  Nodo *raiz;
%}

%union {
  char* texto;
  Nodo *nodo;
  VetorNodo *vetor_nodos;
}

/* Tokens léxicos */
%token <texto> t_mais t_menos t_asteristico t_barra
%token <texto> t_maior t_menor t_igual t_exclamacao
%token <texto> t_igual_a t_diferente_de t_menor_ou_igual t_maior_ou_igual

%token <texto> t_abrivetor t_fechavetor t_int t_float t_char
%token <texto> t_num t_decimal t_identificador t_string t_eof

%token <texto> t_class t_construtor t_destrutor t_func t_return t_variavel t_this t_identificadorclasse

%token <texto> t_for t_while t_if t_else t_switch t_case t_default t_break
%token <texto> t_abrichave t_fechachave t_abriparentes t_fechaparentes
%token <texto> t_pontovirgula t_virgula t_doispontos t_interrogacao t_ponto

/* Precedência de operadores */
%left t_igual_a t_diferente_de
%left t_maior t_maior_ou_igual t_menor t_menor_ou_igual
%left t_mais t_menos
%left t_asteristico t_barra
%nonassoc "then"
%nonassoc t_else

/* Tipagem semântica das regras */
%type <nodo> inicio codigo funcao classe tipofunc tipo
%type <nodo> parametro parametrosfunc expressao operador_binario
%type <nodo> atribuicao atributo argumento
%type <nodo> comando comandoif comandoswitch forcomando whilecomando
%type <nodo> corpoloop corpofuncao corpowhile membro

%type <vetor_nodos> lista_codigo lista_parametros lista_argumentos
%type <vetor_nodos> lista_elementos lista_cases lista_membros

/* Ponto de entrada */
%start inicio

%%

inicio:
    lista_codigo;

lista_codigo:
    /* vazio */
  | codigo lista_codigo
  | codigo error;

codigo:
    funcao
  | classe;

funcao:
    tipofunc t_identificador t_abriparentes parametrosfunc t_fechaparentes corpofuncao;

tipofunc:
    tipo
  | tipo t_abrivetor t_fechavetor;

parametrosfunc:
    /* vazio */
  | lista_parametros;

lista_parametros:
    parametro
  | parametro t_virgula lista_parametros;

parametro:
    tipo t_identificador
  | tipo t_abrivetor t_fechavetor t_identificador;

tipo:
    t_int | t_float | t_char | t_identificador;

corpofuncao:
    t_abrichave bloco t_fechachave;

bloco:
    /* vazio */
  | lista_elementos;

lista_elementos:
    elemento
  | elemento lista_elementos;

elemento:
    declaracao t_pontovirgula
  | comando;

declaracao:
    tipo t_identificador
  | tipo t_identificador t_igual expressao
  | tipo t_abrivetor t_fechavetor t_identificador;

comando:
    comandoif
  | comandoswitch
  | forcomando
  | whilecomando
  | atribuicao t_pontovirgula
  | t_return expressao t_pontovirgula
  | t_break t_pontovirgula;

comandoif:
    t_if t_abriparentes expressao t_fechaparentes corpoloop %prec "then"
  | t_if t_abriparentes expressao t_fechaparentes corpoloop t_else corpoloop;

comandoswitch:
    t_switch t_abriparentes atributo t_fechaparentes t_abrichave corposwitch t_fechachave;

corposwitch:
    lista_cases
  | lista_cases defaultswitch;

lista_cases:
    case
  | case lista_cases;

case:
    t_case atributo t_doispontos bloco
  | t_case atributo t_doispontos t_abrichave bloco t_fechachave;

defaultswitch:
    t_default t_doispontos bloco
  | t_default t_doispontos t_abrichave bloco t_fechachave;

forcomando:
    t_for t_abriparentes parte1for t_pontovirgula expressao t_pontovirgula parte3for t_fechaparentes corpoloop;

parte1for:
    /* vazio */
  | tipo t_identificador t_igual atributo
  | t_identificador t_igual atributo;

parte3for:
    t_identificador t_igual atributo operador_binario atributo;

whilecomando:
    t_while t_abriparentes expressao t_fechaparentes corpowhile;

corpowhile:
    corpoloop
  | error { errossintatico += 1; yyerror; printf("ERRO: corpo do while incorreto\n"); };

corpoloop:
    comando
  | t_abrichave bloco t_fechachave;

expressao:
    expressao operador_binario expressao
  | t_exclamacao expressao
  | t_abriparentes expressao t_fechaparentes
  | atributo;

operador_binario:
    t_mais | t_menos | t_asteristico | t_barra
  | t_igual_a | t_diferente_de | t_maior | t_maior_ou_igual | t_menor | t_menor_ou_igual;

atribuicao:
    t_identificador t