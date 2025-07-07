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
	n->filhos = NULL;
	n->tipo = TIPO_REGRA;
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
	if(!nodo) return 0;
	while (nodo[i-1])
	{
		i++;
	}
	return i-1;
}
Nodo *criaNodoFuncao( char *identificador, Nodo *tipofunc,  Nodo **parametros, Nodo *corpo ){
	Nodo *nodofuncao = criarNodo();
	nodofuncao->nome = strdup(identificador);
	nodofuncao->tipo = TIPO_FUNCAO;
	nodofuncao->token.tval = tipofunc->tipo;
	Nodo **filhos= criaVetorNodo(NULL);
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
	
	for (int i= 0; i< NIVEIS; i++) niveis[i][0] = 0;
	niveis[0][0] = 1;
	printf("|(%s)\n",  nodo->nome);
	int i =0;
	if(!nodo->filhos) return;
	while( nodo->filhos[i] ){
		if(nodo->filhos[i])
			printNodoFilhos(nodo->filhos[i], 1, niveis);
		i++;
	}
}

char *strTipo(Tipo tipo){
	char nome[TAM];
	switch (tipo)
	{
	case TIPO_REGRA:
		strncpy(nome,"TIPO_REGRA", TAM);
		break;
	case TIPO_INT:
		strncpy(nome,"TIPO_INT", TAM);
		break;
	case TIPO_FLOAT:
		strncpy(nome,"TIPO_FLOAT", TAM);
		break;
	case TIPO_CHAR:
		strncpy(nome,"TIPO_CHAR", TAM);
		break;
	case TIPO_FOR:
		strncpy(nome,"TIPO_FOR", TAM);
		break;
	case TIPO_WHILE:
		strncpy(nome,"TIPO_WHILE", TAM);
		break;
	case TIPO_IF:
		strncpy(nome,"TIPO_IF", TAM);
		break;
	case TIPO_ELSE:
		strncpy(nome,"TIPO_ELSE", TAM);
		break;
	case TIPO_SWICTH:
		strncpy(nome,"TIPO_SWICTH", TAM);
		break;
	case TIPO_BREAK:
		strncpy(nome,"TIPO_BREAK", TAM);
		break;
	case TIPO_RETURN:
		strncpy(nome,"TIPO_RETURN", TAM);
		break;
	case TIPO_FUNCAO:
		strncpy(nome,"TIPO_FUNCAO", TAM);
		break;
	case TIPO_CLASSE:
		strncpy(nome,"TIPO_CLASSE", TAM);
		break;
	case TIPO_IDENTIFICADOR:
		strncpy(nome,"TIPO_IDENTIFICADOR", TAM);
		break;
	case TIPO_IDENTIFICADORCLASSE:
		strncpy(nome,"TIPO_IDENTIFICADORCLASSE", TAM);
		break;
	case TIPO_INTEIRO:
		strncpy(nome,"TIPO_INTEIRO", TAM);
		break;
	case TIPO_STRING:
		strncpy(nome,"TIPO_STRING", TAM);
		break;
	case TIPO_DECIMAL:
		strncpy(nome,"TIPO_DECIMAL", TAM);
		break;
	case TIPO_CHAMADA_FUNCAO:
		strncpy(nome,"TIPO_CHAMADA_FUNCAO", TAM);
		break;
	case TIPO_CHAMADA_METODO:
		strncpy(nome,"TIPO_CHAMADA_METODO", TAM);
		break;
	case TIPO_VETOR:
		strncpy(nome,"TIPO_VETOR", TAM);
		break;
	default:
		strncpy(nome,"DESCONHECIDO", TAM);
		break;
	}
	return strdup(nome);
}
void printNodoFilhos(Nodo *n, int nivel, int niveis[NIVEIS][1])
{
	if(!n) return;
	
	if(nivel > 0){
		printf("%s", stringNivel(nivel, niveis)); /*, n->nome, n->valor);*/
		switch (n->tipo)
		{
			case TIPO_DECIMAL:
				printf("-> %.2f (%s)\n", n->token.dval, strTipo(n->tipo));
				break;
			case TIPO_INTEIRO:
				printf("-> %d (%s)\n", n->token.ival, strTipo(n->tipo));
				break;
			case TIPO_STRING:
				printf("-> %s (%s)\n", n->token.sval, strTipo(n->tipo));
				break;
			case TIPO_IDENTIFICADOR:
				printf("-> %s (%s -> %s )\n", n->token.sval,  strTipo(n->tipo), strTipo(n->tipo_identificador));
				break;
			default: /*depuração*/
				printf("-> %s (%s)\n", n->nome, strTipo(n->tipo));

				break;
		}
	}
	//printf("passou aqui nivel %d \n", nivel);
	int i=0;	
	while(n->filhos && i < MAXNODOS && n && n->filhos[i] ){
		printNodoFilhos(n->filhos[i], nivel + 1, niveis);
		i+=1;
		if(!n) break;
	}
}


Nodo** criaVetorNodo(Nodo *nodo){
	Nodo **n= malloc(MAXNODOS * sizeof(Nodo*));
	for(int i=0; i< MAXNODOS; i++) n[i]= NULL;
    n[0] = nodo;
	return n;
}

Nodo **concactenaFilhosdeNodos(Nodo **n1, Nodo **n2)
{
	int tam = numNodos(n1) + numNodos(n2);
	Nodo **n= malloc((tam+1) * sizeof(Nodo*));
	printf("n ogual a %d\n", numNodos(n1));
	printf("n ogual a %d\n", numNodos(n2));
	if(!n){
		printf("Não conseguiu alocar memoria em concacterFilhos\n");
		exit(-1);
	}
	for(int i=0; i< (tam+1); i++) n[i]= NULL;
	int cont = 0;
	if(n1)
	{
		while (n1[cont])
		{
			n[cont] = n1[cont];
			cont++;
		}
	}
	int cont2=0;
	if(n2)
	{
		while (n2[cont2])
		{
			n[cont] = n2[cont2];
			cont+= 1;
			cont2+=1;
		}
	}
	return n;
}
Nodo** criaVetorNodoRecursivo(Nodo *nodo, Nodo **nodo_direita){
	Nodo **n = criaVetorNodo(nodo);
	int nn = 1;
    int i = 1;
    while(nodo_direita[i-1] && nn < MAXNODOS){
    	n[i] = nodo_direita[i-1];
        i++;
		nn++;
    }
	return n;
}

Nodo *criarIF( Nodo *corpocomandos){
	Nodo *n = criarNodo();
	n->nome = strdup("IF");
	n->filhos = criaVetorNodo(NULL);
	n->filhos[0]=corpocomandos;
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

