%option noyywrap
%{
	#include <string.h>
	#include "AST.h"
    #include "testesintatico.tab.h"
	extern long linha;
	extern long coluna;
	extern long coluna_tmp;
	extern long imprimir_ast;
	extern char **source;
	extern int debug;
	long linhacomentario = 0;
	char *meustring = NULL;
	void printErrorsrc(char **src, int linha, int coluna);
	int tam(char *s);
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
{aberturacomentario} { coluna +=tam(yytext); linhacomentario = linha; BEGIN(comentario); }
<comentario>{fechamentocomentario} {BEGIN(INITIAL); /*É um escape do sub scanner 'comentario' - fim de comentário*/}
<comentario>[^*\n]+ {coluna +=tam(yytext);}
<comentario>"*" {coluna +=tam(yytext);}
<comentario><<EOF>> { 
	coluna +=tam(yytext);
	//printErrorsrc(source, linha, coluna);
	fprintf(stderr, "<< Comentario não fechado da linha %d ate a linha %d >>\n", linhacomentario , linha); 
	exit(-1); 
}
<comentario>{novalinha} {coluna =1; linha=linha+1; /* não retornar token, apenas incrementa a variável de controle*/}

\" {BEGIN(textoscanner);}
<textoscanner>\" {BEGIN(INITIAL); coluna +=coluna_tmp; coluna_tmp=tam(yytext);}
<textoscanner>{novalinha} { 
	coluna +=coluna_tmp ; 
	coluna_tmp=tam(yytext);
	printErrorsrc(source, linha, coluna);
	fprintf(stderr, "<< String quebrada na linha %d >>\n", linha);
	exit(-1);
}
<textoscanner>[^"\n]* {coluna +=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_string;}

"==" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_igual_a;}
"!=" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_diferente_de;}
"<=" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_menor_ou_igual;}
">=" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_maior_ou_igual;}
"," {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_virgula;}
";" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_pontovirgula; }
"=" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_igual; }
">" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_maior; }
"<" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_menor; }
"+" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_mais;}
"-" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_menos;}
"*" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_asteristico;}
"/" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_barra;}
"[" {coluna+= coluna_tmp ; coluna_tmp =1;yylval.texto= strdup(yytext); return t_abrivetor;}
"]" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_fechavetor;}
"(" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_abriparentes;}
")" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_fechaparentes;}
"{" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_abrichave;}
"}" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_fechachave;}
"!" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_exclamacao;}
"?" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_interrogacao;}
":" {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_doispontos;}
"." {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_ponto;}
{variavel}"."{variavel} {coluna+= coluna_tmp ; coluna_tmp =1; yylval.texto= strdup(yytext); return t_identificadorclasse;}
int {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_int;}
float {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_float;}
char {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_char;}
if {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_if;}
else {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_else;}
return {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_return;}
class {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_class;}
this {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_this;}
construtor {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_construtor;}
destrutor {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_destrutor;}
for {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_for;}
while {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_while;}
switch {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_switch;}
case {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_case;}
default {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_default;}
break {coluna+=coluna_tmp; coluna_tmp=tam(yytext);yylval.texto= strdup(yytext); return t_break;}



{numero} { coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext);  return t_num;}
{decimal} { coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext);  return t_decimal;}
{varincorreta} {coluna+=coluna_tmp; coluna_tmp=tam(yytext); fprintf(stderr, "<< Linha %d: variavel incorreta ou separe numero e string >>\n", linha); exit(-1); }
{variavel} {coluna+=coluna_tmp; coluna_tmp=tam(yytext);yylval.texto=strdup(yytext);;return t_identificador;} 
{novalinha} {coluna =1; linha=linha+1;/* não retornar token, apenas incrementa a variável de controle*/}
{espaco} {coluna+=1;} /* Não faz nada, apenas consome*/


. { 
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

void printErrorsrc(char **src, int linha, int coluna)
{
	if(!src){
		printf("Não pode acessar o src");
		exit(-1);
	}
	puts(src[linha-1]);
	for( int i=0; i <coluna; i++) printf(" ");
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

void yyerror (char const *s){
	extern long linha;
	extern long coluna;
	/*fprintf(stderr, "Erro desconhecido:\
ultimo lexema aceito [%s], linha [%d], coluna[%d],  %s\n",yytext, linha, coluna, s );*/
	printErrorsrc(source, linha, coluna);
	printf("->>> %s - linha %d coluna %d\n", s, linha, coluna);
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
		    for(int i=0; i< 100; i++) printf("-");
			printf("\nArquivo acima: %s\n",arqv[ifile]);
			for(int i=0; i< 100; i++) printf("-");
			puts("");
		}

	}

	yyparse();
	


}
