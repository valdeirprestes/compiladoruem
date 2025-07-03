#include "pilha.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int criaPilha(Pilha *p){
	*p=NULL;
	return SUCESS;
}
int Pilhavazia(Pilha p){
	return (p == NULL);
}
int topoPilha(Pilha p, Nodo *dado){
	if(!p)
		return ERROR;
	*dado = p->dado;
	return SUCESS;
}
int empilhaPilha(Pilha *p, Nodo dado){
	Elemento *tmp =(Elemento *) malloc(sizeof(Elemento)* 1) ;
	if(!tmp)
		return ERROR;
	tmp->dado = dado;
	tmp->prox = (*p);
	*p= tmp;
	return SUCESS;
}
int desempilhaPilha(Pilha *p, Nodo *dado){
	Elemento *tmp;
	if(Pilhavazia(*p)){
		return ERROR;
	}
	*dado = (*p)->dado;
	tmp= (*p)->prox;
	free(*p);
	*p = tmp;
	return SUCESS;
}