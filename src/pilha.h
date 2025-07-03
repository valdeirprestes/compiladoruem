#ifndef PILHA
#define PILHA
#define SUCESS 1
#define ERROR 0 
#include "AST.h"
typedef struct Elemento{
	Nodo dado;
	struct Elemento *prox;
}Elemento;

typedef Elemento* Pilha;

int criaPilha(Pilha *p);
int Pilhavazia(Pilha p);
int topoPilha(Pilha p, Nodo *dado);
int empilhaPilha(Pilha *p, Nodo dado);
int desempilhaPilha(Pilha *p, Nodo *dado);
#endif