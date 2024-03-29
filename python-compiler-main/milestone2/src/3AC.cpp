#ifndef THREE_AC_HPP
#define THREE_AC_HPP
#include <bits/stdc++.h>
using namespace std;

class ThreeAC
{
    string op;
    string arg1;
    string arg2;
    string result;

public:
    ThreeAC(string op, string arg1, string arg2, string result) : op(op), arg1(arg1), arg2(arg2), result(result) {};
    ThreeAC(string op, string arg1, string result) : op(op), arg1(arg1), result(result) {};
    ThreeAC(string arg1, string result) : arg1(arg1), result(result){};
    ThreeAC(string result) : result(result){};
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
            if(result == "call" || result == "if not"){
                out << result << " " << arg1 << " " << op << " " << arg2 << endl;
            }
            else{
                out << result << " = " << arg1 << " " << op << " " << arg2 << endl;
            }
        }
    }
};

#endif