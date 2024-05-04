rm -f lex.yy.c parser.tab.c parser.tab.h a.out tree.dot
bison -dv -Wcounterexamples -Wother parser.y 2> out
flex lexer.l
g++ -std=c++17 lex.yy.c parser.tab.c parser.tab.h -o parser
./parser < ../tests/public4.py
dot -Tpng tree.dot -o ../tests/pub4.png