%option yylineno
%{
    #include <bits/stdc++.h>
    #include "parser.tab.h"
    #include "ast_node.h"

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
            yylval.node=new AST_Node(yylineno,yytext,"NUMBER","NUMBER");
            yylval.node->set_int_val(stoi(yytext));
            return NUMBER;
        }

{STRINGLITERAL} {
            yylval.node=new AST_Node(yylineno,yytext,"STRING","STRING");
            return STRING;
        }
"async"   {
            yylval.node=new AST_Node(yylineno,yytext,"ASYNC","KEYWORD");
            return ASYNC;
        }
await   {
            yylval.node=new AST_Node(yylineno,yytext,"AWAIT","KEYWORD");
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
"!="    {
            yylval.node = new AST_Node(yylineno, yytext, "NOTEQUAL", "OPERATOR");
            return NOTEQUAL;
        } 

"%"    {
            yylval.node = new AST_Node(yylineno, yytext, "MODULO", "OPERATOR");
            return MODULO;
        }
"%="    {
            yylval.node = new AST_Node(yylineno, yytext, "MODULO_EQUAL", "OPERATOR");
            return MODULO_EQUAL;
        }
"&"     {
            yylval.node = new AST_Node(yylineno, yytext, "BITWISE_AND", "OPERATOR");
            return BITWISE_AND;
        }
"&="    {
            yylval.node = new AST_Node(yylineno, yytext, "BITWISE_AND_EQUAL", "OPERATOR");
            return BITWISE_AND_EQUAL;
        }
"\("     {
            yylval.node = new AST_Node(yylineno, yytext, "OPEN_PAREN", "DELIMITER");
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_PAREN;
        }
"\)"     {
            yylval.node = new AST_Node(yylineno, yytext, "CLOSE_PAREN", "DELIMITER");
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_PAREN;
        }
"*"     {
            yylval.node = new AST_Node(yylineno, yytext, "MULTIPLY", "OPERATOR");
            return MULTIPLY;
        }
"**"    {
            yylval.node = new AST_Node(yylineno, yytext, "POWER", "OPERATOR");
            return POWER;
        }
"**="   {
            yylval.node = new AST_Node(yylineno, yytext, "POWER_EQUAL", "OPERATOR");
            return POWER_EQUAL;
        }
"*="    {
            yylval.node = new AST_Node(yylineno, yytext, "MULTIPLY_EQUAL", "OPERATOR");
            return MULTIPLY_EQUAL;
        }
"+"     {
            yylval.node = new AST_Node(yylineno, yytext, "PLUS", "OPERATOR");
            return PLUS;
        }
"+="    {
            yylval.node = new AST_Node(yylineno, yytext, "PLUS_EQUAL", "OPERATOR");
            return PLUS_EQUAL;
        }
","     {
            yylval.node = new AST_Node(yylineno, yytext, "COMMA", "DELIMITER");
            return COMMA;
        }
"-"     {
            yylval.node = new AST_Node(yylineno, yytext, "MINUS", "OPERATOR");
            return MINUS;
        }
"-="        {
            yylval.node = new AST_Node(yylineno, yytext, "MINUS_EQUAL", "OPERATOR");
            return MINUS_EQUAL;
        }
"->"    {
            yylval.node = new AST_Node(yylineno, yytext, "ARROW", "OPERATOR");
            return ARROW;
        }
"."     {
            yylval.node = new AST_Node(yylineno, yytext, "DOT", "OPERATOR");
            return DOT;
        }
"..."   {
            yylval.node = new AST_Node(yylineno, yytext, "ELLIPSIS", "DELIMITER");
            return ELLIPSIS;
        }
"/"     {
            yylval.node = new AST_Node(yylineno, yytext, "DIVIDE", "OPERATOR");
            return DIVIDE;
        }
"//"    {
            yylval.node = new AST_Node(yylineno, yytext, "FLOOR_DIVIDE", "OPERATOR");
            return FLOOR_DIVIDE;
        }
"//="   {
            yylval.node = new AST_Node(yylineno, yytext, "FLOOR_DIVIDE_EQUAL", "OPERATOR");
            return FLOOR_DIVIDE_EQUAL;
        }
"/="    {
            yylval.node = new AST_Node(yylineno, yytext, "DIVIDE_EQUAL", "OPERATOR");
            return DIVIDE_EQUAL;
        }
":"     {
            yylval.node = new AST_Node(yylineno, yytext, "COLON", "DELIMITER");
            return COLON;
        }
":="    {
            yylval.node = new AST_Node(yylineno, yytext, "COLONEQUAL", "OPERATOR");
            return COLONEQUAL;
        }
";"     {
            yylval.node = new AST_Node(yylineno, yytext, "SEMICOLON", "DELIMITER");
            return SEMICOLON;
        }
"<"     {
            yylval.node = new AST_Node(yylineno, yytext, "LESS_THAN", "OPERATOR");
            return LESS_THAN;
        }
"<<"    {
            yylval.node = new AST_Node(yylineno, yytext, "LEFT_SHIFT", "OPERATOR");
            return LEFT_SHIFT;
        }
"<<="   {
            yylval.node = new AST_Node(yylineno, yytext, "LEFT_SHIFT_EQUAL", "OPERATOR");
            return LEFT_SHIFT_EQUAL;
        }
"<="    {
            yylval.node = new AST_Node(yylineno, yytext, "LESS_THAN_EQUAL", "OPERATOR");
            return LESS_THAN_EQUAL;
        }
"="     {
            yylval.node = new AST_Node(yylineno, yytext, "EQUAL", "OPERATOR");
            return EQUAL;
        }
"=="    {
            yylval.node = new AST_Node(yylineno, yytext, "EQUAL_EQUAL", "OPERATOR");
            return EQUAL_EQUAL;
        }
">"     {
            yylval.node = new AST_Node(yylineno, yytext, "GREATER_THAN", "OPERATOR");
            return GREATER_THAN;
        }
">="    {
            yylval.node = new AST_Node(yylineno, yytext, "GREATER_THAN_EQUAL", "OPERATOR");
            return GREATER_THAN_EQUAL;
        }
">>"    {
            yylval.node = new AST_Node(yylineno, yytext, "RIGHT_SHIFT", "OPERATOR");
            return RIGHT_SHIFT;
        }
">>="   {
            yylval.node = new AST_Node(yylineno, yytext, "RIGHT_SHIFT_EQUAL", "OPERATOR");
            return RIGHT_SHIFT_EQUAL;
        }
"@"     {
            yylval.node = new AST_Node(yylineno, yytext, "AT", "OPERATOR");
            return AT;
        }
"@="    {
            yylval.node = new AST_Node(yylineno, yytext, "ATEQUAL", "OPERATOR");
            return ATEQUAL;
        }
"False" {
            yylval.node = new AST_Node(yylineno, yytext, "FALSE_", "KEYWORD");
            return FALSE_;
        }
"None"  {
            yylval.node = new AST_Node(yylineno, yytext, "NONE", "KEYWORD");
            return NONE;
        }
"True"  {
            yylval.node = new AST_Node(yylineno, yytext, "TRUE_", "KEYWORD");
            return TRUE_;
        }
"["     {
            yylval.node = new AST_Node(yylineno, yytext, "OPEN_BRACKET", "DELIMITER");
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_BRACKET;
        }
"]"     {
            yylval.node = new AST_Node(yylineno, yytext, "CLOSE_BRACKET", "DELIMITER");
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_BRACKET;
        }
"^"     {
            yylval.node = new AST_Node(yylineno, yytext, "BITWISE_XOR", "OPERATOR");
            return BITWISE_XOR;
        }
"^="    {
            yylval.node = new AST_Node(yylineno, yytext, "BITWISE_XOR_EQUAL", "OPERATOR");
            return BITWISE_XOR_EQUAL;
        }
"and"   {
            yylval.node = new AST_Node(yylineno, yytext, "AND", "OPERATOR");
            return AND;
        }
"as"    {
            yylval.node = new AST_Node(yylineno, yytext, "AS", "KEYWORD");
            return AS;
        }
"assert"    {
            yylval.node = new AST_Node(yylineno, yytext, "ASSERT", "KEYWORD");
            return ASSERT;
        }
"break"    {
            yylval.node = new AST_Node(yylineno, yytext, "BREAK", "KEYWORD");
            return BREAK;
        }
"class"   {
            yylval.node = new AST_Node(yylineno, yytext, "CLASS", "KEYWORD");
            return CLASS;
        }
"continue"  {
            yylval.node = new AST_Node(yylineno, yytext, "CONTINUE", "KEYWORD");
            return CONTINUE;
        }
"def"   {
            yylval.node = new AST_Node(yylineno, yytext, "DEF", "KEYWORD");
            return DEF;
        }
"del"   {
            yylval.node = new AST_Node(yylineno, yytext, "DEL", "KEYWORD");
            return DEL;
        }
"elif"  {
            yylval.node = new AST_Node(yylineno, yytext, "ELIF", "KEYWORD");
            return ELIF;
        }
"else"  {
            yylval.node = new AST_Node(yylineno, yytext, "ELSE", "KEYWORD");
            return ELSE;
        }
"except"    {
            yylval.node = new AST_Node(yylineno, yytext, "EXCEPT", "KEYWORD");
            return EXCEPT;
        }
"finally"   {
            yylval.node = new AST_Node(yylineno, yytext, "FINALLY", "KEYWORD");
            return FINALLY;
        }
"for"   {
            yylval.node = new AST_Node(yylineno, yytext, "FOR", "KEYWORD");
            return FOR;
        }
"from"  {
            yylval.node = new AST_Node(yylineno, yytext, "FROM", "KEYWORD");
            return FROM;
        }
"global"    {
            yylval.node = new AST_Node(yylineno, yytext, "GLOBAL", "KEYWORD");
            return GLOBAL;
        }
"if"    {
            yylval.node = new AST_Node(yylineno, yytext, "IF", "KEYWORD");
            return IF;
        }
"import"    {
            yylval.node = new AST_Node(yylineno, yytext, "IMPORT", "KEYWORD");
            return IMPORT;
        }
"in"    {
            yylval.node = new AST_Node(yylineno, yytext, "IN", "KEYWORD");
            return IN;
        }
"is"    {
            yylval.node = new AST_Node(yylineno, yytext, "IS", "KEYWORD");
            return IS;
        }
"lambda"    {
            yylval.node = new AST_Node(yylineno, yytext, "LAMBDA", "KEYWORD");
            return LAMBDA;
        }
"nonlocal"  {
            yylval.node = new AST_Node(yylineno, yytext, "NONLOCAL", "KEYWORD");
            return NONLOCAL;
        }
"not"   {
            yylval.node = new AST_Node(yylineno, yytext, "NOT", "OPERATOR");
            return NOT;
        }
"or"    {
            yylval.node = new AST_Node(yylineno, yytext, "OR", "OPERATOR");
            return OR;
        }
"pass"  {
            yylval.node = new AST_Node(yylineno, yytext, "PASS", "KEYWORD");
            return PASS;
        }
"raise" {
            yylval.node = new AST_Node(yylineno, yytext, "RAISE", "KEYWORD");
            return RAISE;
        }
"return"    {
            yylval.node = new AST_Node(yylineno, yytext, "RETURN", "KEYWORD");
            return RETURN;
        }
"try"   {
            yylval.node = new AST_Node(yylineno, yytext, "TRY", "KEYWORD");
            return TRY;
        }
"while" {
            yylval.node = new AST_Node(yylineno, yytext, "WHILE", "KEYWORD");
            return WHILE;
        }
"with"  {
            yylval.node = new AST_Node(yylineno, yytext, "WITH", "KEYWORD");
            return WITH;
        }
"yield" {
            yylval.node = new AST_Node(yylineno, yytext, "YIELD", "KEYWORD");
            return YIELD;
        }
"\{"    {
            yylval.node = new AST_Node(yylineno, yytext, "OPEN_BRACE", "DELIMITER");
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_BRACE;
        }
"|"    {
            yylval.node = new AST_Node(yylineno, yytext, "BITWISE_OR", "OPERATOR");
            return BITWISE_OR;
        }
"|="    {
            yylval.node = new AST_Node(yylineno, yytext, "BITWISE_OR_EQUAL", "OPERATOR");
            return BITWISE_OR_EQUAL;
        }
"\}"   {
            yylval.node = new AST_Node(yylineno, yytext, "CLOSE_BRACE", "DELIMITER");
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_BRACE;
        }
"~"     {
            yylval.node = new AST_Node(yylineno, yytext, "BITWISE_NOT", "OPERATOR");
            return BITWISE_NOT;
        }
{NAME}  {
    
        if(debug) printf("LEXER:%s\n",yytext);
            yylval.node=new AST_Node(yylineno,yytext,"NAME","NAME");
            return NAME;
        }
{FLOATNUMBER}   {
                    if(debug) printf("FLOATNUMBER: %s\n", yytext);
                    yylval.node=new AST_Node(yylineno,yytext,"REAL_NUMBER","REAL_NUMBER");
                    yylval.node->set_float_val(stof(yytext));
                    return REAL_NUMBER;
                }
. {

}
%%

int yywrap() {
    return 1;
}