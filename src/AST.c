#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "AST.h"

AST  *criarAST()
{
	AST *ast = (AST*) malloc(sizeof(AST));
	if(!ast) return NULL;
	ast->raiz= NULL;
	return ast;
}

Nodo *criarNodo()
{
	Nodo *n = (Nodo*) malloc(sizeof(Nodo));
	n->nfilhos = 0;
	for (int i=0 ; i< MAXNODOS; i++) n->filhos[i] = NULL;
	return n;
}

Nodo *operacaoNodo(char *regra, double num1,char op, double num2)
{
	
}

Nodo *valorNodo(Tipo tipo, char *valor )
{
	Nodo *nodo = criarNodo();
	if(!nodo)
	{
		printf("Error de alocação!\n");
		exit(-1);
		return NULL; /* Nem sera executado no exemplo!*/
	}
	nodo->tipo = tipo;
	switch(tipo){
		case TIPO_VARIAVEL: /* ainda não sei como vou ajustar */
			nodo->dado.sval = strdup(valor);
			break;
		case TIPO_INTEIRO:
			nodo->dado.ival = atoi(valor);
			break;
		default:
		;
	}
	
	return nodo;
}

void printNodo(Nodo *nodo)
{
	int niveis[NIVEIS][1];
	printf("\n\n");
	for (int i= 0; i< NIVEIS; i++) niveis[i][0] = 0;
	niveis[0][0] = 1;
	printf("|(%s)\n",  nodo->nome);
	for(int i = 0; i < nodo->nfilhos ; i++)
		if(nodo->filhos[i])
			printNodoFilho(nodo->filhos[i], 1, niveis);
}
void printNodoFilho(Nodo *n, int nivel, int niveis[NIVEIS][1])
{
	if(nivel > 0)
		printf("%s(%s)---> \n", stringNivel(nivel, niveis)); /*, n->nome, n->valor);*/
	else
		printf("%s(%s)\n", stringNivel(nivel, niveis), n->nome);
	if(n->filhos[1]) niveis[nivel][0] =1;
	if(n->filhos[0]) niveis[nivel][0] +=1;
	if(n->filhos[1])
		printNodoFilho(n->filhos[1], nivel + 1, niveis);
	if(n->filhos[0])
		printNodoFilho(n->filhos[0], nivel + 1, niveis);
	
}
char *stringNivel(int nivel, int niveis[NIVEIS][1])
{
	char espaco[1000];
	int i;
	for(i = 0 ; i <= nivel * ESPACOARVORE; i++)
	{
		if(i % ESPACOARVORE == 0)
		{
			if(niveis[nivel][0]<=nivel)
				espaco[i]= '|';
		}
		else
			espaco[i]= ' ';
	}
	//niveis[nivel][0] -=1;
	espaco[i]='\0';
	return strdup(espaco);
}