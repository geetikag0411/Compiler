%{
    #include <bits/stdc++.h>
    #include <unistd.h>
    #include <sstream>
    #include "NonTerminal.cpp"
    #include "symbol_table.hpp"
    #include "3AC.cpp"
    using namespace std;

    //python 3.7
    #define YYDEBUG 1
    extern int yylineno;
    extern char* yytext;
    extern int yylex(void);
    extern FILE* yyin;
    extern FILE* yyout;
    void yyerror(const char*);
    int debug=0;
    bool string_one_or_more = false;
    bool verbose = false;
    std::ostringstream output;
    stack<symbol_table*> symbol_table_stack;
    symbol_table* curr_symbol_table{nullptr};
    symbol_table_global* global_symbol_table{nullptr};
    stack<symbol_table_function*> curr_function;
    stack<string> curr_if_end_jump_label;
    stack<string> curr_loop_start_jump_label;
    stack<string> curr_loop_end_jump_label;
    stack<Type> curr_return_type;
    stack<int> function_arg_counter;
    stack<bool> is_print_function;
    vector<vector<ThreeAC*>> threeAC;
    stack<string> op_3AC;
    void add_len_function(symbol_table_global* global_symbol_table){
        symbol_table_function* len_func = global_symbol_table->create_new_function("len");
        Type type;
        type.datatype = "any";
        type.is_list = true;
        len_func->add_parameter("a", type, 0);
        len_func->set_return_type({"int"});
                                                           
        auto len = new NonTerminal(0, "len");
        len->gen("len:");
        len->gen("begin function");
        len->gen("pushq", "$rbp");
        len->gen("$rbp","$rsp");
        len->gen("$rsp","$rsp","-",to_string(12+56));      
        len->gen("mov48","regs","-56($rbp)"); 
        len->gen("movq","16($rbp)","a");
        len->gen("a","a","-","4");
        len->gen("b","*a");
        len->gen("movq","b","$rax");
        len->gen("mov48","-56(rbp)","regs");
        len->gen("mov8","$rbp","$rsp");
        len->gen("popq", "$rbp");
        len->gen("ret");
        len->gen("end function");
        
        threeAC.push_back(len->get_code());
    }

    bool is_compatible_datatype(Type type_l, Type type_r)
    {
        if((type_l.is_class || type_l.is_list || type_l.datatype == "str") && type_r.datatype == "None") return true;
        if((type_l.datatype=="any"||type_r.datatype=="any")&&type_r.is_list&&type_l.is_list) return true;
        if(type_l.is_list != type_r.is_list) return false;
        if(type_l.datatype == type_r.datatype) return true;
        if((type_l.datatype == "int" || type_l.datatype == "float" || type_l.datatype == "bool") && (type_r.datatype == "int" || type_r.datatype == "float" || type_r.datatype == "bool")){ 
        if((type_l.datatype=="bool"&&type_r.datatype=="float")||(type_l.datatype=="float"&&type_r.datatype=="bool")) return false;
      return true;
        }
        if(type_r.is_class && type_l.is_class){
            symbol_table_class* temp_class_table = type_r.class_table;
            while(temp_class_table != nullptr){
                if(temp_class_table->get_name() == type_l.class_table->get_name()) return true;
                temp_class_table = temp_class_table->get_parent_class();
            }
        }
        return false;  
    }

    int calculate_size(Type type,bool need_class_size){
        if(type.is_list) return 8;
        if(type.is_class){
            if(need_class_size) return type.class_table->get_offset();
            else return 8;
        }
        else if(type.datatype == "int" || type.datatype == "float") return 4;
        else if(type.datatype == "bool") return 1;
        else if(type.datatype == "str") return 8;
        return -1;
    }

    void push_argument(NonTerminal* arg){
        if(is_print_function.top())
        {
            int top = function_arg_counter.top();
            function_arg_counter.pop();
            function_arg_counter.push(top+1);
            if(top == 0)
            {
                if((arg->get_datatype().is_list)||(arg->get_datatype().datatype != "int" && arg->get_datatype().datatype != "float" && arg->get_datatype().datatype != "bool" && arg->get_datatype().datatype != "str"))
                {
                    cout << "Print function only allowed for primitive data types at line no "<<arg->get_line_no()<<endl;
                    exit(-1);
                }
            }
            else
            {
                cout << "Print function should have only one argument at line no "<<arg->get_line_no()<<endl;
                exit(-1);
            }
        }
        else{
            int top = function_arg_counter.top();
            function_arg_counter.pop();
            function_arg_counter.push(top+1);
            cout<<top<<" "<<curr_function.top()->is_first_argument_self()<<endl;
            auto datatype=curr_function.top()->get_parameter_type_from_end(top - curr_function.top()->is_first_argument_self());
            if(!is_compatible_datatype(datatype,arg->get_datatype())){
                int arg_index = function_arg_counter.top() + 1 - curr_function.top()->is_first_argument_self();
                cout<<"Datatypes of " << arg_index << (arg_index == 1 ? "st" : arg_index == 2 ? "nd" : "th") << " actual ("<<arg->get_datatype().datatype<<(arg->get_datatype().is_list?"[]":"")<<") and formal argument ("<<datatype.datatype<<(datatype.is_list?"[]":"")<<") of function " <<curr_function.top()->get_name() <<" are incompatible at line no: " << arg->get_line_no() << endl;
                exit(1);
            }
        }
        auto datatype=arg->get_datatype();
        arg->gen("push"+to_string(calculate_size(datatype,false)), arg->get_temporary());
    }
    void relate_string(NonTerminal* result, NonTerminal* str1, NonTerminal* str2, string operation)
    {
        result->gen("pushq", str2->get_temporary());
        result->gen("pushq", str1->get_temporary());
        result->gen("call", "strcmp", "2");
        auto temp = NonTerminal::get_new_temporary();
        result->gen("$rsp", "$rsp", "+", "16");
        result->gen(temp, "$rax");
        if(operation=="==")
        {
            result->gen(result->set_temporary(), temp, "==", "0");
        }
        else if(operation=="!=")
        {
            result->gen(result->set_temporary(), temp, "!=", "0");
        }
        else if (operation =="<")
        {
            result->gen(result->set_temporary(), temp, "<", "0");
        }
        else if (operation ==">")
        {
            result->gen(result->set_temporary(), temp, ">", "0");
        }
        else if (operation =="<=")
        {
            result->gen(result->set_temporary(), temp, "<=", "0");
        }
        else if (operation ==">=")
        {
            result->gen(result->set_temporary(), temp, ">=", "0");
        }
    }
%}

%union{
    class NonTerminal* node;
    struct Type* type;
    class NonTerminal* nonTerminal;
}

%token<nonTerminal> FOR SEMICOLON KEYWORDS ASYNC AWAIT COMMENT DEDENT END FSTRING INDENT MIDDLE NAME NEWLINE NUMBER MULTIPLY MODULO_EQUAL ERROR;
%token<nonTerminal> START STRING TYPE END_MARKER AND OR NOT COMMA EQUAL_EQUAL COLONEQUAL LEFT_SHIFT RIGHT_SHIFT PLUS MINUS POWER DIVIDE 
%token<nonTerminal> FLOOR_DIVIDE AT MODULO AND_KEYWORD OR_KEYWORD NOT_KEYWORD BITWISE_AND BITWISE_OR BITWISE_XOR BITWISE_NOT IN IMPORT RANGE
%token<nonTerminal> YIELD FROM ELSE IF IS NOTEQUAL LESS_THAN GREATER_THAN EQUAL LESS_THAN_EQUAL COLON GREATER_THAN_EQUAL LEFT_SHIFT_EQUAL RIGHT_SHIFT_EQUAL ATEQUAL FALSE_ TRUE_ NONE NONLOCAL
%token<nonTerminal> CLOSE_BRACE BITWISE_OR_EQUAL BITWISE_AND_EQUAL OPEN_PAREN CLOSE_PAREN POWER_EQUAL MULTIPLY_EQUAL PLUS_EQUAL MINUS_EQUAL ARROW DOT ELLIPSIS FLOOR_DIVIDE_EQUAL DIVIDE_EQUAL 
%token<nonTerminal> OPEN_BRACKET CLOSE_BRACKET BITWISE_XOR_EQUAL AS ASSERT BREAK CLASS CONTINUE DEF DEL ELIF EXCEPT FINALLY GLOBAL LAMBDA PASS RAISE RETURN TRY WHILE WITH OPEN_BRACE REAL_NUMBER
%type<nonTerminal> file_input newline_or_stmt_one_or_more funcdef parameters typedargslist stmts stmt simple_stmt small_stmt expr_stmt small_stmt_semicolon_sep expr_3_or equal_testlist_star_expr testlist_star_expr augassign flow_stmt return_stmt compound_stmt if_stmt elif_namedexpr_test_colon_suite_one_or_more while_stmt for_stmt suite namedexpr_test test or_test and_test_star and_test and_not_test_plus not_test not_plus_comparison comparison comp_op_expr_plus comp_op expr r_expr xor_expr x_expr and_expr a_expr shift_expr lr_shift arith_expr pm_term term op_fac factor power atom_expr atom string_one_or_more testlist_comp comma_named_star_comma named_star_or comma_named_star  exprlist  testlist classdef arglist comma_arg argument func_body_suite func_return_type global_stmt funcdef_head
%type<type> datatype
%precedence NAME CLOSE_BRACKET
%precedence OPEN_BRACKET OPEN_PAREN DOT
%start file_input
%right COMMA

%%
file_input: END_MARKER 
| newline_or_stmt_one_or_more END_MARKER {$$ = $1;}
;

newline_or_stmt_one_or_more: newline_or_stmt_one_or_more NEWLINE {$$ = $1;}
| newline_or_stmt_one_or_more stmt { $$ = $1; $$->copy_code($2);}
| NEWLINE { $$ = new NonTerminal(yylineno, "Newline");}
| stmt {$$ = $1;}
;

funcdef: funcdef_head parameters COLON func_body_suite  {
                                                            Type new_type;
                                                            new_type.datatype = "None";
                                                            curr_symbol_table->set_return_type(new_type);
                                                            curr_symbol_table->set_line_no($1->get_line_no());
                                                            if(symbol_table_stack.size() == 0){
                                                                cout << "Trying to pop empty stack" << endl;
                                                                exit(-1);
                                                            }

                                                            $$ = $1;     
                                                            $$->gen("pushq", "$rbp");
                                                            $$->gen("$rbp","$rsp");
                                                            $$->copy_code($2);
                                                            //wrong need to subtract the of
                                                            $$->gen("$rsp","$rsp","-",to_string(curr_symbol_table->get_offset()+56));      
                                                            $$->gen("mov48","regs","-56(rbp)");                                      
                                                            $$->copy_code($4);
                                                            if($4->get_has_return_stmt()==false)
                                                            {
                                                                $$->gen("mov48","-56(rbp)","regs");
                                                                $$->gen("mov8","$rbp","$rsp");
                                                                $$->gen("popq", "$rbp");
                                                                $$->gen("ret");
                                                                $$->gen("end function");
                                                            }
                                                            threeAC.push_back($$->get_code());
                                                            symbol_table_stack.pop();
                                                            curr_symbol_table = symbol_table_stack.top();
                                                        }
| funcdef_head parameters func_return_type COLON func_body_suite    { 
                                                                        if(symbol_table_stack.size() == 0)
                                                                        {
                                                                            cout << "Trying to pop empty stack" << endl; 
                                                                            exit(-1);
                                                                        }
                                                                        curr_symbol_table->set_line_no($1->get_line_no());
                                                                        $$ = $1;                                                       
                                                                        $$->gen("pushq", "$rbp");
                                                                        $$->gen("$rbp","$rsp");
                                                                        $$->copy_code($2);
                                                                        $$->gen("$rsp","$rsp","-",to_string(curr_symbol_table->get_offset()+56));
                                                                        $$->gen("mov48","regs","-56(rbp)");
                                                                        $$->copy_code($5);
                                                                        if($5->get_has_return_stmt()==false)
                                                                        {
                                                                            if(curr_symbol_table->get_return_type().datatype == "None"){
                                                                                $$->gen("mov48","-56(rbp)","regs");
                                                                                $$->gen("mov8","$rbp","$rsp");
                                                                                $$->gen("popq", "$rbp");
                                                                                $$->gen("ret");
                                                                                $$->gen("end function");
                                                                            }
                                                                            else
                                                                            {
                                                                                cout << "Control reaches end of non-void function " << $1->get_lexeme() << " declared at line no: " << $1->get_line_no() << endl;
                                                                                exit(-1);
                                                                            
                                                                            }
                                                                        }
                                                                        symbol_table_stack.pop(); 
                                                                        threeAC.push_back($$->get_code());
                                                                        curr_symbol_table = symbol_table_stack.top();
                                                                    }
;

funcdef_head: DEF NAME  {
                            auto func_symbol_table = curr_symbol_table->create_new_function($2->get_lexeme()); 
                            symbol_table_stack.push(func_symbol_table); 
                            $$ = new NonTerminal($2->get_line_no(), $2->get_lexeme());
                            if(curr_symbol_table->get_symbol_table_type() == 2)
                            {
                                $$->gen(curr_symbol_table->get_name()+ "." + $2->get_lexeme() + ":");
                            }
                            else 
                            {
                                $$->gen($2->get_lexeme()+":");
                            }
                            $$->gen("begin function");
                            curr_symbol_table = func_symbol_table; 
                            Type type = {"None", 0}; 
                            curr_symbol_table->set_return_type(type);
                            
                        }
;

parameters: OPEN_PAREN CLOSE_PAREN {$$ = new NonTerminal($1->get_line_no());}
| OPEN_PAREN typedargslist CLOSE_PAREN {$$ = $2;}
;

func_return_type: ARROW datatype {curr_symbol_table->set_return_type(*$2);}
| ARROW NONE    {
                    Type type = {"None", 0}; 
                    curr_symbol_table->set_return_type(type);
                }
;

typedargslist: NAME COLON datatype  {
                                        $$ = new NonTerminal($1->get_line_no());
                                        auto offset= curr_symbol_table->get_offset();
                                        $$->gen("mov"+to_string(calculate_size(*$3,false)),to_string(offset + 16)+"(rbp)",$1->get_lexeme());
                                        curr_symbol_table->add_parameter($1->get_lexeme(),*$3,$1->get_line_no());
                                        
                                    }
| typedargslist COMMA NAME COLON datatype   {
                                                
                                                auto offset= curr_symbol_table->get_offset();
                                                $$ = $1;
                                                $$->gen("mov"+to_string(calculate_size(*$5,false)),to_string(offset+16)+"(rbp)",$3->get_lexeme());
                                                curr_symbol_table->add_parameter($3->get_lexeme(),*$5,$1->get_line_no());
                                            }
| typedargslist COMMA NAME {    // erroneous production for catching error
    cout << "Datatype for function parameter " << $3->get_lexeme() <<  " not specified on line no: "<< $3->get_line_no() << "\n"; 
    exit(-1);
}
| NAME {
            $$ = $1;
            if($1->get_lexeme() != "self")
            {
                cout << "Datatype for function parameter " << $1->get_lexeme() <<  " not specified on line no: "<< $1->get_line_no() << "\n"; 
                exit(-1);
            }
            Type new_type;
            symbol_table_class* parent_class_st = curr_symbol_table->get_parent_class_st();
            new_type.datatype = parent_class_st->get_name();
            new_type.is_class = true;
            new_type.class_table = parent_class_st;
            auto offset= curr_symbol_table->get_offset();
            curr_symbol_table->add_parameter($1->get_lexeme(),new_type,$1->get_line_no());
            $$->gen("mov8",to_string(offset+16)+"(rbp)",$1->get_lexeme());
        }
;

stmt: simple_stmt {
                $$ = $1;
                if(curr_symbol_table == global_symbol_table && curr_if_end_jump_label.empty() && curr_loop_end_jump_label.empty()) 
                threeAC.push_back($1->get_code());
            }
| compound_stmt {$$ = $1;}
;

stmts: stmts stmt {$$ = $1; $$->copy_code($2); $$->set_has_return_stmt($$->get_has_return_stmt() || $2->get_has_return_stmt());}
| stmt {$$ = $1;}
;

simple_stmt: small_stmt_semicolon_sep NEWLINE {$$ = $1;}
;

small_stmt: expr_stmt {$$ = $1;}
| flow_stmt {$$ = $1;}
| global_stmt {$$ = $1;}
;

global_stmt: GLOBAL NAME    {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword used in global scope at line no: " << $1->get_line_no() << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup($2->get_lexeme()) ;
    auto curr_entry = curr_symbol_table->lookup($2->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable "<<$2->get_lexeme()<<" already defined in current scope cannot be global at line no:" << $2->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable "<<$2->get_lexeme()<<" not defined in global scope at line no: "<<$2->get_line_no()<<endl;
    } 
}
| GLOBAL NAME comma_name_one_or_more {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword used in global scope at line no: " << $1->get_line_no() << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup($2->get_lexeme());
    auto curr_entry = curr_symbol_table->lookup($2->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable "<<$2->get_lexeme()<<" already defined in current scope cannot be global in line no:" << $2->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable "<<$2->get_lexeme()<<" not defined in global scope at line no: "<<$2->get_line_no()<<endl;
    } 
}
;

comma_name_one_or_more: COMMA NAME  {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword used in global scope at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup($2->get_lexeme());
    auto curr_entry = curr_symbol_table->lookup($2->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable "<<$2->get_lexeme()<<" already defined in current scope cannot be global in line no:" << $2->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable "<<$2->get_lexeme()<<" not defined in global scope at line no: "<<$2->get_line_no()<<endl;
    } 

}
| COMMA NAME comma_name_one_or_more {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword used in global scope at line no: " << $1->get_line_no() << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup($2->get_lexeme()); 
    auto curr_entry = curr_symbol_table->lookup($2->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable "<<$2->get_lexeme()<<" already defined in current scope cannot be global in line no:" << $2->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable "<<$2->get_lexeme()<<" not defined in global scope at line no: "<<$2->get_line_no()<<endl;
    } 
}
; 

small_stmt_semicolon_sep: small_stmt SEMICOLON small_stmt_semicolon_sep {$$=new NonTerminal($1->get_line_no(), "SmallStmt");$$->copy_code($1);$$->copy_code($3);}
| small_stmt {$$=$1;}
| small_stmt SEMICOLON {$$=$1;}
;

expr_stmt: testlist_star_expr expr_3_or {
                                            if(!$1->get_is_lvalue()){
                                                cout << "Left hand side of assignment is not a lvalue at line no: " << $2->get_line_no() << endl;
                                                exit(-1);
                                            }
                                            if($2->get_operator_type_augassign()==0)
                                            {
                                                if(!is_compatible_datatype($1->get_datatype(), $2->get_datatype()))
                                                {
                                                    cout << "Type mismatch in assignment at line no: " << $2->get_line_no() << endl;
                                                    cout << $2->get_datatype().datatype << ($2->get_datatype().is_list? "[]" : "") << " is not assignable to " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << endl;
                                                    exit(0);
                                                }

                                            }
                                            else if($2->compare_datatype_expr3or($1->get_datatype())==0)
                                            {
                                                cout << "Incompatible operator " << $2->get_operator() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
                                                exit(0);
                                            }

                                            $$=$2;
                                            $$->copy_code($1);
                                            if($$->get_operator_type_augassign() == 0){ // assignment case
                                                // if($1->get_is_ptr()){
                                                //         cout<<"ki"<<endl;
                                                //         if($1->get_temporary()[0] == '*'){
                                                //             string new_temp = NonTerminal::get_new_temporary();
                                                //             $$->gen(new_temp, $1->get_temporary());
                                                //             $$->gen("*"+new_temp,$2->get_temporary());
                                                //         }
                                                //         else $$->gen("*"+$1->get_temporary(),$2->get_temporary());
                                                // }
                                                // else{
                                                //     $$->gen($1->get_temporary(),$2->get_temporary());
                                                // }
                                                if($1->get_datatype().is_list)
                                                {
                                                    $2->print_curr_list_temporaries();
                                                    $$->set_temporary($1->get_temporary());
                                                    auto type = $1->get_datatype();
                                                    type.is_list = false;
                                                    $$->gen_list_code(calculate_size(type,true),$1->get_temporary());
                                                    // cout<<"lkl"<<endl;
                                                    
                                                }
                                                else
                                                $$->gen($1->get_temporary(),$2->get_temporary());
                                            }
                                            else{   // augmented assignment case
                                                if($1->get_datatype().is_list){
                                                    cout << "Augmented assignment with operator " << $2->get_operator() << " is not possible for lists at line no: " << $2->get_line_no() << endl;
                                                    exit(-1);
                                                }
                                                string op = op_3AC.top();
                                                op.pop_back();
                                                // if($1->get_is_ptr()){
                                                //     auto temp = NonTerminal::get_new_temporary();
                                                //     if($1->get_temporary()[0] == '*'){
                                                //         string new_temp = NonTerminal::get_new_temporary();
                                                //         $$->gen(new_temp, $1->get_temporary());
                                                //         $$->gen(temp, "*"+new_temp, op, $2->get_temporary());
                                                //         $$->gen("*"+new_temp, temp);
                                                //     }
                                                //     else{
                                                //         $$->gen(temp, "*"+$1->get_temporary(), op, $2->get_temporary());
                                                //         $$->gen("*"+$1->get_temporary(),temp);
                                                //     }
                                                // }
                                                // else{
                                                //     auto temp = NonTerminal::get_new_temporary();                                                    
                                                //     $$->gen(temp, $1->get_temporary(), op, $2->get_temporary());
                                                //     $$->gen($1->get_temporary(),temp);
                                                // }
                                                auto temp = NonTerminal::get_new_temporary();                                                    
                                                $$->gen(temp, $1->get_temporary(), op, $2->get_temporary());
                                                $$->gen($1->get_temporary(),temp);
                                                op_3AC.pop();
                                            }

                                        }
| NAME COLON datatype   {
                            if($1->get_lexeme() == "self"){
                                cout << "Name of variable cannot be self at line no: " << $1->get_line_no() << endl;
                                exit(-1);
                            }
                            if(curr_symbol_table->lookup($1->get_lexeme()) != nullptr)
                            {
                                cout << "Redeclaration of variable " << $1->get_lexeme()<< " in same scope at line no: " << $1->get_line_no() << endl; 
                                exit(-1);
                            }
                            if(curr_symbol_table->lookup_global_entry($1->get_lexeme()) != nullptr)
                            {
                                cout << "Redeclaration of variable "<<$1->get_lexeme()<<" earlier stated to be Global at line no: " << $1->get_line_no() << endl;
                                exit(-1);
                            }
                            // st_entry* global_entry  = (global_symbol_table->lookup($1->get_lexeme))
                            curr_symbol_table->insert($1->get_lexeme(), *$3, $1->get_line_no(), false);
                        }
| NAME COLON datatype EQUAL testlist_star_expr  {
                                                    if($1->get_lexeme() == "self"){
                                                        cout << "Name of variable cannot be self at line no: " << $1->get_line_no() << endl;
                                                        exit(-1);
                                                    }
                                                    $$ = $1;
                                                    // if(debug)printf("here2\n");
                                                    $$->copy_cur_temp($5);
                                                    if(curr_symbol_table->lookup($1->get_lexeme()) != nullptr){
                                                        cout << "Redeclaration of variable " << $1->get_lexeme()<< " in same scope at line no: " << $5->get_line_no() << endl;
                                                        exit(-1);
                                                    }
                                                    if(curr_symbol_table->lookup_global_entry($1->get_lexeme()) != nullptr)
                                                    {
                                                        cout << "Redeclaration of variable " << $1->get_lexeme()<< " earlier stated to be Global at line no: " << $1->get_line_no() << endl;
                                                        exit(-1);
                                                    }
                                                    
                                                    if(!is_compatible_datatype(*$3, $5->get_datatype())){
                                                        cout << "Type mismatch in assignment at line no: " << $5->get_line_no() << endl;
                                                        cout << $5->get_datatype().datatype << ($5->get_datatype().is_list? "[]" : "") << " is not assignable to " << $3->datatype << ($3->is_list?"[]":"") << endl;
                                                        exit(-1);
                                                    }
                                                    
                                                    $$->copy_code($5);
                                                    if($3->is_list){
                                                        $$->set_temporary($1->get_lexeme());
                                                        auto type = *$3;
                                                        type.is_list = false;
                                                        $$->gen_list_code(calculate_size(type,true),$1->get_temporary());
                                                    }
                                                    else{
                                                        $$->gen($1->get_lexeme(), $5->get_temporary());
                                                    }
                                                    curr_symbol_table->insert($1->get_lexeme(), *$3, $1->get_line_no(), true);
                                                }
| testlist_star_expr { $$ =$1;}
| atom DOT NAME COLON datatype EQUAL testlist_star_expr {
                                                            if($1->get_lexeme() != "self"){
                                                                cout << "Attribute declaration of non self variable at line no: " << $1->get_line_no();
                                                                exit(-1);
                                                            }
                                                            if($1->get_datatype().is_class == false)
                                                            {
                                                                cout << "Attribute declaration of non class variable at line no: " << $1->get_line_no();
                                                                exit(-1);
                                                            }
                                                            symbol_table_class* class_table = curr_symbol_table->get_parent_class_st();
                                                            if(class_table->lookup($3->get_lexeme()) != nullptr){
                                                                cout << "Redeclaration of variable " << $3->get_lexeme()<< " in same scope at line no: " << $7->get_line_no() << endl;
                                                                exit(-1);
                                                            }
                                                            int offset = class_table->get_offset();
                                                            class_table->insert($3->get_lexeme(), *$5, $7->get_line_no(), true);
                                                            if(!is_compatible_datatype(*$5, $7->get_datatype())){
                                                                
                                                                cout << "Type mismatch in assignment at line no: " << $7->get_line_no() << endl;
                                                                cout << $7->get_datatype().datatype << ($7->get_datatype().is_list? "[]" : "") << " is not assignable to " << $5->datatype << ($5->is_list?"[]":"") << endl;
                                                                exit(-1);
                                                            }
                                                            $$ = $1;
                                                            auto temp = NonTerminal::get_new_temporary();
                                                            $$->copy_code($7);
                                                            $$->gen(temp, $1->get_temporary(), "+", to_string(offset));
                                                       if(debug)    printf("here3\n");
                                                            $$->copy_cur_temp($7);
                                                            if($5->is_list){
                                                                $$->set_temporary($1->get_lexeme());
                                                                auto type = *$5;
                                                                type.is_list = false;
                                                                $$->gen_list_code(calculate_size(type,true),"*"+temp);
                                                            }
                                                            else{
                                                                $$->gen("*"+temp, $7->get_temporary());
                                                            }
                                                        }
| atom DOT NAME COLON datatype  {
                                    if($1->get_lexeme() != "self"){
                                        cout << "Attribute declaration of non self variable at line no: " << $1->get_line_no();
                                        exit(-1);
                                    }
                                    symbol_table_class* class_table = curr_symbol_table->get_parent_class_st();
                                    class_table->insert($3->get_lexeme(), *$5, $3->get_line_no(), false);
                                }
;

expr_3_or: augassign testlist   { 
                                    $$ = $2;
                                    $$->set_operator($1->get_operator());
                                    int check=$$->compare_datatype($1->get_operator_type_augassign());
                                    if(!check){
                                        cout << "Incompatible operator " << $2->get_operator() << " with operand of type " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")<< " at line no: " << $2->get_line_no() << endl;
                                        exit(-1);
                                    }
                                    $$->set_operator_type_augassign($1->get_operator_type_augassign());
                                } 
| equal_testlist_star_expr { $$ = $1; }
;

equal_testlist_star_expr: EQUAL testlist_star_expr  { 
                                                        $$=$2;
                                                        $$->set_operator_type_augassign(0);
                                                        op_3AC.push("=");
                                                        
                                                    }
;                     

testlist_star_expr: test {$$=$1;}
;

augassign: PLUS_EQUAL {$$=$1;$$->set_operator_type_augassign(3);op_3AC.push("+=");$$->set_operator($1->get_lexeme());}
| MINUS_EQUAL {$$=$1;$$->set_operator_type_augassign(1);op_3AC.push("-=");$$->set_operator($1->get_lexeme());} //not str 1
| MULTIPLY_EQUAL {$$=$1;$$->set_operator_type_augassign(1);op_3AC.push("*=");$$->set_operator($1->get_lexeme());} //not str 1
| DIVIDE_EQUAL {$$=$1;$$->set_operator_type_augassign(1);op_3AC.push("/=");$$->set_operator($1->get_lexeme());} //not str 1
| MODULO_EQUAL {$$=$1;$$->set_operator_type_augassign(1);op_3AC.push("%=");$$->set_operator($1->get_lexeme());} //not str 1
| BITWISE_AND_EQUAL{$$=$1;$$->set_operator_type_augassign(2);op_3AC.push("&=");$$->set_operator($1->get_lexeme());}  //bool int  2
| BITWISE_OR_EQUAL {$$=$1;$$->set_operator_type_augassign(2);op_3AC.push("|=");$$->set_operator($1->get_lexeme());} //bool int 2
| BITWISE_XOR_EQUAL {$$=$1;$$->set_operator_type_augassign(2);op_3AC.push("^=");$$->set_operator($1->get_lexeme());} //int bool int 2
| LEFT_SHIFT_EQUAL {$$=$1;$$->set_operator_type_augassign(2);op_3AC.push("<<=");$$->set_operator($1->get_lexeme());} //int bool int 2
| RIGHT_SHIFT_EQUAL {$$=$1;$$->set_operator_type_augassign(2);op_3AC.push(">>=");$$->set_operator($1->get_lexeme());}//int bool int 2
| POWER_EQUAL {$$=$1;$$->set_operator_type_augassign(1);op_3AC.push("*=");$$->set_operator($1->get_lexeme());} //not str 1
| FLOOR_DIVIDE_EQUAL {$$=$1;$$->set_operator_type_augassign(1);op_3AC.push("//=");$$->set_operator($1->get_lexeme());} //not str 1
;
    

flow_stmt: BREAK {
    if(curr_loop_start_jump_label.size()==0)
    {
        cout << "Break statement is not inside any loop at line no: " << $1->get_line_no() << endl; 
        exit(-1);
    } 
    $$ = $1; $$->gen("goto", curr_loop_end_jump_label.top()); }
| CONTINUE {
    $$=$1;
    if(curr_loop_start_jump_label.size()==0)
    {
        cout << "Continue statement is not inside any loop at line no: " << $1->get_line_no() << endl; 
        exit(-1);
    }    
    $$->gen("goto", curr_loop_start_jump_label.top());
    }
| return_stmt {$$=$1;}
;

return_stmt: RETURN {
                        if(curr_symbol_table->get_symbol_table_type() != 1)
                        {
                            cout << "Return statement is only allowed inside functions"<<endl;
                            exit(-1);
                        }
                        Type type = curr_symbol_table->get_return_type();
                        if(curr_symbol_table->get_return_type().datatype != "None")
                        {
                            cout << "Return statement without any return value written line no: " << $1->get_line_no() <<" expected "<<type.datatype<<(type.is_list?"[]":"")<< endl;
                            exit(-1);
                        }
                        $$ = new NonTerminal($1->get_line_no(), "Return");
                        $$->gen("mov48","-56(rbp)","regs");
                        $$->gen("mov8","$rbp","$rsp");
                        $$->gen("popq", "$rbp");
                        $$->gen("ret");
                        $$->set_has_return_stmt(true);
                    }
| RETURN testlist_star_expr {
    if(curr_symbol_table->get_symbol_table_type() != 1){
        cout << "Return statement is only allowed inside functions" << endl;
        exit(-1);
    }
    if(!is_compatible_datatype(curr_symbol_table->get_return_type(), $2->get_datatype())){
        cout << "Type mismatch in return statement on line no: " << $2->get_line_no() << endl;
        cout << "Expected return type is " << curr_symbol_table->get_return_type().datatype << (curr_symbol_table->get_return_type().is_list ? "[]" : "") << ", found " << $2->get_datatype().datatype << ($2->get_datatype().is_list ? "[]" : "") << endl;
        exit(-1);
    }
    $$ = $2;
    $$->gen("movq", $2->get_temporary(),"$rax");
    $$->gen("mov48","-56(rbp)","regs");
    $$->gen("mov8","$rbp","$rsp");
    $$->gen("popq", "$rbp");
    $$->gen("ret");
    $$->set_has_return_stmt(true);
}
;

compound_stmt: if_stmt {$$ = $1; if(curr_symbol_table == global_symbol_table) threeAC.push_back($$->get_code());}
| while_stmt {$$ = $1; if(curr_symbol_table == global_symbol_table) threeAC.push_back($$->get_code());}
| for_stmt {$$ = $1;if(curr_symbol_table == global_symbol_table) threeAC.push_back($$->get_code());}
| funcdef {$$ = $1;}
| classdef {$$ = $1;}
;

if_head: IF {
    curr_if_end_jump_label.push(NonTerminal::get_new_label());
}

if_stmt: if_head namedexpr_test COLON suite {
    $$=new NonTerminal($2->get_line_no(), "If");
    $$->copy_code($2);
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", curr_if_end_jump_label.top());
    $$->copy_code($4);
    $$->gen(curr_if_end_jump_label.top());
    curr_if_end_jump_label.pop();                                                
}
| if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more {
    $$=new NonTerminal($2->get_line_no(), "If");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", label_elif);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top());
    $$->gen(label_elif);
    $$->copy_code($5);
    $$->gen(curr_if_end_jump_label.top());
    curr_if_end_jump_label.pop();
}
| if_head namedexpr_test COLON suite ELSE COLON suite  {
    $$=new NonTerminal($2->get_line_no(), "If");
    $$->copy_code($2);
    string label_else = NonTerminal::get_new_label();
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", label_else);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top());
    $$->gen(label_else);
    $$->copy_code($7);
    $$->gen(curr_if_end_jump_label.top());
    if($4->get_has_return_stmt() && $7->get_has_return_stmt()) $$->set_has_return_stmt(true);
    curr_if_end_jump_label.pop();
}
| if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more ELSE COLON suite {
    $$=new NonTerminal($2->get_line_no(), "If");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", label_elif);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top());
    $$->gen(label_elif);
    $$->copy_code($5);
    $$->copy_code($8);
    $$->gen(curr_if_end_jump_label.top());
    if($4->get_has_return_stmt() && $5->get_has_return_stmt() && $8->get_has_return_stmt()) $$->set_has_return_stmt(true);
    curr_if_end_jump_label.pop();
}
;


elif_namedexpr_test_colon_suite_one_or_more: ELIF namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more  {
    $$=new NonTerminal($2->get_line_no(), "elif");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", label_elif);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top());
    $$->gen(label_elif);
    $$->copy_code($5);
    $$->set_has_return_stmt($4->get_has_return_stmt() && $5->get_has_return_stmt());
}
| ELIF namedexpr_test COLON suite {
    $$=new NonTerminal($2->get_line_no(), "elif");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", label_elif);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top());
    $$->gen(label_elif);
    $$->set_has_return_stmt($4->get_has_return_stmt());
    }
;

while_stmt: while_head namedexpr_test COLON suite  {
    $$=new NonTerminal($2->get_line_no(), "While");

    string label_start = curr_loop_start_jump_label.top();
    $$->gen_new_label(label_start);
        $$->copy_code($2);

    curr_loop_start_jump_label.pop();
    string label_end = curr_loop_end_jump_label.top();
    curr_loop_end_jump_label.pop();
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", label_end);
    $$->copy_code($4);
    $$->gen("goto", label_start);
    $$->gen_new_label(label_end);
}
|while_head namedexpr_test COLON suite ELSE COLON suite {
    $$=new NonTerminal($2->get_line_no(), "While");
    string label_start = curr_loop_start_jump_label.top();
    curr_loop_start_jump_label.pop();
    $$->gen_new_label(label_start);
        $$->copy_code($2);

    string label_end = curr_loop_end_jump_label.top();
    curr_loop_end_jump_label.pop();
    $$->gen("if not", "("+$2->get_temporary()+")", "goto", label_end);
    $$->copy_code($4);
    $$->gen("goto", label_start);
    $$->gen_new_label(label_end);
    $$->copy_code($6);
}
;
while_head: WHILE {
        curr_loop_start_jump_label.push(NonTerminal::get_new_label());
        curr_loop_end_jump_label.push(NonTerminal::get_new_label());
    }
;

for_stmt: for_head exprlist IN RANGE OPEN_PAREN test COMMA test CLOSE_PAREN COLON suite {
        if(!$2->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no: "<<$2->get_line_no()<<endl;
            exit(-1);
        }
        if(!($6->get_datatype().datatype == "int"||$6->get_datatype().datatype=="bool")||$6->get_datatype().is_list){
            cout << "Range should have integer arguments at line no: "<<$6->get_line_no()<<endl;
            exit(-1);
        }
        if(!($8->get_datatype().datatype == "int"||$8->get_datatype().datatype=="bool")||$8->get_datatype().is_list){
            cout << "Range should have integer arguments at line no: "<<$8->get_line_no()<<endl;
            exit(-1);
        }

        $$=new NonTerminal($2->get_line_no(), "For");
        $$->copy_code($2);
        $$->copy_code($6);
        $$->copy_code($8);
        $$->gen($2->get_temporary(), $6->get_temporary(), "-", "1");
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label_start);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        $$->gen("if", "("+$2->get_temporary()+ ">="+ $8->get_temporary()+")", "goto", label_end);
        $$->copy_code($11);
        $$->gen("goto", label_start);
        $$->gen_new_label(label_end);
        // $$->print_code();
    }
|for_head exprlist IN RANGE OPEN_PAREN test CLOSE_PAREN COLON suite {
        if(!$2->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no "<<$2->get_line_no()<<endl;
            exit(-1);
        }
        if(!($6->get_datatype().datatype == "int"||$6->get_datatype().datatype=="bool")||$6->get_datatype().is_list){
        cout << "Range should have integer arguments at line no "<<$6->get_line_no()<<endl;
        exit(-1);
        }

        $$=new NonTerminal($2->get_line_no(), "For");
        $$->copy_code($2);
        $$->copy_code($6);
        $$->gen($2->get_temporary(), "-1");
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label_start);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        $$->gen("if", "("+$2->get_temporary()+ ">="+ $6->get_temporary()+")", "goto", label_end);
        $$->copy_code($9);
        $$->gen("goto", label_start);
        $$->gen_new_label(label_end); 
        // $$->print_code();
    }
| for_head exprlist IN RANGE OPEN_PAREN test CLOSE_PAREN COLON  suite ELSE COLON suite {
        if(!$2->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no "<<$2->get_line_no()<<endl;
            exit(-1);
        }
        if(!($6->get_datatype().datatype == "int"||$6->get_datatype().datatype=="bool")||$6->get_datatype().is_list){
        cout << "Range should have integer arguments at line no "<<$6->get_line_no()<<endl;
        exit(-1);
    }
        $$=new NonTerminal($2->get_line_no(), "For");
        $$->copy_code($2);
        $$->copy_code($6);
        $$->gen($2->get_temporary(), "-1");
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label_start);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        $$->gen("if", "("+$2->get_temporary()+ ">="+ $6->get_temporary()+")", "goto", label_end);
        $$->copy_code($9);
        $$->gen("goto", label_start);
        $$->gen_new_label(label_end);
        $$->copy_code($12); 
        // $$->print_code();
    }
|for_head exprlist IN RANGE OPEN_PAREN test COMMA test CLOSE_PAREN COLON  suite ELSE COLON suite {
        if(!$2->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no "<<$2->get_line_no()<<endl;
            exit(-1);
        }
        if(!($6->get_datatype().datatype == "int"||$6->get_datatype().datatype=="bool")||$6->get_datatype().is_list){
            cout << "Range should have integer arguments at line no "<<$6->get_line_no()<<endl;
            exit(-1);
        }
        if(!($8->get_datatype().datatype == "int"||$8->get_datatype().datatype=="bool")||$8->get_datatype().is_list){
            cout << "Range should have integer arguments at line no "<<$8->get_line_no()<<endl;
            exit(-1);
        }
        $$=new NonTerminal($2->get_line_no(), "For");
        $$->copy_code($2);
        $$->copy_code($6);
        $$->copy_code($8);
        $$->gen($2->get_temporary(), $6->get_temporary(), "-", "1");
        auto label = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        $$->gen("if", "("+$2->get_temporary()+ ">="+ $8->get_temporary()+")", "goto", label_end);
        $$->copy_code($11);
        $$->gen("goto", label);
        $$->gen_new_label(label_end);
        $$->copy_code($14); 
        // $$->print_code();
    }
;


for_head: FOR{
    string label_start = NonTerminal::get_new_label();
    string label_end = NonTerminal::get_new_label();
    curr_loop_start_jump_label.push(label_start);
    curr_loop_end_jump_label.push(label_end);
}
;


suite: simple_stmt {$$=$1;}
| NEWLINE INDENT stmts DEDENT  {$$=$3;}
;

namedexpr_test: test {$$ = $1;}
| test COLONEQUAL test {
    if(!$1->get_is_lvalue()){
        cout << "Left hand side of walrus operator is not a lvalue at line no: " << $3->get_line_no() << endl;
        exit(-1);
    }
    $$=$1;
    $$->copy_code($3);
    $$->gen($1->get_temporary(), $3->get_temporary());
    $$->set_temporary($1->get_temporary());
    $$->set_is_lvalue(false); 
    auto type=$1->compare_datatype($3->get_datatype());
if(type.datatype == "ERROR"){
    cout << "Type mismatch in walrus assignment at line no: " << $3->get_line_no() << endl;
    cout << $3->get_datatype().datatype << ($3->get_datatype().is_list? "[]" : "") << " is not assignable to " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << endl;
    exit(-1);
} 
$$->set_datatype(type);}   

;

test: or_test {
    $$=$1;
}
;

or_test: and_test {$$ = $1;}
| and_test_star and_test  {
    auto type = $2->get_datatype();
    if(!(!type.is_list && (type.datatype == "int" || type.datatype == "bool"))){
        cout << "Incompatible operator 'or' with operand of type " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") <<" at line no: " <<$2->get_line_no() << endl;
        exit(-1);
    }
    $$ = $1;
    $$->set_datatype({"bool",false});

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "or", $2->get_temporary());    
}
;

and_test_star: and_test OR  {
    auto type = $1->get_datatype();
    if(!(!type.is_list && (type.datatype == "int" || type.datatype == "bool"))){
        cout << "Incompatible operator 'or' with operand of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"")<<" at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$ = $1; 
    $$->set_is_lvalue(false);  
    $$->set_datatype({"bool",false});
}
| and_test_star and_test OR {
    auto type = $2->get_datatype();
    if(!(!type.is_list && (type.datatype == "int" || type.datatype == "bool"))){
        cout << "Incompatible operator 'or' with operand of type " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") << " at line no: "<<$3->get_line_no() << endl;
        exit(-1);
    }
    $$ = $1;
    $$->set_datatype({"bool",false});
    
    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "or", $2->get_temporary());
}
;
and_test: not_test {$$ = $1;}
| and_not_test_plus not_test {
    auto type = $2->get_datatype();
    if(!(!type.is_list && (type.datatype == "int" || type.datatype == "bool"))){
        cout << "Incompatible operator 'and' with operand of type " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")<<" at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$ = $1;
    $$->set_datatype({"bool",false});
    
    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "and", $2->get_temporary());
}
;

and_not_test_plus: not_test AND  {
    auto type = $1->get_datatype();
    if(!(!type.is_list && (type.datatype == "int" || type.datatype == "bool"))){
        cout << "Incompatible operator 'and' with operand of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"")<<" at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$ = $1;
    $$->set_is_lvalue(false); 
    $$->set_datatype({"bool",false});
}
| and_not_test_plus not_test AND     {
    auto type = $2->get_datatype();
    if(!(!type.is_list && (type.datatype == "int" || type.datatype == "bool"))){
        cout << "Incompatible operator 'and' with operand of type " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") << " at line no: " << $3->get_line_no() << endl;
        exit(-1);
    }
    $$ = $1;
    $$->set_datatype({"bool",false});
    
    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "and", $2->get_temporary());
}
;
not_test: not_plus_comparison   {$$ = $1;}
| comparison    {$$ = $1;}
;

not_plus_comparison : NOT comparison  {
    auto type = $2->get_datatype();
    if(!(!type.is_list && (type.datatype == "int" || type.datatype == "bool"))){
        cout << "Incompatible operator 'not' with operand of type " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$ = $2;
    $$->set_is_lvalue(false);
    $$->set_datatype({"bool",false});
    
    auto old_temp = $2->get_temporary();
    $$->gen($$->set_temporary(), "not", old_temp);  /*TODO: is "not" as operator fine?*/
}
| NOT not_plus_comparison   {
    $$ = $2;
    $$->set_datatype({"bool",false});
    
    auto old_temp = $2->get_temporary();
    $$->gen($$->set_temporary(), "not", old_temp);  /*TODO: is "not" as operator fine?*/
}
;

comparison: comp_op_expr_plus expr {
    $$=$1;
    Type type;
    if((op_3AC.top()=="=="||op_3AC.top()=="!=" )&&  ($1->get_datatype().is_class || $1->get_datatype().datatype == "None")&& ($2->get_datatype().is_class || $2->get_datatype().datatype == "None")){
        type.datatype="bool";
    }
    else if($1->compare_datatype($2->get_datatype()).datatype == "ERROR"){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    else type=$1->compare_datatype($2->get_datatype());
    $$->set_datatype({"bool"});
    $$->copy_code($2);
    if(type.datatype=="str")
    {
        relate_string($$,$1,$2,op_3AC.top());
    }
    else
    {
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    }
    op_3AC.pop();
}
| expr {$$ = $1;}
;

comp_op_expr_plus: expr comp_op {
    $$=$1;
    $$->set_is_lvalue(false);

    op_3AC.push($2->get_lexeme());
}
| comp_op_expr_plus expr comp_op {
    $$=$1;
    Type type;
    if((op_3AC.top()=="=="||op_3AC.top()=="!=" ) && ($1->get_datatype().is_class||$1->get_datatype().datatype=="None") && ($2->get_datatype().is_class||$2->get_datatype().datatype=="None")){
        type.datatype="bool";
    }
    else if($1->compare_datatype($2->get_datatype()).datatype == "ERROR"){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $3->get_line_no() << endl;
        exit(-1);
    }
    else type=$1->compare_datatype($2->get_datatype());
    $$->set_datatype({"bool"}); 
    $$->copy_code($2);
    if(type.datatype=="str")
    {
        relate_string($$,$1,$2,op_3AC.top());
    }
    else
    {
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    }
    op_3AC.pop();
    op_3AC.push($3->get_lexeme());
}
;

comp_op: GREATER_THAN {$$ = $1;}
| LESS_THAN {$$ = $1;}
| EQUAL_EQUAL {$$ = $1;}
| GREATER_THAN_EQUAL {$$ = $1;}
| LESS_THAN_EQUAL   {$$ = $1;}
| NOTEQUAL  {$$ = $1;}
| IN    {$$ = $1;}
| NOT IN  {$$ = $2; $$->set_lexeme($1->get_lexeme() + $2->get_lexeme()); /*TODO: chances of making mistakes, should use alternate strategy?*/}
| IS    {$$ = $1;}
| IS NOT   {$$ = $1; $$->set_lexeme($1->get_lexeme() + $2->get_lexeme()); /*TODO: chances of making mistakes, should use alternate strategy?*/}
;



expr: r_expr xor_expr    {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"||datatype.datatype=="float"){
        cout << "Incompatible operator | with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "|", $2->get_temporary());
}
| xor_expr  {$$=$1;}
;

r_expr: r_expr xor_expr BITWISE_OR  {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator | with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "|", $2->get_temporary());
}
|  xor_expr BITWISE_OR {
    $$=$1; 
    $$->set_is_lvalue(false);
    auto datatype=$$->get_datatype();
    if(!(datatype.datatype == "int"||datatype.datatype=="bool"))
    {
        cout << "Incompatible operator | with operand of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << $2->get_line_no() << endl;
        exit(-1);
    }
    }
;

xor_expr: x_expr and_expr  {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator ^ with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "^", $2->get_temporary());
}
| and_expr  {$$ = $1;}
;

x_expr: x_expr and_expr BITWISE_XOR  {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator ^ with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "^", $2->get_temporary());
}
| and_expr BITWISE_XOR   {
    $$ = $1;
    $$->set_is_lvalue(false); 
    auto datatype=$$->get_datatype();
    if(!(datatype.datatype == "int"||datatype.datatype=="bool"))
    {
        cout << "Incompatible operator ^ with operand of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << $2->get_line_no() << endl;
        exit(-1);
    }
    }
;

and_expr: a_expr shift_expr  {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator & with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "&", $2->get_temporary());
}
| shift_expr    {$$ = $1;}
;

a_expr: a_expr shift_expr BITWISE_AND    {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator & with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, "&", $2->get_temporary());
}
| shift_expr BITWISE_AND     {
    $$=$1; 
    $$->set_is_lvalue(false);auto datatype=$$->get_datatype();
    if(!(datatype.datatype == "int"||datatype.datatype=="bool"))
    {
        cout << "Incompatible operator & with operand of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << $2->get_line_no() << endl;
        exit(-1);
    }
    }
;

shift_expr: lr_shift arith_expr     {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator "<<op_3AC.top()<< " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();
}
| arith_expr  {$$ = $1;}
;

lr_shift: arith_expr LEFT_SHIFT  {
    $$ = $1;
    $$->set_is_lvalue(false);
    auto datatype=$$->get_datatype();
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push("<<");
}
| arith_expr RIGHT_SHIFT     {
    $$ = $1;
    $$->set_is_lvalue(false);
    auto datatype=$$->get_datatype();
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push(">>");
}
| lr_shift arith_expr LEFT_SHIFT {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator "<<op_3AC.top()<< " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();
    op_3AC.push("<<");
}
| lr_shift arith_expr RIGHT_SHIFT {
    $$=$1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Incompatible operator "<<op_3AC.top()<< " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();
    op_3AC.push(">>");
}
;

arith_expr:pm_term term {
    $$ = $1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"){
        cout << "Incompatible operator "<<op_3AC.top()<< " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();  
}
| term  {$$=$1;}
;

pm_term:term PLUS   {
    $$ = $1;
    $$->set_is_lvalue(false);
    auto datatype=$$->get_datatype();
    if(datatype.datatype=="ERROR"){
        cout << "Incompatible operator + with operand of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push("+");
}
| term  MINUS    {
    $$ = $1;
    $$->set_is_lvalue(false);
    auto datatype=$$->get_datatype();
    if(datatype.datatype=="str"||datatype.datatype=="ERROR"){
        cout << "Incompatible operator - with operand of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push("-");
}
| pm_term term PLUS {
    $$ = $1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"){
        cout << "Incompatible operator "<<op_3AC.top()<< " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();
    op_3AC.push("+");   
}
| pm_term term MINUS      {
    $$ = $1;auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Incompatible operator "<<op_3AC.top()<< " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();
    op_3AC.push("-");
}
;

term: factor {$$ = $1;}
| op_fac factor  {
    $$ = $1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);
    
    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();
}
;

op_fac:factor MULTIPLY  {$$ = $1; $$->set_is_lvalue(false); op_3AC.push("*");}
| factor DIVIDE  {$$ = $1; $$->set_is_lvalue(false); op_3AC.push("/");}
| factor MODULO  {$$ = $1; $$->set_is_lvalue(false); op_3AC.push("%");}
| factor FLOOR_DIVIDE    {$$ = $1; $$->set_is_lvalue(false); op_3AC.push("//");}
| op_fac factor MULTIPLY    {
    $$ = $1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);
    $$->set_operator_type_augassign(1);

    $$->copy_code($2);
    auto old_temp = $1->get_temporary();
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary());
    op_3AC.pop();
    op_3AC.push("*");
}
| op_fac factor DIVIDE   {
    $$ = $1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);
    $$->set_operator_type_augassign(1);

    $$->copy_code($2);
    auto old_temp=$1->get_temporary();
    $$->gen($$->set_temporary(), old_temp,op_3AC.top(),$2->get_temporary());
    op_3AC.pop();
    op_3AC.push("/");
}
| op_fac factor MODULO   {
    $$ = $1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);
    $$->set_operator_type_augassign(1);

    $$->copy_code($2);
    auto old_temp=$1->get_temporary();
    $$->gen($$->set_temporary(), old_temp,op_3AC.top(),$2->get_temporary());
    op_3AC.pop();
    op_3AC.push("%");
}
| op_fac factor FLOOR_DIVIDE     {
    $$ = $1;
    auto datatype=$$->compare_datatype($2->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Incompatible operator " << op_3AC.top() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);
    $$->set_operator_type_augassign(1);

    $$->copy_code($2);
    auto old_temp=$1->get_temporary();
    $$->gen($$->set_temporary(),old_temp,op_3AC.top(),$2->get_temporary());
    op_3AC.pop();
    op_3AC.push("//");
}
;

factor: PLUS factor {
    $$ =$2;
    auto datatype=$2->get_datatype();
    if(!(!datatype.is_list && (datatype.datatype == "int" || datatype.datatype == "float" || datatype.datatype == "bool"))){
        cout << "Unary + operator cannot be applied for datatype " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") <<  " on line no: "<<$1->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);
}
| MINUS factor  {
    $$ =$2;
    auto datatype=$2->get_datatype();
    if(!(!datatype.is_list && (datatype.datatype == "int" || datatype.datatype == "float" || datatype.datatype == "bool")))
    {
        cout << "Unary - operator cannot be applied for datatype " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") <<  " on line no: "<<$1->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->gen($$->set_temporary(),"-",$2->get_temporary());

}
| BITWISE_NOT factor   {$$ =$2;
    $$->set_is_lvalue(false);
    auto datatype=$2->get_datatype();
    if(!(!datatype.is_list && (datatype.datatype == "int" || datatype.datatype == "float" || datatype.datatype == "bool"))){
        cout << "Unary ~ operator cannot be applied for datatype " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") <<  " on line no: "<<$1->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->gen($$->set_temporary(),"~",$2->get_temporary());
}
| power {$$ = $1;}
;

power: atom_expr    {$$=$1;/*$1->print_code();*/}
| atom_expr POWER factor    {
    // $1->print_code();
    $$=$1;
    auto temp=$1->get_temporary();
    $$->set_is_lvalue(false);
    auto datatype= $$->compare_datatype($3->get_datatype());
    if(datatype.datatype == "ERROR" || datatype.datatype=="str" ){
        cout << "Incompatible operator ** with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $3->get_datatype().datatype<<($3->get_datatype().is_list?"[]":"")  << " at line no: " << $3->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($3);
    $$->gen($$->set_temporary(),temp,"**",$3->get_temporary());
    
}
| atom {$$=$1;}
| atom POWER factor {
    $$=$1;
    auto temp=$1->get_temporary();
    $$->set_is_lvalue(false);
    auto datatype= $$->compare_datatype($3->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Incompatible operator ** with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $3->get_datatype().datatype<<($3->get_datatype().is_list?"[]":"")  << " at line no: " << $3->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    $$->copy_code($3);
    $$->gen($$->set_temporary(),temp,"**",$3->get_temporary());
    }
;

atom_expr: atom DOT NAME {
        Type type = $1->get_datatype();
        if(!type.is_class){
            cout << "Type " << type.datatype << (type.is_list ? "[]":"") << " is not a class at line no: " <<$3->get_line_no()<< endl;
            exit(-1);
        }
        st_entry* entry = type.class_table->lookup_class_member($3->get_lexeme());
        if(entry == nullptr){
            symbol_table_function* function_table = type.class_table->lookup_function($3->get_lexeme());
            if(function_table == nullptr){
                // no etry no function
                cout << "Class " << type.datatype << " has no member named " << $3->get_lexeme() <<" at line no: "<<$1->get_line_no()<< endl;
                exit(-1);
            }
            //function
            Type new_type;
            new_type.datatype = $3->get_lexeme();
            new_type.is_function = true;
            new_type.function_table = function_table;
            is_print_function.push(false);
            curr_function.push(function_table);
            curr_return_type.push(function_table->get_return_type());
            if(function_table->is_first_argument_self())
            function_arg_counter.push(1);
            else
            function_arg_counter.push(0);
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), new_type);
            $$->set_temporary($1->get_temporary());
            $$->copy_code($1);
        }
        else{
            //entry
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), entry->get_datatype());
            $$->copy_code($1);
            $$->set_is_lvalue(true);
            if(entry->get_datatype().is_class||entry->get_datatype().is_list)
            {
                $$->set_is_ptr(true);
            }
            $$->gen($$->set_temporary(),$1->get_temporary(),"+",to_string(entry->get_offset()));
            $$->set_temporary("*"+$$->get_temporary());
        }
    }

| atom_expr DOT NAME {
        Type type = $1->get_datatype();
        if(!type.is_class){
            cout << "Type " << type.datatype << (type.is_list ? "[]":"") << " is not a class at line no " << $3->get_line_no()<<endl;
            exit(-1);
        }
        st_entry* entry = type.class_table->lookup_class_member($3->get_lexeme());
        if(entry == nullptr){
            symbol_table_function* function_table = type.class_table->lookup_function($3->get_lexeme());
            if(function_table == nullptr){
                cout << "Class " << type.datatype << " has no member named " << $1->get_lexeme() << "at line no: " << $1->get_lexeme() << endl;
                exit(-1);
            }
            Type new_type;
            new_type.datatype = $3->get_lexeme();
            new_type.is_function = true;
            is_print_function.push(false);
            new_type.function_table = function_table;
            curr_function.push(function_table);
            curr_return_type.push(function_table->get_return_type());
            if(function_table->is_first_argument_self())
            function_arg_counter.push(1);
            else
            function_arg_counter.push(0);
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), new_type);
            $$->set_temporary($1->get_temporary());
            $$->copy_code($1);
        }
        else{
            $$ = new NonTerminal($3->get_line_no(), $3->get_lexeme(), entry->get_datatype());
            $$->copy_code($1);
            $$->set_is_lvalue(true);
            if(entry->get_datatype().is_class || entry->get_datatype().is_list)
            {
                $$->set_is_ptr(true);
            }
            $$->gen($$->set_temporary(),$1->get_temporary(),"+",to_string(entry->get_offset()));
            $$->set_temporary("*"+$$->get_temporary());
        }
    }

| atom OPEN_BRACKET test CLOSE_BRACKET {
        Type type = $1->get_datatype();
        if(!type.is_list){
            cout << "Type " << type.datatype << " is not a list at line no: " << $4->get_line_no() << endl;
            exit(-1);
        }
        if(!($3->get_datatype().datatype == "int" ||$3->get_datatype().datatype == "bool")||$3->get_datatype().is_list)
        {
            cout << "Index of list should be of type int or bool at line no "<<$3->get_line_no()<<endl;
            exit(-1);
        }
        type.is_list = false;
        $$ = new NonTerminal($3->get_line_no(), type);
        $$->set_is_lvalue(true);
        $$->copy_code($1);
        $$->copy_code($3);
        $$->gen($$->set_temporary(),$3->get_temporary(),"*",to_string(calculate_size(type,false)));
        auto old_temp = $$->get_temporary();
        $$->gen($$->set_temporary(),$1->get_temporary(),"+",old_temp);
        if($$->get_temporary()[0] == '*'){
            string new_temp = NonTerminal::get_new_temporary();
            $$->gen(new_temp, $$->get_temporary());
            $$->set_temporary("*"+new_temp);
        }
        else $$->set_temporary("*"+$$->get_temporary());        
}

| atom_expr OPEN_BRACKET test CLOSE_BRACKET  {
        Type type = $1->get_datatype();
        if(!type.is_list){
            cout << "Type " << type.datatype << " is not a list" << endl;
            exit(-1);
        }
        if(!($3->get_datatype().datatype == "int" ||$3->get_datatype().datatype == "bool")||$3->get_datatype().is_list)
        {
            cout << "Index of list should be of type int or bool at line no: "<<$3->get_line_no()<<endl;
            exit(-1);
        }
        type.is_list = false;
        $$ = new NonTerminal($3->get_line_no(), type);
        $$->set_is_lvalue(true);
        $$->copy_code($1);
        $$->copy_code($3);
        $$->gen($$->set_temporary(),$3->get_temporary(),"*",to_string(calculate_size(type,false)));
        auto old_temp = $$->get_temporary();
        $$->gen($$->set_temporary(),$1->get_temporary(),"+",old_temp);
        if($$->get_temporary()[0] == '*'){
            string new_temp = NonTerminal::get_new_temporary();
            $$->gen(new_temp, $$->get_temporary());
            $$->set_temporary("*"+new_temp);
        }
        else $$->set_temporary("*"+$$->get_temporary());  
    }
    

| atom OPEN_PAREN arglist CLOSE_PAREN {
    // $3->print_code();
    if(is_print_function.top())
    {
        // is_print_function = false;
        $$ = new NonTerminal($3->get_line_no(), {"None",false,false,false,nullptr,nullptr});
        $$->copy_code($1);        
        $$->copy_code($3);
        // $$->gen("stackpointer", "+xxx");

        $$->gen("call", "print", "1");        
        $$->gen("$rsp","$rsp","+",to_string(calculate_size($3->get_datatype(),false))); 
    }
    else
    {
        Type type = $1->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << $1->get_lexeme() << " is not a function at line no "<<$1->get_line_no() << endl;
            exit(-1);
        }
        int top = function_arg_counter.top();//how many paramenters we have matched
        int top2 = top;
        if(type.function_table->is_first_argument_self())
        { --top;}
        if(top != type.function_table->get_parameter_count()){
            cout << "Use of function " << $1->get_lexeme() << " does not match with its definition at line no"<<$4->get_line_no() << endl;
            exit(-1);
        }
        $$ = new NonTerminal($3->get_line_no(), curr_return_type.top());
        $$->copy_code($1);        
        $$->copy_code($3);
        if(type.function_table->is_first_argument_self())
        {
            if($1->get_temporary() == "" && type.function_table->get_name()=="__init__"){
                $$->gen("pushl", to_string(type.function_table->get_parent_st()->get_offset()));
                // $$->gen("stackpointer", "+xxx");
                $$->gen("call", "allocmem", "1");
                $$->gen("$rsp", "$rsp","+","4");
                $$->gen($$->set_temporary(), "$rax");
                $$->gen("pushq", $$->get_temporary());
            }
            else $$->gen("pushq",$1->get_temporary());
        }
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), to_string(top2));
        }
        else
        {
            $$->gen("call", type.function_table->get_name(), to_string(top2));
        }       
        $$->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
        if(curr_return_type.top().datatype != "None" && type.function_table->get_name()!="__init__"){
            $$->gen($$->set_temporary(), "$rax");
        }
        curr_return_type.pop();
        curr_function.pop();  
    }
    function_arg_counter.pop();
    is_print_function.pop();
    }
| atom OPEN_PAREN CLOSE_PAREN {
    if(is_print_function.top())
    {
        cout << "Print function should have exactly one argument at line no: " << $3->get_line_no() << endl;
        exit(-1);
    }
    else
    {
        Type type = $1->get_datatype(); 
        if(!type.is_function){
            cout << $1->get_lexeme() << " is not a function at line no: " << $3->get_line_no() << endl;
            exit(-1);
        }
        if(type.function_table->get_parameter_count() != 0){
            cout << "Use of function " << $1->get_lexeme() << " does not match with its definition at line no: "<<$3->get_line_no() << endl;
            exit(-1);
        }
        $$ = new NonTerminal($3->get_line_no(), curr_return_type.top());
        $$->copy_code($1);
        if($1->get_temporary() == "" && type.function_table->get_name()=="__init__"){
            $$->gen("pushl", to_string(type.function_table->get_parent_st()->get_offset()));
            // $$->gen("stackpointe", "+xxx");
            $$->gen("call", "allocmem", "1");
            $$->gen("$rsp", "$rsp","+","4");
            $$->gen($$->set_temporary(), "rax");
            $$->gen("pushq", $$->get_temporary());
        }
        else if(type.function_table->is_first_argument_self()) $$->gen("pushq",$1->get_temporary());
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), "1");
        }
        else
        {
            $$->gen("call", type.function_table->get_name(), "0");
        }       
        $$->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
        if(curr_return_type.top().datatype != "None" && type.function_table->get_name()!="__init__")
            $$->gen($$->set_temporary(), "$rax");
        curr_return_type.pop();
        curr_function.pop();        
    }  
    function_arg_counter.pop();
    is_print_function.pop();
    }
| atom_expr OPEN_PAREN CLOSE_PAREN {
    // $1->print_code();
    Type type = $1->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
    if(!type.is_function){
        cout << $1->get_lexeme() << " is not a function at line no: " << $3->get_line_no() << endl;
        exit(-1);
    }
    if(type.function_table->get_parameter_count() != 0){
        cout << "Use of function " << $1->get_lexeme() << " does not match with its definition at line no: "<<$3->get_line_no() << endl;
        exit(-1);
    }
    $$ = new NonTerminal($3->get_line_no(), curr_return_type.top());
    $$->copy_code($1);
    if(type.function_table->is_first_argument_self())
    $$->gen("pushq",$1->get_temporary());
    // $$->gen("stackpointer", "+xxx");
    auto parent_sym_table= type.function_table->get_parent_st();
    if(parent_sym_table->get_symbol_table_type()==2)
    {
        $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), "1");
    }
    else
    {
        $$->gen("call", type.function_table->get_name(), "0");
    }       
    $$->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
    if(curr_return_type.top().datatype != "None")
        $$->gen($$->set_temporary(), "$rax");
    curr_return_type.pop();
    curr_function.pop();    
    function_arg_counter.pop();
    is_print_function.pop();
}

| atom_expr OPEN_PAREN arglist CLOSE_PAREN  {
        Type type = $1->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << $1->get_lexeme() << " is not a function at line no: " << $4->get_line_no() << endl;
            exit(-1);
        }
        int top = function_arg_counter.top();
        int top2 = top;
        if(type.function_table->is_first_argument_self()) { --top;}
        if(top != type.function_table->get_parameter_count()){
            cout << "Use of Function " << $1->get_lexeme() << " does not match with its definition at line no: "<<$4->get_line_no() << endl;
            exit(-1);
        }
        $$ = new NonTerminal($3->get_line_no(), curr_return_type.top());  
        $$->copy_code($1);
        $$->copy_code($3);
        if(type.function_table->is_first_argument_self())
        $$->gen("pushq",$1->get_temporary());
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), to_string(top2));
        }
        else
        {
            $$->gen("call", type.function_table->get_name(), to_string(top2));
        }       
        $$->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
        if(curr_return_type.top().datatype != "None")
            $$->gen($$->set_temporary(), "$rax"); 
        curr_return_type.pop();
        curr_function.pop(); 
        function_arg_counter.pop();  
        is_print_function.pop();
}
;

atom: OPEN_PAREN testlist_comp CLOSE_PAREN  {
    $$=$2;
    $$->clear_curr_list_temporaries();
}
| OPEN_PAREN CLOSE_PAREN    {$$=new NonTerminal($2->get_line_no(),{"",false,false,false,nullptr,nullptr}); }
| OPEN_BRACKET testlist_comp CLOSE_BRACKET  {$$=$2;$$->set_list(true);$$->print_curr_list_temporaries();}
| OPEN_BRACKET CLOSE_BRACKET    {$$=new NonTerminal($2->get_line_no(), {"",true,false,false,nullptr,nullptr});}
| NAME{
        if($1->get_lexeme() == "print"){
            Type new_type;
            new_type.datatype = $1->get_lexeme();
            new_type.is_function = true;
            is_print_function.push(true);
            new_type.function_table = nullptr;
            function_arg_counter.push(0);
            $$ = new NonTerminal($1->get_line_no(), $1->get_lexeme(), new_type);
        }
        else{
            st_entry* entry = curr_symbol_table->lookup_all($1->get_lexeme());
            if(entry == nullptr){
                symbol_table_function* function_table = global_symbol_table->lookup_function($1->get_lexeme());
                if(function_table == nullptr){
                    symbol_table_class* class_table = global_symbol_table->lookup_class($1->get_lexeme());
                    if(class_table == nullptr)
                    {    
                        cout << "Variable " << $1->get_lexeme() << " used before declaration at line no: " << $1->get_line_no() << endl;
                        exit(-1);
                    }
                    Type new_type;
                    new_type.datatype = $1->get_lexeme();
                    new_type.is_function = true;
                    is_print_function.push(false);
                    new_type.function_table = class_table->lookup_function("__init__");
                    curr_function.push(new_type.function_table);
                    Type class_type;
                    class_type.datatype = $1->get_lexeme();
                    class_type.class_table = class_table;
                    class_type.is_class = true;
                    curr_return_type.push(class_type);
                    function_arg_counter.push(1);
                    $$ = new NonTerminal($1->get_line_no(), $1->get_lexeme(), new_type);
                    
                }
                else{
                    Type new_type;
                    new_type.datatype = $1->get_lexeme();
                    new_type.is_function = true;
                    is_print_function.push(false);
                    new_type.function_table = function_table;
                    curr_function.push(function_table);
                    curr_return_type.push(function_table->get_return_type());
                    if(curr_function.top()->is_first_argument_self())
                    function_arg_counter.push(1);
                    else
                    function_arg_counter.push(0);
                    $$ = new NonTerminal($1->get_line_no(), $1->get_lexeme(), new_type);
                }                
            }
            else{
                $$ = $1;
                $$->set_is_lvalue(true);
                $$->set_datatype(entry->get_datatype());
                $$->set_temporary($$->get_lexeme());
            }
        }  
    }
| NUMBER {$$=$1;$$->set_datatype({"int",false}); $$->gen($$->set_temporary(),$$->get_lexeme());}
| string_one_or_more    {$$=$1;}
| NONE  {$$=$1;$$->set_datatype({"None",false}); $$->set_temporary("0");}
| TRUE_     {$$=$1;$$->set_datatype({"bool",false});$$->gen($$->set_temporary(),$$->get_lexeme());}
| FALSE_    {$$=$1;$$->set_datatype({"bool",false});$$->gen($$->set_temporary(),$$->get_lexeme());}
| REAL_NUMBER   {$$=$1;$$->set_datatype({"float",false});$$->gen($$->set_temporary(),$$->get_lexeme());}
;


string_one_or_more: string_one_or_more STRING   {$$=$1;auto temp = $1-> get_temporary();$$->set_lexeme($1->get_lexeme() + $2->get_lexeme()); $$->gen($$->set_temporary(),temp,"+",$2->get_lexeme());}
| STRING    {$$=$1;$$->set_datatype({"str",false});$$->gen($$->set_temporary(),$$->get_lexeme());}
;

testlist_comp: named_star_or comma_named_star_comma {
    if($2->get_datatype().datatype == "COMMA"){
        $$ =$1;
    }
    else{
        $$ = $1;
        $$->set_datatype($$->compare_datatype($2->get_datatype()));
        $$->copy_code($2);
        $$->copy_cur_temp($2);
    }
}
| named_star_or {
if(debug)    printf("here\n");
    $$ =$1;
}
;


comma_named_star_comma: comma_named_star COMMA  {$$=$1;}
| comma_named_star  {$$ = $1;}
| COMMA {$$ = $1;$$->set_datatype({"COMMA",false});}
;
named_star_or: namedexpr_test   {
    $$ =$1;
    $$->curr_list_temporaries_push($1->get_temporary());
}
;

comma_named_star: COMMA named_star_or   {$$= $2; }
| comma_named_star COMMA named_star_or  {$$=$1; $$->copy_code($3);$$->curr_list_temporaries_push($3->get_temporary()); $$->set_datatype($$->compare_datatype($3->get_datatype()));}
;

exprlist: expr {$$=$1;}
;


testlist: test {$$=$1;} 
;




classdef: classdef_head suite {
    $$ = $2;
    if(symbol_table_stack.size() == 0){
        cout << "Trying to pop empty stack" << endl;
        exit(-1);
    }
    symbol_table_stack.top()->add_init();
    symbol_table_stack.pop();
    curr_symbol_table=symbol_table_stack.top();
}
;

classdef_head: CLASS NAME COLON {
    auto new_class = curr_symbol_table->create_new_class($2->get_lexeme(), nullptr);
    new_class->set_line_no($2->get_line_no());
    symbol_table_stack.push(new_class); curr_symbol_table = new_class;
    
}
| CLASS NAME OPEN_PAREN CLOSE_PAREN COLON {
    auto new_class = curr_symbol_table->create_new_class($2->get_lexeme(), nullptr);
    new_class->set_line_no($2->get_line_no());
    symbol_table_stack.push(new_class); curr_symbol_table = new_class;
}
| CLASS NAME OPEN_PAREN NAME CLOSE_PAREN COLON {
    auto parent_class = curr_symbol_table->lookup_class($4->get_lexeme()); /*if(parent_class == nullptr){cout << "Base class not defined\n";}*/
    auto new_class = curr_symbol_table->create_new_class($2->get_lexeme(), parent_class);
    new_class->set_line_no($2->get_line_no());
    symbol_table_stack.push(new_class); curr_symbol_table = new_class;
}
;

arglist: argument comma_arg {push_argument($1); $$ = $2; $$->copy_code($1);}
| argument comma_arg COMMA {push_argument($1); $$ = $2; $$->copy_code($1);} 
| argument  {push_argument($1); $$=$1;}
| argument COMMA    {push_argument($1); $$ = $1;}
;

comma_arg: COMMA argument   {push_argument($2); $$=$2;}
| COMMA argument comma_arg  {push_argument($2);$$=$3;$$->copy_code($2);}
;

argument: test  {
    $$ = $1;
}
;


func_body_suite: simple_stmt { $$ = $1; }
| NEWLINE INDENT stmts DEDENT { $$ = $3;  }
;

datatype: NAME {
    $$ = new Type; $$->datatype = $1->get_lexeme(); 
    $$->is_list = false;
    if(!($1->get_lexeme() == "int" || $1->get_lexeme() == "float" || $1->get_lexeme() == "bool" || $1->get_lexeme() == "str")){
        $$->is_class=true;
        $$->class_table=global_symbol_table->lookup_class($1->get_lexeme());
        if($$->class_table == nullptr){
            cout << $1->get_lexeme() << " is not a valid datatype at line no: " << $1->get_line_no() << endl;
            exit(-1);
        }
    }
}
| NAME OPEN_BRACKET NAME CLOSE_BRACKET {
    if($1->get_lexeme() != "list"){
        cout << "Invalid type declaration at line no: " << $1->get_line_no() << endl;
        exit(-1);
    }
    $$ = new Type; $$->datatype = $3->get_lexeme(); $$->is_list=true;
    if(!($3->get_lexeme() == "int" || $3->get_lexeme() == "float" || $3->get_lexeme() == "bool" || $3->get_lexeme() == "str")){
        $$->is_class=true;
        $$->class_table=global_symbol_table->lookup_class($1->get_lexeme());
        if($$->class_table == nullptr){
            cout << $1->get_lexeme() << " is not a valid datatype at line no: " << $1->get_line_no() << endl;
            exit(-1);
        }
    }
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
void print_threeAC(string path)
{
     ofstream file;
    file.open(path);
    for(auto &code_block: threeAC){
        for(auto &code: code_block){
            code->print_raw(file);
        }
        file << endl;
    }
}
int main(int argc, char* argv[]) {    
    yydebug = 0;
    string input_file_path;
    string output_file_path = "3AC.txt";
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
        else if(string(argv[i]) == "--output"){
            if(++i < argc) output_file_path = argv[i];
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
    global_symbol_table->insert("__name__", {"str"}, 0, true);
    add_len_function(global_symbol_table);
    symbol_table_stack.push(curr_symbol_table);
    
    
    yyparse();
    print_threeAC(output_file_path);
    global_symbol_table->make_csv();

    if(verbose)
    {   
       print_verbose();
       yydebug = 1;
    }
}

void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error: Line number:%d offending token: %s\n",yylineno, yytext);
    if(verbose)
    {
       print_verbose();
        yydebug = 1;
    }
    exit(1);
}