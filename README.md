# Projeto desenvolvido para matéria de compiladores - 2025

## Enunciado

Equipe
- Valdeir de Souza Prestes ra 88257
- Victor Hugo Franciscon ra12077
- William Massashi Ito Yoshida ra117497

Na disciplina de compiladores vimos que um compilador é dividido entre o
front-end e o back-end. O front-end realiza a analise léxica, sintática
e semantica. Enquanto que o back-end cuida de criar o objeto alvo e otimizações
para compilação.

No contexto apresentado, o compilador deverá:  
- Reconhecer e manipular os tipos de variáveis inteiro, float, char e
string;  
- Reconhecer e manipular vetores;  
- Reconhecer e manipular no mínimo uma estrutura de decisão;  
- Reconhecer e manipular no mínimo uma estrutura de repetição;  
- Reconhecer e manipular palavras e funções reservadas;  
- Reconhecer e manipular chamadas de pelo menos um método/função  
(excluindo a Main);  
   
   
   


Linguagem projetada pela equipe:

Tipos:
```
int var1;
float var2;
char var3; 
string var4[];   /* classe */
/* vetor */
int var1[];
float var2[];
char var3[]; 
string var4[]; /* classe */
```

Estrutura de repetição
```
for (int i; teste ; i++){
	commnad;
}

while( teste ){
}
```
Estrutura condicionais
```
expressao ? var1 : var2; 
if{} else if  {} else {}
switch(){ case default}
```

Suporte a classe (sem herança, polimorfismo e encapsulamento)
```
class  var1 {
 	init(){ return;}
destructor() {}
(tipo) funcsome(){}
}
```
Suporte a funções
```
(tipo) func(){ return;}
```

Função principal
```
int main (){}
```

Comando para compilação.
```
comando1
comando2
comando3
[...]
```
   
Para compilar :
```
bison -H bison.y && flex lexico.lex && gcc -g -o teste bison.tab.c lex.yy.c
```
Para executar use:
./teste -e arquivo.teste -s saida.teste

