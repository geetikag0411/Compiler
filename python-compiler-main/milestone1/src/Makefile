all:
	@rm -f lex.yy.c parser.tab.c parser.tab.h parser verbose.log
	@bison -d parser.y
	@flex lexer.l
	@g++ -std=c++17 lex.yy.c parser.tab.c parser.tab.h -o parser
	@rm -f lex.yy.c parser.tab.c parser.tab.h parser.tab.h.gch 