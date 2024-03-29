#include<iostream>
using namespace std;
class A{
    public:
    int a;
    A(){
        a = 9;
    }
};
int main(){
    A a = A();
    A b = a;
    b.a = 10;
    cout<<(a.a);
}