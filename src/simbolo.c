#include "simbolo.h"
#include "parser.tab.h"
Simbolo *tabelaSimbolos = NULL;
char *escopoAtual = "global";
Nodo *nodoAnterior = NULL;
Nodo *nodoEscopo = NULL;
Nodo *funcaonodo =NULL;
Nodo *classenodo = NULL;
extern int debug;
extern int errossemanticos;
extern char **source;
void printErrorsrc(char **source, int linha, int coluna);
extern int asprintf (char **__restrict __ptr,
		      char *__restrict __fmt, ...);


Simbolo* buscarSimboloPorNome( char *nome,  char *escopo) {
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
Simbolo* buscarSimboloGeral( char *nome){
    Simbolo *s = buscarSimboloPorNome( nome, escopoAtual);
    if(s != NULL) return s;
    s = buscarSimboloPorNome(nome, "global");
    return s;
}

void inserirSimbolo( char *nome,  char *escopo, Tipo tipo, int isParametro, int isVetor, char *tipo_classe, Tipo tipo_id, Tipo tipo_vetor, int linha, int coluna) {
    Simbolo *simboloExistente = buscarSimboloPorNome(nome, escopo);
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
    novoSimbolo->tipo_id = tipo_id;
    novoSimbolo->tipo_vetor = tipo_vetor;

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
    printf("%-10.10s %-10.10s %-26.26s %-15.15s %15.15s %4.4s %6.6s\n", "Nome","Escopo","Tipo", "tipo_id", "Vetor", "Parm",  "Classe");
    printf("----------------------------------------------------------------------------------------------------\n");
    while (atual != NULL) {
        char *tipoSimboloStr = strTipo(atual->tipo); // Usando strTipo
        char *tipoSimboloIdStr = strTipo(atual->tipo_id); // Usando strTipo
        char *tipoSimboloVetorStr = strTipo(atual->tipo_vetor); // Usando strTipo
        printf("%-10.10s %-10.10s %-26.26s %-15.15s %15.15s %4.4s %6.6s\n",
            atual->nome,
            atual->escopo,
            tipoSimboloStr,
            tipoSimboloIdStr,
            tipoSimboloVetorStr,
            atual->parametro ? "Sim" : "Não",
            atual->tipo_classe == NULL? "  -------  ":atual->tipo_classe
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
    char *strclasse  = NULL;
    if (no == NULL) {
        return;
    }
    char *escopoAnterior = NULL;
    if((no->tipo == TIPO_DECLARACAO || no->tipo == TIPO_PARAMETRO )&& no->nfilhos >= 2){
        Nodo *nofilho = no->filhos[1];
        if (nofilho->tipo == TIPO_ID || 
            nofilho->tipo == TIPO_ID_VETOR || 
            nofilho->tipo == TIPO_FUNCAO ||
            nofilho->tipo == TIPO_CLASSE ) {
            int isVetor = (no->filhos[0]->tipo == TIPO_VETOR )? 1 :0;
            int isParametro = (no->tipo == TIPO_PARAMETRO)? 1: 0;
            Tipo tipo_vetor = (isVetor == 0) ? TIPO_NADA: no->filhos[0]->filhos[0]->tipo;
            strclasse = (nofilho->tipo == TIPO_CLASSE)? strdup(nofilho->nome):NULL;
            inserirSimbolo(nofilho->nome, escopoAtual, nofilho->tipo, isParametro, isVetor,strclasse,nofilho->tipo_id,nofilho->tipo_vetor, nofilho->linha, nofilho->coluna);
            /*for(int i=1; i < nofilho->nfilhos; i++){
                addFilhoaoNodo(nofilho, no->filhos[i]);
            }*/
        }
    }
    else if ( no->tipo == TIPO_FUNCAO ||  no->tipo == TIPO_CLASSE || no->tipo == TIPO_METODOCLASSE){
        nodoAnterior = no;
        verificarDeclaracao(no);
        escopoAnterior = escopoAtual;
        escopoAtual = no->nome;
        if(no->tipo == TIPO_FUNCAO) funcaonodo = no;
        if(no->tipo == TIPO_CLASSE) classenodo = no;
    }
    if(no->tipo == TIPO_ID) {
        nodoAnterior = no;
        verificarDeclaracao(no);
    }
    if(no->tipo ==TIPO_PARAMETROS);
    if(no->tipo == TIPO_BLOCO);
    
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
        nodoAnterior = NULL;
        if(no->tipo == TIPO_FUNCAO) funcaonodo = NULL;
        if(no->tipo == TIPO_CLASSE) classenodo = NULL;
    }
    else if(no->tipo == TIPO_ATRIBUICAO){
        if(no->filhos[0])
            verificarAtribuicao(no->filhos[0]);
    }
    else if(no->tipo == TIPO_SOMA){
        verificarSoma(no);
    }
    else if (no->tipo == TIPO_SUBTRACAO){
        verificarSubtracao(no);
    }
    else if (no->tipo == TIPO_MULTIPLICACAO){
        verificarMultiplicacao(no);
    }
    else if(no->tipo == TIPO_DIVISAO){
        verificarDivisao(no);
    }
}




Tipo retornaTipo(Nodo *no){
        Simbolo *Simbol = buscarSimboloPorNome(no->nome, escopoAtual);
        if(Simbol == NULL){
           if(no->tipo = TIPO_INTEIRO)
                return TIPO_INT;
           if(no->tipo = TIPO_DECIMAL)
                return TIPO_FLOAT;
           if(no->tipo = TIPO_STRING)
                return  TIPO_VETOR;
        }
        if(Simbol->tipo_id == TIPO_VETOR){
            return  Simbol->tipo_vetor;
        }
        else
            return Simbol->tipo_id;
        return TIPO_NADA;
}

int tiposCompatíveis(Nodo *esq, Nodo *dir) {
    Tipo tesq = retornaTipo(esq);
    Tipo tdir = retornaTipo(dir);
    if(tesq == TIPO_NADA || tdir == TIPO_NADA) return 0;
    if(tesq == TIPO_VETOR || tdir == TIPO_VETOR ){
        Simbolo *s1 = buscarSimboloPorNome(esq->nome, escopoAtual);
        Simbolo *s2 = buscarSimboloPorNome(esq->nome, escopoAtual);
        return s1->tipo_vetor == s2->vetor;
    }
    return tdir == tesq;
}

void verificarAtribuicao(Nodo *nodo) 
{
    if ( nodoAnterior != NULL && !tiposCompatíveis(nodo, nodoAnterior)) {
        errossemanticos +=1;
        printErrorsrc(source, nodo->linha, nodo->coluna);
        printf("Erro semantico: atribuição incompativel na linha %ld coluna %ld\n", nodo->linha, nodo->coluna);
    }
}

void verificarDeclaracao(Nodo *nodo) {
    Simbolo *s = buscarSimboloGeral(nodo->nome);
    if (s == NULL) {
        errossemanticos +=1;
        printErrorsrc(source, nodo->linha, nodo->coluna);
        printf("Erro semantico: %s não foi declarada - linha %ld coluna %ld\n", nodo->nome,  nodo->linha, nodo->coluna);
    }
}

void verificarDeclaracaoLocal(Nodo *nodo, char *escopo) {
    Simbolo *s = buscarSimboloPorNome(nodo->nome, escopo);
    if (s == NULL) {
        errossemanticos +=1;
        printErrorsrc(source, nodo->linha, nodo->coluna);
        printf("Erro semantico: variavel não declarada linha %ld coluna %ld\n", nodo->linha, nodo->coluna);
    }
}


void verificarSoma(Nodo *nodo) {
    Nodo *esq = nodo->filhos[0];
    Nodo *dir = nodo->filhos[1];

    if (!tiposCompatíveis(esq, dir)) {
        errossemanticos +=1;
        printErrorsrc(source, esq->linha, esq->coluna);
        printf("Erro semantico: soma com tipos incompatíveis na linha %ld coluna %ld\n", esq->linha, esq->coluna);
    }
}

void verificarSubtracao(Nodo *nodo) {
    Nodo *esq = nodo->filhos[0];
    Nodo *dir = nodo->filhos[1];

    if (!tiposCompatíveis(esq, dir)) {
        errossemanticos +=1;
        printErrorsrc(source, esq->linha, esq->coluna);
        printf("Erro semantico: subtração com tipos incompatíveis na linha %ld coluna %ld\n", esq->linha, esq->coluna);
    }
}

void verificarMultiplicacao(Nodo *nodo) {
    Nodo *esq = nodo->filhos[0];
    Nodo *dir = nodo->filhos[1];

    if (!tiposCompatíveis(esq, dir)) {
        errossemanticos +=1;
        printErrorsrc(source, esq->linha, esq->coluna);
        printf("Erro semantico: multiplicação com tipos incompatíveis na linha %ld coluna %ld\n", esq->linha, esq->coluna);
    }
}

void verificarDivisao(Nodo *nodo) {
    Nodo *esq = nodo->filhos[0];
    Nodo *dir = nodo->filhos[1];

    if (!tiposCompatíveis(esq, dir)) {
        errossemanticos +=1;
        printErrorsrc(source, esq->linha, esq->coluna);
        printf("Erro semantico: divisão com tipos incompatíveis na linha %ld coluna %ld\n", nodo->linha, esq->coluna);
    }
}