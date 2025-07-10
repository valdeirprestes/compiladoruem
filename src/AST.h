#ifndef ABSTRACTSINTATICTREE
#define ABSTRACTSINTATICTREE
#define MAXNODOS 20
#define NIVEIS 1000
#define ESPACOARVORE 10
#define TAM 1000
#define FRACASSO -1
#define SUCESSO 1



typedef enum _Tipo{
	TIPO_REGRA,
	TIPO_INT,
	TIPO_FLOAT,
	TIPO_CHAR,
	TIPO_FOR,
	TIPO_WHILE,
	TIPO_IF,
	TIPO_IFELSE,
	TIPO_SWICTH,
	TIPO_BREAK,
	TIPO_RETURN,
	TIPO_FUNCAO,
	TIPO_CLASSE,
	TIPO_IDENTIFICADOR,
	TIPO_IDENTIFICADORCLASSE,
	TIPO_METODOCLASSE,
	TIPO_CASE,
	TIPO_DEFAULT,
	TIPO_INTEIRO,
	TIPO_STRING,
	TIPO_DECIMAL,
	TIPO_CHAMADA_FUNCAO,
	TIPO_CHAMADA_METODO,
	TIPO_VETOR,
	TIPO_BLOCO,
	TIPO_OPERACAO,
	TIPO_TESTEBOLEAN,
	TIPO_PARAMETROS,
	TIPO_ARGUMENTOS
} Tipo;

typedef union token{
	char *sval;
	double dval;
	long  ival;
	char  cval;
	Tipo tval;
} Token;

typedef struct Nodo{
	char *nome;
	Token token;
	Tipo tipo;
	Tipo tipo_identificador;
	int nfilhos;
	int uso;
	long linha;
	long coluna;
	struct Nodo **filhos;
} Nodo;

typedef struct VetorNodo{
	int capacidade;
	int uso;
	Nodo **nodos;
}VetorNodo;


Nodo *criarNodo();
Nodo *criarNodo2(char *nome, Tipo tipo, int linha, int coluna);
int addFilhoaoNodo(Nodo *nodopai, Nodo *nodofilho);
Nodo** criaVetorNodo(int tam);
Nodo **concactenaFilhosdeNodos(Nodo **n1, Nodo **n2);
Nodo *criarNodoRegraInicio(Nodo *codigos);
Nodo *criarNodoRegraCodigos(Nodo *n1, Nodo *n2);
Nodo *criarNodoRegraParametrosFunc(Nodo *n1, Nodo *n2);
Nodo *criarNodoRegraParametro(Nodo *tiponodo, char *identificador, Tipo tipo );
Nodo *criaNodoRegraFuncao( char *identificador, Nodo *tipofunc, Nodo *parametros, Nodo *corpo );
Nodo *criarNodoRegraCorpoFuncao( Nodo *declaracoes_comandos);
Nodo *criarNodoRegraDeclaracao(Nodo *tiponodo, char *identificador, Tipo tipo, Nodo *filho);
Nodo *criarNodoRegraDeclaracoesComandos(Nodo *n1, Nodo *n2);
Nodo *criarNodoRegraComando( Nodo *comando);
Nodo *valorNodo(Tipo tipo, char *valor, Nodo *nodotipo );
int numNodos( Nodo **nodo);




void printNodo(Nodo *nodo);
char *strTipo(Tipo tipo);
void printNodoFilhos(Nodo *n, int nivel,int niveis[NIVEIS][1]);


Nodo** criaVetorNodoRecursivo(Nodo *nodo, Nodo **nodo_direita);
Nodo *criarIF( Nodo *corpocomandos);
char *stringNivel(int nivel, int niveis[NIVEIS][1]);
VetorNodo *novoVetorNodo(int nfilhos);
int adicionarNodoaVetorNodo(VetorNodo *vetor, Nodo *nodo);
VetorNodo *concactenarVetorNodo(VetorNodo *v1, VetorNodo *v2);
Nodo *converterVetorParaNodo(VetorNodo *v, char *nome, Tipo tipo);
Nodo *concactenaNodosFilhos(Nodo *n1, Nodo *n2, char *sregra, Tipo tipo);
#endif
