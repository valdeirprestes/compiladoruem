#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "AST.h"

Nodo *criarNodo()
{
	Nodo *n = (Nodo*) malloc(sizeof(Nodo));
	if(!n){
		return NULL;
	}
	n->nfilhos = 0;
	n->uso = 0;
	n->filhos = NULL;
	n->tipo = TIPO_REGRA; /*default*/
	return n;
}

Nodo *criarNodo2(char *nome, Tipo tipo, int linha, int coluna)
{
	Nodo *n = (Nodo*) malloc(sizeof(Nodo));
	if(!n){
		return NULL;
	}
	if(!nome){
		printf("Nao eh possivel criar o nodo porque o nome eh invalido\n");
		exit(-1);
	}
	n->nome = nome;
	n->tipo = tipo;
	n->linha = linha;
	n->coluna = coluna;
	n->nfilhos = 0;
	n->filhos = criaVetorNodo(MAXNODOS);
	if(!n->filhos )
	{
		printf("Não conseguiu alocar os nodos filhos\n");
		free(n);
		exit(-1);
	}
	n->nfilhos = MAXNODOS;
	n->uso = 0;
	return n;
}

int addFilhoaoNodo(Nodo *nodopai, Nodo *nodofilho)
{
	if(!nodofilho){
		return FRACASSO;
	}
	if(nodopai->uso > nodopai->nfilhos){
		printf("Nodo filhos insuficientes - falta de memoria\n");
		//return FRACASSO;
		exit(-1);
	}
	nodopai->filhos[nodopai->uso] = nodofilho;
	nodopai->uso += 1;
	return SUCESSO;
}

Nodo** criaVetorNodo(int tam)
{
	Nodo **n= malloc(tam * sizeof(Nodo*));
	if (!n) return NULL;
	for(int i=0; i< tam; i++) n[i]= NULL;
	return n;
}

Nodo **concactenaFilhosdeNodos(Nodo **n1, Nodo **n2)
{
	int tam = numNodos(n1) + numNodos(n2);
	Nodo **n= malloc((tam+1) * sizeof(Nodo*));
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

Nodo *criarNodoRegraInicio(Nodo *codigos){
	Nodo *nodo = criarNodo();
	if(!nodo){
		printf("Não conseguiu alocar Nodo para regra inicio");
		exit(-1);
	}
    nodo->nome = strdup("INICIO");
	nodo->filhos = criaVetorNodo(1);
	if(!nodo->filhos){
		printf("Não conseguiu alocar Nodo para regra parametro");
		exit(-1);
	}
	nodo->nfilhos = 1;
	if(codigos)
	{
		nodo->filhos[0] = codigos;
		nodo->nfilhos =1;
	}
    return nodo;
}

Nodo *criarNodoRegraCodigos(Nodo *n1, Nodo *n2)
{
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra codigos");
		exit(-1);
	}
	n->nome=strdup("CODIGOS");
	n->tipo = TIPO_REGRA;	
	int tam = 0;
	if(n1) tam += n1->nfilhos;
	if(n2) tam += n2->nfilhos;
	n->filhos = criaVetorNodo(tam);
	if(!n->filhos){
		printf("Não conseguiu alocar filhos para o Nodo para regra codigos");
		exit(-1);
	}
	n->nfilhos = tam;
	int i=0;
	while(n1 && i < n1->nfilhos)
	{
		n->filhos[i] = n1->filhos[i];
		i += 1;
	}
	int i2 = 0;
	while( n2 && i2 < n2->nfilhos)
	{
		printf("%s", n2->filhos[i2]->nome);
		n->filhos[i] = n2->filhos[i2];
		i2 += 1;
		i += 1;
	}
	return n;
}

Nodo *criarNodoRegraParametrosFunc(Nodo *n1, Nodo *n2){
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra parametrosfunc\n");
		exit(-1);
	}
	n->nome=strdup("PARAMETROS");
	n->tipo = TIPO_REGRA;
	int tam = 0;
	if(n1) tam += n1->nfilhos;
	if(n2) tam += n2->nfilhos;
	n->filhos = criaVetorNodo(tam);
	if(!n->filhos){
		printf("Não conseguiu alocar filhos para o Nodo para regra parametrosfunc\n");
		exit(-1);
	}
	n->nfilhos = tam;
	int i=0;
	while( n1 && i < n1->nfilhos)
	{
		n->filhos[i] = n1->filhos[i];
		i += 1;
	}
	int i2 = 0;
	while( n2 && i2 < n2->nfilhos)
	{
		printf("%s", n2->filhos[i2]->nome);
		n->filhos[i] = n2->filhos[i2];
		i2 += 1;
		i += 1;
	}
	return n;
}

Nodo *criarNodoRegraParametro(Nodo *tiponodo, char *identificador, Tipo tipo ){
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra parametro\n");
		exit(-1);
	}
	n->nome=strdup("PARAMETRO");
	n->tipo = TIPO_REGRA;
	n->filhos = criaVetorNodo(1);
	if(!n->filhos){
		printf("Não conseguiu alocar Nodo para regra parametro\n");
		exit(-1);
	}
	n->nfilhos = 1;
	int tam = 1;
	n->filhos[0] = valorNodo(tipo, identificador , tiponodo);
	return n;
}
Nodo *criaNodoRegraFuncao( char *identificador, Nodo *tipofunc,  Nodo *parametros, Nodo *corpo ){
	Nodo *nodofuncao = criarNodo();
	nodofuncao->nome = strdup(identificador);
	nodofuncao->tipo = TIPO_FUNCAO;
	nodofuncao->token.tval = tipofunc->tipo;
	nodofuncao->filhos = criaVetorNodo(1);
	if(!nodofuncao->filhos){
		printf("Não conseguiu alocar Nodo para regra funcao\n");
		exit(-1);
	}
	nodofuncao->nfilhos = 1;
	nodofuncao->filhos[0] = corpo;
	return nodofuncao;
}

Nodo *criarNodoRegraCorpoFuncao( Nodo *declaracoes_comandos)
{
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra corpofuncao\n");
		exit(-1);
	}
	n->nome=strdup("FUNCAO");
	n->tipo = TIPO_FUNCAO;
	n->filhos = criaVetorNodo(1);
	if(!n->filhos){
		printf("Não conseguiu alocar Nodo para regra corpofuncao\n");
		exit(-1);
	}
	n->nfilhos = 1;
	int tam = 1;
	n->filhos[0] = declaracoes_comandos;
	return n;
}
Nodo *criarNodoRegraDeclaracao(Nodo *tiponodo, char *identificador, Tipo tipo, Nodo *filho){
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra declaracao\n");
		exit(-1);
	}
	n->nome=strdup("DECLARACAO");
	n->tipo = TIPO_REGRA;
	int tam = 1;
	if(filho) tam +=1;
	n->filhos = criaVetorNodo(tam);
	if(!n->filhos){
		printf("Não conseguiu alocar Nodo para regra declaracao\n");
		exit(-1);
	}
	n->nfilhos = tam;
	
	n->filhos[0] = valorNodo(tipo, identificador , tiponodo);
	if(filho)
		n->filhos[1] = filho;
	return n;
}
Nodo *criarNodoRegraDeclaracoesComandos(Nodo *n1, Nodo *n2){
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra declaracao_comandos\n");
		exit(-1);
	}
	n->nome=strdup("DECLARACAO_COMANDOS");
	n->tipo = TIPO_REGRA;
	int tam = 0;
	if(n1) tam += n1->nfilhos;
	if(n2) tam += n2->nfilhos;
	n->filhos = criaVetorNodo(tam);
	if(!n->filhos){
		printf("Não conseguiu alocar filhos para o Nodo para regra declaracao_comandos\n");
		exit(-1);
	}
	int i=0;
	while( n1 && i < n1->nfilhos)
	{
		n->filhos[i] = n1->filhos[i];
		i += 1;
	}
	int i2 = 0;
	while( n2 && i2 < n2->nfilhos)
	{
		printf("%s", n2->filhos[i2]->nome);
		n->filhos[i] = n2->filhos[i2];
		i2 += 1;
		i += 1;
	}
	return n;
}

Nodo *criarNodoRegraComando( Nodo *comando)
{
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra comando\n");
		exit(-1);
	}
	n->nome=strdup("COMANDO");
	n->tipo = TIPO_REGRA;
	n->filhos = criaVetorNodo(1);
	if(!n->filhos){
		printf("Não conseguiu alocar Nodo para regra comando\n");
		exit(-1);
	}
	int tam = 1;
	n->filhos[0] = comando;
	return n;
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
	nodo->nome = strdup(valor);
	nodo->tipo = tipo;
	switch(tipo){
		case TIPO_IDENTIFICADOR: /* ainda não sei como vou ajustar */
			nodo->token.sval = strdup(valor);
			if(nodotipo)
				nodo->token.tval = nodotipo->tipo;
			break;
		case TIPO_INTEIRO:
			nodo->token.ival = atoi(valor);
			break;
		case TIPO_STRING:
			nodo->token.sval = strdup(valor);
			nodo->nfilhos = 0;
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







void printNodo(Nodo *nodo)
{
	int niveis[NIVEIS][1];
	
	for (int i= 0; i< NIVEIS; i++) niveis[i][0] = 0;
	niveis[0][0] = 1;
	printf("|(%s)\n",  nodo->nome);
	int i =0;
	if(!nodo->filhos) return;
	while( i < nodo->uso ){
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
			/*case TIPO_IDENTIFICADOR:
				printf("-> %s (%s -> %s )\n", n->token.sval,  strTipo(n->tipo), strTipo(n->tipo_identificador));
				break;*/
			default: /*depuração*/
				printf("-> %s (%s)\n", n->nome, strTipo(n->tipo));

				break;
		}
	}
	/*printf("passou aqui nivel %d \n", nivel);*/
	int i=0;	
	while( i <  n->uso ){
		printNodoFilhos(n->filhos[i], nivel + 1, niveis);
		i+=1;
	}
}





Nodo** criaVetorNodoRecursivo(Nodo *nodo, Nodo **nodo_direita){
	Nodo **n = criaVetorNodo(MAXNODOS);
	n[1] = nodo;
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
	n->filhos = criaVetorNodo(MAXNODOS);
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

VetorNodo *novoVetorNodo(int nfilhos){
	VetorNodo *v =  malloc(sizeof(VetorNodo));
	if(!v) return NULL;
	v->uso=0;
	v->capacidade=0;
	v->nodos = NULL;
	if(nfilhos)
	{
		v->nodos = malloc(nfilhos * sizeof(Nodo*));
		if(!v) return NULL;
		v->capacidade = nfilhos;
	}
	return v;
}
int adicionarNodoaVetorNodo(VetorNodo *vetor, Nodo *nodo)
{
	if(vetor->uso + 1 > vetor->capacidade)
		return FRACASSO;
	vetor->uso += 1;
	vetor->nodos[vetor->uso - 1] = nodo;
	return SUCESSO;
}
VetorNodo *concactenarVetorNodo(VetorNodo *v1, VetorNodo *v2)
{
	int tam = 0;
	if(v1)  tam = v1->capacidade;
	if(v2)  tam += v2->capacidade;
	VetorNodo *v =  novoVetorNodo(tam);
	if(!v)
	{
		printf("Nao conseguiu alocar VetorNodo\n");
		exit(-1);
	}
	if(v1)
	{
		while(v->uso < v1->uso)
		{
			v->nodos[v->uso] = v1->nodos[v->uso];
			v->uso += 1;
		} 
	}
	if(v2)
	{
		int cont = 0;
		while(cont < v2->uso)
		{
			v->nodos[ v->uso + cont] = v2->nodos[cont];
			cont += 1;

		}
		v->uso += cont; 
	}
	return v;
}
Nodo *converterVetorParaNodo(VetorNodo *v, char *nome, Tipo tipo)
{
	Nodo *nodo = criarNodo();
	if(!nodo){
		printf("Falhou em criar o nodo para converter vetor para nodo\n");
		exit(-1);
	}
	nodo->nome = nome;
	nodo->tipo = tipo;
	nodo->nfilhos = v->uso;
	nodo->filhos = v->nodos;
	return nodo;
}

Nodo *concactenaNodosFilhos(Nodo *n1, Nodo *n2, char *sregra, Tipo tipo)
{
	Nodo *n = criarNodo();
	if(!n){
		printf("Não conseguiu alocar Nodo para regra codigos");
		exit(-1);
	}
	n->nome=strdup(sregra);
	n->tipo = TIPO_REGRA;	
	int tam = 0;
	if(n1) tam += n1->nfilhos;
	if(n2) tam += n2->nfilhos;
	n->filhos = criaVetorNodo(tam);
	if(!n->filhos){
		printf("Não conseguiu alocar filhos para o Nodo para regra codigos");
		exit(-1);
	}
	n->nfilhos = tam;
	//printf("alocado %d ", tam);
	int i=0;
	while(n1 && i < n1->nfilhos)
	{
		printf("%s", n1->filhos[i]->nome);
		n->filhos[i] = n1->filhos[i];
		i += 1;
	}
	int i2 = 0;
	while( n2 && i2 < n2->nfilhos)
	{
		printf("%s", n2->filhos[i2]->nome);
		n->filhos[i] = n2->filhos[i2];
		i2 += 1;
		i += 1;
	}
	return n;
}

