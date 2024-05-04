
%{
    #include <bits/stdc++.h>
    #include <unistd.h>
    #include <sstream>
    #include "NonTerminal.hpp"
    #include "symbol_table.hpp"
    using namespace std;

    //python 3.7
    #define YYDEBUG 1
    extern int yylineno;
    extern char* yytext;
    extern int yylex(void);
    extern FILE* yyin;
    extern FILE* yyout;
    void yyerror(const char*);
    bool string_one_or_more = false;
    bool verbose = false;
    std::ostringstream output;
    stack<symbol_table*> symbol_table_stack;
    symbol_table* curr_symbol_table{nullptr};
    symbol_table_global* global_symbol_table{nullptr};
    symbol_table_function* curr_function{nullptr};
    int funtion_arg_counter = 0;
%}

%union{
    class NonTerminal* node;
    struct Type* type;
    class NonTerminal* nonTerminal;
}

%token<nonTerminal> FOR SEMICOLON KEYWORDS ASYNC AWAIT COMMENT DEDENT END FSTRING INDENT MIDDLE NAME NEWLINE NUMBER MULTIPLY MODULO_EQUAL ERROR;
%token<nonTerminal> START STRING TYPE END_MARKER AND OR NOT COMMA EQUAL_EQUAL COLONEQUAL LEFT_SHIFT RIGHT_SHIFT PLUS MINUS POWER DIVIDE 
%token<nonTerminal> FLOOR_DIVIDE AT MODULO AND_KEYWORD OR_KEYWORD NOT_KEYWORD BITWISE_AND BITWISE_OR BITWISE_XOR BITWISE_NOT IN IMPORT
%token<nonTerminal> YIELD FROM ELSE IF IS NOTEQUAL LESS_THAN GREATER_THAN EQUAL LESS_THAN_EQUAL COLON GREATER_THAN_EQUAL LEFT_SHIFT_EQUAL RIGHT_SHIFT_EQUAL ATEQUAL FALSE_ TRUE_ NONE NONLOCAL
%token<nonTerminal> CLOSE_BRACE BITWISE_OR_EQUAL BITWISE_AND_EQUAL OPEN_PAREN CLOSE_PAREN POWER_EQUAL MULTIPLY_EQUAL PLUS_EQUAL MINUS_EQUAL ARROW DOT ELLIPSIS FLOOR_DIVIDE_EQUAL DIVIDE_EQUAL 
%token<nonTerminal> OPEN_BRACKET CLOSE_BRACKET BITWISE_XOR_EQUAL AS ASSERT BREAK CLASS CONTINUE DEF DEL ELIF EXCEPT FINALLY GLOBAL LAMBDA PASS RAISE RETURN TRY WHILE WITH OPEN_BRACE REAL_NUMBER
%type<nonTerminal> file_input newline_or_stmt_one_or_more funcdef parameters typedargslist stmts stmt simple_stmt small_stmt expr_stmt small_stmt_semicolon_sep expr_3_or equal_testlist_star_expr testlist_star_expr augassign flow_stmt return_stmt compound_stmt if_stmt elif_namedexpr_test_colon_suite_one_or_more while_stmt for_stmt suite namedexpr_test test or_test and_test_star and_test and_not_test_plus not_test not_plus_comparison comparison comp_op_expr_plus comp_op expr r_expr xor_expr x_expr and_expr a_expr shift_expr lr_shift arith_expr pm_term term op_fac factor power atom_expr atom string_one_or_more testlist_comp comma_named_star_comma named_star_or comma_named_star  exprlist  testlist classdef arglist comma_arg argument func_body_suite func_return_type global_stmt funcdef_head
%type<type> datatype
%precedence NAME CLOSE_BRACKET
%precedence OPEN_BRACKET OPEN_PAREN DOT
%start file_input
%left COMMA

%%
file_input: END_MARKER 
| newline_or_stmt_one_or_more END_MARKER 
;

newline_or_stmt_one_or_more: newline_or_stmt_one_or_more NEWLINE 
| newline_or_stmt_one_or_more stmt 
| NEWLINE 
| stmt 
;

funcdef: funcdef_head parameters COLON func_body_suite {
        if($1->get_lexeme() == "__init__"){
            Type new_type;
            new_type.datatype = curr_symbol_table->get_parent_st()->get_name();
            curr_symbol_table->set_return_type(new_type);
        }
        if(symbol_table_stack.size() == 0){
            cout << "trying to pop empty stack" << endl;
            exit(-1);
        }
        symbol_table_stack.pop();
        curr_symbol_table = symbol_table_stack.top();
    }
| funcdef_head parameters func_return_type COLON func_body_suite { if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
;

funcdef_head: DEF NAME {auto func_symbol_table = curr_symbol_table->create_new_function($2->get_lexeme()); symbol_table_stack.push(func_symbol_table); curr_symbol_table = func_symbol_table; $$ = new NonTerminal($2->get_line_no(), $2->get_lexeme());}
;

parameters: OPEN_PAREN CLOSE_PAREN 
| OPEN_PAREN typedargslist CLOSE_PAREN 
;

func_return_type: ARROW datatype {curr_symbol_table->set_return_type(*$2);}
| ARROW NONE {Type type = {"None", 0}; curr_symbol_table->set_return_type(type);}
;

typedargslist: NAME COLON datatype {
    curr_symbol_table->add_parameter($1->get_lexeme(),*$3,$1->get_line_no());}
| typedargslist COMMA NAME COLON datatype {
    curr_symbol_table->add_parameter($3->get_lexeme(),*$5,$1->get_line_no());/*$$ = $1;$$->add_children($2,$3,$4,$5);*/}
| NAME {
        if($1->get_lexeme() != "self")
        {
            cout << "datatype for function parameter " << $1->get_lexeme() <<  " not specified on line no: "<< $1->get_line_no() << "\n"; exit(-1);
        }
        curr_symbol_table->add_parameter($1->get_lexeme(),{, 0},$1->get_line_no());
        
        }
| typedargslist COMMA NAME {if($1->get_lexeme() != "self"){cout << "function parameter datatype " << $1->get_lexeme() <<  " not specified on line no: "<< $1->get_line_no() << "\n"; exit(-1);} curr_symbol_table->add_parameter($1->get_lexeme(),{"self", 0},$1->get_line_no());/*$$ = $1;$$->add_children($2,$3,$4,$5);*/}
;

stmt: simple_stmt 
| compound_stmt 
;

stmts: stmts stmt 
| stmt 
;

simple_stmt: small_stmt_semicolon_sep NEWLINE 
;

small_stmt: expr_stmt 
| flow_stmt 
| global_stmt
;

global_stmt: GLOBAL NAME
| GLOBAL NAME comma_name_one_or_more
;

comma_name_one_or_more: COMMA NAME
| COMMA NAME comma_name_one_or_more
; 

small_stmt_semicolon_sep: small_stmt SEMICOLON small_stmt_semicolon_sep 
| small_stmt 
| small_stmt SEMICOLON 
;

expr_stmt: testlist_star_expr expr_3_or 
| NAME COLON datatype {if(curr_symbol_table->lookup($1->get_lexeme()) != nullptr){cout << "Variable redeclaration in same scope at line no: " << $3->get_line_no() << endl; exit(-1);} curr_symbol_table->insert($1->get_lexeme(), *$3, $3->get_line_no(), false);}
| NAME COLON datatype EQUAL testlist_star_expr {
        if(curr_symbol_table->lookup($1->get_lexeme()) != nullptr){
            cout << "Variable redeclaration in same scope at line no: " << $5->get_line_no() << endl;
            exit(-1);
        }
        curr_symbol_table->insert($3->get_lexeme(), *$3, $3->get_line_no(), true);
        if(!$5->is_compatible_datatype(*$3)){
            cout << "Type mismatch in assignment at line no: " << $5->get_line_no();
            exit(-1);
        }
    }
| testlist_star_expr 
;

expr_3_or: augassign testlist 
| equal_testlist_star_expr 
;

equal_testlist_star_expr: EQUAL testlist_star_expr 
| EQUAL testlist_star_expr equal_testlist_star_expr 
;                     

testlist_star_expr: test
;

augassign: PLUS_EQUAL 
| MINUS_EQUAL 
| MULTIPLY_EQUAL 
| ATEQUAL 
| DIVIDE_EQUAL 
| MODULO_EQUAL 
| BITWISE_AND_EQUAL  
| BITWISE_OR_EQUAL 
| BITWISE_XOR_EQUAL 
| LEFT_SHIFT_EQUAL 
| RIGHT_SHIFT_EQUAL 
| POWER_EQUAL 
| FLOOR_DIVIDE_EQUAL 
;
    

flow_stmt: BREAK 
| CONTINUE 
| return_stmt 
;

return_stmt: RETURN 
| RETURN testlist_star_expr 
;

compound_stmt: if_stmt 
| while_stmt 
| for_stmt 
| funcdef 
| classdef 
;

if_stmt: if_head namedexpr_test COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop();curr_symbol_table = symbol_table_stack.top();}
| if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more {}
| if_head namedexpr_test COLON suite else_head COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);}symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
| if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more else_head1 COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack"<<endl; exit(-1);}symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
;

if_head:IF{symbol_table* new_curr=curr_symbol_table->add_new_block();symbol_table_stack.push(new_curr);curr_symbol_table=new_curr;}
;

else_head1:ELSE{symbol_table* new_curr=curr_symbol_table->add_new_block();symbol_table_stack.push(new_curr);curr_symbol_table=new_curr;}
;

else_head:ELSE{if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); symbol_table* new_curr=curr_symbol_table->add_new_block();symbol_table_stack.push(new_curr);curr_symbol_table=new_curr;}
;


elif_head:ELIF{if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top(); symbol_table* new_curr=curr_symbol_table->add_new_block();symbol_table_stack.push(new_curr);curr_symbol_table=new_curr;}
;
elif_head1:ELIF{curr_symbol_table = symbol_table_stack.top(); symbol_table* new_curr=curr_symbol_table->add_new_block();symbol_table_stack.push(new_curr);curr_symbol_table=new_curr;}
;

elif_namedexpr_test_colon_suite_one_or_more: elif_namedexpr_test_colon_suite_one_or_more elif_head1 namedexpr_test COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
| elif_head namedexpr_test COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
;

while_stmt: while_head namedexpr_test COLON suite  {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
| while_head namedexpr_test COLON suite else_head COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
;
while_head: WHILE {symbol_table* new_curr=curr_symbol_table->add_new_block();symbol_table_stack.push(new_curr);curr_symbol_table=new_curr;}
;
for_stmt: for_head exprlist IN testlist COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
| for_head exprlist IN testlist COLON  suite else_head COLON suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop(); curr_symbol_table = symbol_table_stack.top();}
;


for_head: FOR{symbol_table* new_curr=curr_symbol_table->add_new_block();symbol_table_stack.push(new_curr);curr_symbol_table=new_curr;}
;


suite: simple_stmt 
| NEWLINE INDENT stmts DEDENT 
;

namedexpr_test: test {$$ = $1;}
| test COLONEQUAL test {$$=$1; auto type=$1->compare_datatype($3->get_datatype());
if(type.datatype == "ERROR"){cout << "Datatypes of both sides of := are not same on line "<<$1->get_line_no() << endl; exit(-1);} 
$$->set_datatype(type);}    
;

test: or_test {$$=$1;}
;

or_test: and_test {$$ = $1;}
|and_test_star and_test  {$$ = $1; $$->set_datatype({"bool",false});}
;

and_test_star: and_test OR  {$$ = $1; $$->set_datatype({"bool",false});}
| and_test_star and_test OR {$$ = $1; $$->set_datatype({"bool",false});}
;
and_test: not_test {$$ = $1;}
|and_not_test_plus not_test {$$ = $1; $$->set_datatype({"bool",false});}
;

and_not_test_plus: not_test AND  {$$ = $1; $$->set_datatype({"bool",false});}
| and_not_test_plus not_test AND     {$$ = $1; $$->set_datatype({"bool",false});}
;
not_test: not_plus_comparison   {$$ = $1;}
| comparison    {$$ = $1;}
;

not_plus_comparison : NOT comparison  {$$ = $2; $$->set_datatype({"bool",false});}
| NOT not_plus_comparison   {$$ = $2; $$->set_datatype({"bool",false});}
;

comparison: comp_op_expr_plus expr {$$=$1;auto type=$1->compare_datatype($2->get_datatype());if(type.datatype == "ERROR"){cout << "Datatypes of both sides of comparison operator are not same on line "<<$1->get_line_no() << endl; exit(-1);} $$->set_datatype(type);}
| expr {$$ = $1;}
;

comp_op_expr_plus: expr comp_op {$$=$1;}
| comp_op_expr_plus expr comp_op   {$$=$1;auto type=$1->compare_datatype($2->get_datatype());if(type.datatype == "ERROR"){cout << "Datatypes of both sides of comparison operator are not same on line "<<$1->get_line_no() << endl; exit(-1);} $$->set_datatype(type);}
;

comp_op: GREATER_THAN 
| LESS_THAN 
| EQUAL_EQUAL 
| GREATER_THAN_EQUAL 
| LESS_THAN_EQUAL   
| NOTEQUAL  
| IN    
| NOT IN  
| IS    
| IS NOT   
;



expr: r_expr xor_expr    {$$=$1;auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| xor_expr  {$$=$1;}
;

r_expr: r_expr xor_expr BITWISE_OR  {$$=$1; auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise or operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
|  xor_expr BITWISE_OR {$$=$1; auto datatype=$$->get_datatype();if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise or operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}}
;

xor_expr: x_expr and_expr  {$$=$1; auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise xor operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| and_expr  {$$ = $1;}
;

x_expr: x_expr and_expr BITWISE_XOR  {$$=$1; auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise xor operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
|and_expr BITWISE_XOR   {$$ = $1; auto datatype=$$->get_datatype();if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise xor operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}}
;

and_expr: a_expr shift_expr  {{$$=$1;auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise and operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}}
| shift_expr    {$$ = $1;}
;

a_expr: a_expr shift_expr BITWISE_AND    {$$=$1;auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise and operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
|shift_expr BITWISE_AND     {$$=$1; auto datatype=$$->get_datatype();if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Bitwise and operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}}
;

shift_expr: lr_shift arith_expr     {{$$=$1; auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Left shift operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}}
| arith_expr  {$$ = $1;}
;

lr_shift: arith_expr LEFT_SHIFT  {$$ = $1; auto datatype=$$->get_datatype();if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Left shift operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}}
| arith_expr RIGHT_SHIFT     {$$ = $1; auto datatype=$$->get_datatype();if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Left shift operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}}
| lr_shift  arith_expr LEFT_SHIFT {$$=$1; auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Left shift operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| lr_shift  arith_expr RIGHT_SHIFT {$$=$1; auto datatype=$$->compare_datatype($2->get_datatype());if(!(datatype.datatype == "int"&&datatype.datatype=="bool")){cout << "Left shift operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
;

arith_expr:pm_term term     {$$ = $1;auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| term  {$$=$1;}
;

pm_term:term PLUS   {$$ = $1; auto datatype=$$->get_datatype();if(datatype.datatype=="ERROR"){cout << "Addition operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}}
| term  MINUS    {$$ = $1; auto datatype=$$->get_datatype();if(datatype.datatype=="str"||datatype.datatype=="ERROR"){cout << "Addition operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}}
|pm_term term PLUS   {$$ = $1;auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| pm_term term MINUS      {$$ = $1;auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
;

term: factor {$$ = $1;}
| op_fac factor  {$$ = $1;auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
;

op_fac:factor MULTIPLY  {$$ = $1; }
| factor DIVIDE  {$$ = $1;/*$$ = $2; $$->add_children($1);*/}
| factor MODULO  {$$ = $1;/*$$ = $2; $$->add_children($1);*/}
| factor FLOOR_DIVIDE    {$$ = $1;/*$$ = $2; $$->add_children($1);*/}
| op_fac factor  MULTIPLY    {$$ = $1;auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| op_fac factor DIVIDE   {$$ = $1; auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| op_fac  factor MODULO   {$$ = $1; auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| op_fac factor FLOOR_DIVIDE     {$$ = $1; auto datatype=$$->compare_datatype($2->get_datatype());if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of operator are not same on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
;

factor: PLUS factor {$$ =$1;auto datatype=$2->get_datatype();if(datatype.datatype=="ERROR"){cout << "Unary plus operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| MINUS factor  {$$ =$1;auto datatype=$2->get_datatype();if(datatype.datatype=="ERROR"||datatype.datatype=="str"){cout << "Unary minus operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| BITWISE_NOT factor   {$$ =$1;auto datatype=$2->get_datatype();if(!(datatype.datatype=="bool"&&datatype.datatype=="int")){cout << "Bitwise not operator cannot be applied on line "<<$1->get_line_no() << endl; exit(-1);}$$->set_datatype(datatype);}
| power {$$ = $1;}
;

power: atom_expr    {$$=$1;}
| atom_expr POWER factor    {$$=$1; auto datatype= $$->compare_datatype($3->get_datatype()); if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of power operator are not same on line "<<$1->get_line_no() << endl; exit(-1);} $$->set_datatype(datatype);}
| atom {$$=$1;}
| atom POWER factor {$$=$1; auto datatype= $$->compare_datatype($3->get_datatype()); if(datatype.datatype == "ERROR"||datatype.datatype=="str"){cout << "Datatypes of both sides of power operator are not same on line "<<$1->get_line_no() << endl; exit(-1);} $$->set_datatype(datatype);}
;

atom_expr: atom DOT NAME {
        Type type = $1->get_datatype();
        if(!type.is_class){
            cout << "Type " << type.datatype << " is not a class" << endl;
            exit(-1);
        }
        st_entry* entry = type.class_table->lookup_class_member($3->get_lexeme());
        if(entry == nullptr){
            symbol_table_function* function_table = type.class_table->lookup_function($3->get_lexeme());
            if(function_table == nullptr){
                cout << "Class " << type.datatype << " has no member named " << $1->get_lexeme() << endl;
                exit(-1);
            }
            Type new_type;
            new_type.datatype = $3->get_lexeme();
            new_type.is_function = true;
            new_type.function_table = function_table;
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), new_type);
        }
        else{
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), entry->get_datatype());
        }
    }

| atom_expr DOT NAME {
        Type type = $1->get_datatype();
        if(!type.is_class){
            cout << "Type " << type.datatype << " is not a class" << endl;
            exit(-1);
        }
        st_entry* entry = type.class_table->lookup_class_member($3->get_lexeme());
        if(entry == nullptr){
            symbol_table_function* function_table = type.class_table->lookup_function($3->get_lexeme());
            if(function_table == nullptr){
                cout << "Class " << type.datatype << " has no member named " << $1->get_lexeme() << endl;
                exit(-1);
            }
            Type new_type;
            new_type.datatype = $3->get_lexeme();
            new_type.is_function = true;
            new_type.function_table = function_table;
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), new_type);
        }
        else{
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), entry->get_datatype());
        }
    }

| atom OPEN_BRACKET test CLOSE_PAREN {
        Type type = $1->get_datatype();
        if(!type.is_list){
            cout << "Type " << type.datatype << " is not a list" << endl;
            exit(-1);
        }
        type.is_list = false;
        $$ = new NonTerminal($3->get_line_no(), type);
}

| atom_expr OPEN_BRACKET test CLOSE_PAREN  {
        Type type = $1->get_datatype();
        if(!type.is_list){
            cout << "Type " << type.datatype << " is not a list" << endl;
            exit(-1);
        }
        type.is_list = false;
        $$ = new NonTerminal($3->get_line_no(), type);
    }
    

| atom OPEN_PAREN arglist CLOSE_PAREN {
        Type type = $1->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << $1->get_lexeme() << " is not a function" << endl;
            exit(-1);
        }
        if(type.function_table == nullptr){ // __init__ function
            Type new_type;
            new_type.datatype = $1->get_datatype();
            new_type.is_function = true;
            new_type.function_table = function_table;
        }
        $$ = new NonTerminal($3->get_line_no(), type.function_table->get_return_type());        
    }
| atom OPEN_PAREN CLOSE_PAREN {
        Type type = $1->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << $1->get_lexeme() << " is not a function" << endl;
            exit(-1);
        }
        $$ = new NonTerminal($3->get_line_no(), type.function_table->get_return_type());        
    }
| atom_expr OPEN_PAREN CLOSE_PAREN {
    {
        Type type = $1->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << $1->get_lexeme() << " is not a function" << endl;
            exit(-1);
        }
        $$ = new NonTerminal($3->get_line_no(), type.function_table->get_return_type());        
    }
}
| atom_expr OPEN_PAREN arglist CLOSE_PAREN  {
        Type type = $1->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << $1->get_lexeme() << " is not a function" << endl;
            exit(-1);
        }
        $$ = new NonTerminal($3->get_line_no(), type.function_table->get_return_type());        
    }
;

atom: OPEN_PAREN testlist_comp CLOSE_PAREN  {$$=$2;}
| OPEN_PAREN CLOSE_PAREN    {$$=new NonTerminal($2->get_line_no(),{"",false,false,false,nullptr,nullptr});}
| OPEN_BRACKET testlist_comp CLOSE_BRACKET  {$$=$2;$$->set_list(true);}
| OPEN_BRACKET CLOSE_BRACKET    {$$=new NonTerminal($2->get_line_no(), {"",true,false,false,nullptr,nullptr});}
| NAME{
        st_entry* entry = curr_symbol_table->lookup_all($1->get_lexeme());
        if(entry == nullptr){
            symbol_table_function* function_table = global_symbol_table->lookup_function($1->get_lexeme());
            if(function_table == nullptr){
                symbol_table_class* class_table = global_symbol_table->lookup_class($1->get_lexeme());
                if(class_table == nullptr)
                {    
                    cout << "Variable " << $1->get_lexeme() << "used before declaration at line no: " << $1->get_line_no() << endl;
                    exit(-1);
                }
                Type new_type;
                new_type.datatype = $1->get_lexeme();
                new_type.is_function = true;
                new_type.function_table = class_table->lookup_function("__init__");
                if(new_type.function_table == nullptr){
                    curr_function = nullptr;
                }
                else{
                    curr_function = new_type.function_table;
                }
                function_arg_counter = 1;
                $$ = new NonTerminal($1->get_line_no(), $1->get_lexeme(), new_type);
                
            }
            Type new_type;
            new_type.datatype = $1->get_lexeme();
            new_type.is_function = true;
            new_type.function_table = function_table;
            curr_function = function_table;
            function_arg_counter = 0;
            $$ = new NonTerminal($1->get_line_no(), $1->get_lexeme(), new_type);
        }
        else{
            $$->set_datatype(entry->get_datatype());
        }
    }
| NUMBER {$$=$1;$$->set_datatype({"int",false});}
| string_one_or_more    {$$=$1;}
| NONE  {$$=$1;$$->set_datatype({"None",false});}
| TRUE_     {$$=$1;$$->set_datatype({"bool",false});}
| FALSE_    {$$=$1;$$->set_datatype({"bool",false});}
| REAL_NUMBER   {$$=$1;$$->set_datatype({"float",false});}
;


string_one_or_more: string_one_or_more STRING   {$$=$1;$$->set_lexeme($1->get_lexeme() + $2->get_lexeme());}
| STRING    {$$=$1;$$->set_datatype({"str",false});}
;

testlist_comp: named_star_or comma_named_star_comma {if($2->get_datatype().datatype == "COMMA") {$$ =$1;} else{ $$ = $1;$$->set_datatype($$->compare_datatype($2->get_datatype()));}}
| named_star_or {$$ =$1;}
;


comma_named_star_comma: comma_named_star COMMA  {$$=$1;}
| comma_named_star  {$$ = $1;}
| COMMA {$$ = $1;$$->set_datatype({"COMMA",false});}
;
named_star_or: namedexpr_test   {$$ =$1;}
// | star_expr {$$ =$1;}
;

comma_named_star: COMMA named_star_or   {$$ = $2;}
| comma_named_star COMMA named_star_or  {$$=$1;  $$->set_datatype($$->compare_datatype($3->get_datatype()));}
;

exprlist: expr {$$=$1;}
;


testlist: test {$$=$1;} 
;




classdef: classdef_head suite {if(symbol_table_stack.size() == 0){cout << "trying to pop empty stack" << endl; exit(-1);} symbol_table_stack.pop();curr_symbol_table=symbol_table_stack.top();}
;

classdef_head: CLASS NAME COLON {auto new_class = curr_symbol_table->create_new_class($2->get_lexeme(), nullptr); symbol_table_stack.push(new_class); curr_symbol_table = new_class;}
| CLASS NAME OPEN_PAREN CLOSE_BRACE COLON {auto new_class = curr_symbol_table->create_new_class($2->get_lexeme(), nullptr); symbol_table_stack.push(new_class); curr_symbol_table = new_class;}
| CLASS NAME OPEN_PAREN NAME CLOSE_BRACE COLON {auto parent_class = curr_symbol_table->lookup_class($4->get_lexeme()); /*if(parent_class == nullptr){cout << "Base class not defined\n";}*/  auto new_class = curr_symbol_table->create_new_class($2->get_lexeme(), parent_class); symbol_table_stack.push(new_class); curr_symbol_table = new_class;}
;

arglist: argument comma_arg 
| argument comma_arg COMMA  
| argument  
| argument COMMA    
;

comma_arg: COMMA argument   
| comma_arg COMMA argument  
;

argument: test  {auto datatype=curr_symbol_table->get_parameter_type(function_arg_counter++);
if(datatype==nullptr){cout<<"Extra arguments passed to function at line no"<<$1->get_line_no();exit(1);}
if(!is_compatible_datatype(datatype,$1->get_datatype()))
 {cout<<"Function type mismatch at line no"<<$1->get_line_no();
 exit(1)}}
;


func_body_suite: simple_stmt 
| NEWLINE INDENT stmts DEDENT 
;

datatype: NAME {$$ = new Type; $$->datatype = $1->get_lexeme(); 
$$->is_list = false;
if(!($1->get_lexeme() == "int" || $1->get_lexeme() == "float" || $1->get_lexeme() == "bool" || $1->get_lexeme() == "str"))
{ $$->is_class=true;
$$->class_table=global_symbol_table->lookup_class($1->get_lexeme());
if($$->class_table == nullptr)
{
    printf("Class %s not defined\n",$1->get_lexeme().c_str());
    exit(1);
}}
}
| NAME OPEN_BRACKET NAME CLOSE_BRACKET {$$ = new Type; $$->datatype = $3->get_lexeme(); $$->is_list=true;
if(!($1->get_lexeme() == "int" || $1->get_lexeme() == "float" || $1->get_lexeme() == "bool" || $1->get_lexeme() == "str"))
{ $$->is_class=true;
$$->class_table=global_symbol_table->lookup_class($1->get_lexeme());
if($$->class_table == nullptr)
{
    printf("Class %s not defined\n",$1->get_lexeme().c_str());
    exit(1);
}}
}
;//check if datatype is class or not

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
    cout << "Usage: ./parser <flags>" << endl;
    cout << "--input <input-file>: Specify the input program file" << endl;
    cout << "--output <output-file>: Specify the output dot file" << endl;
    cout << "--verbose: Generate additional details about parsing in \"verbose.log\" file" << endl;
    cout << "--help: Print this help" << endl;
}

int main(int argc, char* argv[]) {    
    yydebug = 0;
    string input_file_path;
    // string output_file_path = "tree.dot";
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
                cerr << "Error: No input file provided" << endl;
                return 1;
            }
        }
        else{
            cerr << "Error: unknown flag " << argv[i] << "" << endl;
            print_help();
            return 1;
        }
    }
    if(input_file_path.size() > 0){
        FILE *input_file = fopen(input_file_path.c_str(), "r");
        if (!input_file) {
            cerr << "Error: Unable to open " << input_file_path << "" << endl;
            return 1;
        }
        yyin = input_file;
    }
    
    curr_symbol_table = global_symbol_table = new symbol_table_global();
    symbol_table_stack.push(curr_symbol_table);
    yyparse();
    global_symbol_table->print();
    // root->make_tree(output_file_path);

    if(verbose)
    {   
       print_verbose();
       yydebug = 1;
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
