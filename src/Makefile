CC = gcc -g  
BIN= testelexico testesintatico #compiler
FONTELEXICO = lex.yy.c
FONTETESTELEXICO = testelexico.tab.c 
FONTETESTESINTATICO = testesintatico.tab.c 
FONTEPARSER= parser.tab.c 
FONTEHEADERS = testelexico.tab.h testesintatico.tab.h parser.tab.h
all: $(BIN)
	@echo "Arquivos compilados!"
testelexico.tab.c: testelexico.y
	bison -H testelexico.y --report=counterexamples -Wother -Wconflicts-sr
testesintatico.tab.c: testesintatico.y
	bison -H testesintatico.y --report=counterexamples -Wother -Wconflicts-sr -Wcounterexamples
#parser.tab.c: parser.y
#	bison -H parser.y --report=counterexamples -Wother
lex.yy.c: lexico.lex $(FONTETESTESINTATICO)
	flex lexico.lex 
testelexico: $(FONTELEXICO) $(FONTETESTELEXICO)
	$(CC) -o testelexico $(FONTELEXICO) $(FONTETESTELEXICO) 
testesintatico: $(FONTELEXICO) $(FONTETESTESINTATICO) AST.c
	$(CC) -o testesintatico $(FONTELEXICO) $(FONTETESTESINTATICO) AST.c
compiler: $(FONTELEXICO) $(FONTEPARSER)
	$(CC) -o compiler $(FONTELEXICO) $(FONTEPARSER)
clean:
	rm -vf $(BIN) $(FONTELEXICO) $(FONTETESTESINTATICO) $(FONTETESTELEXICO) $(FONTEPARSER) $(FONTEHEADERS) *.output

