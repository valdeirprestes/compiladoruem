CC = gcc -g  
BIN= testelexico
FONTELEXICO = lex.yy.c
FONTETESTELEXICO = bison.tab.c
all: $(BIN)
	@echo "Arquivos compilados!"
bison.tab.c: bison.y
	bison -H bison.y -Wcounterexamples
lex.yy.c: lexico.lex $(FONTETESTELEXICO)
	flex lexico.lex
testelexico: $(FONTELEXICO) 
	$(CC) -o testelexico $(FONTELEXICO) $(FONTETESTELEXICO)
clean:
	rm -vf $(BIN)

