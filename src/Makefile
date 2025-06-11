CC = gcc -g  
BIN= testelexico testesintatico compiler
FONTELEXICO = lex.yy.c
FONTETESTELEXICO = testelexico.tab.c 
FONTETESTESINTATICO = testesintatico.tab.c 
FONTEPARSER= parser.tab.c 
all: $(BIN)
	@echo "Arquivos compilados!"
testelexico.tab.c: testelexico.y
	bison -H testelexico.y -Wcounterexamples
testesintatico.tab.c: testesintatico.y
	bison -H testesintatico.y -Wcounterexamples
parser.tab.c: parser.y
	bison -H parser.y -Wcounterexamples
lex.yy.c: lexico.lex $(FONTETESTELEXICO)
	flex lexico.lex
testelexico: $(FONTELEXICO) $(FONTETESTELEXICO)
	$(CC) -o testelexico $(FONTELEXICO) $(FONTETESTELEXICO)
testesintatico: $(FONTELEXICO) $(FONTETESTESINTATICO)
	$(CC) -o testesintatico $(FONTELEXICO) $(FONTETESTESINTATICO)
compiler: $(FONTELEXICO) $(FONTEPARSER)
	$(CC) -o compiler $(FONTELEXICO) $(FONTEPARSER)
clean:
	rm -vf $(BIN) $(FONTELEXICO) $(FONTETESTELEXICO) $(FONTEPARSER)

