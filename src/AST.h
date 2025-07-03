#ifndef ABSTRACTSINTATICTREE
#define ABSTRACTSINTATICTREE
#define MAXNODOS 10
#define NIVEIS 1000
#define ESPACOARVORE 10
#define TAM 1000


typedef enum _Tipo{
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
	TIPO_FUNC,
	TIPO_CLASSE,
	TIPO_VARIAVEL,
	TIPO_INTEIRO,
	TIPO_STRING,
	TIPO_DECIMAL,
	TIPO_CHAMADA_FUNCAO,
	TIPO_CHAMADA_METODO
} Tipo;

typedef union token{
	char *sval;
	double dval;
	long  ival;
	char  cval;
} Token;

typedef struct Nodo{
	char *nome;
	Token token;
	Tipo tipo;
	int nfilhos;
	struct Nodo *filhos[MAXNODOS];
} Nodo;
typedef struct AST{
	Nodo *raiz;
}AST;
AST  *criarAST();
Nodo *criarNodo();
void vaziaAST(AST *arvore);
Nodo *operacaoNodo(char *regra, double num1,char op, double num2);
Nodo *valorNodo(Tipo tipo, char *valor );
void printNodo(Nodo *nodo);
void printNodoFilho(Nodo *n, int nivel,int niveis[NIVEIS][1]);
char *stringNivel(int nivel, int niveis[NIVEIS][1]);
#endif
