CC = gcc -g  
BIN= compilador
ARQUIVOLEX=lexico.lex
FONTELEXICO = lex.yy.c
FONTEparser = parser.tab.c 
FONTEPARSER= parser.tab.c 
FONTEHEADERS = testelexico.tab.h parser.tab.h parser.tab.h
all: $(BIN)
	@echo "Arquivos compilados!"
testelexico.tab.c: testelexico.y
	bison -H testelexico.y --report=counterexamples -Wother -Wconflicts-sr
parser.tab.c: parser.y
	bison -H parser.y --report=counterexamples -Wother -Wconflicts-sr -Wcounterexamples
lex.yy.c: $(FONTEparser)
	flex $(ARQUIVOLEX) 
testelexico: $(FONTELEXICO) 
	$(CC) -o testelexico $(FONTELEXICO)  
parser: $(FONTELEXICO) $(FONTEparser) AST.c
	$(CC) -o parser $(FONTELEXICO) $(FONTEparser) AST.c
compilador: $(FONTELEXICO) $(FONTEPARSER) AST.c AST.h
	$(CC) -o compilador $(FONTELEXICO) $(FONTEPARSER) AST.c
clean:
	rm -vf $(BIN) $(FONTELEXICO) $(FONTEparser)  $(FONTEPARSER) $(FONTEHEADERS) *.output

