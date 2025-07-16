#ifndef SIMBOLO
#define SIMBOLO
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "AST.h"


/*
Tratar variáveis e escopo
funcoes 
classe
variaves do tipo Classe
*/
typedef struct Simbolo {
    char *nome;         // Nome do símbolo (ex: nome da variável, função)
    char *escopo;       // Escopo do símbolo (ex: "global", "main", "nome_da_funcao")
    Tipo tipo;          // Tipo do símbolo (ex: TIPO_INT, TIPO_FUNCAO)
    int parametro;      // 1 se for um parâmetro de função, 0 caso contrário
    int vetor;          // 1 se for um vetor, 0 caso contrário
    char *tipo_classe;  // Flag: nomeclasse se for um variavel criada a partir de um classe 
    int linha;          // Linha onde o símbolo foi declarado
    int coluna;         // Coluna onde o símbolo foi declarado
    Tipo tipo_id;
    Tipo tipo_vetor;
    struct Simbolo *proximo; // Ponteiro para o próximo símbolo na lista encadeada
} Simbolo;

// Ponteiro global para o início da tabela de símbolos
extern Simbolo *tabelaSimbolos;
extern char *escopoAtual;



void inserirSimbolo(const char *nome, const char *escopo, Tipo tipo, int isParametro, int isVetor, char *tipo_classe,Tipo tipo_id,Tipo tipo_vetor, int linha, int coluna);
Simbolo* buscarSimbolo(const char *nome, const char *escopo);

Simbolo* buscarSimboloPorNome(const char *nome, const char *escopoAtual);
void imprimirTabelaSimbolos();
void liberarTabelaSimbolos();
void gerarTabelaSimbolosDaAST(Nodo *no);
#endif