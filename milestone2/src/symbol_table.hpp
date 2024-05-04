 #ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H
#include <bits/stdc++.h>
using namespace std;
class symbol_table;
class symbol_table_global;
class symbol_table_function;
class symbol_table_class;

enum class symbol_table_types: int{
    GLOBAL_ST,
    FUNCTION_ST,
    CLASS_ST
};

typedef struct Type{
    //warning don't change the order of the args
    string datatype;
    bool is_list{false};
    bool is_function{false};
    bool is_class{false};
    symbol_table_function* function_table{nullptr};
    symbol_table_class* class_table{nullptr};
    int length_if_list{0};
} Type;

class st_entry
{
    string name;
    Type type;
    int offset;
    int line_no;
    int size;
    string temporary;
    symbol_table *table{NULL};
    bool is_initialized{false};

public:
    st_entry(string name, Type type, int line_no, symbol_table *table, bool is_initialized);
    st_entry(string name, Type type, int offset, int line_no, symbol_table *table, bool is_initialized);
    void print(int indent = 0);
    Type get_datatype();
    string get_temporary();
    int get_offset();

    // string get_name();
    // st_entry (string name, Type type, int offset, int line_no, int dimensions, symbol_table* table, bool is_initialized, bool is_list);
    friend class symbol_table;
    friend class symbol_table_global;
    friend class symbol_table_function;
    friend class symbol_table_class;
};

class symbol_table
{
protected:
    map<string, st_entry*> entries;
    // vector<symbol_table*> blocks;
    symbol_table_types symbol_table_type;
    symbol_table *parent_st{nullptr};
    map<string, st_entry*> global_entries;
    int curr_offset{0};
    int line_no{0};

public:
    int get_symbol_table_type(){return static_cast<int>(symbol_table_type);}
    symbol_table_class* get_parent_class_st();
    symbol_table(){}
    symbol_table(symbol_table *parent_st) : parent_st(parent_st) {}
    st_entry* lookup(string name);  //TODO: lookup should do the job of lookup
    st_entry* lookup_all(string name);
    symbol_table* get_parent_st();
    void add_global_entry(st_entry*);

    // string get_temporary(string name);

    st_entry* lookup_global_entry(string name);
    void insert(string name, Type type, int line_no, bool is_initialized, string temporary);
    void insert(string name, Type type, int line_no, bool is_initialized);
    virtual void set_return_type(Type type){return;}
    virtual symbol_table_class *create_new_class(string name, symbol_table_class *parent_st) { return nullptr; }
    virtual symbol_table_function *create_new_function(string name) { return nullptr; }
    virtual symbol_table_class *lookup_class(string name) { return nullptr; }
    virtual symbol_table_function *lookup_function(string name) { return nullptr; }
    virtual symbol_table_function *lookup_function_all(string name) { return nullptr; }
    virtual void add_parameter(string name, Type type, int line_no){ return; }
    virtual st_entry* lookup_class_member(string name){return nullptr;}
    virtual string get_name(){return "";}
    virtual void print(int indent = 0) = 0;
    virtual void make_csv()=0;
    virtual Type get_return_type(){return {""};}
    virtual symbol_table_class* get_parent_class(){return nullptr;}
    virtual Type get_parameter_type_from_end(int index){return {""};}
    virtual bool is_first_argument_self(){return false;}
    int get_offset(){return curr_offset;}
    int get_line_no(){return line_no;}
    void set_line_no(int line_no){this->line_no = line_no;}
    virtual void add_init(){return;}
};

class symbol_table_global : public symbol_table
{
    map<string, symbol_table_class *> classes;
    map<string, symbol_table_function *> functions;

public:
    symbol_table_global(){symbol_table_type = symbol_table_types::GLOBAL_ST;}
    symbol_table_class *create_new_class(string name, symbol_table_class *parent) override;
    symbol_table_function *create_new_function(string name) override;
    symbol_table_class *lookup_class(string name) override;
    symbol_table_function *lookup_function(string name) override;
    void print(int indent = 0) override;
    void make_csv()override;
};

class symbol_table_function : public symbol_table
{
    string name;
    vector<st_entry*> parameters;
    Type return_type;
    // int line_no;

public:
    symbol_table_function(string name, symbol_table *parent_st) : name(name), symbol_table(parent_st) {symbol_table_type = symbol_table_types::FUNCTION_ST;}
    void add_parameter(string name, Type type, int line_no) override;
    void set_return_type(Type type) override;
    Type get_parameter_type_from_end(int index) override;
    Type get_return_type() override;
    string get_name() override;
    bool is_first_argument_self() override;
    void print(int indent = 0) override;
    void make_csv()override;
    void make_csv(string str);
    int get_parameter_count();
    int get_agrument_size();
    // void set_line_no(int line_no) {this->line_no = line_no;}
    // int get_line_no() {return line_no;}
};

class symbol_table_class : public symbol_table
{
    string name;
    symbol_table_class *parent_class;
    map<string, symbol_table_function *> functions;
    // int line_no;

public:
    symbol_table_class(string name, symbol_table_class *parent_class, symbol_table *parent_st) : name(name), parent_class(parent_class), symbol_table(parent_st){
        symbol_table_type = symbol_table_types::CLASS_ST;    
        insert_parent_class_entries();   
        if(parent_class != nullptr)
        curr_offset = parent_class->curr_offset;
    }
    void add_init() override;
    void insert_parent_class_entries();
    symbol_table_function *create_new_function(string name) override;
    symbol_table_function* lookup_function(string name) override;
    st_entry* lookup_class_member(string name) override;
    string get_name() override;
    symbol_table_class* get_parent_class() override;
    // int get_offset() override;
    void print(int indent = 0) override;
    void make_csv()override;
    // void set_line_no(int line_no) {this->line_no = line_no;}
    // int get_line_no() {return line_no;}
};

#endif