CC := g++
CFLAGS := -std=c++17

all: parser	

parser:	parser.tab.o lex.yy.o symbol_table.o NonTerminal.o 3AC.o
	$(CC) $(CFLAGS) $^

parser.tab.o: parser.y symbol_table.o NonTerminal.o 3AC.o
	@bison -dv -Wother -Wcounterexamples $<
	$(CC) $(CFLAGS) -c -o $@ parser.tab.c

lex.yy.o: lexer.l
	@flex $^
	$(CC) $(CFLAGS) -c -o $@ lex.yy.c

symbol_table.o: symbol_table.cpp symbol_table.hpp
	$(CC) $(CFLAGS) -c -o $@ $<

NonTerminal.o: NonTerminal.cpp symbol_table.o
	$(CC) $(CFLAGS) -c -o $@ $<

3AC.o: 3AC.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	@rm -f *.o parser.tab.c parser.tab.h lex.yy.c *.gch parser
