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
    

public:
    NonTerminal(int line_no) : m_line_no(line_no) {}
    NonTerminal(int line_no, string lexeme) : m_line_no(line_no), m_lexeme(lexeme) {}
    NonTerminal(int line_no, Type datatype) : m_line_no(line_no), m_datatype(datatype) {}
    NonTerminal(int line_no, string lexeme, Type datatype) : m_line_no(line_no), m_lexeme(lexeme), m_datatype(datatype) {}
    void curr_list_temporaries_push(string temp)
    {
        curr_list_temporaries.push_back(temp);
    }
   void copy_cur_temp(NonTerminal *other)
    {
        for (auto temp : other->curr_list_temporaries)
        {
            curr_list_temporaries.push_back(temp);
        }
    }
    void gen_list_code(int size, string t1)
    {
        //t1= $1->get_temporary();
        gen("pushl", to_string(curr_list_temporaries.size()*(size)+4));                                                // $$->gen("stackpointer", "+xxx");
        gen("call", "allocmem", "1");
        gen("$rsp", "$rsp","+", "4");
        auto temp = NonTerminal::get_new_temporary();
        gen(temp, "$rax");
        gen("*"+temp, to_string(curr_list_temporaries.size()));
        gen(t1, temp, "+", "4");
        for(int i=0;i<curr_list_temporaries.size();++i)
        {
            auto temp2 = NonTerminal::get_new_temporary();
            // cout<<"line 399"<<$1->get_temporary()<<endl;
            gen(temp2, t1, "+", to_string(i*size));
            gen("*"+temp2, curr_list_temporaries[i]);
        }
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
        return "L" + to_string(label_count)+ ":";
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
        if (m_datatype.is_list != datatype.is_list)
            return {"ERROR", 0};
       else if(m_datatype.is_class||datatype.is_class)
        {
            cout<<"Operator not supported for class objects at line number "<< m_line_no<<"\n";
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

    vector<ThreeAC*>& get_code(){
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

    void gen(string result, string arg1, string op, string arg2) { m_code.push_back(new ThreeAC(op, arg1, arg2, result)); }

    void gen(string result, string op, string arg1) { m_code.push_back(new ThreeAC(op, arg1, result)); }

    void gen(string result, string arg1) { m_code.push_back(new ThreeAC(arg1, result)); }

    void gen(string result) { m_code.push_back(new ThreeAC(result)); }

    string gen_new_label()
    {
        auto label=get_new_label();
        m_code.push_back(new ThreeAC(label));
        return label;
    }
    void gen_new_label(string label)
    {
        m_code.push_back(new ThreeAC(label));
    }
    // void print_code(){
    //     for(auto &code: m_code){
    //         code->print_raw();
    //     }
    //     cout<<'\n';
    // }
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