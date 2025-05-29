%option noyywrap
%{
	#include <string.h>
    #include "bison.tab.h"
	long linha=1;
%}


texto [a-zA-Z]
numero [0-9]
decimal [0-9]*.[0-9]

%% /* definições de toke para o flex procurar*/
"=" { return t_igual;}
"+" { return t_mais;}
"-" { return t_menos;}
"*" { return t_asteristico;}
"/" {return t_barra;}

"int" {return t_int;}
"float" {return t_float;}
"char" {return t_char;}
"["  {return t_vetorabri;}
"]" { return t_vetorfecha;}


{numero}+ { yylval= atoi(yytext);  return t_num;}
{decimal} { yylval= atoi(yytext);  return t_decimal;}
{texto}+ {} { yylval= atoi(yytext);  return t_palavra;}
\n { linha= linha +1; return t_novalinha;}
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
