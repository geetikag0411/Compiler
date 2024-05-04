
%{
    #include <bits/stdc++.h>
    #include <unistd.h>
    #include <sstream>
    #include "ast_node.h"
    using namespace std;

    //python 3.7
    #define YYDEBUG 1
    extern int yylineno;
    extern char* yytext;
    extern int yylex(void);
    extern FILE* yyin;
    extern FILE* yyout;
    void yyerror(const char*);
    AST_Node* root{nullptr};
    int AST_Node::count = 0;
    bool kaam = false;
    bool string_one_or_more = false;
    bool verbose = false;
    std::ostringstream output;
%}

%union{
    class AST_Node* node;
}

%token<node>FOR SEMICOLON KEYWORDS ASYNC AWAIT COMMENT DEDENT END FSTRING INDENT MIDDLE NAME NEWLINE NUMBER MULTIPLY MODULO_EQUAL ERROR;
%token<node>START STRING TYPE END_MARKER AND OR NOT COMMA EQUAL_EQUAL COLONEQUAL LEFT_SHIFT RIGHT_SHIFT PLUS MINUS POWER DIVIDE 
%token<node>FLOOR_DIVIDE AT MODULO AND_KEYWORD OR_KEYWORD NOT_KEYWORD BITWISE_AND BITWISE_OR BITWISE_XOR BITWISE_NOT IN IMPORT
%token<node> YIELD FROM ELSE IF IS NOTEQUAL LESS_THAN GREATER_THAN EQUAL LESS_THAN_EQUAL COLON GREATER_THAN_EQUAL LEFT_SHIFT_EQUAL RIGHT_SHIFT_EQUAL ATEQUAL FALSE_ TRUE_ NONE NONLOCAL
%token<node> CLOSE_BRACE BITWISE_OR_EQUAL BITWISE_AND_EQUAL OPEN_PAREN CLOSE_PAREN POWER_EQUAL MULTIPLY_EQUAL PLUS_EQUAL MINUS_EQUAL ARROW DOT ELLIPSIS FLOOR_DIVIDE_EQUAL DIVIDE_EQUAL 
%token<node> OPEN_BRACKET CLOSE_BRACKET BITWISE_XOR_EQUAL AS ASSERT BREAK CLASS CONTINUE DEF DEL ELIF EXCEPT FINALLY GLOBAL LAMBDA PASS RAISE RETURN TRY WHILE WITH OPEN_BRACE REAL_NUMBER
%type<node>file_input newline_or_stmt_one_or_more funcdef parameters typedargslist stmts stmt simple_stmt small_stmt expr_stmt small_stmt_semicolon_sep expr_3_or equal_testlist_star_expr testlist_star_expr augassign flow_stmt return_stmt compound_stmt if_stmt elif_namedexpr_test_colon_suite_one_or_more while_stmt for_stmt suite namedexpr_test test or_test and_test_star and_test and_not_test_plus not_test not_plus_comparison comparison comp_op_expr_plus comp_op star_expr expr r_expr xor_expr x_expr and_expr a_expr shift_expr lr_shift arith_expr pm_term term op_fac factor power atom_expr trailer_one_or_more atom string_one_or_more testlist_comp comma_named_star_comma named_star_or comma_named_star trailer subscriptlist com_sub_rec subscript sliceop exprlist expr_or_star_expr_rec testlist cm_test expr_or_star_expr classdef optional_arguments arglist comma_arg argument comp_for_test comp_iter comp_for comp_if func_body_suite datatype
%precedence NAME CLOSE_BRACKET
%precedence OPEN_BRACKET OPEN_PAREN DOT
%start file_input
%left COMMA

%%
file_input: END_MARKER {/*if(verbose)printf("\nCompiled Successfully!\n");*/ $$=new AST_Node(yylineno, "file_input"); root = $$;} 
| newline_or_stmt_one_or_more END_MARKER {/*printf("\nCompiled Successfully!\n");*/ $$ = $1; root = $$;}
;

newline_or_stmt_one_or_more: newline_or_stmt_one_or_more NEWLINE {$$ = $1;}
| newline_or_stmt_one_or_more stmt {$$=$1;$$->add_children($2);}
| NEWLINE {$$=new AST_Node(yylineno, "File_input");}
| stmt {$$ = new AST_Node($1->get_line_no(), "File_input");$$->add_children($1);}
;

funcdef: DEF NAME parameters COLON func_body_suite {/*if(YYDEBUG) printf("Function\n");*/ $$ = new AST_Node($5->get_line_no(), "Function"); $$->add_children($1,$2, $3,$4, $5);}
| DEF NAME parameters ARROW test COLON func_body_suite {/*if(YYDEBUG) printf("Function\n");*/ $$=new AST_Node($7->get_line_no(), "Function");$$->add_children($1,$2, $3,$4, $5, $6, $7);}
;

parameters: OPEN_PAREN CLOSE_PAREN {/*if(YYDEBUG) printf("Parameters\n");*/ $$=new AST_Node($2->get_line_no(), "parameters");$$->add_children($1,$2);}
| OPEN_PAREN typedargslist CLOSE_PAREN {/*if(YYDEBUG) printf("Parameters\n");*/ $$=new AST_Node($3->get_line_no(), "parameters");$$->add_children($1,$2,$3);}
;

typedargslist: NAME {$$ = new AST_Node($1->get_line_no(), "Function Arguments");$$->add_children($1);}
| NAME COLON datatype {$$ = new AST_Node($3->get_line_no(), "Function Arguments");$$->add_children($1,$2,$3);}
| typedargslist COMMA NAME {$$ = $1; $$->add_children($2,$3);}
| typedargslist COMMA NAME COLON datatype {$$ = $1;$$->add_children($2,$3,$4,$5);}
| NAME EQUAL test {$$ = new AST_Node($3->get_line_no(), "Function Arguments");$$->add_children($2);$2->add_children($1,$3);}
| NAME COLON datatype EQUAL test {$$ = new AST_Node($5->get_line_no(), "Function Arguments");$$->add_children($4);auto var = new AST_Node($3->get_line_no(),"Variable");var->add_children($1,$2,$3);$4->add_children(var,$5);} 
| typedargslist COMMA NAME EQUAL test {$$ = $1; $$->add_children($2, $4); $4->add_children($3,$5);}
| typedargslist COMMA NAME COLON datatype EQUAL test {$$ = $1; AST_Node* var = new AST_Node($5->get_line_no(), "Variable"); var->add_children($3, $4, $5); $$->add_children($2, $6); $6->add_children(var,$7);}
;

stmt: simple_stmt {$$ = $1;}
| compound_stmt {$$ = $1;}
;

stmts: stmts stmt {$$=$1; $$->add_children($2);$$->change_line($2->get_line_no());} 
| stmt {$$ = new AST_Node($1->get_line_no(), "Statements");$$->add_children($1);}
;

simple_stmt: small_stmt_semicolon_sep NEWLINE {$$ = $1;}
;

small_stmt: expr_stmt {/*if(YYDEBUG) printf("\nParsersmall_stmt\n");*/ $$ = $1;}
| flow_stmt {/*if(YYDEBUG) printf("\nParserflow_stmt\n");*/ $$ = $1;}
;

small_stmt_semicolon_sep: small_stmt SEMICOLON small_stmt_semicolon_sep {$$=new AST_Node($3->get_line_no(), "Semicolon seperated statement");$$->add_children($1,$2);bool f = false;for(auto node: $3->get_children()){$$->add_children(node);f=true;};if(!f)$$->add_children($3);}
| small_stmt {$$ = $1;}
| small_stmt SEMICOLON {$$=new AST_Node($2->get_line_no(), "Semicolon seperated statement");$$->add_children($1,$2);}
;

expr_stmt: testlist_star_expr expr_3_or {$$ = new AST_Node($2->get_line_no(), "Expression"); auto node= new AST_Node($2->get_line_no(),$2->get_lexeme(), $2->get_type(),"OPERATOR");$$->add_children(node);node->add_children($1);for(auto child:$2->get_children())node->add_children(child); }
| testlist_star_expr COLON test {$$ = new AST_Node($3->get_line_no(), "Expression"); $$->add_children($1,$2,$3);}
| testlist_star_expr COLON test EQUAL testlist_star_expr    {$$ = new AST_Node($5->get_line_no(), "Expression"); AST_Node* variable = new AST_Node($3->get_line_no(), "Variable"); variable->add_children($1, $2, $3);auto node= new AST_Node($4->get_line_no(),"=", $4->get_type(),"OPERATOR"); $$->add_children(node); node->add_children(variable,$5); /*$4->add_children(variable, $5);*/}
| testlist_star_expr {$$ = new AST_Node($1->get_line_no(), "Expression"); $$->add_children($1);}
;

expr_3_or: augassign testlist {$$ = $1; $$->add_children($2);}
| equal_testlist_star_expr {$$ = $1;}
;

equal_testlist_star_expr: EQUAL testlist_star_expr {$$ =$1; $$->add_children($2);}
| EQUAL testlist_star_expr equal_testlist_star_expr {$$ = $1;  /*$$->add_children($3); $3->add_children($2);*/auto node= new AST_Node($3->get_line_no(),"=", $3->get_type(),"OPERATOR");$$->add_children(node);node->add_children($2);for(auto child:$3->get_children())node->add_children(child);}
;                     

testlist_star_expr: test COMMA testlist_star_expr {$$ = new AST_Node($3->get_line_no(), "Comma Seperated Expression"); $$->add_children($1,$2);if(!kaam){for(auto node: $3->get_children()){$$->add_children(node);}}else{$$->add_children($3);}kaam =false;}
| star_expr COMMA testlist_star_expr {$$ = new AST_Node($3->get_line_no(), "Comma Seperated Expression"); $$->add_children($1,$2);if(!kaam){for(auto node: $3->get_children()){$$->add_children(node);}}else{$$->add_children($3);}kaam =false;}
| test {$$ = $1;kaam = true;}
| star_expr {$$ = $1; kaam = true;}
| test COMMA {$$ = new AST_Node($2->get_line_no(), "Comma Seperated Expression"); $$->add_children($1,$2); kaam = false;}
| star_expr COMMA {$$ = new AST_Node($2->get_line_no(), "Comma Seperated Expression"); $$->add_children($1,$2); kaam = false;}
;

augassign: PLUS_EQUAL {$$ = $1;}
| MINUS_EQUAL {$$ = $1;}
| MULTIPLY_EQUAL {$$ = $1;}
| ATEQUAL {$$ = $1;}
| DIVIDE_EQUAL {$$ = $1;}
| MODULO_EQUAL {$$ = $1;}
| BITWISE_AND_EQUAL  {$$ = $1;}
| BITWISE_OR_EQUAL {$$ = $1;}
| BITWISE_XOR_EQUAL {$$ = $1;}
| LEFT_SHIFT_EQUAL {$$ = $1;}
| RIGHT_SHIFT_EQUAL {$$ = $1;}
| POWER_EQUAL {$$ = $1;}
| FLOOR_DIVIDE_EQUAL {$$ = $1;}
;
    

flow_stmt: BREAK {$$ = $1;}
| CONTINUE {$$ = $1;}
| return_stmt {$$ = $1;}
;

return_stmt: RETURN {$$ = $1;}
| RETURN testlist_star_expr {$$ = new AST_Node($2->get_line_no(), "return_stmt"); $$->add_children($1,$2);}
;

compound_stmt: if_stmt {$$= $1;}
| while_stmt {$$ = $1;}
| for_stmt {$$ = $1;}
| funcdef {$$ = $1;}
| classdef {$$ = $1;}
;

if_stmt: IF namedexpr_test COLON suite {$$ = new AST_Node($4->get_line_no(), "If statement"); $$->add_children($1,$2,$3,$4);}
| IF namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more {$$ = new AST_Node($5->get_line_no(), "If statement"); $$->add_children($1,$2,$3,$4); for(auto child:$5->get_children())$$->add_children(child);}
| IF namedexpr_test COLON suite ELSE COLON suite {$$ = new AST_Node($7->get_line_no(), "If statement"); $$->add_children($1,$2,$3,$4,$5,$6,$7);}
| IF namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more ELSE COLON suite {$$ = new AST_Node($8->get_line_no(), "If statement"); $$->add_children($1,$2,$3,$4);for(auto child:$5->get_children())$$->add_children(child);$$->add_children($6,$7,$8);}
;

elif_namedexpr_test_colon_suite_one_or_more: elif_namedexpr_test_colon_suite_one_or_more ELIF namedexpr_test COLON suite {$$ = $1; $$->add_children($2,$3,$4,$5);}
| ELIF namedexpr_test COLON suite {$$ = new AST_Node($4->get_line_no(), "elif_namedexpr_test_colon_suite_one_or_more"); $$->add_children($1,$2,$3,$4);}
;

while_stmt: WHILE namedexpr_test COLON suite  { $$ = new AST_Node($4->get_line_no(), "While statement"); $$->add_children($1,$2,$3,$4);}
| WHILE namedexpr_test COLON suite ELSE COLON suite { $$ = new AST_Node($7->get_line_no(), "While statement"); $$->add_children($1,$2,$3,$4,$5,$6,$7);}
;

for_stmt: FOR exprlist IN testlist COLON suite { $$ = new AST_Node($6->get_line_no(), "For statement"); $$->add_children($1,$2,$3,$4,$5,$6);}
| FOR exprlist IN testlist COLON suite ELSE COLON suite {$$ = new AST_Node($9->get_line_no(), "For statement"); $$->add_children($1,$2,$3,$4,$5,$6,$7,$8,$9);}
;

suite: simple_stmt {$$ = $1;}
| NEWLINE INDENT stmts DEDENT {$$ = $3;}
;

namedexpr_test: test {$$ = $1;}
| test COLONEQUAL test {$$=$2; $$->add_children($1,$3);}
;

test: or_test {$$ = $1;}
| or_test IF or_test ELSE test {$$ = new AST_Node($2->get_line_no(), "Ternary Operator"); $$->add_children($1,$2,$3,$4,$5);}
;



or_test: and_test {$$ = $1;}
|and_test_star and_test    {$$ = $1; $$->add_children($2);}
;

and_test_star: and_test OR  {$$=$2; $$->add_children($1);}
| and_test_star and_test OR {$$ = $3; $1->add_children($2); $$->add_children($1);}
;
and_test: not_test {$$ = $1;}
|and_not_test_plus not_test {$$ =$1; $$->add_children($2);}
;

and_not_test_plus: not_test AND  {$$ = $2; $$->add_children($1);}
| and_not_test_plus not_test AND     {$$ =$3; $1->add_children($2); $$->add_children($1);}
;
not_test: not_plus_comparison  {$$ = $1;}
| comparison    {$$ = $1;}
;

not_plus_comparison : NOT comparison  {$$ = $1; $$->add_children($2);}
| NOT not_plus_comparison   {$$ = $1; $$->add_children($2);}
;

comparison: comp_op_expr_plus expr {$$ = $1; $$->add_children($2);}
| expr {$$ = $1;}
;

comp_op_expr_plus: expr comp_op {$$ = $2; $$->add_children($1);}
| comp_op_expr_plus expr comp_op   {$$=$3; $1->add_children($2); $$->add_children($1);}
;

comp_op: GREATER_THAN {$$ = $1;}
| LESS_THAN {$$ = $1;}
| EQUAL_EQUAL {$$ = $1;}
| GREATER_THAN_EQUAL {$$ = $1;}
| LESS_THAN_EQUAL   {$$ = $1;}
| NOTEQUAL  {$$ = $1;}
| IN    {$$ = $1;}
| NOT IN  {$$ = new AST_Node($2->get_line_no(), "comp_op"); $$->add_children($1,$2);}
| IS    {$$ = $1;}
| IS NOT   {$$ = new AST_Node($2->get_line_no(), "comp_op"); $$->add_children($1,$2);}
;

star_expr: MULTIPLY expr {$$ = $1; $$->add_children($2);}
;

expr: r_expr xor_expr    {$$ = $1; $$->add_children($2);}
| xor_expr  {$$=$1;}
;

r_expr: r_expr xor_expr BITWISE_OR  {$$ = $3; $$->add_children($1); $1->add_children($2);}
|  xor_expr BITWISE_OR {$$ = $2; $$->add_children($1);}
;

xor_expr: x_expr and_expr    {$$ = $1; $1->add_children($2);}
| and_expr  {$$ = $1;}
;

x_expr: x_expr and_expr BITWISE_XOR  {$$ = $3; $$->add_children($1); $1->add_children($2);}
|and_expr BITWISE_XOR   {$$ = $2; $$->add_children($1);}
;

and_expr: a_expr shift_expr  {$$ = $1; $1->add_children($2);}
| shift_expr    {$$ = $1;}
;

a_expr: a_expr shift_expr BITWISE_AND    {$$ = $3; $$->add_children($1); $1->add_children($2);}
|shift_expr BITWISE_AND     {$$ = $2; $$->add_children($1);}
;

shift_expr: lr_shift arith_expr     {$$ = $1; $1->add_children($2);}
| arith_expr  {$$ = $1;}
;

lr_shift: arith_expr LEFT_SHIFT  {$$ = $2; $$->add_children($1);}
| arith_expr RIGHT_SHIFT     {$$ = $2; $$->add_children($1);}
| lr_shift  arith_expr LEFT_SHIFT {$$ = $3; $$->add_children($1); $1->add_children($2);}
| lr_shift  arith_expr RIGHT_SHIFT     {$$ = $3; $$->add_children($1); $1->add_children($2);}
;

arith_expr:pm_term term     {$$ = $1; $1->add_children($2);}
| term  {$$ = $1;}
;

pm_term:term PLUS   {$$ = $2; $$->add_children($1);}
| term  MINUS    {$$ = $2; $$->add_children($1);}
|pm_term term PLUS   {$$ = $3; $$->add_children($1); $1->add_children($2);}
| pm_term term MINUS      {$$ = $3; $$->add_children($1); $1->add_children($2);}
;

term: factor {$$ = $1;}
| op_fac factor  {$$ = $1; $1->add_children($2);}
;

op_fac:factor MULTIPLY  {$$ = $2; $$->add_children($1);}
| factor AT  {$$ = $2; $$->add_children($1);}
| factor DIVIDE  {$$ = $2; $$->add_children($1);}
| factor MODULO  {$$ = $2; $$->add_children($1);}
| factor FLOOR_DIVIDE    {$$ = $2; $$->add_children($1);}
| op_fac factor  MULTIPLY    {$$ = $3; $1->add_children($2); $$->add_children($1);}
| op_fac factor AT   {$$ = $3; $$->add_children($1); $1->add_children($2);}
| op_fac factor DIVIDE   {$$ = $3; $$->add_children($1); $1->add_children($2);}
| op_fac  factor MODULO   {$$ = $3; $$->add_children($1); $1->add_children($2);}
| op_fac factor FLOOR_DIVIDE     {$$=$3; $$->add_children($1); $1->add_children($2);}
;

factor: PLUS factor {$$ =$1; $$->add_children($2);}
| MINUS factor  {$$ =$1; $$->add_children($2);}
| BITWISE_NOT factor    {$$ =$1; $$->add_children($2);}
| power {$$ = $1;}
;

power: atom_expr    {$$ = $1;}
| atom_expr POWER factor    {$$ = $2; $$->add_children($1,$3);/*$$ = new AST_Node($3->get_line_no(), "power");  $$->add_children($1, $2, $3);*/ }
;

atom_expr: atom {$$ = $1;}
| atom trailer_one_or_more  {$$ = new AST_Node($2->get_line_no(), "Atomic Expression");  $$->add_children($1);for(auto child:$2->get_children()){if(child->get_type()=="Atomic Expression"){for(auto node:child->get_children())$$->add_children(node);}else{$$->add_children(child);}}}
;

trailer_one_or_more: trailer_one_or_more trailer    {$$ = $1; for(auto node: $2->get_children()) $$->add_children(node);}
| trailer   {$$ = $1;}
;

atom: OPEN_PAREN testlist_comp CLOSE_PAREN  {$$ = new AST_Node($3->get_line_no(), "Atom");  $$->add_children($1, $2, $3);}
| OPEN_PAREN CLOSE_PAREN    {$$ = new AST_Node($2->get_line_no(), "Atom");  $$->add_children($1, $2);}
| OPEN_BRACKET testlist_comp CLOSE_BRACKET  {$$ = new AST_Node($3->get_line_no(), "Atom");  $$->add_children($1, $2, $3);}
| OPEN_BRACKET CLOSE_BRACKET    {$$ = new AST_Node($2->get_line_no(), "Atom");  $$->add_children($1, $2);}
| NAME {$$=$1;}
| NUMBER {$$=$1;}
| string_one_or_more    {$$=$1;}
| ELLIPSIS  {$$=$1;}
| NONE  {$$=$1;}
| TRUE_     {$$=$1;}
| FALSE_    {$$=$1;}
| REAL_NUMBER   {$$=$1;}
;


string_one_or_more: string_one_or_more STRING   {if(string_one_or_more){$$ = new AST_Node($2->get_line_no(),"Strings"); $$->add_children($1,$2);}else{$$=$1;$$->add_children($2);}string_one_or_more=false;/*$$ = new AST_Node($2->get_line_no(), "string_one_or_more");  $$->add_children($1, $2);*/}
| STRING    {$$=$1;string_one_or_more = true;}
;

testlist_comp: named_star_or comp_for   {$$ = new AST_Node($2->get_line_no(), "Arguments");  $$->add_children($1, $2);} 
| named_star_or comma_named_star_comma  {$$ = new AST_Node($2->get_line_no(), "Arguments");  $$->add_children($1); for(auto node: $2->get_children())$$->add_children(node);}
| named_star_or {$$ =$1;}
;

;
comma_named_star_comma: comma_named_star COMMA  {$$=$1;$$->add_children($2);}
| comma_named_star  {$$ = $1;}
| COMMA {$$ = $1;}
;
named_star_or: namedexpr_test   {$$ =$1;}
| star_expr {$$ =$1;}
;

comma_named_star: COMMA named_star_or   {$$ = new AST_Node($2->get_line_no(), "comma_named_star");  $$->add_children($1, $2);}
| comma_named_star COMMA named_star_or  {$$ = $1;  $$->add_children($2, $3);}
;

trailer: OPEN_PAREN arglist CLOSE_PAREN {$$ = new AST_Node($3->get_line_no(), "trailer");  $$->add_children($1, $2, $3);}
| OPEN_PAREN CLOSE_PAREN {$$ = new AST_Node($2->get_line_no(), "trailer");  $$->add_children($1, $2);}
| OPEN_BRACKET subscriptlist CLOSE_BRACKET {$$ = new AST_Node($3->get_line_no(), "trailer");  $$->add_children($1, $2, $3);}
| DOT NAME  {$$= new AST_Node($2->get_line_no(), "trailer");$$->add_children($1,$2);}
;
subscriptlist: subscript com_sub_rec COMMA  {$$ = new AST_Node($3->get_line_no(), "Subscriptlist");  $$->add_children($1); for(auto &child: $2->get_children()){$$->add_children(child);} $$->add_children($3);}
|subscript com_sub_rec  {$$ = new AST_Node($2->get_line_no(), "Subscriptlist");  $$->add_children($1); for(auto &child: $2->get_children()){$$->add_children(child);}}
|subscript COMMA    {$$ = new AST_Node($2->get_line_no(), "Subscriptlist");  $$->add_children($1, $2);}
|subscript  {$$ =$1;}
;
com_sub_rec: com_sub_rec COMMA subscript    {$$ = $1; $$->add_children($2, $3);}
| COMMA subscript   {$$ = new AST_Node($2->get_line_no(), "com_sub_rec");  $$->add_children($1, $2);}
;

subscript: test {$$ = $1;}
| COLON {$$ = $1;}
| test COLON    {$$ = new AST_Node($2->get_line_no(), "Subscript");  $$->add_children($1, $2);}
| COLON test    {$$ = new AST_Node($1->get_line_no(), "Subscript");  $$->add_children($1,$2);}
| test COLON test   {$$ = new AST_Node($3->get_line_no(), "Subscript");  $$->add_children($1, $2, $3);}
| COLON sliceop {$$ = new AST_Node($2->get_line_no(), "Subscript");  $$->add_children($1, $2);}
| test COLON sliceop    {$$ = new AST_Node($3->get_line_no(), "Subscript"); $$->add_children($1,$2,$3);}
| COLON test sliceop    {$$ = new AST_Node($3->get_line_no(), "Subscript"); $$->add_children($1,$2,$3);}
| test COLON test sliceop   { $$ = new AST_Node($4->get_line_no(), "Subscript"); $$->add_children($1,$2,$3,$4);}
;
sliceop: COLON  { $$ =$1;}
| COLON test    { $$ = new AST_Node($2->get_line_no(), "Slice"); $$->add_children($1,$2);}
;

/*can make exprlist shorter*/
exprlist: expr_or_star_expr COMMA   { $$ = new AST_Node($2->get_line_no(), "Expression List"); $$->add_children($1,$2);}
|expr_or_star_expr  { $$ =$1;}
|expr_or_star_expr expr_or_star_expr_rec    { $$ = new AST_Node($2->get_line_no(), "Expression List"); $$->add_children($1); for(auto &child: $2->get_children()){$$->add_children(child);}} 
|expr_or_star_expr expr_or_star_expr_rec COMMA  { $$ = new AST_Node($3->get_line_no(), "Expression List"); $$->add_children($1); for(auto &child: $2->get_children()){$$->add_children(child);} $$->add_children($3);}
;
expr_or_star_expr_rec:COMMA expr_or_star_expr   { $$ = new AST_Node($2->get_line_no(), "expr_or_star_expr_rec"); $$->add_children($1,$2);}
|expr_or_star_expr_rec COMMA expr_or_star_expr   { $$ = $1;; $$->add_children($2,$3);}
;

testlist: test cm_test COMMA    { $$ = new AST_Node($3->get_line_no(), "Testlist"); $$->add_children($1);for(auto child: $2->get_children())$$->add_children(child);$$->add_children($3);}
| test cm_test   { $$ = new AST_Node($2->get_line_no(), "Testlist"); $$->add_children($1); for(auto child: $2->get_children())$$->add_children(child);}
| test   { $$ =$1;}
| test COMMA    { $$ = new AST_Node($2->get_line_no(), "Testlist"); $$->add_children($1,$2);}
;
cm_test: cm_test COMMA test  { $$ = $1; $$->add_children($2,$3);}
|COMMA test {$$ = new AST_Node($2->get_line_no(), "cm_test"); $$->add_children($1,$2);}
;
expr_or_star_expr: expr { $$ =$1;}
| star_expr { $$ =$1;}
;

classdef: CLASS NAME optional_arguments COLON suite { $$ = new AST_Node($5->get_line_no(), "Class Defination"); $$->add_children($1,$2,$3,$4,$5);}
| CLASS NAME COLON suite    { $$ = new AST_Node($4->get_line_no(), "Class Defination"); $$->add_children($1,$2,$3,$4);}
;

optional_arguments: OPEN_PAREN CLOSE_PAREN  { $$ = new AST_Node($2->get_line_no(), "Optional arguments"); $$->add_children($1,$2);}
| OPEN_PAREN arglist CLOSE_PAREN    { $$ = new AST_Node($3->get_line_no(), "Optional arguments"); $$->add_children($1,$2,$3);}
;

arglist: argument comma_arg {$$ = new AST_Node($2->get_line_no(), "Arguments"); $$->add_children($1); for(auto child:$2->get_children())$$->add_children(child);}
| argument comma_arg COMMA  { $$ = new AST_Node($2->get_line_no(), "Arguments"); $$->add_children($1); for(auto child:$2->get_children())$$->add_children(child);$$->add_children($3);}
| argument  {$$ =$1;}
| argument COMMA    { $$ = new AST_Node($2->get_line_no(), "Arguments"); $$->add_children($1,$2);}
;

comma_arg: COMMA argument   {$$ = new AST_Node($2->get_line_no(), "Arguments"); $$->add_children($1,$2);}
| comma_arg COMMA argument  {$$ = $1; $$->add_children($2,$3);}
;

argument: test  {$$ =$1;}
| test comp_for_test    {$$ = new AST_Node($2->get_line_no(), "Argument"); $$->add_children($1,$2);}
| POWER test  {$$ = $1; $$->add_children($2);}
| MULTIPLY test {$$ = $1; $$->add_children($2);}
;

comp_for_test: comp_for {$$ =$1;}
| COLONEQUAL test {$$ = $1; $$->add_children($2);}
| EQUAL test    {$$ = $1; $$->add_children($2);}
;

comp_iter: comp_for {$$ =$1;}
| comp_if {$$ =$1;}
;


comp_for: FOR exprlist IN or_test {$$ = new AST_Node($4->get_line_no(), "Inline For");$$->add_children($1,$2,$3,$4);}
| FOR exprlist IN or_test comp_iter {$$ = new AST_Node($5->get_line_no(), "Inline For");$$->add_children($1,$2,$3,$4,$5);}
;

comp_if: IF or_test {$$ = new AST_Node($2->get_line_no(), "If inside For");$$->add_children($1,$2);}
| IF or_test comp_iter {$$ = new AST_Node($3->get_line_no(), "If inside For");$$->add_children($1,$2,$3);}
;

func_body_suite: simple_stmt {$$ =$1;}
| NEWLINE INDENT stmts DEDENT {$$ =$3;}
;

datatype: NAME {$$ =$1;}
| NAME OPEN_BRACKET NAME CLOSE_BRACKET {$$ = new AST_Node($4->get_line_no(), "Datatype"); $$->add_children($1,$2,$3,$4);}
;

%%

 void print_verbose() {
    std::ifstream file("temp");
    if (!file.is_open()) {
        std::cerr << "Error opening file" << std::endl;
        return;
    }

    // Open the output file "verbose.log" with append mode
    std::ofstream outfile("verbose.log", std::ios_base::app);
    if (!outfile.is_open()) {
        std::cerr << "Error opening output file" << std::endl;
        file.close(); // Close the input file
        return;
    }

    std::vector<std::vector<std::string>> lines;

    std::string line;
    while (std::getline(file, line)) {
        std::istringstream iss(line);
        std::vector<std::string> tokens;
        std::string token;
        while (iss >> token) {
            tokens.push_back(token);
        }
        lines.push_back(tokens);
    }

    file.close();

    for (const auto& line : lines) {
        if (line.size() > 0) {
            if (line[0] == "Shifting") {
                if (line.size() > 2) { // Ensure there are enough elements in the line
                    outfile << "Next token read is " << line[2];
                    outfile << std::endl;
                }
            } else if (line[0] == "Reducing"&&line.size()>1) {

            outfile<<line[0]<<' '<<line[1]<<' '<<line[2]<<' '<<line[3]<<' '<<"on"<<' '<<line[5]<<line[6]<<" in parser.y";
                // Do something for "Reducing" lines if needed
                                    outfile << std::endl;

            }
        }
    }

    outfile.close(); // Close the output file
}

void print_help(){
    cout << "Usage: ./parser <flags>\n";
    cout << "--input <input-file>: Specify the input program file\n";
    cout << "--output <output-file>: Specify the output dot file\n";
    cout << "--verbose: Generate additional details about parsing in \"verbose.log\" file\n";
    cout << "--help: Print this help\n";
}

int main(int argc, char* argv[]) {    
    yydebug = 0;
    string input_file_path;
    string output_file_path = "tree.dot";
    for(int i = 1; i < argc; ++i){
        if(string(argv[i]) == "--help"){
            print_help();
            return 0;
        }
        else if(string(argv[i]) == "--verbose") {
            verbose = true;
            yydebug = 1; 
            string error_file_path = "temp";
            freopen(error_file_path.c_str(), "w", stderr); 
        }
        else if(string(argv[i]) == "--input"){
            if(++i < argc) input_file_path = argv[i];
            else{
                cerr << "Error: No input file provided\n";
                return 1;
            }
        }
        else if(string(argv[i]) == "--output"){
            if(++i < argc) output_file_path = argv[i];
            else{
                cerr << "Error: No output file provided\n";
                return 1;
            }
        }
        else{
            cerr << "Error: unknown flag " << argv[i] << "\n";
            print_help();
            return 1;
        }
    }
    if(input_file_path.size() > 0){
        FILE *input_file = fopen(input_file_path.c_str(), "r");
        if (!input_file) {
            cerr << "Error: Unable to open " << input_file_path << "\n";
            return 1;
        }
        yyin = input_file;
    }
     
    // cout<<output.str();
    yyparse();
    /* cout<<output.str(); */
    root->make_tree(output_file_path);
    // cout<<output.str();
    // cout << verbose << endl;

    if(verbose)
    {   
       print_verbose();
       yydebug = 1;
    }

    string output_pdf_file;
    for(int i=output_file_path.size()-1; i>=0; i--){
        if(output_file_path[i] == '.'){
            // cout << output_file_path<< i << "   hgfjhgv "<<endl;
            output_pdf_file = output_file_path.substr(0,i) + ".pdf";
            break;        
            }
            if(output_file_path[i] == '/'){
            output_pdf_file = output_file_path + ".pdf";
            break;
            }
    }
    if(output_pdf_file == ""){
        output_pdf_file = output_file_path + ".pdf";
    }
    const char *output_file_path_c = output_file_path.c_str();
    const char *output_pdf_file_c= output_pdf_file.c_str();
    char *const argv2[] = { const_cast<char*>("/bin/dot"),  const_cast<char*>("-Tpdf"), const_cast<char*>(output_file_path_c), const_cast<char*>("-o"), const_cast<char*>(output_pdf_file_c), NULL};
    // argv[2] = output_file_path_c;
    // argv[3] = "-o";
    // argv[4] = output_pdf_path_c;

    if (execvp("/bin/dot", const_cast<char* const*>(argv2)) == -1) {
        perror("execve");
    }
}

void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error: Line number:%d offending token:%s\n",yylineno, yytext);
    if(verbose)
    {
       print_verbose();
        yydebug = 1;
    }
    exit(1);
 }
