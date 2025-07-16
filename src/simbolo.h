#ifndef SIMBOLO
#define SIMBOLO
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "AST.h"


typedef struct Simbolo {
    char *nome;         
    char *escopo;       
    Tipo tipo;          
    int parametro;      
    int vetor;          
    char *tipo_classe;  
    int linha;          
    int coluna;         
    Tipo tipo_id;
    Tipo tipo_vetor;
    struct Simbolo *proximo; 
} Simbolo;


extern Simbolo *tabelaSimbolos;
extern char *escopoAtual;



void inserirSimbolo( char *nome,  char *escopo, Tipo tipo, int isParametro, int isVetor, char *tipo_classe,Tipo tipo_id,Tipo tipo_vetor, int linha, int coluna);
/*Simbolo* buscarSimbolo( char *nome,  char *escopo);*/
Simbolo* buscarSimboloGeral( char *nome);
Simbolo* buscarSimboloPorNome( char *nome,  char *escopoAtual);
void imprimirTabelaSimbolos();
void liberarTabelaSimbolos();
void gerarTabelaSimbolosDaAST(Nodo *no);
int tiposCompatíveis(Nodo *esq, Nodo *dir);
void verificarAtribuicao(Nodo *nodo);
void verificarDeclaracao(Nodo *nodo);
void verificarSoma(Nodo *nodo);
void verificarSubtracao(Nodo *nodo);
void verificarMultiplicacao(Nodo *nodo);
void verificarDivisao(Nodo *nodo);
#endif