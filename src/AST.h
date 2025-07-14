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
	TIPO_ARGUMENTOS,
	TIPO_SOMA,
	TIPO_DIVISAO,
	TIPO_MULTIPLICACAO,
	TIPO_SUBTRACAO,
	TIPO_ATRIBUICAO,
	TIPO_TESTE_IGUAL,
	TIPO_TESTE_DIFERENTE,
	TIPO_TESTE_MAIOR,
	TIPO_TESTE_MAIORIGUAL,
	TIPO_TESTE_MENOR,
	TIPO_TESTE_MENOR_IGUAL,
	TIPO_OP_NEGACAO,
	TIPO_OP_OU,
	TIPO_OP_AND,
	TIPO_DECLARACAO
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



Nodo *criarNodo(char *nome, Tipo tipo, int linha, int coluna);
Nodo *criarNodoDeclaracao(Nodo *idcomfilhotipo, int linha, int coluna);
Nodo *criarNodoIdentificador(char *nome, Tipo tipo, int linha, int coluna, Nodo *nodotipo);
int addFilhoaoNodo(Nodo *nodopai, Nodo *nodofilho);
Nodo *criarNodoComFilho(char *nome, Tipo tipo, int linha, int coluna,Nodo *filho);
int numNodos( Nodo **nodo);
void printNodo(Nodo *nodo);
char *strTipo(Tipo tipo);
void printNodoFilhos(Nodo *n, int nivel,int niveis[NIVEIS][1]);
Nodo** criaVetorNodoRecursivo(Nodo *nodo, Nodo **nodo_direita);
char *stringNivel(int nivel, int niveis[NIVEIS][1]);
Nodo *criarNodoFuncao(char *nome, Nodo *tipofuncao, Nodo* parametrosfunc, Nodo* corpofuncao, int linha, int coluna);
Nodo *addRecursivoNodo(char *nome, Tipo tipo, int linha, int coluna, Nodo *nodo1, Nodo *nodo2);
Nodo *criarExpOperador( char *operador, Nodo *expr1, Nodo *expr2, int linha, int coluna );
#endif
