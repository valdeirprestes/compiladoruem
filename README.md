# Projeto desenvolvido para matéria de compiladores - 2025

## Enunciado

Equipe
- Valdeir de Souza Prestes ra 88257

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
   
   
   


### Linguagem projetada pela equipe:
Comentário
```
/* comentário
	acabou */
```

Valores aceitos:  
```
"string" /* apenas uma linha */
123
123.00
```

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

Atribuções:
```
int i =  x;
i = x;
int i[];
i[1]  = x;
i[i]  = j[x];

```

Teste de comparação:
```
> maior
>= maior ou igual
< menor
<= menor ou igual
!= diferente
```
Estrutura de repetição
```
for (int i; expressao ; i++){
	commnad;
}

while( expressao ){
}
```
Estrutura condicionais
``` 
if{} else if  {} else {}
switch(){ case x:  default}
```

Suporte a classe (sem herança, polimorfismo e encapsulamento)
```
class  var1 {
 	construtor(){ return;}
	destrutor() {}
(tipo)[] funcsome(){}
}
```
Suporte a funções
```
(tipo)[] func(){ return;}
```

Função principal
```
int main (){}
```



### Para compilar e executar existem duas  maneiras


## Usando o make 
Ou pelo uso de GNU Make, que faz estes três comandos.  
```
make
```


Para executar use:
```
./compilador -e arquivo.teste -s saida.teste
```

Opções:
```
-e Arquivo entrada.
-p Imprimi o arquivo de entrada.
-d Imprimi variáveis e regras.
-a Imprimi arvore AST.
-t Tabela de símbolos.
-s Arquivo se saida ( ainda a implementar).
```