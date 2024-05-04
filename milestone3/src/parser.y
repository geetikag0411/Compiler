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
    stack<vector<vector<ThreeAC*>>> list_expr_code_stack;
    vector<vector<ThreeAC*>> list_expr_code;
    stack<bool> is_list_expr_code;
    stack<string> op_3AC;
    queue<string> available_regs;
    map<string, string> reg_allocation;
    map<string, string> stack_allocation;
    int stack_allocation_size{0};
    map<string, string> string_label;
    static int string_label_counter{0};
    string output_x86_file_path = "../output/x86.s";
    ofstream x86_dump;

string get_new_string_label(){
    return ".str"+to_string(string_label_counter++);
}

void initialize_available_regs(){
    available_regs.push("%r8");
    available_regs.push("%r9");
    available_regs.push("%r10");
    available_regs.push("%r11");
    available_regs.push("%r12");
    available_regs.push("%r13");
    // r14, r15 needed for double dereference
    // available_regs.push("%r14");
    // available_regs.push("%r15");
}

// .data

// integer_format: .asciz

// .global main

// void gen_global(){
//     instruction ins;
//     ins = instruction(".data", "", "", "", "segment");
//     this -> code.push_back(ins);

//     ins = instruction("integer_format:", ".asciz", "\"%ld\\n\"", "", "ins");
//     this -> code.push_back(ins);

//     ins = instruction(".global", "main", "", "", "segment");      // define entry point
//     this -> code.push_back(ins);
// }

string make_expr_x86_instruction(ThreeAC* tac, string result_addr, string arg1_addr, string op, string arg2_addr){
            //  cout << "51 " << result_addr << " " << arg1_addr << " " << op << " " << arg2_addr << endl;             
            if(op == "+"){                                //working
                string ins1 = "\t\tmovq\t" + arg2_addr + ", %rdx";
                string ins2 = "\t\taddq\t" + arg1_addr + ", " + "%rdx";
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n" + ins2 + "\n" + ins3;
            }
            else if(op == "-"){
                                //working
                // cout<<arg1_addr<<" "<<arg2_addr<<endl;
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tsubq\t" + arg2_addr + ", " + "%rdx";
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n" + ins2 + "\n" + ins3;
            }
            else if(op == "*"){
                // cout<<"MULTIPLY\n";
                                //working

                string ins1 = "\t\tmovq\t" + arg2_addr + ", %rdx";
                string ins2 = "\t\timulq\t" + arg1_addr + ", " + "%rdx";
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3;
            }
            else if(op == "/"){
//test
// printf("DIVIDE\n");
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rax";
                string ins2 = "\t\tidivq\t" + arg2_addr;
                string ins3 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+"\t\tcqto\t\n" + ins2 + "\n" + ins3;

            }
            else if(op == "//"){
                // printf("Floor DIVIDE\n");
                 string ins1 = "\t\tmovq\t" + arg1_addr + ", %rax";
                string ins2 = "\t\tidivq\t" + arg2_addr;
                string ins3 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+"\t\tcqto\t\n" + ins2 + "\n" + ins3;
                

            }
             else if(op == "%"){
                //working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rax";
                string ins2 = "\t\tidivq\t" + arg2_addr;
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n"+"\t\tcqto\t\n" + ins2 + "\n" + ins3;

            }
            else if(op == "=="){
                //working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tcmpq\t" + "%rdx"s+", " + "%rcx";
                string ins4 = "\t\tsete\t" + "%al"s;
                string ins5 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins6 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6;

            }
            else if(op=="<")
            {//working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tcmpq\t" + "%rcx"s+", " + "%rdx";
                string ins4 = "\t\tsetl\t" + "%al"s;
                string ins5 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins6 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6;


            }
            else if(op == ">"){
                //working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tcmpq\t" + "%rcx"s+", " + "%rdx";
                string ins4 = "\t\tsetg\t" + "%al"s;
                string ins5 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins6 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6;

            }
            else if(op==">=")
            {
                //working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tcmpq\t" + "%rcx"s+", " + "%rdx";
                string ins4 = "\t\tsetge\t" + "%al"s;
                string ins5 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins6 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6;

            }
            else if(op == "<="){
                //working
            string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tcmpq\t" + "%rcx"s+", " + "%rdx";
                string ins4 = "\t\tsetle\t" + "%al"s;
                string ins5 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins6 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6;

            }
            else if(op=="!=")
            {
                //working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tcmpq\t" + "%rcx"s+", " + "%rdx";
                string ins4 = "\t\tsetne\t" + "%al"s;
                string ins5 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins6 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6;

            }
            else if(op=="<<")
            {
                //working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tsal\t" + "%cl"s + ", " + "%rdx";
                string ins4 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4;

            }
            else if(op == ">>"){
                //working
                string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tmovq\t" + arg2_addr + ", %rcx";
                string ins3 = "\t\tsar\t" + "%cl"s + ", " + "%rdx";
                string ins4 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4;
            }
            else if(op=="&")
            {//
                string ins1 = "\t\tmovq\t" + arg2_addr + ", %rdx";
                string ins2 = "\t\tandq\t" + arg1_addr + ", " + "%rdx";
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n" + ins2 + "\n" + ins3;

            }
            else if(op == "|"){
                string ins1 = "\t\tmovq\t" + arg2_addr + ", %rdx";
                string ins2 = "\t\torq\t" + arg1_addr + ", " + "%rdx";
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n" + ins2 + "\n" + ins3;
            }
          else if(op=="**")
          {
                auto label1 = NonTerminal::get_new_label();
                auto label2 = NonTerminal::get_new_label();
                label1.pop_back();
                label2.pop_back();
                string part1 = "\t\tmovq\t$1, " + result_addr + "\n"s +
                       "\t\tmovq\t" + arg2_addr + ", %rdx\n" +
                       label1+":\n"+
                       "\t\tmovq\t$0, %rcx\n"s +
                       "\t\tcmpq\t" + "%rcx"s+", %rdx\n" +
                       "\t\tsetg\t" + "%al\n"s +
                       "\t\tmovzbl\t" + "%al"s + ", %eax\n" +
                       "\t\tmovq\t$1, %rcx\n"s+
                       "\t\tcmpq\t%rax, %rcx\n"s +
                       "\t\tjne\t\t" + label2 + "\n";
                string part2 = "\t\tmovq\t" + arg1_addr + ", %rcx\n"+
                       "\t\timulq\t" + result_addr + ", " + "%rcx\n"+
                       "\t\tmovq\t%rcx, " + result_addr + "\n"+
                       "\t\tsubq\t$1, %rdx\n"s +
                       "\t\tjmp\t\t"+label1+"\n"s +
                       label2+":";
                return part1+part2;
          }
            else if(op == "^"){
                string ins1 = "\t\tmovq\t" + arg2_addr + ", %rdx";
                string ins2 = "\t\txorq\t" + arg1_addr + ", " + "%rdx";
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n" + ins2 + "\n" + ins3;
            }
            else if(op=="not")
          {
            // printf("Not\n");
            string ins1 = "\t\tmovq\t" + "$0"s + ", %rdx";
                string ins2 = "\t\tcmpq\t" + arg1_addr+", " + "%rdx";
                string ins3 = "\t\tsete\t" + "%al"s;
                string ins4 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins5 = "\t\tmovq\t%rax, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5;
          }
            else if(op=="and")
            {
                // printf("AND\n");
                 string ins1 = "\t\tmovq\t" + "$0"s + ", %rdx";
                string ins2 = "\t\tcmpq\t" + arg1_addr+", " + "%rdx";
                string ins3 = "\t\tsetne\t" + "%al"s;
                string ins4 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins5 = "\t\tmovq\t%rax, " + arg1_addr;
                 string ins6 = "\t\tmovq\t" + "$0"s + ", %rdx";
                string ins7 = "\t\tcmpq\t" + arg2_addr+", " + "%rdx";
                string ins8 = "\t\tsetne\t" + "%al"s;
                string ins9 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins10 = "\t\tmovq\t%rax, "s + "%rdx";
                string ins11 = "\t\tandq\t" + arg1_addr + ", " + "%rdx";
                string ins12 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6+"\n" + ins7+"\n" + ins8+"\n" + ins9+"\n" + ins10+"\n" + ins11+"\n" + ins12;

                
            }
            else if(op == "or"){
                string ins1 = "\t\tmovq\t" + "$0"s + ", %rdx";
                string ins2 = "\t\tcmpq\t" + arg1_addr+", " + "%rdx";
                string ins3 = "\t\tsetne\t" + "%al"s;
                string ins4 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins5 = "\t\tmovq\t%rax, " + arg1_addr;
                string ins6 = "\t\tmovq\t" + "$0"s + ", %rdx";
                string ins7 = "\t\tcmpq\t" + arg2_addr+", " + "%rdx";
                string ins8 = "\t\tsetne\t" + "%al"s;
                string ins9 = "\t\tmovzbl\t" + "%al"s + ", %eax";
                string ins10 = "\t\tmovq\t%rax, "s + "%rdx";
                string ins11 = "\t\torq\t" + arg1_addr + ", " + "%rdx";
                string ins12 = "\t\tmovq\t%rdx, " + result_addr;
                return ins1 + "\n"+ ins2 + "\n" + ins3+"\n" + ins4+"\n" + ins5+"\n" + ins6+"\n" + ins7+"\n" + ins8+"\n" + ins9+"\n" + ins10+"\n" + ins11+"\n" + ins12;


            }
            
         return "";            
}

string get_register(string temporary, bool is_def){
    if(is_def){
        if(temporary[1] == 'T' || available_regs.size() == 0){
            // cout << "Ran out of available registers... moving to stack allocation for temp " << temporary << endl;
            return "";
            exit(-1);
        }
        reg_allocation[temporary] = available_regs.front();
        available_regs.pop();
        return reg_allocation[temporary];
    }
    else{
        if(reg_allocation.find(temporary) == reg_allocation.end()){
            return "";
        }
        available_regs.push(reg_allocation[temporary]);
        auto reg = reg_allocation[temporary];
        reg_allocation.erase(reg_allocation.find(temporary));
        return reg;
    }
}

string get_stack_location(string temporary, bool is_def, symbol_table* curr_symbol_table){
    static string extra_stack_location;
    if(is_def){
        if(extra_stack_location.size() > 0){
            string location = extra_stack_location;
            extra_stack_location = "";
            return location;
        }
        stack_allocation_size += 16;
        // x86_dump << "\t\tsubq\t$16, %rsp" << endl;
        string stack_location = "-"+to_string(8+curr_symbol_table->get_offset())+"(%rbp)";
        string extra_stack_location = "-"+to_string(16+curr_symbol_table->get_offset())+"(%rbp)";
        stack_allocation[temporary] = stack_location;
        curr_symbol_table->set_offset(16+curr_symbol_table->get_offset());
        return stack_allocation[temporary];
    }
    else{
        if(stack_allocation.find(temporary) == stack_allocation.end()){
            cout << "No register/stack location allocated to temporary " << temporary << endl;
            exit(-1);
        }
        return stack_allocation[temporary];
    }
}

void get_addresses(ThreeAC *tac, string &result_addr, string &arg1_addr, string &arg2_addr, string &op_addr, symbol_table *curr_symbol_table)
{
    string arg1 = tac->get_arg1(), arg2 = tac->get_arg2(), result = tac->get_result(), op = tac->get_op();
    // cout << result << " " << arg1 << " " << op << " " << arg2 << endl;
    int ins_type = tac->get_instruction_type();
    bool is_result_deref, is_arg1_deref, is_arg2_deref, is_op_deref;
    is_result_deref = is_arg1_deref = is_arg2_deref = is_op_deref = false;
    if(result.size() > 0 && result[0] == '*'){
        is_result_deref = true;
        result = result.substr(1);
    }
    if(arg1.size() > 0 && arg1[0] == '*'){
        is_arg1_deref = true;
        arg1 = arg1.substr(1);
    }
    if(arg2.size() > 0 && arg2[0] == '*'){
        is_arg2_deref = true;
        arg2 = arg2.substr(1);
    }
    if(op.size() > 0 && op[0] == '*'){
        is_op_deref = true;
        op = op.substr(1);
    }
    if(result.size() > 0 && result[0] == '$'){  // temporary
        if(is_result_deref){
            result_addr = get_register(result, false);
            if(result_addr.size() == 0) result_addr = get_stack_location(result, false, curr_symbol_table);
            result_addr = "(" + result_addr + ")";
        }
        else{
            result_addr = get_register(result, true);
            if(result_addr.size() == 0) result_addr = get_stack_location(result, true, curr_symbol_table);
        }
    }
    else if(result.size() > 0 && (result[0] == '%' ||result[0]== '(')) result_addr = result; // register
    else if(result.size() > 0 && (result[0] >= '0' && result[0] <= '9' && result.back() != ')')) result_addr = "$" + result;   //immediate value
    else{
        auto entry = curr_symbol_table->lookup(result);
        if(entry != nullptr) result_addr = "-"+to_string(entry->get_offset()+8)+"(%rbp)";
        else{   // maybe global variable, will handle later
            result_addr = result;
        }
        if(is_result_deref) result_addr = "(" + result_addr + ")";
    }
    
    if(arg1.size() > 0 && arg1[0] == '$'){
        arg1_addr = get_register(arg1, false);
        if(arg1_addr.size() == 0) arg1_addr = get_stack_location(arg1, false, curr_symbol_table);
        if(is_arg1_deref) arg1_addr = "(" + arg1_addr + ")";
    }
    else if(arg1.size() > 0 && (arg1[0] == '%' || result[0]=='(')) arg1_addr = arg1; // register
    else if(arg1.size() > 0 && (arg1[0] >= '0' && arg1[0] <= '9' && arg1.back() != ')')) arg1_addr = "$" + arg1;   //immediate value
    else{
        auto entry = curr_symbol_table->lookup(arg1);
        if(entry != nullptr) arg1_addr = "-"+to_string(entry->get_offset()+8)+"(%rbp)";
        else{   // maybe global variable, will handle later
            arg1_addr = arg1;
        }
        if(is_arg1_deref) arg1_addr = "(" + arg1_addr + ")";
    }
    if(arg2.size() > 0 && arg2[0] == '$'){
        arg2_addr = get_register(arg2, false);
        if(arg2_addr.size() == 0) arg2_addr = get_stack_location(arg2, false, curr_symbol_table);
        if(is_arg2_deref) arg2_addr = "(" + arg2_addr + ")";
    }
    else if(arg2.size() > 0 && (arg2[0] == '%' ||result[0]== '(')) arg2_addr = arg2; // register
    else if(arg2.size() > 0 && (arg2[0] >= '0' && arg2[0] <= '9' && arg2.back() != ')')) arg2_addr = "$" + arg2;   //immediate value
    else{
        auto entry = curr_symbol_table->lookup(arg2);
        if(entry != nullptr) arg2_addr = "-"+to_string(entry->get_offset()+8)+"(%rbp)";
        else{   // maybe global variable, will handle later
            arg2_addr = arg2;
        }
        if(is_arg2_deref) arg2_addr = "(" + arg2_addr + ")";
    }
    if(tac->get_instruction_type()==EXPR)
    {
        op_addr = op;
    }
   else if(op.size() > 0 && op[0] == '$'){
        op_addr = get_register(op, false);
        if(op_addr.size() == 0) op_addr = get_stack_location(op, false, curr_symbol_table);
        if(is_op_deref) op_addr = "(" + op_addr + ")";
    }
    else if(op.size() > 0 && (op[0] == '%' ||result[0]== '(')) op_addr = op; // register
    else if(op.size() > 0 && (op[0] >= '0' && op[0] <= '9' && op.back() != ')')) op_addr = "$" + op; //immediate value
    else{
        auto entry = curr_symbol_table->lookup(op);
        if(entry != nullptr) op_addr = "-"+to_string(entry->get_offset()+8)+"(%rbp)";
        else{   // maybe global variable, will handle later
            op_addr = op;
        }
        if(is_op_deref) op_addr = "(" + op_addr + ")";
    }
    if(result_addr=="False")result_addr="$0";
    if(result_addr=="True")result_addr="$1";
    if(arg1_addr=="False")arg1_addr="$0";
    if(arg1_addr=="True")arg1_addr="$1";
    if(arg2_addr=="False")arg2_addr="$0";
    if(arg2_addr=="True")arg2_addr="$1";
    if(op=="False")op_addr="$0";
    if(op=="True")op_addr="$1";
}

string make_x86_instruction(ThreeAC *tac, symbol_table *curr_symbol_table )
{
    string result_addr, arg1_addr, arg2_addr,op_addr;
    // string op = tac->get_op();
    get_addresses(tac, result_addr, arg1_addr, arg2_addr, op_addr, curr_symbol_table);
    //  cout<<"result_addr: "<<result_addr<<" arg1_addr: "<<arg1_addr<<" arg2_addr: "<<arg2_addr<<" op:"<<op_addr<<endl;
    // if(tac->get_result() == "$t6") cout << result_addr << " " << arg1_addr << endl;
    string extra_ins;
            
    if(result_addr[0] == '('){
        result_addr = result_addr.substr(1, result_addr.size()-2);
        extra_ins += "\t\tmovq\t" + result_addr + ", %rbx\n";
        result_addr = "(%rbx)";
    }
    if(arg1_addr[0] == '('){
        arg1_addr = arg1_addr.substr(1, arg1_addr.size()-2);
        extra_ins += "\t\tmovq\t" + arg1_addr + ", %r14\n";
        arg1_addr = "(%r14)";
    }
    if(arg2_addr[0] == '('){
        arg2_addr = arg2_addr.substr(1, arg2_addr.size()-2);
        extra_ins += "\t\tmovq\t" + arg2_addr + ", %r15\n";
        arg2_addr = "(%r15)";
    }
    string pre_call = "\t\tpushq\t%r8\n\t\tpushq\t%r9\n\t\tpushq\t%r10\n\t\tpushq\t%r11\n\t\tpushq\t%r12\n\t\tpushq\t%r13\n\t\tpushq\t%r14\n\t\tpushq\t%r15\n";
    string post_call = "\t\tpopq\t%r15\n\t\tpopq\t%r14\n\t\tpopq\t%r13\n\t\tpopq\t%r12\n\t\tpopq\t%r11\n\t\tpopq\t%r10\n\t\tpopq\t%r9\n\t\tpopq\t%r8";
    string label;
    switch (tac->get_instruction_type())
    {
        case POP:
            return extra_ins + "\t\tpopq\t" + arg1_addr;
            break;
        case PUSH:
            return extra_ins + "\t\tpushq\t" + arg1_addr;
            break;
        case MOV:
            if(tac->get_op()=="")
            {
                if(arg1_addr[0] == '-' || (arg1_addr[0] >= '0' && arg1_addr[0] <= '9')){
                    if(result_addr[0] == '%') return extra_ins + "\t\tmovq\t" + arg1_addr + ", " + result_addr;
                    else return extra_ins + "\t\tmovq\t" +arg1_addr+", %rdx\n\t\tmovq\t%rdx, " + result_addr;
                }
                else if(arg1_addr[0] == '('){
                    arg1_addr = arg1_addr.substr(1,arg1_addr.size()-2);
                    if(result_addr[0] =='(' || result_addr[0] == '-' || (result_addr[0] >= '0' && result_addr[0] <= '9'))
                    {
                        return extra_ins + "\t\tmovq\t" +arg1_addr+", %rdx\n\t\tmovq\t(%rdx), %rdx\n\t\tmovq\t%rdx, " + result_addr;
                    }
                    else return extra_ins + "\t\tmovq\t" +arg1_addr+", %rdx\n\t\tmovq\t(%rdx), " + result_addr;
                }
                else{
                    return extra_ins + "\t\tmovq\t"+arg1_addr+", "+result_addr;
                }
            }
            else
            {
                if(op_addr[0] == '-' || (op_addr[0] >= '0' && op_addr[0] <= '9')){
                    if(arg1_addr[0] == '%') return extra_ins + "\t\tmovq\t" + op_addr + ", " + arg1_addr;
                    else return extra_ins + "\t\tmovq\t" + op_addr+", %rdx\n\t\tmovq\t%rdx, " + arg1_addr;
                }
                else if(op_addr[0] == '('){
                    op_addr = op_addr.substr(1,op_addr.size()-2);
                    if(arg1_addr[0] =='(' || arg1_addr[0] == '-' || (arg1_addr[0] >= '0' && arg1_addr[0] <= '9'))
                    {
                        return extra_ins + "\t\tmovq\t" +op_addr+", %rdx\n\t\tmovq\t(%rdx), %rdx\n\t\tmovq\t%rdx, " + arg1_addr;
                    }
                    else return extra_ins + "\t\tmovq\t" +op_addr+", %rdx\n\t\tmovq\t(%rdx), " + arg1_addr;;
                }
                else return extra_ins + "\t\tmovq\t"+op_addr+", "+arg1_addr;
    
            }  
            break;            

        case RET: return extra_ins + (curr_symbol_table->get_name() == "main" ? "\t\tmovq\t$0, %rax\n"s : ""s) + "\t\tret\n";
        
        case GOTO:
            if(arg1_addr.back() == ':') arg1_addr.pop_back();      
            return extra_ins + "\t\tjmp\t\t"+arg1_addr+"\n";
        case EXPR: 
            return extra_ins + make_expr_x86_instruction(tac, result_addr, arg1_addr, tac->get_op(), arg2_addr);
            break;
        case CALL:
            if(op_addr == "print"){
                return extra_ins + "\t\tleaq\tinteger_format(%rip), %rdi\n" + pre_call+"\t\tcall\tprintf@PLT\n"+post_call;
            }
            else if(op_addr == "print_str"){
                return extra_ins + pre_call+"\t\tcall\tputs@PLT\n"+post_call;
            }
            return extra_ins + pre_call+"\t\tcall\t"+op_addr+"\n"+post_call;       
        case IFGOTO:
        { string ins1 = "\t\tmovq\t" + "$0"s + ", %rcx";
                string ins3 = "\t\tcmpq\t" + arg1_addr+", " + "%rcx";
                arg2_addr = tac->get_arg2();
                arg2_addr.pop_back();
                string ins4 = "\t\tjne\t" + arg2_addr;
                return extra_ins + ins1 + "\n" + ins3 + "\n" + ins4;
                }         break;        
        case IFNOT:{ string ins1 = "\t\tmovq\t" + "$0"s + ", %rcx";
                string ins3 = "\t\tcmpq\t" + arg1_addr+", " + "%rcx";
                arg2_addr = tac->get_arg2();
                arg2_addr.pop_back();
                string ins4 = "\t\tje\t\t" + arg2_addr;
                return extra_ins + ins1 + "\n" + ins3 + "\n" + ins4;
                }          break;        
        case FUNCLABEL:   return extra_ins + result_addr;        
        case CLASSFUNCLABEL:   return extra_ins + result_addr;     
        case LABEL:     return  extra_ins + result_addr;     
        case ASSIGN:         break;
        case UNARYEXPR:
        {
            if(tac->get_op()=="~")
            {
                 string ins1 = "\t\tmovq\t" + arg1_addr + ", %rdx";
                string ins2 = "\t\tnotq\t" + "%rdx"s;
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return extra_ins + ins1 + "\n" + ins2 + "\n" + ins3;
            }
            else if(tac->get_op()=="-")
            {
                string ins1 = "\t\tmovq\t" + "$0"s + ", %rdx";
                string ins2 = "\t\tsubq\t" + arg1_addr + ", " + "%rdx";
                string ins3 = "\t\tmovq\t%rdx, " + result_addr;
                return extra_ins + ins1 + "\n" + ins2 + "\n" + ins3; 
            }
        }
        case LEAQ:
            {
                return extra_ins + "\t\tleaq\t" + tac->get_op() + ", " + tac->get_arg1();
            }
        case MOVSX:
            {
                return extra_ins + "\t\tmovsx\t%eax, %rax"; 
            }
        case ALIGN:
            /*movq    %rbp, %rdx
            subq    %rsp, %rdx
            andq	$15, %rdx
            testq    %rdx, %rdx
            je      .L0
            subq    $8, %rsp
.L0:		# $t0 = $t1 & $t2*/
            label = NonTerminal::get_new_label();
            label.pop_back();
            return  extra_ins + 
                    "\t\tmovq\t%rbp, %rdx\n"s+
                    "\t\tsubq\t%rsp, %rdx\n"+
                    "\t\tandq\t$15, %rdx\n"+ 
                    "\t\ttestq\t%rdx, %rdx\n"+
                    "\t\tje\t\t"+label+"\n"+
                    "\t\tsubq\t$8, %rsp\n"+
                    "\t\tmovq\t$8, %rbx\n"+
                    label+":\n";
                    "\t\tmovq\t$0, %rbx";
        // case REALIGN:
        //     label = NonTerminal::get_new_label();
        //     label.pop_back();
        //     return  "\t\tcmpq\t$1, %rbx\n"s+
        //             "\t\tjne\t\t" + label + "\n"+   
        //             "\t\taddq\t$8, %rsp\n"+
        //             label+":";
    }
    return "";
}

void gen_x86(vector<vector<ThreeAC *>> &threeAC, symbol_table_global *global_symbol_table)
{
    initialize_available_regs();
    symbol_table *curr_symbol_table = global_symbol_table;
    x86_dump << ".data\n";
    x86_dump << ".text\n";
    x86_dump << "integer_format:\n\t\t.string \"%ld\\n\"\n";
    x86_dump << ".global main\n";
    for(auto &[str, str_label]: string_label){
        x86_dump << str_label << ":\n";
        x86_dump << "\t\t.string " << str << "\n";
    }
    for (auto &code_block : threeAC)
    {
        curr_symbol_table = global_symbol_table;
        vector<string> block_x86;
        for (int i=0;i<code_block.size();++i)
        {
            auto code = code_block[i];
            string arg1 = code->get_arg1(), arg2 = code->get_arg2(), result = code->get_result(), op = code->get_op();
            if(code->get_instruction_type() == FUNCLABEL){
                string func_name = code->get_result();
                func_name.pop_back();
                curr_symbol_table = global_symbol_table->lookup_function(func_name);
            }
            if(code->get_instruction_type() == CLASSFUNCLABEL){
                string class_func_name = code->get_result();
                int i=0;
                for(i=0;i<class_func_name.size();++i){
                    if(class_func_name[i] == '.') break;
                }
                string class_name = class_func_name.substr(0, i);
                string func_name = class_func_name.substr(i+1);
                func_name.pop_back();
                symbol_table_class* class_table = global_symbol_table->lookup_class(class_name);
                curr_symbol_table = class_table->lookup_function(func_name);
            }   
            block_x86.push_back(make_x86_instruction(code, curr_symbol_table));   
        }
        for(int i=0; i<block_x86.size(); ++i){
            x86_dump << block_x86[i] << "\n";
            if(i==2 && stack_allocation_size>0) x86_dump << "\t\tsubq\t$"+to_string(stack_allocation_size)+", %rsp\n";
        }
        if(stack_allocation_size > 0){
            //x86_dump << "\t\taddq\t$"+to_string(stack_allocation_size)+", %rsp";
            curr_symbol_table->set_offset(curr_symbol_table->get_offset()-stack_allocation_size);
            stack_allocation_size = 0;
        }
        x86_dump << endl;
    }
}
    
void dfs(int v,vector<vector<int>> &adj, vector<ThreeAC*> &rescheduled_instructions, vector<ThreeAC*> &basic_block, vector<int> &vis) {
    if(vis[v]) return;
    vis[v] = 1;
    if(adj[v].size() == 2 && adj[adj[v][0]].size() < adj[adj[v][1]].size()) swap(adj[v][0], adj[v][1]);
    for(auto u:adj[v]){
        dfs(u,adj,rescheduled_instructions,basic_block,vis);
    }    
    rescheduled_instructions.push_back(basic_block[v]);
}
vector<ThreeAC*> reschedule_basic_block(vector<ThreeAC*> &basic_block, vector<vector<int>> &dependency_graph){
    vector<ThreeAC*> rescheduled_instructions;
    vector<int>vis(basic_block.size(),0);
    vector<ThreeAC*> dependent_instructions;
    for(int root=basic_block.size()-1;root>=0;root--){
        if(!vis[root]){
            dfs(root,dependency_graph,dependent_instructions,basic_block,vis);
            reverse(dependent_instructions.begin(), dependent_instructions.end());
            for(auto &code: dependent_instructions) rescheduled_instructions.push_back(code);
            dependent_instructions.clear();
        }
    }
    reverse(rescheduled_instructions.begin(), rescheduled_instructions.end());
    return rescheduled_instructions;
}
// vector<vector<int>> get_dependency_graph(vector<ThreeAC*> &threeAC);
vector<vector<int>> get_dependency_graph(vector<ThreeAC*> &threeAC){
    map<string,int> def_pos;
    int n=threeAC.size();
    vector<vector<int>> dependency_graph(n);
    for(int i=0;i<n;i++){
        string result = threeAC[i]->get_result(), arg1 = threeAC[i]->get_arg1(), arg2 = threeAC[i]->get_arg2(), op = threeAC[i]->get_op();
        if(result.size() > 1 && result[0] == '$' && result[1] == 't'){
            def_pos[result] = i;
        }
        if(arg1.size() > 1 && arg1[0] == '$' && arg1[1] == 't'){
            if(def_pos.find(arg1)!=def_pos.end()) dependency_graph[i].push_back(def_pos[arg1]);
            // else cout<<"code phat gya: Def of " << arg1 << " is not in current basic block\n";
        }
        if(arg2.size() > 1 && arg2[0] == '$' && arg2[1] == 't') {
            if(def_pos.find(arg2)!=def_pos.end()) dependency_graph[i].push_back(def_pos[arg2]);
            // else cout<<"code phat gya: Def of " << arg2 << " is not in current basic block\n";
        }
        if(result.size() > 2 && result[0] == '*' && result[1] == '$' && result[2] == 't'){
            string temp = result.substr(1);
            if(def_pos.find(temp)!=def_pos.end()) dependency_graph[i].push_back(def_pos[temp]);
            // else cout<<"code phat gya: Def of " << temp << " is not in current basic block\n";
        }
        if(arg1.size() > 2 && arg1[0] == '*' && arg1[1] == '$' && arg1[2] == 't'){
            string temp = arg1.substr(1);
            if(def_pos.find(temp)!=def_pos.end()) dependency_graph[i].push_back(def_pos[temp]);
            // else cout<<"code phat gya: Def of " << temp << " is not in current basic block\n";
        }
        if(arg2.size() > 2 && arg2[0] == '*' && arg2[1] == '$' && arg2[2] == 't'){
            string temp = arg2.substr(1);
            if(def_pos.find(temp)!=def_pos.end()) dependency_graph[i].push_back(def_pos[temp]);
            // else cout<<"code phat gya: Def of " << temp << " is not in current basic block\n";
        }
    }
    return dependency_graph;
}
vector<ThreeAC*> reschedule_block(vector<ThreeAC*> &threeAC)
{
    vector<ThreeAC*> rescheduled_threeAC;
    vector<ThreeAC*> basic_block;
    for(auto code: threeAC){
        string result = code->get_result(), arg1 = code->get_arg1(), arg2 = code->get_arg2(), op = code->get_op();
        basic_block.push_back(code);
        if(!((result.size() > 1 && result[0] == '$' && (result[1] == 't' || result[1] == 'T')) || (result.size() > 2 && result[0] == '*' && result[1] == '$' && (result[2] == 't' || result[2] == 'T')))){
            // cout<<"sz_bb"<<basic_block.size()<<' ';
            vector<vector<int>> dependency_graph = get_dependency_graph(basic_block);
            vector<ThreeAC*> rescheduled_bb = reschedule_basic_block(basic_block, dependency_graph);
            if(rescheduled_bb.size() != basic_block.size()){
                cout << "code phat gya" << endl;
            }
            for(auto bb_code: rescheduled_bb){
                rescheduled_threeAC.push_back(bb_code);
                // bb_code->print_raw();
            }
            // cout << endl;
            basic_block.clear();
        }
    }
    return rescheduled_threeAC;
}

    void add_len_function(symbol_table_global* global_symbol_table){
        symbol_table_function* len_func = global_symbol_table->create_new_function("len");
        Type type;
        type.datatype = "any";
        type.is_list = true;
        len_func->add_parameter("a", type, 0);
        len_func->insert("b", {"int"}, 0, 0);
        len_func->set_return_type({"int"});
                                                           
        auto len = new NonTerminal(0, "len");
        len->gen("len:", FUNCLABEL);
        // len->gen("begin function");
        len->gen("pushq", "%rbp",PUSH);
        len->gen("mov","%rsp","%rbp",MOV);
        len->gen("%rsp","%rsp","-",to_string(16), EXPR);      
        // len->gen("%rsp","%rsp","-",to_string(12+56), EXPR);      
        // len->gen("mov48","regs","-56(%rbp)", MOV);

        len->gen("a","80(%rbp)", MOV);
        // len->gen("a","16(%rbp)");
        len->gen("$t0","a","-","8",EXPR);
        // len->gen("$t0","a",MOV);
        len->gen("%rax", "*$t0", MOV);
        // len->gen("%rax","$t1",MOV);
        // len->gen("movq","b","%rax", MOV);
        // len->gen("mov48","-56(rbp)","regs", MOV);
        len->gen("mov8","%rbp","%rsp", MOV);
        len->gen("popq", "%rbp", POP);
        len->gen("ret", RET);
        // len->gen("end function");
        
        threeAC.push_back(len->get_code());
    }

    bool is_compatible_datatype(Type type_l, Type type_r)
    {
        if(type_l.is_list && type_r.is_list) 
        {
            if(type_l.datatype == type_r.datatype || type_l.datatype == "any"|| type_r.datatype == "any") 
            return true;
            else
            return false;
        }
        if((type_l.is_class || type_l.is_list || type_l.datatype == "str") && type_r.datatype == "None") return true;
        if((type_l.datatype=="any"||type_r.datatype=="any")&&type_r.is_list&&type_l.is_list) return true;
        if(type_l.is_list != type_r.is_list) return false;
        if(type_l.datatype == type_r.datatype) return true;
        if((type_l.datatype == "int" || type_l.datatype == "float" || type_l.datatype == "bool") && (type_r.datatype == "int" || type_r.datatype == "float" || type_r.datatype == "bool"))
        { 
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
        else if(type.datatype == "int" || type.datatype == "float") return 8;
        else if(type.datatype == "bool") return 8;
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
            auto datatype=curr_function.top()->get_parameter_type_from_end(top - curr_function.top()->is_first_argument_self());
            if(!is_compatible_datatype(datatype,arg->get_datatype())){
                int arg_index = function_arg_counter.top() + 1 - curr_function.top()->is_first_argument_self();
                cout<<"Datatypes of " << arg_index << (arg_index == 1 ? "st" : arg_index == 2 ? "nd" : "th") << " actual ("<<arg->get_datatype().datatype<<(arg->get_datatype().is_list?"[]":"")<<") and formal argument ("<<datatype.datatype<<(datatype.is_list?"[]":"")<<") of function " <<curr_function.top()->get_name() <<" are incompatible at line no: " << arg->get_line_no() << endl;
                exit(1);
            }
            if(datatype.datatype == "bool" && arg->get_datatype().datatype =="int" )
            {
                auto temp = arg->get_temporary();
                arg->gen(arg->set_temporary(), temp, "!=", "0", EXPR);
            }
        }
        auto datatype=arg->get_datatype();
        if(is_print_function.top()) 
        {
            if(arg->get_datatype().datatype == "int" || arg->get_datatype().datatype == "bool")
            {
                arg->gen("movq", arg->get_temporary(), "%rsi", MOV);
            }
            else if (arg->get_datatype().datatype == "str")
            {
                arg->gen("movq", arg->get_temporary(), "%rdi", MOV);
            }
            // arg->gen("movq", arg->get_temporary(), "%rsi", MOV);
        }
        arg->push_function_arg(arg->get_temporary());
        // else arg->gen("push"+to_string(calculate_size(datatype,false)), arg->get_temporary(), PUSH);
    }
    void relate_string(NonTerminal* result, NonTerminal* str1, NonTerminal* str2, string operation)
    {
        // result->gen("pushq", str2->get_temporary(), PUSH);
        // result->gen("pushq", str1->get_temporary(), PUSH);
        result->gen("movq", str1->get_temporary(), "%rdi", MOV);
        result->gen("movq", str2->get_temporary(), "%rsi", MOV);

        result->gen("call", "strcmp", "2", CALL);
        auto temp = NonTerminal::get_new_temporary();
        // auto temp1 = NonTerminal::get_new_temporary();
        // result->gen("%rsp", "%rsp", "+", "16",EXPR);
        result->gen("movsx", "%eax", "%rax", MOVSX);
        result->gen(temp, "%rax",MOV);
        if(operation=="==")
        {
            result->gen(result->set_temporary(), temp, "==", "0",EXPR);
        }
        else if(operation=="!=")
        {
            result->gen(result->set_temporary(), temp, "!=", "0",EXPR);
        }
        else if (operation =="<")
        {
            result->gen(result->set_temporary(), temp, "<", "0",EXPR);
            // auto temp1 = NonTerminal::get_new_temporary();
            // auto temp2 = NonTerminal::get_new_temporary();
            // auto temp3 = NonTerminal::get_new_temporary();
            // result->gen(temp1, "1", "<<", "31", EXPR);
            // result->gen(temp2, temp1, "&", temp, EXPR);
            // result->gen(temp3, temp2, ">>", "31", EXPR);
            // if(operation == "<") result->set_temporary(temp3, EXPR);
            // else result->gen(result->set_temporary(), "not", temp3, EXPR);
        }
        else if (operation ==">")
        {
            result->gen(result->set_temporary(), temp, ">", "0",EXPR);
            
        }
        else if (operation =="<=")
        {
            result->gen(result->set_temporary(), temp, "<=", "0",EXPR);
        }
        else if (operation ==">=")
        {
            result->gen(result->set_temporary(), temp, ">=", "0",EXPR);
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
%type<nonTerminal> file_input newline_or_stmt_one_or_more funcdef parameters typedargslist stmts stmt simple_stmt small_stmt expr_stmt small_stmt_semicolon_sep expr_3_or equal_testlist_star_expr testlist_star_expr augassign flow_stmt return_stmt compound_stmt if_stmt elif_namedexpr_test_colon_suite_one_or_more while_stmt for_stmt suite namedexpr_test test or_test and_test_star and_test and_not_test_plus not_test not_plus_comparison comparison comp_op_expr_plus comp_op expr r_expr xor_expr x_expr and_expr a_expr shift_expr lr_shift arith_expr pm_term term op_fac factor power atom_expr atom string_one_or_more testlist_comp comma_named_star_comma named_star_or comma_named_star  exprlist  testlist classdef arglist comma_arg argument func_body_suite func_return_type global_stmt funcdef_head open_bracket open_paren
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
                                                            // $$->gen("realign", REALIGN);     
                                                            $$->gen("pushq", "%rbp",PUSH);
                                                            $$->gen("%rbp","%rsp",MOV);
                                                            $$->copy_code($2);
                                                            //wrong need to subtract the of
                                                            $$->gen("%rsp","%rsp","-",to_string(((curr_symbol_table->get_offset()-1)/16 +1)*16),EXPR);      
                                                            // $$->gen("mov48","regs","-56(rbp)",MOV);                                    
                                                            $$->copy_code($4);
                                                            if($4->get_has_return_stmt()==false)
                                                            {
                                                                // $$->gen("mov48","-56(rbp)","regs", MOV);
                                                                $$->gen("mov8","%rbp","%rsp", MOV);
                                                                $$->gen("popq", "%rbp", POP);
                                                                $$->gen("ret",RET);
                                                                // $$->gen("end function");
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
                                                                        $$->gen("pushq", "%rbp", PUSH);
                                                                        $$->gen("%rbp","%rsp",MOV);
                                                                        $$->copy_code($2);
                                                                        $$->gen("%rsp","%rsp","-",to_string(((curr_symbol_table->get_offset()-1)/16 +1)*16),EXPR);
                                                                        // $$->gen("mov48","regs","-56(rbp)", MOV);
                                                                        $$->copy_code($5);
                                                                        if($5->get_has_return_stmt()==false)
                                                                        {
                                                                            if(curr_symbol_table->get_return_type().datatype == "None"){
                                                                                // $$->gen("mov48","-56(rbp)","regs", MOV);
                                                                                $$->gen("mov8","%rbp","%rsp", MOV);
                                                                                $$->gen("popq", "%rbp", POP);
                                                                                $$->gen("ret", RET);
                                                                                // $$->gen("end function");
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
                                $$->gen(curr_symbol_table->get_name()+ "." + $2->get_lexeme() + ":", CLASSFUNCLABEL);
                            }
                            else 
                            {
                                $$->gen($2->get_lexeme()+":", FUNCLABEL);
                            }
                            // $$->gen("begin function");
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
                                        // $$->gen("movq", "%rbx", "%rcx",MOV);
                                        // $$->gen("%rcx", "%rcx", "+", to_string(offset + 16 + 64), EXPR);
                                        // $$->gen("%rcx", "%rcx", "+", "%rbp", EXPR);
                                        // $$->gen("movq", "(%rcx)", "%rcx", MOV);
                                        // $$->gen("movq", "%rcx", $1->get_lexeme(), MOV);

                                        $$->gen("movq"+to_string(calculate_size(*$3,false)),to_string(offset + 16 + 64)+"(%rbp)",$1->get_lexeme(), MOV);
                                        curr_symbol_table->add_parameter($1->get_lexeme(),*$3,$1->get_line_no());
                                        
                                    }
| typedargslist COMMA NAME COLON datatype   {
                                                
                                                auto offset= curr_symbol_table->get_offset();
                                                $$ = $1;
                                                // $$->gen("movq", "%rbx", "%rcx",MOV);
                                                // $$->gen("%rcx", "%rcx", "+", to_string(offset + 16 + 64), EXPR);
                                                // $$->gen("%rcx", "%rcx", "+", "%rbp", EXPR);
                                                // $$->gen("movq", "(%rcx)", "%rcx", MOV);
                                                // $$->gen("movq", "%rcx", $1->get_lexeme(), MOV);
                                                $$->gen("mov"+to_string(calculate_size(*$5,false)),to_string(offset + 16 + 64)+"(%rbp)",$3->get_lexeme(), MOV);
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
            // $$->gen("movq", "%rbx", "%rcx",MOV);
            // $$->gen("%rcx", "%rcx", "+", to_string(offset + 16 + 64), EXPR);
            // $$->gen("%rcx", "%rcx", "+", "%rbp", EXPR);
            // $$->gen("movq", "(%rcx)", "%rcx", MOV);
            // $$->gen("movq", "%rcx", $1->get_lexeme(), MOV);
            $$->gen("mov8",to_string(offset+16+64)+"(%rbp)",$1->get_lexeme(), MOV);
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
                                                    exit(-1);
                                                }

                                            }
                                            else if($2->compare_datatype_expr3or($1->get_datatype())==0)
                                            {
                                                cout << "Incompatible operator " << $2->get_operator() << " with operands of type " << $1->get_datatype().datatype<<($1->get_datatype().is_list?"[]":"") << " and " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"")  << " at line no: " << $2->get_line_no() << endl;
                                                exit(0);
                                            }

                                            $$=$2;
                                            auto temp_2 = $$->get_temporary();
                                            // $$->copy_code($1);
                                            if($$->get_operator_type_augassign() == 0){ // assignment case
                                                if($1->get_datatype().is_list)
                                                {
                                                    $$->set_temporary($1->get_temporary());
                                                    auto type = $1->get_datatype();
                                                    type.is_list = false;
                                                    if($2->get_is_list_initializer())
                                                    {
                                                        auto temp = $$->gen_list_code1(calculate_size(type,true));
                                                        $$->copy_code($1);
                                                        $$->gen($$->get_temporary(), temp, MOV);
                                                        $$->gen_list_code2(calculate_size(type,false),list_expr_code,temp);
                                                    }
                                                    else
                                                    {
                                                        $$->copy_code($1);
                                                        $$->gen($1->get_temporary(), temp_2, MOV);
                                                    }
                                                    
                                                    list_expr_code.clear();
                                                    // cout<<"lkl"<<endl;
                                                    
                                                }
                                                else{
                                                    $$->copy_code($1);
                                                    if($1->get_datatype().datatype == "bool"){
                                                        auto bool_temp = NonTerminal::get_new_temporary();
                                                        $$->gen(bool_temp, $2->get_temporary(), "!=" , "0", EXPR);
                                                        $$->gen($1->get_temporary(), bool_temp, MOV);
                                                    }
                                                    else $$->gen($1->get_temporary(),$2->get_temporary(),MOV);
                                                }
                                            }
                                            else{   // augmented assignment case
                                                $$->copy_code($1);
                                                if($1->get_datatype().is_list){
                                                    cout << "Augmented assignment with operator " << $2->get_operator() << " is not possible for lists at line no: " << $2->get_line_no() << endl;
                                                    exit(-1);
                                                }
                                                string op = op_3AC.top();
                                                op.pop_back();
                                                auto temp = NonTerminal::get_new_temporary();
                                                string temp1 = $1->get_temporary();
                                                auto temp2 = NonTerminal::get_new_temporary();
                                                temp2[1] = 'T';
                                                if(temp1[0] == '*'){
                                                    $$->gen(temp2, temp1.substr(1), MOV);
                                                    $$->gen(temp, "*"+temp2, op, $2->get_temporary(), EXPR);
                                                    if($1->get_datatype().datatype == "bool"){
                                                        auto bool_temp = NonTerminal::get_new_temporary();
                                                        $$->gen(bool_temp, temp, "!=" , "0", EXPR);
                                                        $$->gen("*"+temp2, bool_temp, MOV);
                                                    }
                                                    else $$->gen("*"+temp2, temp, MOV);
                                                }
                                                else{
                                                    $$->gen(temp, $1->get_temporary(), op, $2->get_temporary(), EXPR);
                                                    if($1->get_datatype().datatype == "bool"){
                                                        auto bool_temp = NonTerminal::get_new_temporary();
                                                        $$->gen(bool_temp, temp, "!=" , "0", EXPR);
                                                        $$->gen($1->get_temporary(), bool_temp, MOV);
                                                    }
                                                    else $$->gen($1->get_temporary(),temp,MOV);
                                                }                               
                                                
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
                                                    
                                                    if($3->is_list){
                                                        $$->set_temporary($1->get_lexeme());
                                                        auto type = *$3;
                                                        type.is_list = false;
                                                        if($5->get_is_list_initializer())
                                                        {
                                                            auto temp = $$->gen_list_code1(calculate_size(type,true));
                                                            $$->gen($$->get_temporary(), temp, MOV);
                                                            $$->gen_list_code2(calculate_size(type,false),list_expr_code,temp);
                                                        }
                                                        else
                                                        {
                                                            $$->copy_code($5);
                                                            $$->gen($$->get_temporary(), $5->get_temporary(), MOV);
                                                        }
                                                        list_expr_code.clear();
                                                    }
                                                    else{
                                                        $$->copy_code($5);
                                                        if($3->datatype == "bool"){
                                                            auto bool_temp = NonTerminal::get_new_temporary();
                                                            $$->gen(bool_temp, $5->get_temporary(), "!=" , "0", EXPR);
                                                            $$->gen($1->get_lexeme(), bool_temp, MOV);
                                                        }
                                                        else $$->gen($1->get_lexeme(), $5->get_temporary(),MOV);
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
                                                            // $$ = $1;
                                                            $$=new NonTerminal($1->get_line_no());
                                                            if(debug) printf("here3\n");
                                                            $$->copy_cur_temp($7);
                                                            if($5->is_list){
                                                                $$->set_temporary($1->get_lexeme());
                                                                auto type = *$5;
                                                                type.is_list = false;
                                                                $$->copy_code($1);
                                                                if($7->get_is_list_initializer())
                                                                {
                                                                    auto temp = $$->gen_list_code1(calculate_size(type,true));
                                                                    auto temp2 = NonTerminal::get_new_temporary();
                                                                    $$->gen(temp2, $1->get_temporary(), "+", to_string(offset),EXPR);
                                                                    $$->gen("*"+temp2, temp, MOV);
                                                                    $$->gen_list_code2(calculate_size(type,false),list_expr_code,temp);
                                                                }
                                                                else
                                                                {
                                                                    $$->copy_code($7);
                                                                    auto temp = NonTerminal::get_new_temporary();
                                                                    $$->gen(temp, $1->get_temporary(), "+", to_string(offset),EXPR);
                                                                    $$->gen("*"+temp, $7->get_temporary(), MOV);
                                                                }
                                                                
                                                                list_expr_code.clear();
                                                            }
                                                            else{
                                                                $$->copy_code($1);
                                                                $$->set_temporary($1->get_temporary());
                                                                $$->copy_code($7);
                                                                auto temp = NonTerminal::get_new_temporary();
                                                                $$->gen(temp, $1->get_temporary(), "+", to_string(offset),EXPR);
                                                                if($5->datatype == "bool"){
                                                                    auto bool_temp = NonTerminal::get_new_temporary();
                                                                    $$->gen(bool_temp, $7->get_temporary(), "!=" , "0", EXPR);
                                                                    $$->gen("*"+temp, bool_temp, MOV);
                                                                }
                                                                else $$->gen("*"+temp, $7->get_temporary(),MOV);
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
    // $$->gen("popq","%rdx",POP);
    $$ = $1; $$->gen("goto", curr_loop_end_jump_label.top(),GOTO); }
| CONTINUE {
    $$=$1;
    if(curr_loop_start_jump_label.size()==0)
    {
        cout << "Continue statement is not inside any loop at line no: " << $1->get_line_no() << endl; 
        exit(-1);
    }    
    $$->gen("goto", curr_loop_start_jump_label.top(),GOTO);
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
                        // $$->gen("mov48","-56(rbp)","regs", MOV);
                        $$->gen("mov8","%rbp","%rsp", MOV);
                        $$->gen("popq", "%rbp", POP);
                        $$->gen("ret",RET);
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
    if(curr_symbol_table->get_return_type().is_list==1&&$2->get_is_list_initializer()==true)
    {                    
        auto type=$2->get_datatype();      
        type.is_list=false;                          
        auto temp = $$->gen_list_code1(calculate_size(type,true));
        $2->set_temporary(temp);
        $$->gen_list_code2(calculate_size(type,false),list_expr_code,temp); 
        list_expr_code.clear();                                                       
    }
    if(curr_symbol_table->get_return_type().datatype == "bool" && $2->get_datatype().datatype == "int")
    {
        auto temp =$2->get_temporary();
        $$->gen($2->set_temporary(), temp, "!=", "0", EXPR);
    }
    $$->gen("%rax", $2->get_temporary(), MOV);
    // $$->gen("mov48","-56(rbp)","regs", MOV);
    $$->gen("mov8","%rbp","%rsp", MOV);
    $$->gen("popq", "%rbp", POP);
    $$->gen("ret",RET);
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
    $$->gen("if not", $2->get_temporary(), "goto", curr_if_end_jump_label.top(),IFNOT);
    $$->copy_code($4);
    $$->gen(curr_if_end_jump_label.top(),LABEL);
    curr_if_end_jump_label.pop();                                                
}
| if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more {
    $$=new NonTerminal($2->get_line_no(), "If");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", $2->get_temporary(), "goto", label_elif,IFNOT);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top(),GOTO);
    $$->gen(label_elif,LABEL);
    $$->copy_code($5);
    $$->gen(curr_if_end_jump_label.top(),LABEL);
    curr_if_end_jump_label.pop();
}
| if_head namedexpr_test COLON suite ELSE COLON suite  {
    $$=new NonTerminal($2->get_line_no(), "If");
    $$->copy_code($2);
    string label_else = NonTerminal::get_new_label();
    $$->gen("if not", $2->get_temporary(), "goto", label_else,IFNOT);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top(),GOTO);
    $$->gen(label_else,LABEL);
    $$->copy_code($7);
    $$->gen(curr_if_end_jump_label.top(),LABEL);
    if($4->get_has_return_stmt() && $7->get_has_return_stmt()) $$->set_has_return_stmt(true);
    curr_if_end_jump_label.pop();
}
| if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more ELSE COLON suite {
    $$=new NonTerminal($2->get_line_no(), "If");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", $2->get_temporary(), "goto", label_elif,IFNOT);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top(),GOTO);
    $$->gen(label_elif,LABEL);
    $$->copy_code($5);
    $$->copy_code($8);
    $$->gen(curr_if_end_jump_label.top(),LABEL);
    if($4->get_has_return_stmt() && $5->get_has_return_stmt() && $8->get_has_return_stmt()) $$->set_has_return_stmt(true);
    curr_if_end_jump_label.pop();
}
;


elif_namedexpr_test_colon_suite_one_or_more: ELIF namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more  {
    $$=new NonTerminal($2->get_line_no(), "elif");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", $2->get_temporary(), "goto", label_elif,IFNOT);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top(),GOTO);
    $$->gen(label_elif,LABEL);
    $$->copy_code($5);
    $$->set_has_return_stmt($4->get_has_return_stmt() && $5->get_has_return_stmt());
}
| ELIF namedexpr_test COLON suite {
    $$=new NonTerminal($2->get_line_no(), "elif");
    $$->copy_code($2);
    string label_elif = NonTerminal::get_new_label();
    $$->gen("if not", $2->get_temporary(), "goto", label_elif,IFNOT);
    $$->copy_code($4);
    $$->gen("goto", curr_if_end_jump_label.top(),GOTO);
    $$->gen(label_elif,LABEL);
    $$->set_has_return_stmt($4->get_has_return_stmt());
    }
;

while_stmt: while_head namedexpr_test COLON suite  {
    $$=new NonTerminal($2->get_line_no(), "While");

    string label_start = curr_loop_start_jump_label.top();
    // $$->gen("pushq","0",PUSH);
    $$->gen_new_label(label_start);
    $$->copy_code($2);

    curr_loop_start_jump_label.pop();
    string label_end = curr_loop_end_jump_label.top();
    curr_loop_end_jump_label.pop();
    $$->gen("if not", $2->get_temporary(), "goto", label_end,IFNOT);
    $$->copy_code($4);
    $$->gen("goto", label_start, GOTO);
    $$->gen_new_label(label_end);
    // $$->gen("popq","%rdx",POP);
}
|while_head namedexpr_test COLON suite ELSE COLON suite {
    $$=new NonTerminal($2->get_line_no(), "While");
    string label_start = curr_loop_start_jump_label.top();
    curr_loop_start_jump_label.pop();
    // $$->gen("pushq","0",PUSH);
    $$->gen_new_label(label_start);
    $$->copy_code($2);

    string label_end = curr_loop_end_jump_label.top();
    curr_loop_end_jump_label.pop();
    $$->gen("if not", $2->get_temporary(), "goto", label_end,IFNOT);
    $$->copy_code($4);
    $$->gen("goto", label_start, GOTO);
    $$->gen_new_label(label_end);
    // $$->gen("popq","%rdx",POP);

    $$->copy_code($7);
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
        // $$->gen("pushq",$8->get_temporary(),PUSH);
        $$->gen($2->get_temporary(), $6->get_temporary(), "-", "1",EXPR);
        string loop_end_cond_temp = NonTerminal::get_new_temporary();
        loop_end_cond_temp[1] = 'T';
        $$->gen(loop_end_cond_temp, $8->get_temporary(), MOV);
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label_start);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1",EXPR);
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        auto cond_temp = NonTerminal::get_new_temporary();
        $$->gen(cond_temp, $2->get_temporary(), ">=", loop_end_cond_temp, EXPR);
        auto temp_end_label = NonTerminal::get_new_label();
        $$->gen("if", cond_temp, "goto", temp_end_label,IFGOTO);
        $$->copy_code($11);
        $$->gen("goto", label_start,GOTO);
        $$->gen_new_label(temp_end_label);
        $$->gen($2->get_temporary(), $2->get_temporary(), "-", "1", EXPR);
        $$->gen_new_label(label_end);
        // $$->gen("popq","%rdx",POP);
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
        // $$->gen("pushq",$6->get_temporary(),PUSH);
        auto init_temp = NonTerminal::get_new_temporary();
        $$->gen(init_temp, "0", "-", "1", EXPR);
        $$->gen($2->get_temporary(), init_temp,MOV);
        string loop_end_cond_temp = NonTerminal::get_new_temporary();
        loop_end_cond_temp[1] = 'T';
        $$->gen(loop_end_cond_temp, $6->get_temporary(), MOV);
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label_start);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1",EXPR);
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        auto cond_temp = NonTerminal::get_new_temporary();
        $$->gen(cond_temp, $2->get_temporary(), ">=", loop_end_cond_temp, EXPR);
        auto temp_end_label = NonTerminal::get_new_label();
        $$->gen("if", cond_temp, "goto", temp_end_label,IFGOTO);
        $$->copy_code($9);
        $$->gen("goto", label_start,GOTO);
        $$->gen_new_label(temp_end_label);
        $$->gen($2->get_temporary(), $2->get_temporary(), "-", "1",EXPR);
        $$->gen_new_label(label_end); 
        // $$->gen("popq","%rdx",POP);
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
        // $$->gen("pushq",$6->get_temporary(),PUSH);
        auto init_temp = NonTerminal::get_new_temporary();
        $$->gen(init_temp, "0", "-", "1", EXPR);
        $$->gen($2->get_temporary(), init_temp,MOV);
        string loop_end_cond_temp = NonTerminal::get_new_temporary();
        loop_end_cond_temp[1] = 'T';
        $$->gen(loop_end_cond_temp, $6->get_temporary(), MOV);
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label_start);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1",EXPR);
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        auto cond_temp = NonTerminal::get_new_temporary();
        $$->gen(cond_temp, $2->get_temporary(), ">=", loop_end_cond_temp, EXPR);
        auto temp_end_label = NonTerminal::get_new_label();
        $$->gen("if", cond_temp, "goto", temp_end_label,IFGOTO);
        $$->copy_code($9);
        $$->gen("goto", label_start,GOTO);
        $$->gen_new_label(temp_end_label);
        
        $$->gen($2->get_temporary(), $2->get_temporary(), "-", "1",EXPR);
        $$->gen_new_label(label_end);
        // $$->gen("popq","%rdx",POP);
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
        // $$->gen("pushq",$8->get_temporary(),PUSH);
        $$->gen($2->get_temporary(), $6->get_temporary(), "-", "1",EXPR);
        string loop_end_cond_temp = NonTerminal::get_new_temporary();
        loop_end_cond_temp[1] = 'T';
        $$->gen(loop_end_cond_temp, $8->get_temporary(), MOV);
        auto label = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        $$->gen_new_label(label);
        $$->gen($2->get_temporary(), $2->get_temporary(), "+", "1",EXPR);
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        auto cond_temp = NonTerminal::get_new_temporary();
        $$->gen(cond_temp, $2->get_temporary(), ">=", loop_end_cond_temp, EXPR);
        auto temp_end_label = NonTerminal::get_new_label();
        $$->gen("if", cond_temp, "goto", temp_end_label ,IFGOTO);
        $$->copy_code($11);
        $$->gen("goto", label,GOTO);
        $$->gen_new_label(temp_end_label);
        $$->gen($2->get_temporary(), $2->get_temporary(), "-", "1", EXPR);
        $$->gen_new_label(label_end);
        // $$->gen($2->get_temporary(), $2->get_temporary(), "-", "1", EXPR);
        // $$->gen("popq","%rdx",POP);
        
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
    $$->gen($1->get_temporary(), $3->get_temporary(), MOV);
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
    $$->gen($$->set_temporary(), old_temp, "or", $2->get_temporary(), EXPR);  
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
    $$->gen($$->set_temporary(), old_temp, "or", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "and", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "and", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), "not", old_temp, EXPR);  /*TODO: is "not" as operator fine?, EXPR*/
}
| NOT not_plus_comparison   {
    $$ = $2;
    $$->set_datatype({"bool",false});
    
    auto old_temp = $2->get_temporary();
    $$->gen($$->set_temporary(), "not", old_temp, EXPR);  /*TODO: is "not" as operator fine?, EXPR*/
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "|", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "|", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "^", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "^", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "&", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, "&", $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp, op_3AC.top(), $2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp,op_3AC.top(),$2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(), old_temp,op_3AC.top(),$2->get_temporary(), EXPR);
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
    $$->gen($$->set_temporary(),old_temp,op_3AC.top(),$2->get_temporary(), EXPR);
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

    auto old_temp = $2->get_temporary();
    $$->gen($$->set_temporary(),"-",old_temp, UNARYEXPR);

}
| BITWISE_NOT factor   {$$ =$2;
    $$->set_is_lvalue(false);
    auto datatype=$2->get_datatype();
    if(!(!datatype.is_list && (datatype.datatype == "int" || datatype.datatype == "float" || datatype.datatype == "bool"))){
        cout << "Unary ~ operator cannot be applied for datatype " << $2->get_datatype().datatype<<($2->get_datatype().is_list?"[]":"") <<  " on line no: "<<$1->get_line_no() << endl;
        exit(-1);
    }
    $$->set_datatype(datatype);

    auto old_temp = $2->get_temporary();
    $$->gen($$->set_temporary(),"~",old_temp, UNARYEXPR);
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
    $$->gen($$->set_temporary(),temp,"**",$3->get_temporary(), EXPR);
    
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
    $$->gen($$->set_temporary(),temp,"**",$3->get_temporary(), EXPR);
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
            $$->gen($$->set_temporary(),$1->get_temporary(),"+",to_string(entry->get_offset()), EXPR);
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
            $$->gen($$->set_temporary(),$1->get_temporary(),"+",to_string(entry->get_offset()), EXPR);
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
        $$->gen($$->set_temporary(),$3->get_temporary(),"*",to_string(calculate_size(type,false)), EXPR);
        auto old_temp = $$->get_temporary();
        $$->gen($$->set_temporary(),$1->get_temporary(),"+",old_temp, EXPR);
        if($$->get_temporary()[0] == '*'){
            string new_temp = NonTerminal::get_new_temporary();
            $$->gen(new_temp, $$->get_temporary(), MOV);
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
        $$->gen($$->set_temporary(),$3->get_temporary(),"*",to_string(calculate_size(type,false)), EXPR);
        auto old_temp = $$->get_temporary();
        $$->gen($$->set_temporary(),$1->get_temporary(),"+",old_temp, EXPR);
        if($$->get_temporary()[0] == '*'){
            string new_temp = NonTerminal::get_new_temporary();
            $$->gen(new_temp, $$->get_temporary(), MOV);
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
        // $$->copy_function_args($3);
        // $$->gen_push_args();
        // $$->gen("stackpointer", "+xxx");

        // $$->gen("align", "16", ALIGN);
        if($3->get_datatype().datatype == "int" || $3->get_datatype().datatype == "bool")
        $$->gen("call", "print", "1", CALL);
        else if($3->get_datatype().datatype == "str")
        $$->gen("call","print_str","1",CALL);
        // $$->gen("%rsp","%rsp","+",to_string(calculate_size($3->get_datatype(),false)), EXPR); 
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
        $$->copy_function_args($3);
        // $$->gen_push_args();
        bool set = false;
        if(type.function_table->is_first_argument_self())
        {
            if($1->get_temporary() == "" && type.function_table->get_name()=="__init__"){
                // $$->gen("pushq", to_string(type.function_table->get_parent_st()->get_offset()), PUSH);
                // $$->gen("stackpointer", "+xxx");
                $$->gen("movq", to_string(type.function_table->get_parent_st()->get_offset()), "%rdi", MOV);
                $$->gen("call", "malloc", "1", CALL);
                // $$->gen("%rsp", "%rsp","+","4", EXPR);
                auto temp2 = NonTerminal::get_new_temporary();
                temp2[1] = 'T';
                $$->set_temporary(temp2);
                $$->gen(temp2, "%rax", MOV);
                if(type.function_table->get_parameter_count() % 2 == 0){
                    $$->gen("pushq", "0", PUSH);
                    set = true;
                }
                $$->gen_push_args();
                $$->gen("pushq", $$->get_temporary(), PUSH);
            }
            else {
                if(type.function_table->get_parameter_count() % 2 == 0){
                    $$->gen("pushq", "0", PUSH);
                    set = true;
                }
                $$->gen_push_args();
                $$->gen("pushq",$1->get_temporary(), PUSH);
                }
        }
        else
        {
            if(type.function_table->get_parameter_count() % 2 !=0)
            {
                $$->gen("pushq", "0", PUSH);
                set = true;
            }
            $$->gen_push_args();
        }
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        // $$->gen("align", "16", ALIGN);
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), to_string(top2), CALL);
        }
        else
        {
            $$->gen("call", type.function_table->get_name(), to_string(top2), CALL);
        } 
        // if(type.function_table->get_name() == "__init__"){
        //     $$->gen($$->set_temporary(), "(%rsp)", MOV);
        // }  
        $$->gen("%rsp", "%rsp", "+", to_string(type.function_table->get_agrument_size() + set*8), EXPR);
        if(curr_return_type.top().datatype != "None" && type.function_table->get_name()!="__init__"){
            $$->gen($$->set_temporary(), "%rax", MOV);
        }
        curr_return_type.pop();
        curr_function.pop();  
    }
    function_arg_counter.pop();
    is_print_function.pop();
    $$->clear_func_args();
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
        bool set = false;
        $$ = new NonTerminal($3->get_line_no(), curr_return_type.top());
        $$->copy_code($1);
        if($1->get_temporary() == "" && type.function_table->get_name()=="__init__"){
            // $$->gen("pushq", to_string(type.function_table->get_parent_st()->get_offset()), PUSH);
            // $$->gen("stackpointe", "+xxx");
            $$->gen("movq", to_string(type.function_table->get_parent_st()->get_offset()), "%rdi", MOV);
            $$->gen("call", "malloc", "1", CALL);
            // $$->gen("%rsp", "%rsp","+","4", EXPR);
            auto temp2 = NonTerminal::get_new_temporary();
            temp2[1] = 'T';
            $$->set_temporary(temp2);
            $$->gen(temp2, "%rax", MOV);
            $$->gen("pushq", "0", PUSH);
            set =true;
            $$->gen("pushq", $$->get_temporary(), PUSH);
        }
        else if(type.function_table->is_first_argument_self()) $$->gen("pushq",$1->get_temporary(), PUSH);
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        // $$->gen("align", "16", ALIGN);  
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), "1", CALL);
        }
        else
        {
            $$->gen("call", type.function_table->get_name(), "0", CALL);
        }
        // if(type.function_table->get_name() == "__init__"){
        //     $$->gen($$->set_temporary(), "(%rsp)", MOV);
        // }       
        $$->gen("%rsp", "%rsp", "+", to_string(type.function_table->get_agrument_size() + set*8),EXPR);
        if(curr_return_type.top().datatype != "None" && type.function_table->get_name()!="__init__")
            $$->gen($$->set_temporary(), "%rax", MOV);
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
    bool set =false;
    if(type.function_table->is_first_argument_self())
    {
        // $$->gen("align","8",ALIGN);
        $$->gen("pushq","0",PUSH);
        set = true;
        $$->gen("pushq",$1->get_temporary(), PUSH);
    }
    // $$->gen("stackpointer", "+xxx");
    auto parent_sym_table= type.function_table->get_parent_st();
    // $$->gen("align", "16", ALIGN);
    if(parent_sym_table->get_symbol_table_type()==2)
    {
        $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), "1", CALL);
    }
    else
    {
        $$->gen("call", type.function_table->get_name(), "0", CALL);
    }       
    $$->gen("%rsp", "%rsp", "+", to_string(type.function_table->get_agrument_size() + set*8),EXPR);
    if(curr_return_type.top().datatype != "None")
        $$->gen($$->set_temporary(), "%rax", MOV);
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
        $$->copy_function_args($3);
        // $$->gen_push_args();
        bool set = false;
        if(type.function_table->is_first_argument_self())
        {
            if(type.function_table->get_parameter_count()%2==0)
            {
                set = true;
                $$->gen("pushq", "0", PUSH);
            }
            $$->gen_push_args();
            $$->gen("pushq",$1->get_temporary(), PUSH);
        }
        else 
        {
            if(type.function_table->get_parameter_count()%2!=0)
            {
                set = true;
                $$->gen("pushq", "0", PUSH);
            }
            $$->gen_push_args();
        }
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        // $$->gen("align", "16", ALIGN);
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            $$->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), to_string(top2), CALL);
        }
        else
        {
            $$->gen("call", type.function_table->get_name(), to_string(top2), CALL);
        }       
        $$->gen("%rsp", "%rsp", "+", to_string(type.function_table->get_agrument_size()+8*set),EXPR);
        if(curr_return_type.top().datatype != "None")
            $$->gen($$->set_temporary(), "%rax", MOV); 
        curr_return_type.pop();
        curr_function.pop(); 
        function_arg_counter.pop();  
        is_print_function.pop();
        $$->clear_func_args();
}
;

open_bracket: OPEN_BRACKET  {
    is_list_expr_code.push(true);
}

open_paren: OPEN_PAREN  {
    is_list_expr_code.push(false);
}

atom: open_paren testlist_comp CLOSE_PAREN  {
    $$=$2;
    $$->clear_curr_list_temporaries();
    $$->set_is_list_initializer(false);
    is_list_expr_code.pop();
}
| OPEN_PAREN CLOSE_PAREN    {$$=new NonTerminal($2->get_line_no(),{"",false,false,false,nullptr,nullptr}); }
| open_bracket testlist_comp CLOSE_BRACKET  {
    $$=$2;
    $$->set_list(true);
    $$->print_curr_list_temporaries();
    $$->set_is_list_initializer(true);
    is_list_expr_code.pop();
}
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
| NUMBER {$$=$1;$$->set_datatype({"int",false}); $$->gen($$->set_temporary(),$$->get_lexeme(), MOV);}
| string_one_or_more    {$$=$1;}
| NONE  {$$=$1;$$->set_datatype({"None",false}); $$->set_temporary("0");}
| TRUE_     {$$=$1;$$->set_datatype({"bool",false});$$->gen($$->set_temporary(),$$->get_lexeme(), MOV);}
| FALSE_    {$$=$1;$$->set_datatype({"bool",false});$$->gen($$->set_temporary(),$$->get_lexeme(),MOV) ;}
| REAL_NUMBER   {$$=$1;$$->set_datatype({"float",false});$$->gen($$->set_temporary(),$$->get_lexeme(), MOV);}
;


string_one_or_more: STRING    {
    $$=$1;
    if(string_label.find($1->get_lexeme()) == string_label.end()) string_label[$1->get_lexeme()] = get_new_string_label();
    $$->set_datatype({"str",false});
    auto temp = NonTerminal::get_new_temporary();
    temp[1] = 'T';
    $$->set_temporary(temp);
    $$->gen("leaq", string_label[$1->get_lexeme()]+"(%rip)", "%rdx", LEAQ);
    $$->gen(temp, "%rdx", MOV);
}
;

testlist_comp: named_star_or comma_named_star_comma {
    // cout<<"line 2918\n"<<$1->get_datatype().datatype<<endl;
    // cout<<"line 2919\n"<<$2->get_datatype().datatype<<endl;
    if($2->get_datatype().datatype == "COMMA"){
        $$ =$1;
    }
    else{
        $$ = $1;
        if($1->get_datatype().is_class&&$2->get_datatype().is_class){
            // cout<<"cdwji"<<$1->get_datatype().datatype<<endl;
            symbol_table_class* class_table1 =$1->get_datatype().class_table;
            symbol_table_class* class_table2 =$2->get_datatype().class_table;
            while(class_table1!=nullptr && class_table1->get_name()!=class_table2->get_name()){
                class_table1=class_table1->get_parent_class();
            }
            if(class_table1==nullptr){
                class_table1 =$1->get_datatype().class_table;
               while(class_table2!=nullptr && class_table1->get_name()!=class_table2->get_name()){
                class_table2=class_table2->get_parent_class();
            }
            }
            if(class_table1==nullptr || class_table2==nullptr){
                cout << "Incompatible types at line no: " << $2->get_line_no() << endl;
                exit(-1);
            }
            else if(class_table1->get_name()!=class_table2->get_name()){
                cout << "Incompatible types at line no: " << $2->get_line_no() << endl;
                exit(-1);
            }
            else
            {
                $$->set_datatype($1->get_datatype());
            }
        //   cout<<"cdwji"<<$$->get_datatype().datatype<<endl;
        }
        else 
            $$->set_datatype($$->compare_datatype($2->get_datatype()));
        // cout<<$$->get_datatype().datatype<<endl;
        $$->copy_code($2);
        $$->copy_cur_temp($2);
    }
}
| named_star_or {
if(debug) 
   printf("here\n");
    $$ =$1;
}
;


comma_named_star_comma: comma_named_star COMMA  {$$=$1;}
| comma_named_star  {$$ = $1;}
| COMMA {$$ = $1;$$->set_datatype({"COMMA",false});}
;
named_star_or: namedexpr_test   {
    // cout<<"line 2970\n"<<$1->get_datatype().datatype<<endl;
    $$ =$1;
    $$->curr_list_temporaries_push($1->get_temporary());
    if(is_list_expr_code.top()) list_expr_code.push_back($$->get_code());
}
;

comma_named_star: COMMA named_star_or   {$$= $2; }
| comma_named_star COMMA named_star_or  {
    // cout<<"line 2980\n"<<$1->get_datatype().datatype<<$3->get_datatype().datatype<<endl;
    $$=$1; $$->copy_code($3);$$->curr_list_temporaries_push($3->get_temporary()); 
if($1->get_datatype().is_class&&$3->get_datatype().is_class){
            //  cout<<"cdwji"<<$1->get_datatype().datatype<<endl;
            symbol_table_class* class_table1 =$1->get_datatype().class_table;
            symbol_table_class* class_table2 =$3->get_datatype().class_table;
            while(class_table1!=nullptr && class_table1->get_name()!=class_table2->get_name()){
                class_table1=class_table1->get_parent_class();
            }
            if(class_table1==nullptr){
                class_table1 =$1->get_datatype().class_table;
               while(class_table2!=nullptr && class_table1->get_name()!=class_table2->get_name()){
                class_table2=class_table2->get_parent_class();
            }
            }
            if(class_table1==nullptr || class_table2==nullptr){
                cout << "Incompatible types at line no: " << $2->get_line_no() << endl;
                exit(-1);
            }
            else if(class_table1->get_name()!=class_table2->get_name()){
                cout << "Incompatible types at line no: " << $2->get_line_no() << endl;
                exit(-1);
            }
            else
            {
                $$->set_datatype($1->get_datatype());
            }
        //   cout<<"3006cdwji"<<$$->get_datatype().datatype<<endl;
        }
else $$->set_datatype($$->compare_datatype($3->get_datatype()));


}
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

arglist: argument comma_arg {push_argument($1); $$ = $2; $$->copy_code($1); $$->copy_function_args($1);}
| argument comma_arg COMMA {push_argument($1); $$ = $2; $$->copy_code($1); $$->copy_function_args($1);} 
| argument  {push_argument($1); $$=$1;}
| argument COMMA    {push_argument($1); $$ = $1;}
;

comma_arg: COMMA argument   {push_argument($2); $$=$2;}
| COMMA argument comma_arg  {push_argument($2);$$=$3;$$->copy_code($2); $$->copy_function_args($2);}
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
        $$->class_table=global_symbol_table->lookup_class($3->get_lexeme());
        if($$->class_table == nullptr){
            cout << $1->get_lexeme() << "[" << $3->get_lexeme() << "]" << " is not a valid datatype at line no: " << $1->get_line_no() << endl;
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
    cout << "--input=<input-file>: Specify the input program file (without any whitespace between '=' and file path)" << endl;
    cout << "--output=<output-file>: Specify the output x86 file (without any whitespace between '=' and file path)" << endl;
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
    string output_file_path = "../output/3AC.txt";
    output_x86_file_path = "../output/x86.s";
    for(int i = 1; i < argc; ++i){
        string arg(argv[i]);
        if(arg == "--help"){
            print_help();
            return 0;
        }
        else if(arg == "--verbose") {
            verbose = true;
            yydebug = 1; 
            string error_file_path = "temp";
            freopen(error_file_path.c_str(), "w", stderr); 
        }
        else if(arg.size() >= 8 && arg.substr(0,8) == "--input="){
            if(arg.size() > 8) input_file_path = arg.substr(8);
            else{
                cerr << "Error: No input file provided" << endl;
                return 1;
            }
        }
        else if(arg.size() >= 9 && arg.substr(0,9) == "--output="){
            if(arg.size() > 9) output_x86_file_path = arg.substr(9);
            else{
                cerr << "Error: No output file provided" << endl;
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
    global_symbol_table->insert("__name__", {"str"}, 0, true);
    add_len_function(global_symbol_table);
    symbol_table_stack.push(curr_symbol_table);
    
    
    yyparse();
    print_threeAC(output_file_path);
    /* global_symbol_table->make_csv(); */
    x86_dump.open(output_x86_file_path);
    ofstream x86_output("../output/x86.txt");
    vector<vector<ThreeAC*>> rescheduled_threeAC;
    for(auto & code_block: threeAC){
        /* auto rescheduled_block =  */
        vector<ThreeAC*> rescheduled_block = reschedule_block(code_block);
        rescheduled_threeAC.push_back(rescheduled_block);
        for(auto &code: rescheduled_block){
            code->print_raw(x86_output);
        }
        x86_output << endl;
        /* for(auto &code: code_block){
            code->print_raw();
        } */
        /* get_registers(code_block); */
    }
    gen_x86(rescheduled_threeAC, global_symbol_table);
    /* gen_x86(threeAC, global_symbol_table); */

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