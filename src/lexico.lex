%option noyywrap
%{
	#include <string.h>
    #include "bison.tab.h"
	extern long linha;
%}


texto [a-zA-Z]
numero [0-9]
decimal [0-9]*.[0-9]
espaco [" "\t]
novalinha [\n]
variavel [a-zA-Z][a-zA-Z0-9]*
aberturacomentario [/][*]
fechamentocomentario [*][/]

/*subscanner*/
%x comentario 
%x texto
%% /* definições de toke para o flex procurar*/
{aberturacomentario} {BEGIN(comentario);}
<comentario>{fechamentocomentario} {BEGIN(INITIAL); /*É um escape do sub scanner 'comentario' - fim de comentário*/}
<comentario>[^*\n]+ 
<comentario>"*"
<comentario>{novalinha} {linha=linha+1; /* não retornar token, apenas incrementa a variável de controle*/}

\" {BEGIN(texto);}
<texto>\" {BEGIN(INITIAL);}
<texto>. {;}




"=" { yylval= strdup(yytext); return t_igual;}
"+" { yylval= strdup(yytext); return t_mais;}
"-" { yylval= strdup(yytext); return t_menos;}
"*" { yylval= strdup(yytext); return t_asteristico;}
"/" { yylval= strdup(yytext); return t_barra;}

int { yylval= strdup(yytext); return t_int;}
float { yylval= strdup(yytext); return t_float;}
char { yylval= strdup(yytext); return t_char;}
"["  {yylval= strdup(yytext); return t_vetorabri;}
"]" { yylval= strdup(yytext); return t_vetorfecha;}

for {return t_for;}

{numero}+ { yylval= strdup(yytext);  return t_num;}
{decimal} { yylval= strdup(yytext);  return t_decimal;}
{texto}+ { yylval= strdup(yytext);  return t_palavra;}
{variavel} {yylval=strdup(yytext);;return t_variavel;} 
{novalinha} {linha=linha+1; /* não retornar token, apenas incrementa a variável de controle*/}
{espaco} /* Não faz nada, apenas consome*/


. { printf("\'%c\' (linha %d) eh um caractere misterio não usando na linguagem\n", *yytext, linha); }
%%


void yyerror (char const s){
	fprintf(stderr, "%s\n\n",s);
}


int main(int argc, char *arqv[]){
	for(int i = 1; i < argc ; i++){
		if( strcmp(arqv[i], "-e") == 0 && i<argc){
			yyin = fopen(arqv[i+1],"r");
			if(!yyin){
				printf("Não foi possível abrir o arquivo %s\n",arqv[i+1]);
				exit(-1);
			}
			i = i+1;
		}else if(strcmp(arqv[i],"-s") == 0 && i<argc){
			yyout = fopen(arqv[i+1],"w");
			i = i+1;
		}
	}
	return yyparse();
}
