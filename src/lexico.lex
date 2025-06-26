%option noyywrap
%{
	#include <string.h>
    #include "testelexico.tab.h"
	extern long linha;
	extern long coluna;
	extern long coluna_tmp;
	long linhacomentario = 0;
	char *meustring = NULL;

	int tam(char *s);
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
{aberturacomentario} { coluna +=tam(yytext); linhacomentario = linha; BEGIN(comentario); }
<comentario>{fechamentocomentario} {BEGIN(INITIAL); /*É um escape do sub scanner 'comentario' - fim de comentário*/}
<comentario>[^*\n]+ {coluna +=tam(yytext);}
<comentario>"*" {coluna +=tam(yytext);}
<comentario><<EOF>> { coluna +=tam(yytext); fprintf(stderr, "<< Comentario não fechado da linha %d ate a linha %d >>\n", linhacomentario , linha); exit(-1); }
<comentario>{novalinha} {coluna =1; linha=linha+1; /* não retornar token, apenas incrementa a variável de controle*/}

\" {BEGIN(textoscanner);}
<textoscanner>\" {BEGIN(INITIAL); coluna +=coluna_tmp; coluna_tmp=tam(yytext);}
<textoscanner>{novalinha} { 
	coluna +=coluna_tmp ; 
	coluna_tmp=tam(yytext); 
	fprintf(stderr, "<< String quebrada na linha %d >>\n", linha); exit(-1);
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
int {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_int;}
float {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_float;}
char {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_char;}
if {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_if;}
else {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_else;}
return {coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.texto= strdup(yytext); return t_char;}
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



[0-9]+ { printf("acho numero %s", yytext);coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.numero_inteiro= atoi(yytext);  return t_num;}
{decimal} { coluna+=coluna_tmp; coluna_tmp=tam(yytext); yylval.numero_decimal= atof(yytext);  return t_decimal;}
{varincorreta} {coluna+=coluna_tmp; coluna_tmp=tam(yytext); fprintf(stderr, "<< Linha %d: variavel incorreta ou separe numero e string >>\n", linha); exit(-1); }
{variavel} {coluna+=coluna_tmp; coluna_tmp=tam(yytext);yylval.texto=strdup(yytext);;return t_identificador;} 
{novalinha} {coluna =1; linha=linha+1;/* não retornar token, apenas incrementa a variável de controle*/}
{espaco} {coluna+=1;} /* Não faz nada, apenas consome*/


. {  printf("\'%c\' (linha %d coluna %d) eh um caractere misterio não usando na linguagem\n", *yytext, linha, coluna); exit(-1);}
%%


int tam(char *s)
{
	int i = 0;
	while (s[i] !='\0') i++;
	return i;
}

void yyerror (char const *s){
	extern long linha;
	fprintf(stderr, "Ultimo lexema aceito [%s], linha [%d], coluna[%d],  %s\n",yytext, linha, coluna, s );
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
