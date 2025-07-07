#ifndef ABSTRACTSINTATICTREE
#define ABSTRACTSINTATICTREE
#define MAXNODOS 10
#define NIVEIS 1000
#define ESPACOARVORE 10
#define TAM 1000


typedef enum _Tipo{
	TIPO_REGRA,
	TIPO_INT,
	TIPO_FLOAT,
	TIPO_CHAR,
	TIPO_FOR,
	TIPO_WHILE,
	TIPO_IF,
	TIPO_ELSE,
	TIPO_SWICTH,
	TIPO_BREAK,
	TIPO_RETURN,
	TIPO_FUNCAO,
	TIPO_CLASSE,
	TIPO_IDENTIFICADOR,
	TIPO_IDENTIFICADORCLASSE,
	TIPO_INTEIRO,
	TIPO_STRING,
	TIPO_DECIMAL,
	TIPO_CHAMADA_FUNCAO,
	TIPO_CHAMADA_METODO,
	TIPO_VETOR
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
	struct Nodo **filhos;
} Nodo;
typedef struct AST{
	Nodo *raiz;
}AST;
AST  *criarAST();
Nodo *criarNodo();
void vaziaAST(AST *arvore);
Nodo *operacaoNodo(char *regra, double num1,char op, double num2);
Nodo *valorNodo(Tipo tipo, char *valor, Nodo *nodotipo );
int numNodos( Nodo **nodo);
Nodo *criaNodoFuncao( char *identificador, Nodo *tipofunc, Nodo **parametros, Nodo *corpo );
void printNodo(Nodo *nodo);
char *strTipo(Tipo tipo);
void printNodoFilhos(Nodo *n, int nivel,int niveis[NIVEIS][1]);
Nodo** criaVetorNodo(Nodo *nodo);
Nodo **concactenaFilhosdeNodos(Nodo **n1, Nodo **n2);
Nodo** criaVetorNodoRecursivo(Nodo *nodo, Nodo **nodo_direita);
Nodo *criarIF( Nodo *corpocomandos);
char *stringNivel(int nivel, int niveis[NIVEIS][1]);
#endif
