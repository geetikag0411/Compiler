#ifndef NON_TERMINAL_HPP
#define NON_TERMINAL_HPP
#include <bits/stdc++.h>
#include "symbol_table.hpp"
#include "3AC.cpp"
using namespace std;

class NonTerminal
{
    int m_line_no;
    int m_operator_type_augassign;
    string m_lexeme;
    Type m_datatype;
    bool m_is_lvalue{false};
    vector<ThreeAC *> m_code;
    string temporary;
    bool m_is_ptr{false};    
    vector<string> curr_list_temporaries;
    string m_operator;
    bool m_has_return_stmt{false};
    vector<string> function_args;
    bool m_is_list_initializer{false};
public:
    void clear_func_args()
    {
        function_args.clear();
    }
    bool get_is_list_initializer()
    {
        return m_is_list_initializer;
    }
    void set_is_list_initializer(bool is_list_initializer)
    {
        m_is_list_initializer = is_list_initializer;
    }
    void push_function_arg(string arg)
    {
        function_args.push_back(arg);
    }
    void copy_function_args(NonTerminal *other)
    {
        for (auto arg : other->function_args)
        {
            function_args.push_back(arg);
        }
    }
    void gen_push_args()
    {
        for (auto arg : function_args)
        {
            gen("pushq", arg, PUSH);
        }
    }
    NonTerminal(int line_no) : m_line_no(line_no) {}
    NonTerminal(int line_no, string lexeme) : m_line_no(line_no), m_lexeme(lexeme) {}
    NonTerminal(int line_no, Type datatype) : m_line_no(line_no), m_datatype(datatype) {}
    NonTerminal(int line_no, string lexeme, Type datatype) : m_line_no(line_no), m_lexeme(lexeme), m_datatype(datatype) {}
    void set_has_return_stmt(bool has_return_stmt) { m_has_return_stmt = has_return_stmt; }
    bool get_has_return_stmt() { return m_has_return_stmt; }
    void curr_list_temporaries_push(string temp)
    {
        // cout<<"pushing "<<temp<<"\n";
        curr_list_temporaries.push_back(temp);
    }
    void print_curr_list_temporaries()
    {
        return;
        cout<<"curr_list_temporaries size"<<curr_list_temporaries.size()<<"\n";
        for(auto temp:curr_list_temporaries)
        {
            cout<<temp<<" ";
        }
        cout<<"\n\n";
    }
   void copy_cur_temp(NonTerminal *other)
    {
                // cout<<"curr_list_temporaries size"<<curr_list_temporaries.size()<<"\n";

        //  cout<<"copying curr_list_temporaries size"<<other->curr_list_temporaries.size()<<"\n";
        for (auto temp : other->curr_list_temporaries)
        {
            curr_list_temporaries.push_back(temp);
        }
        // cout<<"copied curr_list_temporaries size"<<curr_list_temporaries.size()<<"\n";
    }
    string gen_list_code1(int size){
        // gen("pushl", to_string(curr_list_temporaries.size()*(size)+4), PUSH);
        gen("movq", to_string(curr_list_temporaries.size()*(size)+8), "%rdi", MOV);                                           // $$->gen("stackpointer", "+xxx");
        gen("call", "malloc", "1", CALL);
        // gen("%rsp", "%rsp","+", "4", EXPR);
        auto temp1 = NonTerminal::get_new_temporary();
        gen(temp1, "%rax", MOV);
        gen("*"+temp1, to_string(curr_list_temporaries.size()), MOV);
        auto temp2 = NonTerminal::get_new_temporary();
        temp2[1] = 'T';
        gen(temp2, "%rax", "+", "8", EXPR);
        return temp2;
    }

    void gen_list_code2(int size,vector<vector<ThreeAC*>> list_expr_code, string temp)
    {
        //t1= $1->get_temporary();
        // gen("pushl", to_string(curr_list_temporaries.size()*(size)+4), PUSH);                                                // $$->gen("stackpointer", "+xxx");
        // gen("call", "allocmem", "1", CALL);
        // gen("%rsp", "%rsp","+", "4", EXPR);
        // auto temp1 = NonTerminal::get_new_temporary();
        // gen(temp1, "%rax", MOV);
        // gen("*"+temp1, to_string(curr_list_temporaries.size()), MOV);
        // gen("%rcx", "%rax", "+", "4", EXPR);
        // gen(t1, "%rbx", EXPR);
        // this->copy_code(copy_coder);
        if(curr_list_temporaries.size() > list_expr_code.size()){
            cout << temp << " list_temp_count = " << curr_list_temporaries.size() << ", list_expr_code_count = " << list_expr_code.size() << endl;
            exit(-1);
        }
        for(int i=0;i<curr_list_temporaries.size();++i)
        {
            for(auto &code: list_expr_code[list_expr_code.size()-curr_list_temporaries.size()+i]) m_code.push_back(code);
            auto temp2 = NonTerminal::get_new_temporary();
            gen(temp2, temp, "+", to_string(i*size),EXPR);
            gen("*"+temp2, curr_list_temporaries[i],MOV);
        }
         curr_list_temporaries.clear();
    }
    void clear_curr_list_temporaries()
    {
        curr_list_temporaries.clear();
    }
    static string get_new_temporary()
    {
        static int temp_count = 0;
        ++temp_count;
        return "$t" + to_string(temp_count);
    }
    static string get_new_label()
    {
        static int label_count = 0;
        ++label_count;
        return ".L" + to_string(label_count)+ ":";
    }
    bool get_is_lvalue() { return m_is_lvalue; }
    void set_is_lvalue(bool is_value) { m_is_lvalue = is_value; }
    void set_datatype(Type datatype) { m_datatype = datatype; }
    string set_temporary()
    {
        temporary = get_new_temporary();
        return temporary;
    }
    string get_temporary() { return temporary; }
    void set_temporary(string temp) { temporary = temp; }
    void set_is_ptr(bool is_ptr) { m_is_ptr = is_ptr; }
    void set_operator_type_augassign(int operator_type_augassign) { m_operator_type_augassign = operator_type_augassign; }
    void set_operator(string op){ m_operator = op;}
    string get_operator(){ return m_operator;}

    void set_line_no(int line_no) { m_line_no = line_no; }

    int get_operator_type_augassign() { return m_operator_type_augassign; }

    Type get_datatype() { return m_datatype; }

    int get_line_no() { return m_line_no; }

    bool get_is_ptr() { return m_is_ptr; }

    string get_lexeme() { return m_lexeme; }

    void set_list(bool is_list) { m_datatype.is_list = is_list; }

    void set_lexeme(string lexeme) { m_lexeme = lexeme; }

    void set_isclass(bool is_class) { m_datatype.is_class = is_class; }

    void set_class_table(symbol_table_class *class_table) { m_datatype.class_table = class_table; }

    Type compare_datatype(Type datatype)
    {
        if (m_datatype.is_list || datatype.is_list)
            return {"ERROR", 0};
       else if(m_datatype.is_class||datatype.is_class)
        {
            return {"ERROR", 0};
            exit(-1);
        }
        else if (m_datatype.datatype == datatype.datatype)
            return datatype;
        else if (m_datatype.is_list && datatype.is_list)
        {
            if (m_datatype.datatype == datatype.datatype)
                return datatype;
            else
                return {"ERROR", 0};
        }
        else if(m_datatype.is_class&&datatype.is_class)
        {
            if(m_datatype.class_table->get_name()==datatype.class_table->get_name())
                return m_datatype;
            while(datatype.class_table->get_parent_class()!=nullptr)
            {
                datatype.class_table=datatype.class_table->get_parent_class();
                if(m_datatype.class_table->get_name()==datatype.class_table->get_name())
                    return m_datatype;
            }
        }
        else if ((m_datatype.datatype != "str") && (datatype.datatype != "str"))
        {
            map<string, int> precedence = {{"bool", 0}, {"int", 1}, {"float", 2}, {"ERROR", 3}};
            auto dt=precedence[m_datatype.datatype] > precedence[datatype.datatype]?m_datatype:datatype;
            if(dt.datatype=="float"&&(m_datatype.datatype=="bool"||datatype.datatype=="bool"))
                return {"ERROR", 0};
                
            return dt;
        }
            return {"ERROR", 0};
    }
    bool compare_datatype(int operator_type_augassign)
    {
        if(m_datatype.is_class)
        {
            cout<<"Operator not supported for class objects at line number "<< m_line_no<<"\n";
            exit(-1);
        }
        if (operator_type_augassign == 3)
        {
            if (m_datatype.datatype == "ERROR")
            {
                return false;
            }
            return true;
        }
        else if (operator_type_augassign == 2)
        {
            if (m_datatype.datatype == "bool" || m_datatype.datatype == "int")
            {
                return true;
            }
            return false;
        }
        else if (operator_type_augassign == 1)
        {
            if (m_datatype.datatype == "int" || m_datatype.datatype == "float" || m_datatype.datatype == "bool")
            {
                return true;
            }
            return false;
        }

        else
            return false;
    }
    bool compare_datatype_expr3or(Type datatype)
    {
        if (m_datatype.is_list != datatype.is_list)
            return 0;
        else if (m_datatype.datatype == datatype.datatype)
            return 1;
        else if (m_datatype.is_list && datatype.is_list)
        {
            return m_datatype.datatype == datatype.datatype;
        }
        else if (m_datatype.datatype == "ERROR" || datatype.datatype == "ERROR")
            return 0;
        else if (m_datatype.datatype == "str" || datatype.datatype == "str")
        {
            return 0;
        }
        else if (m_operator_type_augassign == 3)
        {
            if (datatype.datatype == "ERROR")
            {
                return false;
            }
            return true;
        }
        else if (m_operator_type_augassign == 2)
        {
            if (datatype.datatype == "bool" || datatype.datatype == "int")
            {
                return true;
            }
            return false;
        }
        else if (m_operator_type_augassign == 1)
        {
            if (datatype.datatype == "int" || datatype.datatype == "float" || datatype.datatype == "bool")
            {
                if((m_datatype.datatype=="float"&&datatype.datatype=="bool")||(m_datatype.datatype=="bool"&&datatype.datatype=="float"))
                    return false;
                return true;
            }
            return false;
        }

        else
            return false;
    }

    vector<ThreeAC*>& get_code(){   // TODO: return by reference might cause some problems?
        return m_code;
    }

    void copy_code(NonTerminal *other)
    {
        // TODO: can std::move other->m_code for efficiency given that other's m_code will not be used again
        for (auto &code : other->m_code)
        {
            m_code.push_back(code);
        }
    }

    void gen(ThreeAC *code) { m_code.push_back(code); }

    void gen(string result, string arg1, string op, string arg2, int instruction_type) { m_code.push_back(new ThreeAC(op, arg1, arg2, result, instruction_type)); }

    void gen(string result, string op, string arg1, int instruction_type) { m_code.push_back(new ThreeAC(op, arg1, result, instruction_type)); }

    void gen(string result, string arg1, int instruction_type) { m_code.push_back(new ThreeAC(arg1, result, instruction_type)); }

    void gen(string result, int instruction_type) { m_code.push_back(new ThreeAC(result, instruction_type)); }

    string gen_new_label()
    {
        auto label=get_new_label();
        m_code.push_back(new ThreeAC(label,LABEL));
        return label;
    }
    void gen_new_label(string label)
    {
        m_code.push_back(new ThreeAC(label,LABEL));
    }
};

#endif

// augassign: PLUS_EQUAL {$$=$1;$$->set_operator_type_augassign(3);}
// | MINUS_EQUAL {$$=$1;$$->set_operator_type_augassign(1);} //not str 1
// | MULTIPLY_EQUAL {$$=$1;$$->set_operator_type_augassign(1);} //not str 1
// | DIVIDE_EQUAL {$$=$1;$$->set_operator_type_augassign(1);} //not str 1
// | MODULO_EQUAL {$$=$1;$$->set_operator_type_augassign(1);} //not str 1
// | BITWISE_AND_EQUAL{$$=$1;$$->set_operator_type_augassign(2);}  //bool int  2
// | BITWISE_OR_EQUAL {$$=$1;$$->set_operator_type_augassign(2);} //bool int 2
// | BITWISE_XOR_EQUAL {$$=$1;$$->set_operator_type_augassign(2);} //int bool int 2
// | LEFT_SHIFT_EQUAL {$$=$1;$$->set_operator_type_augassign(2);} //int bool int 2
// | RIGHT_SHIFT_EQUAL {$$=$1;$$->set_operator_type_augassign(2);}//int bool int 2
// | POWER_EQUAL {$$=$1;$$->set_operator_type_augassign(1);} //not str 1
// | FLOOR_DIVIDE_EQUAL {$$=$1;$$->set_operator_type_augassign(1);} //not str 1