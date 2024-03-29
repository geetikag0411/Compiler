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
    void print_raw(){
        if(arg1 == ""){
            cout << result << endl;
        }
        else if (result == "param")
        {
            cout<< "param " << arg1 << endl;
        }
        else if(arg2 == ""){
            if(result == "goto" || result == "param" || result == "stackpointer" || result == "if not" || result == "return"||result == "call"){
                cout << result << " " << op << " " << arg1 << endl;
            }
            else{
                cout << result << " = " << op<<" " << arg1 << endl;
            }
        }
        else{
            if(result == "call" || result == "if not"){
                cout << result << " " << arg1 << " " << op << " " << arg2 << endl;
            }
            else{
                cout << result << " = " << arg1 << " " << op << " " << arg2 << endl;
            }
        }
    }
};

#endif