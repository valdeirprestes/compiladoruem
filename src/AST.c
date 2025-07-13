#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "AST.h"


Nodo *criarNodo(char *nome, Tipo tipo, int linha, int coluna)
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
	n->filhos = NULL;
	return n;
}

int addFilhoaoNodo(Nodo *nodopai, Nodo *nodofilho)
{
	if(!nodopai || !nodofilho){
		return FRACASSO;
	}
	nodopai->filhos= realloc(nodopai->filhos, sizeof(Nodo*) * (nodopai->nfilhos + 1));
	nodopai->filhos[nodopai->nfilhos] = nodofilho;
	nodopai->nfilhos += 1;
	return SUCESSO;
}

Nodo *criarNodoComFilho(char *nome, Tipo tipo, int linha, int coluna, Nodo *nodofilho){
	Nodo *nodopai = criarNodo(nome, tipo, linha, coluna);
    addFilhoaoNodo(nodopai, nodofilho);
    return nodopai;
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
	while( i < nodo->nfilhos ){
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
	case TIPO_IFELSE:
		strncpy(nome,"IFTIPO_ELSE", TAM);
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
	case TIPO_BLOCO:
		strncpy(nome,"TIPO_BLOCO", TAM);
		break;
	case TIPO_OPERACAO:
		strncpy(nome,"TIPO_OPERACAO", TAM);
		break;
	case TIPO_TESTEBOLEAN:
		strncpy(nome,"TIPO_BOLEAN", TAM);
		break;
	case TIPO_ARGUMENTOS:
		strncpy(nome,"TIPO_ARGUMENTOS", TAM);
		break;
	case TIPO_PARAMETROS:
		strncpy(nome,"TIPO_PARAMETROS", TAM);
		break;
	case TIPO_SOMA:
		strncpy(nome,"TIPO_SOMA", TAM);
		break;
	case TIPO_DIVISAO:
		strncpy(nome,"TIPO_DIVISAO", TAM);
		break;
	case TIPO_MULTIPLICACAO:
		strncpy(nome,"TIPO_MULTIPLICACAO", TAM);
		break;
	case TIPO_SUBTRACAO:
		strncpy(nome,"TIPO_SUBTRACAO", TAM);
		break;
	case TIPO_ATRIBUICAO:
		strncpy(nome,"TIPO_ATRIBUICAO", TAM);
		break;
	case TIPO_TESTE_IGUAL:
		strncpy(nome,"TIPO_TESTE_IGUAL", TAM);
		break;
	case TIPO_TESTE_DIFERENTE:
		strncpy(nome,"TIPO_TESTE_DIFERENTE", TAM);
		break;
	case TIPO_TESTE_MAIOR:
		strncpy(nome,"TIPO_TESTE_MAIOR", TAM);
		break;
	case TIPO_TESTE_MAIORIGUAL:
		strncpy(nome,"TIPO_TESTE_MAIORIGUAL", TAM);
		break;
	case TIPO_TESTE_MENOR:
		strncpy(nome,"TIPO_TESTE_MENOR", TAM);
		break;
	case TIPO_TESTE_MENOR_IGUAL:
		strncpy(nome,"TIPO_TESTE_MENOR_IGUAL", TAM);
		break;
	case TIPO_OP_OU:
		strncpy(nome,"TIPO_OP_OU", TAM);
		break;
	case TIPO_OP_AND:
		strncpy(nome,"TIPO_OP_AND", TAM);
		break;
	case TIPO_OP_NEGACAO:
		strncpy(nome,"TIPO_OP_NEGACAO", TAM);
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
	while( i <  n->nfilhos ){
		printNodoFilhos(n->filhos[i], nivel + 1, niveis);
		i+=1;
	}
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
	espaco[i]='\0';
	return strdup(espaco);
}

Nodo *criarNodoFuncao(char *nome, Nodo *tipofuncao, Nodo* parametrosfunc, Nodo* corpofuncao, int linha, int coluna){
	Nodo *nodo = criarNodo(nome, TIPO_FUNCAO, linha, coluna);
    addFilhoaoNodo(nodo, tipofuncao);
    addFilhoaoNodo(nodo, parametrosfunc);
    addFilhoaoNodo(nodo, corpofuncao);
	return nodo;
}

Nodo *addRecursivoNodo(char *nome, Tipo tipo, int linha, int coluna, Nodo *nodo1, Nodo *nodo2){
	if(nodo1 )
	{
		addFilhoaoNodo(nodo1, nodo2);
		return nodo1;
	}
	else if (nodo2)
	{
        Nodo *n = criarNodoComFilho(nome, tipo, linha, coluna, nodo2);
		return n;
	}
	else
		return NULL;
}

Nodo *criarExpOperador( char *operador, Nodo *expr1, Nodo *expr2, int linha, int coluna )
{
	Tipo tipo;
	char nome[20];
	if(!operador || !expl || !exp2 || linha < 1 || coluna <1) return NULL;

	if (strcmp(operador, "=" ) == 0){ //t_igual
		strncpy(nome, "Atribuicao",10);
		tipo = TIPO_ATRIBUICAO;
	}else if (strcmp(operador, "+" ) == 0){ //t_mais
		strncpy(nome, "Soma",10);
		tipo = TIPO_SOMA;
	}else if (strcmp(operador, "-") == 0){ // t_menos
		strncpy(nome, "Subtracao",10);
		tipo = TIPO_SUBTRACAO;
	}else if (strcmp(operador, "*") == 0){ // t_asteristico
		strncpy(nome, "Multiplicacao",10);
		tipo = TIPO_MULTIPLICACAO;
	}else if (strcmp(operador, "/") == 0){// t_barra
		strncpy(nome, "Divisao",10);
		tipo = TIPO_DIVISAO;
	}else if (strcmp(operador, "==") == 0){//t_igual_a
		strncpy(nome, "ComparacaoIgualdade",10);
		tipo = TIPO_TESTE_IGUAL;
	}else if (strcmp(operador, "!=") == 0){//t_diferente_de
		strncpy(nome, "ComparacaoDiferente",10);
		tipo = TIPO_TESTE_DIFERENTE;
	}else if (strcmp(operador,">") == 0){ //t_maior
		strncpy(nome, "ComparacaoMaior",10);
		tipo = TIPO_TESTE_MAIOR;
	}else if (strcmp(operador,">=") == 0){ //t_maior_igual
		strncpy(nome, "ComparacaoMaiorIgual",10);
		tipo = TIPO_TESTE_MAIORIGUAL;
	}else if (strcmp(operador,"<") == 0){ //t_menor
		strncpy(nome, "ComparacaoMenor",10);
		tipo = TIPO_TESTE_MENOR;
	}else if (strcmp(operador,"<=") == 0){ //t_maior
		strncpy(nome, "ComparacaoMenorIgual",10);
		tipo = TIPO_TESTE_MENOR_IGUAL;
	}else if (strcmp(operador,"||") == 0){ //t_or_logico
		strncpy(nome, "TesteOU",10);
		tipo = TIPO_OP_OU;
	}else if (strcmp(operador,"&&") == 0){ //t_and_logico
		strncpy(nome, "TesteE",10);
		tipo = TIPO_OP_AND;
	}else if (strcmp(operador,"!") == 0){ //t_not_logico
		strncpy(nome, "Negacao",10);
		tipo = TIPO_OP_NEGACAO;
	}else {
		strncpy(nome, "Desconhecido",10);
		tipo = TIPO_REGRA;
	}

	Nodo *n = criarNodo( nome, tipo , linha, coluna);
    addFilhoaoNodo(n, expr1);
    addFilhoaoNodo(n, expr2);
    return n;
}




