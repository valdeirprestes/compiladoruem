CC = gcc -g  
BIN= compilador
ARQUIVOLEX=lexico.lex
FONTELEXICO = lex.yy.c
FONTEparser = parser.tab.c 
FONTEPARSER= parser.tab.c 
FONTEHEADERS = testelexico.tab.h parser.tab.h parser.tab.h
SRC = AST.c AST.h simbolo.h simbolo.c
OBJAST = AST.o simbolo.o
all: $(BIN)
	@echo "Arquivos compilados!"
AST.o: $(SRC)
	$(CC) -c -o AST.o AST.c
simbolo.o: $(SRC)
	$(CC) -c -o simbolo.o simbolo.c
parser.tab.c: parser.y
	bison -H parser.y --report=counterexamples -Wother -Wconflicts-sr -Wcounterexamples
lex.yy.c: $(FONTEparser) $(ARQUIVOLEX) 
	flex $(ARQUIVOLEX) 
testelexico: $(FONTELEXICO) 
	$(CC) -o testelexico $(FONTELEXICO)  
parser: $(FONTELEXICO) $(FONTEparser) AST.c
	$(CC) -o parser $(FONTELEXICO) $(FONTEparser) AST.c
compilador: $(FONTELEXICO) $(FONTEPARSER) $(SRC) $(OBJAST) 
	$(CC) -o compilador $(FONTELEXICO) $(FONTEPARSER) $(OBJAST)
clean:
	rm -vf $(BIN) $(FONTELEXICO) $(FONTEparser)  $(FONTEPARSER) $(FONTEHEADERS) *.output *.o
#teste: $(BIN)
#	bash -c "for ARQ in $(ls exemplos/sintatico*| grep sintatico[0-9]*.tes*); do echo $ARQ; ./compilador -e $ARQ; done"

