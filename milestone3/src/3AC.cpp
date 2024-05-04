#ifndef THREE_AC_HPP
#define THREE_AC_HPP
#include <bits/stdc++.h>
#define  POP 0
#define  PUSH 1
#define  MOV 2 
#define  RET 3
#define  GOTO 4
#define  EXPR 5 
#define  CALL 6
#define  IFGOTO 7 
#define  IFNOT 8
#define  FUNCLABEL 9
#define  CLASSFUNCLABEL 10
#define  LABEL 11
#define  ASSIGN 12
#define  UNARYEXPR 13
#define  ALIGN 14
#define  REALIGN 15
#define  LEAQ 16
#define  MOVSX 17

using namespace std;

class ThreeAC
{
    string op;
    string arg1;
    string arg2;
    string result;
    int instruction_type;

public:
    ThreeAC(string op, string arg1, string arg2, string result, int instruction_type) : op(op), arg1(arg1), arg2(arg2), result(result), instruction_type(instruction_type) {};
    ThreeAC(string op, string arg1, string result, int instruction_type) : op(op), arg1(arg1), result(result), instruction_type(instruction_type) {};
    ThreeAC(string arg1, string result, int instruction_type) : arg1(arg1), result(result), instruction_type(instruction_type){};
    ThreeAC(string result, int instruction_type) : result(result), instruction_type(instruction_type){};
    string get_op(){return op;}
    string get_arg1(){return arg1;}
    string get_arg2(){return arg2;}
    string get_result(){return result;}
    void update_result(string new_result){result = new_result;}
    void update_arg1(string new_arg1){arg1 = new_arg1;}
    void update_arg2(string new_arg2){arg2 = new_arg2;}
    int get_instruction_type(){return instruction_type;}
    void print_raw(ofstream &out){
        if(arg1 == ""){
            out << result << endl;
        }
        else if (result == "param"||result.substr(0,4)=="push"||result.substr(0,3)=="pop")
        {
            out<< result<<' '<< arg1 << endl;
        }
        else if(arg2 == ""){
            if(result.substr(0,3)=="mov"||result == "goto" || result == "param" || result == "stackpointer" || result == "if not" || result == "return"||result == "call"){
                out << result << " " << op << " " << arg1 << endl;
            }
            else{
                out << result << " = " << op<<" " << arg1 << endl;
            }
        }
        else{
            if(result == "call" || result == "if not" || result == "if"){
                out << result << " " << arg1 << " " << op << " " << arg2 << endl;
            }
            else{
                out << result << " = " << arg1 << " " << op << " " << arg2 << endl;
            }
        }
    }

    void print_raw(){
        if(arg1 == ""){
            std::cout << result << endl;
        }
        else if (result == "param"||result.substr(0,4)=="push"||result.substr(0,3)=="pop")
        {
            std::cout<< result<<' '<< arg1 << endl;
        }
        else if(arg2 == ""){
            if(result.substr(0,3)=="mov"||result == "goto" || result == "param" || result == "stackpointer" || result == "if not" || result == "return"||result == "call"){
                std::cout << result << " " << op << " " << arg1 << endl;
            }
            else{
                std::cout << result << " = " << op<<" " << arg1 << endl;
            }
        }
        else{
            if(result == "call" || result == "if not" || result == "if"){
                std::cout << result << " " << arg1 << " " << op << " " << arg2 << endl;
            }
            else{
                std::cout << result << " = " << arg1 << " " << op << " " << arg2 << endl;
            }
        }
    }
};

#endif