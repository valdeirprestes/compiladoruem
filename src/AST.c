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
	n->nome =nome;
	n->tipo = tipo;
	n->linha = linha;
	n->coluna = coluna;
	n->nfilhos = 0;
	n->filhos = NULL;
	n->tipo_id = TIPO_NADA;
	n->tipo_vetor =  TIPO_NADA;
	return n;
}

Nodo *criarNodoDeclaracao(Nodo *idcomfilhotipo, int linha, int coluna){
	Nodo *n= criarNodo("Declaracao", TIPO_DECLARACAO, linha, coluna);
	addFilhoaoNodo(n, idcomfilhotipo);
	return n;
}

Nodo *criarNodoParametro(Nodo *idcomfilhotipo, int linha, int coluna){
	Nodo *n= criarNodo("Parametro", TIPO_PARAMETRO, linha, coluna);
	addFilhoaoNodo(n, idcomfilhotipo);
	return n;
}


Nodo *criarNodoIdentificador(char *nome, Tipo tipo, int linha, int coluna, Nodo *nodotipo)
{
	Nodo *nodo = criarNodo(nome, tipo, linha, coluna);
	if(!nodo || !nodotipo) return NULL;
	nodo->tipo_id = nodotipo->tipo;
	addFilhoaoNodo(nodo, nodotipo);
	return nodo;
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
		strncpy(nome,"", TAM);
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
	case TIPO_ID:
		strncpy(nome,"TIPO_ID", TAM);
		break;
	case TIPO_IDCLASSE:
		strncpy(nome,"TIPO_IDCLASSE", TAM);
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
	case TIPO_PARAMETRO:
		strncpy(nome,"TIPO_PARAMETRO", TAM);
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
	case TIPO_DECLARACAO:
		strncpy(nome,"TIPO_DECLARACAO", TAM);
		break;
	case TIPO_ID_VETOR:
		strncpy(nome,"TIPO_ID_VETOR", TAM);
		break;
	case TIPO_INDICE_VETOR:
		strncpy(nome,"TIPO_INDICE_VETOR", TAM);
		break;
	case TIPO_METODOCLASSE:
		strncpy(nome,"TIPO_METODOCLASSE", TAM);
		break;
	case TIPO_NADA:
		strncpy(nome,"", TAM);
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
			/*case TIPO_INTEIRO:
				printf("-> %d (%s)\n", n->token.ival, strTipo(n->tipo));
				break;*/
			case TIPO_STRING:
				printf("-> %s (%s)\n", n->token.sval, strTipo(n->tipo));
				break;
			/*case tipo_id:
				printf("-> %s (%s -> %s )\n", n->token.sval,  strTipo(n->tipo), strTipo(n->tipo_id));
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
	if(tipofuncao)
		nodo->tipo_id = tipofuncao->tipo;
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
	
	if(expr1 == expr2 ) return NULL; /*evitar loop infinitos*/
	if(!operador || !expl || !exp2 || linha < 1 || coluna <1) return NULL;

	if (strcmp(operador, "=" ) == 0){ //t_igual
		strncpy(nome, "Atribuicao",10);
		tipo = TIPO_ATRIBUICAO;
		Nodo *n = criarNodo( nome, tipo , linha, coluna);
    	addFilhoaoNodo(expr1,n);
    	addFilhoaoNodo(n, expr2);
    	return expr1;
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




char* retornaPadraoToken(char *token) {
    if (token == NULL) {
        return NULL;
    }

    // Usamos uma série de if-else if para mapear os nomes dos tokens aos seus padrões.
    // Lembre-se de que a string retornada é alocada dinamicamente.
    if (strcmp(token, "t_igual_a") == 0) {
        return strdup("==");
    } else if (strcmp(token, "t_diferente_de") == 0) {
        return strdup("!=");
    } else if (strcmp(token, "t_menor_ou_igual") == 0) {
        return strdup("<=");
    } else if (strcmp(token, "t_maior_ou_igual") == 0) {
        return strdup(">=");
    } else if (strcmp(token, "t_and_logico") == 0) {
        return strdup("&&");
    } else if (strcmp(token, "t_or_logico") == 0) {
        return strdup("||");
    } else if (strcmp(token, "t_not_logico") == 0) {
        return strdup("!");
    } else if (strcmp(token, "t_virgula") == 0) {
        return strdup(",");
    } else if (strcmp(token, "t_pontovirgula") == 0) {
        return strdup(";");
    } else if (strcmp(token, "t_igual") == 0) {
        return strdup("=");
    } else if (strcmp(token, "t_maior") == 0) {
        return strdup(">");
    } else if (strcmp(token, "t_menor") == 0) {
        return strdup("<");
    } else if (strcmp(token, "t_mais") == 0) {
        return strdup("+");
    } else if (strcmp(token, "t_menos") == 0) {
        return strdup("-");
    } else if (strcmp(token, "t_asteristico") == 0) {
        return strdup("*");
    } else if (strcmp(token, "t_barra") == 0) {
        return strdup("/");
    } else if (strcmp(token, "t_abrivetor") == 0) {
        return strdup("[");
    } else if (strcmp(token, "t_fechavetor") == 0) {
        return strdup("]");
    } else if (strcmp(token, "t_abriparentes") == 0) {
        return strdup("(");
    } else if (strcmp(token, "t_fechaparentes") == 0) {
        return strdup(")");
    } else if (strcmp(token, "t_abrichave") == 0) {
        return strdup("{");
    } else if (strcmp(token, "t_fechachave") == 0) {
        return strdup("}");
    } else if (strcmp(token, "t_interrogacao") == 0) {
        return strdup("?");
    } else if (strcmp(token, "t_doispontos") == 0) {
        return strdup(":");
    } else if (strcmp(token, "t_ponto") == 0) {
        return strdup(".");
    } else if (strcmp(token, "t_identificadorclasse") == 0) {
        return strdup("variavel de classe");
    } else if (strcmp(token, "t_int") == 0) {
        return strdup("int");
    } else if (strcmp(token, "t_float") == 0) {
        return strdup("float");
    } else if (strcmp(token, "t_char") == 0) {
        return strdup("char");
    } else if (strcmp(token, "t_if") == 0) {
        return strdup("if");
    } else if (strcmp(token, "t_else") == 0) {
        return strdup("else");
    } else if (strcmp(token, "t_return") == 0) {
        return strdup("return");
    } else if (strcmp(token, "t_class") == 0) {
        return strdup("class");
    } else if (strcmp(token, "t_this") == 0) {
        return strdup("this");
    } else if (strcmp(token, "t_construtor") == 0) {
        return strdup("construtor");
    } else if (strcmp(token, "t_destrutor") == 0) {
        return strdup("destrutor");
    } else if (strcmp(token, "t_for") == 0) {
        return strdup("for");
    } else if (strcmp(token, "t_while") == 0) {
        return strdup("while");
    } else if (strcmp(token, "t_switch") == 0) {
        return strdup("switch");
    } else if (strcmp(token, "t_case") == 0) {
        return strdup("case");
	} else if (strcmp(token, "t_identificador") == 0) {
        return strdup("variavel");
    } else if (strcmp(token, "t_default") == 0) {
        return strdup("default");
    } else if (strcmp(token, "t_break") == 0) {
        return strdup("break");
    }
    return NULL;
}




char* substituirStringPadrao(const char* stringOriginal, const char* stringPadrao, const char* stringSubstituicao) {
    if (!stringOriginal || !stringPadrao || !stringSubstituicao) {
        return NULL; 
	}
    
    size_t lenOriginal = strlen(stringOriginal);
    size_t lenPadrao = strlen(stringPadrao);
    size_t lenSubstituicao = strlen(stringSubstituicao);

    
    if (lenPadrao == 0) {
        return strdup(stringOriginal);
    }

    char* resultado = NULL;
    char* temp = NULL; 
    const char* p = stringOriginal; 
    size_t deslocamento = 0; 

    size_t capacidadeResultado = lenOriginal + 1; 
    resultado = (char*)malloc(capacidadeResultado);
    if (!resultado) return NULL;
    resultado[0] = '\0'; 

    while ((temp = strstr(p, stringPadrao)) != NULL) {
        size_t parteAntesLen = temp - p;

        size_t novoTamanhoNecessario = deslocamento + parteAntesLen + lenSubstituicao + 1;
        if (novoTamanhoNecessario > capacidadeResultado) {
            capacidadeResultado = novoTamanhoNecessario * 2; 
            char* novoResultado = (char*)realloc(resultado, capacidadeResultado);
            if (!novoResultado) {
                free(resultado);
                return NULL;
            }
            resultado = novoResultado;
        }

        strncat(resultado + deslocamento, p, parteAntesLen); 
        deslocamento += parteAntesLen;
        resultado[deslocamento] = '\0'; 

        strcat(resultado + deslocamento, stringSubstituicao);
        deslocamento += lenSubstituicao;

        p = temp + lenPadrao;
    }

    size_t parteFinalLen = strlen(p);
    if (parteFinalLen > 0) {
        size_t novoTamanhoNecessario = deslocamento + parteFinalLen + 1;
        if (novoTamanhoNecessario > capacidadeResultado) {
            char* novoResultado = (char*)realloc(resultado, novoTamanhoNecessario); 
            if (!novoResultado) {
                free(resultado);
                return NULL;
            }
            resultado = novoResultado;
        }
        strcat(resultado + deslocamento, p);
    }

    return resultado;
}
