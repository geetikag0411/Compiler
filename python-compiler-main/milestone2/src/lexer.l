%option yylineno
%{
    #include <bits/stdc++.h>
    #include "parser.tab.h"
    #include "NonTerminal.cpp"
    using namespace std;
    #define debug 0
    stack<unsigned int> indent_level;
    int dedent_count = 0;
    int bracket_depth{0};
    bool has_ended = false;
    char blank = ' ';
%}

%x DEDENT_STATE
%s IMPLICIT_LINE_JOIN

NAME [a-zA-Z"_"][a-zA-Z"_"0-9]*
COMMENT (#[^\n]*)
INTEGER      {DECINTEGER}|{BININTEGER}|{OCTINTEGER}|{HEXINTEGER}
DECINTEGER   {NONZERODIGIT}(["_"]?{DIGIT})*|"0"+(["_"]?"0")*
BININTEGER   "0"("b"|"B")(["_"]?{BINDIGIT})+
OCTINTEGER   "0"("o"|"O")(["_"]?{OCTDIGIT})+
HEXINTEGER   "0"("x"|"X")(["_"]?{HEXDIGIT})+
NONZERODIGIT [1-9]
DIGIT        [0-9]
BINDIGIT     "0"|"1"
OCTDIGIT     [0-7]
HEXDIGIT     {DIGIT}|[a-f]|[A-F]
FLOATNUMBER  {POINTFLOAT}|{EXPONENTFLOAT}
POINTFLOAT     ({DIGITPART}?{FRACTION})|({DIGITPART}".") 
EXPONENTFLOAT  ({DIGITPART}|{POINTFLOAT}){EXPONENT}
DIGITPART      {DIGIT}(["_"]?{DIGIT})*
FRACTION       "."{DIGITPART}
EXPONENT      [eE][+-]?{DIGITPART}
STRINGLITERAL    {STRINGPREFIX}?({SHORTSTRING}|{LONGSTRING})
STRINGPREFIX     "r"|"u"|"R"|"U"|"f"|"F"|"fr"|"Fr"|"fR"|"FR"|"rf"|"rF"|"Rf"|"RF"
SHORTSTRING      "'"{SHORTSTRINGITEM}*"'"|"\""{SHORTSTRINGITEM}*"\""
LONGSTRING       "'''"{LONGSTRINGITEM}*"'''"|"\"\"\""{LONGSTRINGITEM}*"\"\"\""
SHORTSTRINGITEM  {SHORTSTRINGCHAR}|{STRINGESCAPESEQ}
LONGSTRINGITEM   {LONGSTRINGCHAR}|{STRINGESCAPESEQ}
SHORTSTRINGCHAR  [^\\\n'\"]
LONGSTRINGCHAR   [^\\]
STRINGESCAPESEQ  "\\".

%%
"\\\n"[ \t]* {

        }

<IMPLICIT_LINE_JOIN>[ \t\n]+  {

}

{INTEGER}    {
            if(debug) printf("LEXER:%s\n",yytext);
            yylval.nonTerminal=new NonTerminal(yylineno,yytext,{"int"});
            return NUMBER;
        }

{STRINGLITERAL} {
            yylval.nonTerminal=new NonTerminal(yylineno,yytext,{"str"});
            return STRING;
        }
"async"   {
            yylval.nonTerminal=new NonTerminal(yylineno,yytext);
            return ASYNC;
        }
await   {
            yylval.nonTerminal=new NonTerminal(yylineno,yytext);
            return AWAIT;
        }
{COMMENT}   {
            
        }
"\n"/[^" "\t\n]    {

            int count = 0;
            if(indent_level.empty()) indent_level.push(0);
            while(count < indent_level.top())
            {
                indent_level.pop();
                ++dedent_count;
            }
            if(count > indent_level.top()) return ERROR;
            if(dedent_count > 0){
                yyunput(1, &blank);
                BEGIN DEDENT_STATE;
            }
            return NEWLINE;
        }
"\n"/(.)    {                 
            return NEWLINE;
        }
("\n"[" "\t]*(#(.)*)?)/("\n")    {

        }   

    
"\n" {
    int count = 0;
    if(indent_level.empty()) indent_level.push(0);
    while(count < indent_level.top())
    {
        indent_level.pop();
        ++dedent_count;
    }
    if(count > indent_level.top()) return ERROR;
    has_ended = true;
    ++dedent_count;
    yyunput(1, &blank);
    BEGIN DEDENT_STATE;
    return NEWLINE;
}


^([" "\t]*) {
                char* temp = yytext;
                int count = 0;
                while(*temp)
                {
                    if(*temp=='\t') count += 4;
                    else if(*temp ==' ') ++count;
                    ++temp;
                }
                if(indent_level.empty()) indent_level.push(0);
                if(count > indent_level.top())
                {
                    indent_level.push(count);
                    return INDENT;
                }
                while(count < indent_level.top())
                {
                    indent_level.pop();
                    ++dedent_count;
                }
                if(count > indent_level.top()){
                    return ERROR;
                }
                if(dedent_count > 0){
                    yyunput(1, &blank);
                    BEGIN DEDENT_STATE;
                }
        }

<DEDENT_STATE>. {
            --dedent_count;
            if(dedent_count > 0) yyunput(1, &blank);
            else{
                if(has_ended) return END_MARKER;
                BEGIN INITIAL;
            }
            return DEDENT;
          }

"range" {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return RANGE;
        }
"!="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return NOTEQUAL;
        } 

"%"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return MODULO;
        }
"%="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return MODULO_EQUAL;
        }
"&"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BITWISE_AND;
        }
"&="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BITWISE_AND_EQUAL;
        }
"\("     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_PAREN;
        }
"\)"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_PAREN;
        }
"*"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return MULTIPLY;
        }
"**"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return POWER;
        }
"**="   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return POWER_EQUAL;
        }
"*="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return MULTIPLY_EQUAL;
        }
"+"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return PLUS;
        }
"+="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return PLUS_EQUAL;
        }
","     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return COMMA;
        }
"-"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return MINUS;
        }
"-="        {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return MINUS_EQUAL;
        }
"->"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return ARROW;
        }
"."     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return DOT;
        }
"..."   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return ELLIPSIS;
        }
"/"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return DIVIDE;
        }
"//"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return FLOOR_DIVIDE;
        }
"//="   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return FLOOR_DIVIDE_EQUAL;
        }
"/="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return DIVIDE_EQUAL;
        }
":"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return COLON;
        }
":="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return COLONEQUAL;
        }
";"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return SEMICOLON;
        }
"<"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return LESS_THAN;
        }
"<<"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return LEFT_SHIFT;
        }
"<<="   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return LEFT_SHIFT_EQUAL;
        }
"<="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return LESS_THAN_EQUAL;
        }
"="     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return EQUAL;
        }
"=="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return EQUAL_EQUAL;
        }
">"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return GREATER_THAN;
        }
">="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return GREATER_THAN_EQUAL;
        }
">>"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return RIGHT_SHIFT;
        }
">>="   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return RIGHT_SHIFT_EQUAL;
        }
"@"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return AT;
        }
"@="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return ATEQUAL;
        }
"False" {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return FALSE_;
        }
"None"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return NONE;
        }
"True"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return TRUE_;
        }
"["     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_BRACKET;
        }
"]"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_BRACKET;
        }
"^"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BITWISE_XOR;
        }
"^="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BITWISE_XOR_EQUAL;
        }
"and"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return AND;
        }
"as"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return AS;
        }
"assert"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return ASSERT;
        }
"break"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BREAK;
        }
"class"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return CLASS;
        }
"continue"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return CONTINUE;
        }
"def"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return DEF;
        }
"del"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return DEL;
        }
"elif"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return ELIF;
        }
"else"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return ELSE;
        }
"except"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return EXCEPT;
        }
"finally"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return FINALLY;
        }
"for"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return FOR;
        }
"from"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return FROM;
        }
"global"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return GLOBAL;
        }
"if"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return IF;
        }
"import"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return IMPORT;
        }
"in"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return IN;
        }
"is"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return IS;
        }
"lambda"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return LAMBDA;
        }
"nonlocal"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return NONLOCAL;
        }
"not"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return NOT;
        }
"or"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return OR;
        }
"pass"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return PASS;
        }
"raise" {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return RAISE;
        }
"return"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return RETURN;
        }
"try"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return TRY;
        }
"while" {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return WHILE;
        }
"with"  {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return WITH;
        }
"yield" {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return YIELD;
        }
"\{"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_BRACE;
        }
"|"    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BITWISE_OR;
        }
"|="    {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BITWISE_OR_EQUAL;
        }
"\}"   {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_BRACE;
        }
"~"     {
            yylval.nonTerminal = new NonTerminal(yylineno, yytext);
            return BITWISE_NOT;
        }
{NAME}  {
    
        if(debug) printf("LEXER:%s\n",yytext);
            yylval.nonTerminal=new NonTerminal(yylineno,yytext);
            return NAME;
        }
{FLOATNUMBER}   {
                    if(debug) printf("FLOATNUMBER: %s\n", yytext);
                    yylval.nonTerminal=new NonTerminal(yylineno,yytext,{"float"});
                    // yylval.nonTerminal->set_float_val(stof(yytext));
                    return REAL_NUMBER;
                }
. {

}
%%

int yywrap() {
    return 1;
}