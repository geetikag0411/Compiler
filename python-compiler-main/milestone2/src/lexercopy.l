%option yylineno
%option yywrap
%{
    #include <bits/stdc++.h>
    // #include "parser.tab.h"
    using namespace std;
    
    stack<unsigned int> indent_level;
    int bracket_depth = 0;
    bool has_ended = 0;
    int dedent_count = 0;
    char blank = ' ';
    enum {  NUMBER = 258,
            STRING = 259,
            INDENT = 1,
            DEDENT=2,
            ASYNC,
            AWAIT,
            NOTEQUAL,
            MODULO,
            MODULO_EQUAL,
            BITWISE_AND,
            BITWISE_AND_EQUAL,
            OPEN_PAREN,
            CLOSE_PAREN,
            MULTIPLY,
            POWER,
            POWER_EQUAL,
            MULTIPLY_EQUAL,
            PLUS,
            PLUS_EQUAL,
            COMMA = 18,
            MINUS = 19,
            MINUS_EQUAL = 20,
            ARROW = 21,
            DOT = 22,
            ELLIPSIS = 23,
            DIVIDE = 24,
            FLOOR_DIVIDE = 25,
            FLOOR_DIVIDE_EQUAL = 26,
            DIVIDE_EQUAL = 27,
            COLON = 28,
            COLONEQUAL = 29,
            SEMICOLON = 30,
            LESS_THAN = 31,
            LEFT_SHIFT = 32,
            LEFT_SHIFT_EQUAL = 33,
            LESS_THAN_EQUAL = 34,
            EQUAL = 35,
            EQUAL_EQUAL = 36,
            GREATER_THAN = 37,
            GREATER_THAN_EQUAL = 38,
            RIGHT_SHIFT = 39,
            RIGHT_SHIFT_EQUAL = 40,
            AT = 41,
            ATEQUAL = 42,
            FALSE_ = 43,
            NONE = 44,
            TRUE_ = 45,
            OPEN_BRACKET = 46,
            CLOSE_BRACKET = 47,
            BITWISE_XOR = 48,
            BITWISE_XOR_EQUAL = 49,
            AND = 50,
            AS = 51,
            ASSERT = 52,
            BREAK = 53,
            CLASS = 54,
            CONTINUE = 55,
            DEF = 56,
            DEL = 57,
            ELIF = 58,
            ELSE = 59,
            EXCEPT = 60,
            FINALLY = 61,
            FOR = 62,
            FROM = 63,
            GLOBAL = 64,
            IF = 65,
            IMPORT = 66,
            IN = 67,
            IS = 68,
            LAMBDA = 69,
            NONLOCAL = 70,
            NOT = 71,
            OR = 72,
            PASS = 73,
            RAISE = 74,
            RETURN = 75,
            TRY = 76,
            WHILE = 77,
            WITH = 78,
            YIELD = 79,
            OPEN_BRACE = 80,
            BITWISE_OR = 81,
            BITWISE_OR_EQUAL = 82,
            CLOSE_BRACE = 83,
            BITWISE_NOT = 84,
            END_MARKER = 85,
            NAME = 86,
            NEWLINE = 87,
            ERROR = 88,  
            NEWLINE2 = 89, 
            REAL_NUMBER = 90
    };

    map<int, string> jadoo = {  
            {NUMBER, "NUMBER"},
            {STRING,"STRING"},
            {INDENT,"INDENT"},
            {DEDENT, "DEDENT"},
            {ASYNC,"ASYNC"},
            {AWAIT,"AWAIT"},
            {NOTEQUAL,"NOTEQUAL"},
            {MODULO,"MODULO"},
            {MODULO_EQUAL,"MODULO_EQUAL"},
            {BITWISE_AND,"BITWISE_AND"},
            {BITWISE_AND_EQUAL,"BITWISE_AND_EQUAL"},
            {OPEN_PAREN,"OPEN_PAREN"},
            {CLOSE_PAREN,"CLOSE_PAREN"},
            {MULTIPLY,"MULTIPLY"},
            {POWER,"POWER"},
            {POWER_EQUAL,"POWER_EQUAL"},
            {MULTIPLY_EQUAL,"MULTIPLY_EQUAL"},
            {PLUS,"PLUS"},
            {PLUS_EQUAL,"PLUS_EQUAL"},
            {COMMA, "COMMA"},
            {MINUS, "MINUS"},
            {MINUS_EQUAL, "MINUS_EQUAL"},
            {ARROW, "ARROW"},
            {DOT, "DOT"},
            {ELLIPSIS, "ELLIPSIS"},
            {DIVIDE, "DIVIDE"},
            {FLOOR_DIVIDE, "FLOOR_DIVIDE"},
            {FLOOR_DIVIDE_EQUAL, "FLOOR_DIVIDE_EQUAL"},
            {DIVIDE_EQUAL, "DIVIDE_EQUAL"},
            {COLON, "COLON"},
            {COLONEQUAL, "COLONEQUAL"},
            {SEMICOLON, "SEMICOLON"},
            {LESS_THAN, "LESS_THAN"},
            {LEFT_SHIFT, "LEFT_SHIFT"},
            {LEFT_SHIFT_EQUAL, "LEFT_SHIFT_EQUAL"},
            {LESS_THAN_EQUAL, "LESS_THAN_EQUAL"},
            {EQUAL, "EQUAL"},
            {EQUAL_EQUAL, "EQUAL_EQUAL"},
            {GREATER_THAN, "GREATER_THAN"},
            {GREATER_THAN_EQUAL, "GREATER_THAN_EQUAL"},
            {RIGHT_SHIFT, "RIGHT_SHIFT"},
            {RIGHT_SHIFT_EQUAL, "RIGHT_SHIFT_EQUAL"},
            {AT, "AT"},
            {ATEQUAL, "ATEQUAL"},
            {FALSE_, "FALSE_"},
            {NONE, "NONE"},
            {TRUE_, "TRUE_"},
            {OPEN_BRACKET, "OPEN_BRACKET"},
            {CLOSE_BRACKET, "CLOSE_BRACKET"},
            {BITWISE_XOR, "BITWISE_XOR"},
            {BITWISE_XOR_EQUAL, "BITWISE_XOR_EQUAL"},
            {AND, "AND"},
            {AS, "AS"},
            {ASSERT, "ASSERT"},
            {BREAK, "BREAK"},
            {CLASS, "CLASS"},
            {CONTINUE, "CONTINUE"},
            {DEF, "DEF"},
            {DEL, "DEL"},
            {ELIF, "ELIF"},
            {ELSE, "ELSE"},
            {EXCEPT, "EXCEPT"},
            {FINALLY, "FINALLY"},
            {FOR, "FOR"},
            {FROM, "FROM"},
            {GLOBAL, "GLOBAL"},
            {IF, "IF"},
            {IMPORT, "IMPORT"},
            {IN, "IN"},
            {IS, "IS"},
            {LAMBDA, "LAMBDA"},
            {NONLOCAL, "NONLOCAL"},
            {NOT, "NOT"},
            {OR, "OR"},
            {PASS, "PASS"},
            {RAISE, "RAISE"},
            {RETURN, "RETURN"},
            {TRY, "TRY"},
            {WHILE, "WHILE"},
            {WITH, "WITH"},
            {YIELD, "YIELD"},
            {OPEN_BRACE, "OPEN_BRACE"},
            {BITWISE_OR, "BITWISE_OR"},
            {BITWISE_OR_EQUAL, "BITWISE_OR_EQUAL"},
            {CLOSE_BRACE, "CLOSE_BRACE"},
            {BITWISE_NOT, "BITWISE_NOT"},
            {END_MARKER, "END_MARKER"},
            {NAME, "NAME"},
            {NEWLINE, "NEWLINE"},
            {ERROR , "ERROR"},
            {NEWLINE2,"NEWLINE2"}
    };
    
    /* Arithmetic_OPERATORS ("+"|"-"|"*"|"/"|"//"|"%"|"**")
/* Relation_OPERATORS ("=="|"!="|">"|"<"|">="|"<=") 
/* Logical_OPERATORS "and"|"or"|"not" 
/* Bitwise_OPERATORS ("<<"|">>"|"&"|"|"|"^"|"~")
/* Assignment_OPERATORS ("="|"+="|"-="|"*="|"/="|"%="|"**="|"&="|"|="|"^="|"<<="|">>=")
/* OPERATORS ({Arithmetic_OPERATORS}|{Relation_OPERATORS}|{Logical_OPERATORS}|{Bitwise_OPERATORS}|{Assignment_OPERATORS})   
/* KEYWORDS (False|await|else|import|pass|None|break|except|in|raise|True|class|finally|is|return|and|continue|for|lambda|try|as|def|from|nonlocal|while|assert|del|global|not|with|async|elif|if|or|yield)
/* Data_TYPES (int|float|str|bool)
/* Control_FLOW (if|else|elif|while|for|break|continue) */
/* TODO: FSTRING_END */
/* TODO: FSTRING_MIDDLE */
/* TODO: FSTRING_START */
/* TODO: TYPE_COMMENT */
/* TODO: f-string and related  FSTRING_END*/

/* F_STRING ({LITERAL_CHAR}|"{{"|"}}"|{REPLACEMENT_FIELD})*
/* REPLACEMENT_FIELD "{"{F_EXPRESSION}["="]?("!"{CONVERSION})?(":"FORMAT_SPEC)?"}"
/* F_EXPRESSION      (conditional_expression | "*" or_expr)
/*                     ("," conditional_expression | "," "*" or_expr)* [","]
/*                   | yield_expression
/* CONVERSION        "s" | "r" | "a"
/* FORMAT_SPEC       (LITERAL_CHAR | NULL | REPLACEMENT_FIELD)*
/* literal_char      <any code point except "{", "}" or NULL> */

%}
%x DEDENT_STATE
%s IMPLICIT_LINE_JOIN
NAME [a-zA-Z"_"][a-zA-Z"_"0-9]*
COMMENT ("#"[^\n]*)
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
STRINGLITERAL    {STRINGPREFIX}?({SHORTSTRING}|{LONGSTRING})
STRINGPREFIX     "r"|"u"|"R"|"U"|"f"|"F"|"fr"|"Fr"|"fR"|"FR"|"rf"|"rF"|"Rf"|"RF"
SHORTSTRING      "'"{SHORTSTRINGITEM}*"'"|"\""{SHORTSTRINGITEM}*"\""
LONGSTRING       "'''"{LONGSTRINGITEM}*"'''"|"\"\"\""{LONGSTRINGITEM}*"\"\"\""
SHORTSTRINGITEM  {SHORTSTRINGCHAR}|{STRINGESCAPESEQ}
LONGSTRINGITEM   {LONGSTRINGCHAR}|{STRINGESCAPESEQ}
SHORTSTRINGCHAR  [^\\\n'\"]
LONGSTRINGCHAR   [^\\]
STRINGESCAPESEQ  "\\".
ENDF <<EOF>>
FLOATNUMBER  {POINTFLOAT}|{EXPONENTFLOAT}
POINTFLOAT     {DIGITPART}?({FRACTION}|{DIGITPART})"." 
EXPONENTFLOAT  ({DIGITPART}|{POINTFLOAT}){EXPONENT}
DIGITPART      {DIGIT}(["_"]?{DIGIT})*
FRACTION       "."{DIGITPART}
EXPONENT      [eE][+-]?{DIGITPART}

%%
"\\\n"[ \t]* {

        }

<IMPLICIT_LINE_JOIN>[ \t\n]+  {

}


{INTEGER}    {
            //yylval.strval=strdup(yytext);
            return NUMBER;
        }

{STRINGLITERAL} {
            //yylval.strval=strdup(yytext);
            return STRING;
        }
"async"   {
            //yylval.strval=strdup(yytext);
            return ASYNC;
        }
await   {
            //yylval.strval=strdup(yytext);
            return AWAIT;
        }
{COMMENT}   {
            
        }

"\n"/[^" "\t]    {
            // yylval.strval=strdup(yytext);
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

"\n"/.    {
            return NEWLINE;
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
    BEGIN DEDENT_STATE;
    ++dedent_count;
    yyunput(1, &blank);
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
                     //yylval.strval=strdup(yytext);
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
            else 
            {
                if(has_ended) return END_MARKER;
                BEGIN INITIAL;
            }
            return DEDENT;
          }

"!="    {
            //yylval.strval=strdup(yytext);
            return NOTEQUAL;
        } 

"%"    {
            //yylval.strval=strdup(yytext);
            return MODULO;
        }
"%="    {
            //yylval.strval=strdup(yytext);
            return MODULO_EQUAL;
        }
"&"     {
            //yylval.strval=strdup(yytext);
            return BITWISE_AND;
        }
"&="    {
            //yylval.strval=strdup(yytext);
            return BITWISE_AND_EQUAL;
        }
"\("     {
            //yylval.strval=strdup(yytext);
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_PAREN;
        }
"\)"     {
            //yylval.strval=strdup(yytext);
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_PAREN;
        }
"*"     {
            //yylval.strval=strdup(yytext);
            return MULTIPLY;
        }
"**"    {
            //yylval.strval=strdup(yytext);
            return POWER;
        }
"**="   {
            //yylval.strval=strdup(yytext);
            return POWER_EQUAL;
        }
"*="    {
            //yylval.strval=strdup(yytext);
            return MULTIPLY_EQUAL;
        }
"+"     {
            //yylval.strval=strdup(yytext);
            return PLUS;
        }
"+="    {
            //yylval.strval=strdup(yytext);
            return PLUS_EQUAL;
        }
","     {
            //yylval.strval=strdup(yytext);
            return COMMA;
        }
"-"     {
            //yylval.strval=strdup(yytext);
            return MINUS;
        }
"-="        {
            //yylval.strval=strdup(yytext);
            return MINUS_EQUAL;
        }
"->"    {
            //yylval.strval=strdup(yytext);
            return ARROW;
        }
"."     {
            //yylval.strval=strdup(yytext);
            return DOT;
        }
"..."   {
            //yylval.strval=strdup(yytext);
            return ELLIPSIS;
        }
"/"     {
            //yylval.strval=strdup(yytext);
            return DIVIDE;
        }
"//"    {
            //yylval.strval=strdup(yytext);
            return FLOOR_DIVIDE;
        }
"//="   {
            //yylval.strval=strdup(yytext);
            return FLOOR_DIVIDE_EQUAL;
        }
"/="    {
            //yylval.strval=strdup(yytext);
            return DIVIDE_EQUAL;
        }
":"     {
            //yylval.strval=strdup(yytext);
            return COLON;
        }
":="    {
            //yylval.strval=strdup(yytext);
            return COLONEQUAL;
        }
";"     {
            //yylval.strval=strdup(yytext);
            return SEMICOLON;
        }
"<"     {
            //yylval.strval=strdup(yytext);
            return LESS_THAN;
        }
"<<"    {
            //yylval.strval=strdup(yytext);
            return LEFT_SHIFT;
        }
"<<="   {
            //yylval.strval=strdup(yytext);
            return LEFT_SHIFT_EQUAL;
        }
"<="    {
            //yylval.strval=strdup(yytext);
            return LESS_THAN_EQUAL;
        }
"="     {
            //yylval.strval=strdup(yytext);
            return EQUAL;
        }
"=="    {
            //yylval.strval=strdup(yytext);
            return EQUAL_EQUAL;
        }
">"     {
            //yylval.strval=strdup(yytext);
            return GREATER_THAN;
        }
">="    {
            //yylval.strval=strdup(yytext);
            return GREATER_THAN_EQUAL;
        }
">>"    {
            //yylval.strval=strdup(yytext);
            return RIGHT_SHIFT;
        }
">>="   {
            //yylval.strval=strdup(yytext);
            return RIGHT_SHIFT_EQUAL;
        }
"@"     {
            //yylval.strval=strdup(yytext);
            return AT;
        }
"@="    {
            //yylval.strval=strdup(yytext);
            return ATEQUAL;
        }
"False" {
            //yylval.strval=strdup(yytext);
            return FALSE_;
        }
"None"  {
            //yylval.strval=strdup(yytext);
            return NONE;
        }
"True"  {
            //yylval.strval=strdup(yytext);
            return TRUE_;
        }
"["     {
            //yylval.strval=strdup(yytext);
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_BRACKET;
        }
"]"     {
            //yylval.strval=strdup(yytext);
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_BRACKET;
        }
"^"     {
            //yylval.strval=strdup(yytext);
            return BITWISE_XOR;
        }
"^="    {
            //yylval.strval=strdup(yytext);
            return BITWISE_XOR_EQUAL;
        }
"and"   {
            //yylval.strval=strdup(yytext);
            return AND;
        }
"as"    {
            //yylval.strval=strdup(yytext);
            return AS;
        }
"assert"    {
            //yylval.strval=strdup(yytext);
            return ASSERT;
        }
"break"    {
            //yylval.strval=strdup(yytext);
            return BREAK;
        }
"class"   {
            //yylval.strval=strdup(yytext);
            return CLASS;
        }
"continue"  {
            //yylval.strval=strdup(yytext);
            return CONTINUE;
        }
"def"   {
            //yylval.strval=strdup(yytext);
            return DEF;
        }
"del"   {
            //yylval.strval=strdup(yytext);
            return DEL;
        }
"elif"  {
            //yylval.strval=strdup(yytext);
            return ELIF;
        }
"else"  {
            //yylval.strval=strdup(yytext);
            return ELSE;
        }
"except"    {
            //yylval.strval=strdup(yytext);
            return EXCEPT;
        }
"finally"   {
            //yylval.strval=strdup(yytext);
            return FINALLY;
        }
"for"   {
            //yylval.strval=strdup(yytext);
            return FOR;
        }
"from"  {
            //yylval.strval=strdup(yytext);
            return FROM;
        }
"global"    {
            //yylval.strval=strdup(yytext);
            return GLOBAL;
        }
"if"    {
            //yylval.strval=strdup(yytext);
            return IF;
        }
"import"    {
            //yylval.strval=strdup(yytext);
            return IMPORT;
        }
"in"    {
            //yylval.strval=strdup(yytext);
            return IN;
        }
"is"    {
            //yylval.strval=strdup(yytext);
            return IS;
        }
"lambda"    {
            //yylval.strval=strdup(yytext);
            return LAMBDA;
        }
"nonlocal"  {
            //yylval.strval=strdup(yytext);
            return NONLOCAL;
        }
"not"   {
            //yylval.strval=strdup(yytext);
            return NOT;
        }
"or"    {
            //yylval.strval=strdup(yytext);
            return OR;
        }
"pass"  {
            //yylval.strval=strdup(yytext);
            return PASS;
        }
"raise" {
            //yylval.strval=strdup(yytext);
            return RAISE;
        }
"return"    {
            //yylval.strval=strdup(yytext);
            return RETURN;
        }
"try"   {
            //yylval.strval=strdup(yytext);
            return TRY;
        }
"while" {
            //yylval.strval=strdup(yytext);
            return WHILE;
        }
"with"  {
            //yylval.strval=strdup(yytext);
            return WITH;
        }
"yield" {
            //yylval.strval=strdup(yytext);
            return YIELD;
        }
"\{"    {
            //yylval.strval=strdup(yytext);
            ++bracket_depth;
            BEGIN IMPLICIT_LINE_JOIN;
            return OPEN_BRACE;
        }
"|"    {
            //yylval.strval=strdup(yytext);
            return BITWISE_OR;
        }
"|="    {
            //yylval.strval=strdup(yytext);
            return BITWISE_OR_EQUAL;
        }
"\}"   {
            //yylval.strval=strdup(yytext);
            --bracket_depth;
            if(bracket_depth == 0) BEGIN INITIAL;
            return CLOSE_BRACE;
        }
"~"     {
            //yylval.strval=strdup(yytext);
            return BITWISE_NOT;
        }

{NAME}  {
            //yylval.strval=strdup(yytext);
            return NAME;
        }
<<EOF>> {printf("HUI"); if(dedent_count > 0) return DEDENT; else return 0; }
%%

void yyerror(const char* s) {
    fprintf(stderr, "Line number:%d Error: %s\n",yylineno, s);
}
int yywrap(){return 1;};

int main(){
    int type;
    while(type = yylex()){
     if(type==87)   cout << " " << "NEWLINE" << endl;
     else if(type==1)   cout<< " " << "INDENT" << endl;
     else if(type==2)   cout << " " << "DEDENT" << endl;
     else if(type==85) cout << " " << "ENDMARKER" << endl;
        else cout << yytext <<' '<< jadoo[type]<< endl;
    }
    cout << type << endl;
}