#include "simbolo.h"

Simbolo *tabelaSimbolos = NULL;
char *escopoAtual = "global";
extern int debug;



Simbolo* buscarSimbolo(const char *nome, const char *escopo) {
    Simbolo *atual = tabelaSimbolos;
    if(!nome) return NULL;
    while (atual != NULL) {
        if (strcmp(atual->nome, nome) == 0 && strcmp(atual->escopo, escopo) == 0) {
            return atual;
        }
        atual = atual->proximo;
    }
    return NULL;
}

void inserirSimbolo(const char *nome, const char *escopo, Tipo tipo, int isParametro, int isVetor, char *tipo_classe, Tipo tipo_identificador, int linha, int coluna) {
    Simbolo *simboloExistente = buscarSimbolo(nome, escopo);
    if(!nome){
        return;
    }
    if (simboloExistente != NULL) {
        fprintf(stderr, "Erro Semântico: Símbolo '%s' já declarado no escopo '%s' na linha %d, coluna %d.\n", nome, escopo, linha, coluna);
        return;
    }

    Simbolo *novoSimbolo = (Simbolo*) malloc(sizeof(Simbolo));
    if (novoSimbolo == NULL) {
        perror("Erro ao alocar memória para o símbolo");
        exit(EXIT_FAILURE);
    }

    novoSimbolo->nome = strdup(nome);
    if (novoSimbolo->nome == NULL) { perror("strdup nome"); exit(EXIT_FAILURE); }
    novoSimbolo->escopo = strdup(escopo);
    if (novoSimbolo->escopo == NULL) { perror("strdup escopo"); exit(EXIT_FAILURE); }
    novoSimbolo->tipo = tipo;
    novoSimbolo->parametro = isParametro;
    novoSimbolo->vetor = isVetor;
    novoSimbolo->linha = linha;
    novoSimbolo->coluna = coluna;
    novoSimbolo->proximo = NULL;
    novoSimbolo->tipo_tipo_identificador = tipo_identificador;

    if (tabelaSimbolos == NULL) {
        tabelaSimbolos = novoSimbolo;
    } else {
        Simbolo *atual = tabelaSimbolos;
        while (atual->proximo != NULL) {
            atual = atual->proximo;
        }
        atual->proximo = novoSimbolo;
    }
    // Usando strTipo para imprimir o nome do tipo
    char *tipoStr = strTipo(tipo);
    if(debug)
        printf("Símbolo inserido: Nome='%s', Escopo='%s', Tipo=%s (parâmetro:%d, vetor:%d), Linha=%ld, Coluna=%ld\n",
           nome, escopo, tipoStr, isParametro, isVetor, linha, coluna);
    free(tipoStr); // Liberar a memória alocada por strdup em strTipo
}

void liberarTabelaSimbolos() {
    Simbolo *atual = tabelaSimbolos;
    while (atual != NULL) {
        Simbolo *proximo = atual->proximo;
        free(atual->nome);
        free(atual->escopo);
        free(atual);
        atual = proximo;
    }
    tabelaSimbolos = NULL;
    printf("Tabela de símbolos liberada.\n");
}

void imprimirTabelaSimbolos() {
    printf("\n________________________________________ Tabela de Símbolos ________________________________________\n");
    if (tabelaSimbolos == NULL) {
        printf("Tabela de símbolos vazia.\n");
        return;
    }

    Simbolo *atual = tabelaSimbolos;
    if(atual !=NULL)
    printf("%20s %-20s %-30s %-5s %5s %5s %8s\n", "Nome","Escopo","Tipo", "Parm", "Vetor", "Classe", "tipo_id");
    printf("----------------------------------------------------------------------------------------------------\n");
    while (atual != NULL) {
        char *tipoSimboloStr = strTipo(atual->tipo); // Usando strTipo
        printf("%-20s %-20s %-30s %-5s %5s %5s %8s\n",
            atual->nome,
            atual->escopo,
            tipoSimboloStr,
            atual->parametro ? "Sim" : "Não",
            atual->vetor ? "Sim" : "Não",
            atual->tipo_classe? "Sim":"Não",
            atual->tipo_tipo_identificador != TIPO_REGRA? strTipo(atual->tipo_tipo_identificador):""
        );
        free(tipoSimboloStr); 
        atual = atual->proximo;
    }
    printf("----------------------------------------------------------------------------------------------------\n");
}

void gerarTabelaSimbolosDaAST(Nodo *no) {
    /*
    Acho declaracao -> insere tabela variavel / funcao / classe
    Acho indetificador -> valida declaracao e faz operacao
    Acho operacao -> bloco de codigo
    */

    if (no == NULL) {
        return;
    }
    char *escopoAnterior = NULL;
    
    if((no->tipo == TIPO_DECLARACAO || no->tipo == TIPO_PARAMETRO )&& no->nfilhos >= 2){
        Nodo *nofilho = no->filhos[1];
        if (nofilho->tipo == TIPO_IDENTIFICADOR || 
            nofilho->tipo == TIPO_IDENTIFICADORVETOR || 
            nofilho->tipo == TIPO_FUNCAO ||
            nofilho->tipo == TIPO_CLASSE ) {
            int isVetor = (no->filhos[0]->tipo == TIPO_VETOR )? 1 :0;
            int isParametro = (no->tipo == TIPO_PARAMETRO)? 1: 0;
            inserirSimbolo(nofilho->nome, escopoAtual, no->filhos[0]->tipo, isParametro, isVetor,NULL,nofilho->tipo_identificador, nofilho->linha, nofilho->coluna);
            /*for(int i=1; i < nofilho->nfilhos; i++){
                addFilhoaoNodo(nofilho, no->filhos[i]);
            }*/
        }
    }
    else if ( no->tipo == TIPO_FUNCAO){
        escopoAnterior = escopoAtual;
        escopoAtual = no->nome;
    }
    if(no->tipo ==TIPO_PARAMETROS);
    if(no->tipo == TIPO_BLOCO);
    /*  
    else if(( no->tipo == TIPO_FUNCAO ||
            no->tipo == TIPO_CLASSE ) && no->filhos){
        
        if (no->tipo == TIPO_FUNCAO || no->tipo == TIPO_CLASSE ) {
            escopoAnterior = escopoAtual;
            escopoAtual = no->nome;
            char *noTipoStr = strTipo(no->tipo);
            if(debug)
            printf(">>> Entrando no escopo: %s (Nó: %s, Tipo: %s)\n", escopoAtual, no->nome, noTipoStr);
            free(noTipoStr);
        }
        
        if (no->tipo == TIPO_IDENTIFICADOR && no->filhos[0] ) {
            int isVetor = 0;
            int isParametro = 0;
            inserirSimbolo(no->nome, escopoAtual, no->tipo, isParametro, isVetor,NULL,no->tipo_identificador, no->linha, no->coluna);
        }
        
        
        else if (no->tipo == TIPO_FUNCAO || no->tipo == TIPO_METODOCLASSE) {
            inserirSimbolo(no->nome, escopoAnterior, no->tipo, 0, 0, NULL, no->tipo_identificador,no->linha, no->coluna);
            for (int i = 0; i < no->nfilhos; i++) {
                Nodo *filho = no->filhos[i];
                if (filho->tipo == TIPO_PARAMETROS) {
                    for (int j = 0; j < filho->nfilhos; j++) {
                        Nodo *paramNode = filho->filhos[j];
                        if (paramNode->tipo == TIPO_IDENTIFICADOR && paramNode->tipo_identificador != TIPO_REGRA) {
                            int isVetorParam = 0; 
                            inserirSimbolo(paramNode->token.sval, escopoAtual, paramNode->tipo_identificador, 1,  isVetorParam, NULL, paramNode->tipo_identificador, paramNode->linha, paramNode->coluna);
                        }
                    }
                    break;
                }
            }
        }
        
        else if (no->tipo == TIPO_CLASSE) {
            inserirSimbolo(no->nome, escopoAnterior, TIPO_CLASSE, 0, 0,NULL, no->tipo_identificador,no->linha, no->coluna);
        }
        else if (no->tipo == TIPO_IDENTIFICADOR && no->filhos[0] ) {
            int isVetor = 0;
            int isParametro = 0;
            inserirSimbolo(no->nome, escopoAtual, no->tipo, isParametro, isVetor,NULL,no->tipo_identificador, no->linha, no->coluna);
        }

        

    }*/
    // --- Percorrer os filhos (recursão) ---
    for (int i = 0; i < no->nfilhos; i++) 
        gerarTabelaSimbolosDaAST(no->filhos[i]);
    // --- Lógica de Saída de Escopo ---
    if ( (no->tipo == TIPO_FUNCAO || no->tipo == TIPO_CLASSE || no->tipo == TIPO_METODOCLASSE ) && escopoAnterior ) {
        char *noTipoStr = strTipo(no->tipo);
        if(debug)
            printf("<<< Saindo do escopo: %s (Nó: %s, Tipo: %s)\n", escopoAtual, no->nome, noTipoStr);
        free(noTipoStr); // Liberar memória
        escopoAtual = escopoAnterior;
    }
    
}