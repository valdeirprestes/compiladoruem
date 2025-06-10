%option noyywrap
%{
	#include <string.h>
    #include "bison.tab.h"
	extern long linha;
%}


texto [a-zA-Z]
numero [0-9]+
decimal [0-9]*.[0-9]+
espaco [" "\t]
novalinha [\n]
variavel [a-zA-Z][a-zA-Z0-9]*
aberturacomentario [/][*]
fechamentocomentario [*][/]

/*subscanner*/
%x comentario 
%x textoscanner
%% /* definições de toke para o flex procurar*/
{aberturacomentario} {BEGIN(comentario);}
<comentario>{fechamentocomentario} {BEGIN(INITIAL); /*É um escape do sub scanner 'comentario' - fim de comentário*/}
<comentario>[^*\n]+ 
<comentario>"*"
<comentario>{novalinha} {linha=linha+1; /* não retornar token, apenas incrementa a variável de controle*/}

\" {BEGIN(textoscanner);}
<textoscanner>\" {BEGIN(INITIAL);}
<textoscanner>. {;}
<textoscanner>{novalinha} {linha=linha+1; }


";" {yylval.texto= strdup(yytext); return t_pontovirgula;}
"=" { yylval.texto= strdup(yytext); return t_igual;}
">" { yylval.texto= strdup(yytext); return t_maior;}
"<" { yylval.texto= strdup(yytext); return t_menor;}
"+" { yylval.texto= strdup(yytext); return t_mais;}
"-" { yylval.texto= strdup(yytext); return t_menos;}
"*" { yylval.texto= strdup(yytext); return t_asteristico;}
"/" { yylval.texto= strdup(yytext); return t_barra;}
"["  {yylval.texto= strdup(yytext); return t_abrivetor;}
"]" { yylval.texto= strdup(yytext); return t_fechavetor;}
"(" { yylval.texto= strdup(yytext); return t_abriparentes;}
")" { yylval.texto= strdup(yytext); return t_fechaparentes;}
"{" { yylval.texto= strdup(yytext); return t_abrichave;}
"}" { yylval.texto= strdup(yytext); return t_fechachave;}
"!" { yylval.texto= strdup(yytext); return t_exclamacao;}
"?" { yylval.texto= strdup(yytext); return t_interrogacao;}
":" { yylval.texto= strdup(yytext); return t_doispontos;}
int { yylval.texto= strdup(yytext); return t_int;}
float { yylval.texto= strdup(yytext); return t_float;}
char { yylval.texto= strdup(yytext); return t_char;}


for {return t_for;}

{numero} { yylval.numero_inteiro= atoi(yytext);  return t_num;}
{decimal} { yylval.numero_decimal= atof(yytext);  return t_decimal;}
{texto}+ { yylval.texto = strdup(yytext);  return t_palavra;}
{variavel} {yylval.texto=strdup(yytext);;return t_variavel;} 
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
