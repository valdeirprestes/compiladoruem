%option noyywrap
%{
	#include <string.h>
    #include "testelexico.tab.h"
	extern long linha;
	long linhacomentario = 0;
	char *meustring = NULL;
%}


texto [a-zA-Z]
numero [0-9]+
decimal [0-9]*.[0-9]+
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
{aberturacomentario} {BEGIN(comentario); linhacomentario = linha;}
<comentario>{fechamentocomentario} {BEGIN(INITIAL); /*É um escape do sub scanner 'comentario' - fim de comentário*/}
<comentario>[^*\n]+ 
<comentario>"*"
<comentario><<EOF>> { fprintf(stderr, "<< Comentario não fechado da linha %d ate a linha %d >>\n", linhacomentario , linha); exit(-1); }
<comentario>{novalinha} {linha=linha+1; /* não retornar token, apenas incrementa a variável de controle*/}

\" {BEGIN(textoscanner);}
<textoscanner>\" {BEGIN(INITIAL);}
<textoscanner>{novalinha} { fprintf(stderr, "<< String quebrada na linha %d >>\n", linha); exit(-1); }
<textoscanner>[^"\n]* {yylval.texto= strdup(yytext); return t_string;}


"," {yylval.texto= strdup(yytext); return t_virgula;}
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
if { yylval.texto= strdup(yytext); return t_if;}
else { yylval.texto= strdup(yytext); return t_else;}
return { yylval.texto= strdup(yytext); return t_char;}
class { yylval.texto= strdup(yytext); return t_class;}
construtor { yylval.texto= strdup(yytext); return t_construtor;}
destrutor { yylval.texto= strdup(yytext); return t_destrutor;}
for {yylval.texto= strdup(yytext); return t_for;}
while {yylval.texto= strdup(yytext); return t_while;}
switch {yylval.texto= strdup(yytext); return t_switch;}
case {yylval.texto= strdup(yytext); return t_case;}
default {yylval.texto= strdup(yytext); return t_default;}
break {yylval.texto= strdup(yytext); return t_break;}
main {yylval.texto= strdup(yytext); return t_main;}


{numero} { yylval.numero_inteiro= atoi(yytext);  return t_num;}
{decimal} { yylval.numero_decimal= atof(yytext);  return t_decimal;}
{varincorreta} { fprintf(stderr, "<< Linha %d: variavel incorreta ou separe numero e string >>\n", linha); exit(-1); }
{variavel} {yylval.texto=strdup(yytext);;return t_identificador;} 
{novalinha} {linha=linha+1;/* não retornar token, apenas incrementa a variável de controle*/}
{espaco} /* Não faz nada, apenas consome*/


. { printf("\'%c\' (linha %d) eh um caractere misterio não usando na linguagem\n", *yytext, linha); }
%%


void yyerror (char const s){
	fprintf(stderr, "yyerror %s\n\n",s);
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
