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
	Nodo *f[MAXNODOS] = {NULL};
	n->filhos = f;
	return n;
}

Nodo *operacaoNodo(char *regra, double num1,char op, double num2)
{
	
}

Nodo *valorNodo(Tipo tipo, char *valor, Nodo *nodotipo )
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
		case TIPO_IDENTIFICADOR: /* ainda não sei como vou ajustar */
			nodo->token.sval = strdup(valor);
			nodo->token.tval = nodotipo->tipo;
			break;
		case TIPO_INTEIRO:
			nodo->token.ival = atoi(valor);
			break;
		case TIPO_STRING:
			nodo->token.sval = strdup(valor);
			break;
		case TIPO_VETOR:
			nodo->token.tval = nodotipo->tipo;
			break;
		default:
		break;
	}
	
	return nodo;
}

int numNodos( Nodo **nodo)
{
	int i = 1;
	while (nodo[i-1])
	{
		i++;
	}
	return i-1;
}
Nodo *criaNodoFuncao( char *identificador, Nodo *tipofunc,  Nodo **parametros, Nodo *corpo ){
	Nodo *nodofuncao = criarNodo();
	nodofuncao->nome = strdup(identificador);
	nodofuncao->tipo = TIPO_CHAMADA_FUNCAO;
	nodofuncao->token.tval = tipofunc->tipo;
	Nodo *filhos[MAXNODOS] = {NULL};
	int nparametros = numNodos(parametros);
	int i =0;
	while(i < nparametros){
		if(parametros[i]){
			filhos[i] = parametros[i];
		}
		i++;
	}
	filhos[i] = corpo;
	nodofuncao->filhos = filhos;
	return nodofuncao;
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

Nodo** criaVetorNodo(Nodo *nodo){
	Nodo *n[1]={NULL};
    n[0] = nodo;
	return n;
}
Nodo** criaVetorNodoRecursivo(Nodo *nodo, Nodo **nodos){
	Nodo *n[MAXNODOS] = {NULL};
    n[0] = nodo;
	int nn = 1;
    int i = 1;
    while(nodos[i-1] && nn < MAXNODOS){
    	n[i] = nodos[i-1];
        i++;
		nn++;
    }
	return n;
}

Nodo *criarIF( Nodo *corpocomandos){
	Nodo *n = criarNodo;
	n->nome = strdup("IF");
	n[0]=corpocomandos;
	return n;
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

