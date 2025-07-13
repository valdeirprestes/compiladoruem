%option noyywrap
%option yylineno
%option bison-bridge
%{
	#include <string.h>
	#include "AST.h"
    #include "parser.tab.h"
	extern YYLTYPE yylloc;
	extern YYSTYPE yylval;
	
	
	extern long coluna_tmp;
	extern long imprimir_ast;
	extern char **source;
	extern long utoken_linha; /* guarda o ultimo linha com token válido -> para erros */
  	extern long utoken_coluna;/*guarda a ultima linha com token válido  -> para erros*/
  	extern long linha; /* guarda a linha do token atual  -> para erros*/
  	extern long coluna;/*guarda a coluna do token atual  -> para erros*/
	extern int debug;
	long column = 1;
	long linhacomentario = 0;
	char *meustring = NULL;
	void printErrorsrc(char **src, int linha, int coluna);
	int tam(char *s);
	void yycolumn_update(const char *text) {
    	for (int i = 0; text[i] != '\0'; ++i) {
        	if (text[i] == '\n') {
            	//yylineno++;
            	column = 1; // Reseta a coluna ao encontrar uma nova linha
       	 	} else
			{
            	column++;
        	}
    }
}
	#define SETLOC(text) { \
    yylloc.first_line = yylineno; \
    yylloc.first_column = column; \
	utoken_linha = yylloc.first_line; \
	utoken_coluna = yylloc.first_column;\
    yycolumn_update(text); \
    yylloc.last_line = yylineno; \
    yylloc.last_column = column - 1; \
	linha = yylloc.last_line; \
	coluna = yylloc.last_column; \
}
	//printf("DEBUG: Token '%s' - L%d C%d a L%d C%d\n", yytext, yylloc.first_line, yylloc.first_column, yylloc.last_line, yylloc.last_column);
%}

texto [a-zA-Z]
numero [-]*[0-9]+
decimal [-]*[0-9]+.[0-9]+
espaco [" "\t]
novalinha [\n]
variavel [a-zA-Z][a-zA-Z0-9]*
aberturacomentario [/][*]
fechamentocomentario [*][/]
varincorreta [0-9]+[\.]*[a-zA-z]

/*subscanner*/
%x comentario 
%x textoscanner
%% /* definições de toke para o flex procurar*/
{aberturacomentario} { SETLOC(yytext); linhacomentario = yylineno; BEGIN(comentario); }
<comentario>{fechamentocomentario} {SETLOC(yytext);BEGIN(INITIAL); /*É um escape do sub scanner 'comentario' - fim de comentário*/}
<comentario>[^*\n]+ {SETLOC(yytext);}
<comentario>"*" {SETLOC(yytext);}
<comentario><<EOF>> { 
	SETLOC(yytext);
	printErrorsrc(source, linhacomentario, yylineno);
	fprintf(stderr, "<< Comentario não fechado da linha %d ate a linha %d >>\n", linhacomentario , linha); 
	exit(-1); 
}
<comentario>{novalinha} { SETLOC(yytext);/* não retornar token, apenas incrementa a variável de controle*/}

\" {BEGIN(textoscanner);}
<textoscanner>\" {SETLOC(yytext);BEGIN(INITIAL);}
<textoscanner>{novalinha} { 
	SETLOC(yytext);
	printErrorsrc(source, linha, coluna);
	fprintf(stderr, "<< String quebrada na linha %d >>\n", linha);
	exit(-1);
}
<textoscanner>[^"\n]* {SETLOC(yytext);yylval->texto= strdup(yytext); return t_string;}

"==" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_igual_a;}
"!=" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_diferente_de;}
"<=" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_menor_ou_igual;}
">=" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_maior_ou_igual;}
"," {SETLOC(yytext); yylval->texto= strdup(yytext); return t_virgula;}
";" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_pontovirgula; }
"=" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_igual; }
">" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_maior; }
"<" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_menor; }
"+" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_mais;}
"-" {SETLOC(yytext);yylval->texto= strdup(yytext); return t_menos;}
"*" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_asteristico;}
"/" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_barra;}
"[" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_abrivetor;}
"]" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_fechavetor;}
"(" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_abriparentes;}
")" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_fechaparentes;}
"{" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_abrichave;}
"}" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_fechachave;}
"!" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_exclamacao;}
"?" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_interrogacao;}
":" {SETLOC(yytext); yylval->texto= strdup(yytext); return t_doispontos;}
"." {SETLOC(yytext); yylval->texto= strdup(yytext); return t_ponto;}
{variavel}"."{variavel} {SETLOC(yytext); yylval->texto= strdup(yytext); return t_identificadorclasse;}
int { SETLOC(yytext);yylval->texto= strdup(yytext); return t_int;}
float { SETLOC(yytext);yylval->texto= strdup(yytext); return t_float;}
char {SETLOC(yytext); yylval->texto= strdup(yytext); return t_char;}
if { SETLOC(yytext);yylval->texto= strdup(yytext); return t_if;}
else { SETLOC(yytext);yylval->texto= strdup(yytext); return t_else;}
return { SETLOC(yytext);yylval->texto= strdup(yytext); return t_return;}
class {SETLOC(yytext); yylval->texto= strdup(yytext); return t_class;}
this {SETLOC(yytext); yylval->texto= strdup(yytext); return t_this;}
construtor {SETLOC(yytext); yylval->texto= strdup(yytext); return t_construtor;}
destrutor {SETLOC(yytext); yylval->texto= strdup(yytext); return t_destrutor;}
for { SETLOC(yytext);yylval->texto= strdup(yytext); return t_for;}
while { SETLOC(yytext);yylval->texto= strdup(yytext); return t_while;}
switch { SETLOC(yytext);yylval->texto= strdup(yytext); return t_switch;}
case { SETLOC(yytext);yylval->texto= strdup(yytext); return t_case;}
default { SETLOC(yytext);yylval->texto= strdup(yytext); return t_default;}
break {SETLOC(yytext);yylval->texto= strdup(yytext); return t_break;}


{numero} {SETLOC(yytext); yylval->texto= strdup(yytext);  return t_num;}
{decimal} { SETLOC(yytext);yylval->texto= strdup(yytext);  return t_decimal;}
{varincorreta} {SETLOC(yytext); fprintf(stderr, "<< Linha %d: variavel incorreta ou separe numero e string >>\n", linha); exit(-1); }
{variavel} {SETLOC(yytext);yylval->texto=strdup(yytext);return t_identificador;} 
{novalinha} {SETLOC(yytext); /* não retornar token, apenas incrementa a variável de controle*/}
{espaco} {SETLOC(yytext);} /* Não faz nada, apenas consome*/


. { SETLOC(yytext);
	printErrorsrc(source, linha, coluna);
	printf("\'%c\' (linha %d coluna %d) eh um caractere misterio não usando na linguagem\n", *yytext, linha, coluna); 
	exit(-1);
	}
%%


char **alocaSource(FILE *fp, int *nlinhas){
	char linha[1000];
	char **src = malloc( 5000 * sizeof(char*));
	if(!src){ nlinhas =0; return NULL;}
	int cont=0;
	while(fgets(linha, 1000, fp)){
		src[cont] = strdup(linha);
		cont +=1;
	}
	//printf("foram %d linhas", cont);
	*nlinhas = cont;
	fseek(fp, 0, SEEK_SET);
	return src;
}

void printErrorsrc(char **src, int minhalinha, int minhacoluna)
{
	if(!src){
		printf("Não pode acessar o src");
		exit(-1);
	}
	if(minhalinha < 1 || minhacoluna < 1 ) {
		printf("Tem algo errado, por que foi solicitada impressão da linha %d coluna %d\n", minhalinha, minhacoluna);
		return;
	}
	printf("%4d %s\n", minhalinha, src[minhalinha-1]);
	for( int i=0; i <minhacoluna+4; i++) printf(" ");
	printf("^");
	for( int i=1; i < 10; i++) printf("~");
	puts("");

}

int tam(char *s)
{
	int i = 0;
	while (s[i] !='\0') i++;
	return i;
}

  void yyerror ( YYLTYPE *locp, char const *s){
	extern long linha;
	extern long coluna;
	if(locp == NULL)
		printf("->>>  %s - linha %d coluna %d\n", s, linha, coluna);
	//printf("locp->first_line %d  locp->first_column %d \n" , locp->first_line, locp->first_column);
	printErrorsrc(source, linha, coluna);
	
	printf("->>> %s - linha %d coluna %d\n", s, linha,coluna);
}

void meudebug( char *texto){
	if( debug) {
		printf("{Codigo na linha %d coluna %d} %s\n", linha, coluna, texto);
	}
}



int main(int argc, char *arqv[]){
	int nlinhas;
	int ifile;
	for(int i = 1; i < argc ; i++){
		if( strcmp(arqv[i], "-e") == 0 && i<argc){
			ifile = i+1;
			yyin = fopen(arqv[ifile],"r");
			if(!yyin){
				printf("Não foi possível abrir o arquivo %s\n",arqv[ifile]);
				exit(-1);
			}
			source = alocaSource(yyin, &nlinhas);
			
			if(!source){
				printf("Erro, não conseguiu alocar %s na memoria\n", arqv[ifile]);
				exit(-1);
			}
			i = i+1;
		}else if(strcmp(arqv[i],"-s") == 0 && i<argc){
			yyout = fopen(arqv[i+1],"w");
			i = i+1;
		}else if (strcmp(arqv[i], "-t") == 0){
			imprimir_ast = 1;
		}else if (strcmp(arqv[i], "-d") == 0){
			debug = 1;
		}
		else if (strcmp(arqv[i], "-p") == 0){
			//printf("foram %d linhas", nlinhas);
			for(int i=0; i< 100; i++) printf("-");
			puts("");	
			for(int i=0; i < nlinhas; i++)
				printf("%4d %s", i+1, source[i]);
			printf("\n");
		    for(int i=0; i< 100; i++) printf("-");
			printf("\nArquivo acima: %s\n",arqv[ifile]);
			for(int i=0; i< 100; i++) printf("-");
			puts("");
		}

	}

	yyparse();
	


}
