#include "symbol_table.hpp"

void print_indent(int indent)
{
    while (indent--)
        cout << "    ";
}

st_entry::st_entry(string name, Type type, int line_no, symbol_table *table, bool is_initialized) : name(name), type(type), line_no(line_no), table(table), is_initialized(is_initialized) {}

Type st_entry::get_datatype()
{
    return type;
}
int st_entry::get_offset(){
    return offset;
}

st_entry *symbol_table::lookup(string name)
{
    if (entries.find(name) != entries.end())
        return entries[name];
    return nullptr;
}

st_entry* symbol_table::lookup_all(string name)
{
    symbol_table* table = this;
    if(table->get_symbol_table_type() != static_cast<int>(symbol_table_types::CLASS_ST) && entries.find(name) != entries.end()) return entries[name];
    table = table->parent_st;
    if(table != nullptr) return table->lookup_all(name);
    // st_entry* res;
    
    // while (table != nullptr)
    // {
    //     if(table->lookup(name) != nullptr) return 
    //     table = table->parent_st();
    // }
    return nullptr;
}

void st_entry::print(int indent)
{
    print_indent(indent);
    cout << "name: " << name << ", Type.data: " << type.datatype << ", Type.is_list: " << type.is_list << ", line_no: " << line_no << ", is_initialized: " << is_initialized <<", offset: "<<offset<< endl;
}

// void Non_terminal::set_type(Type type){
//     this->type = type;
// }

void symbol_table::print(int indent)
{
    print_indent(indent);
    cout << "Block Symbol Table:\n";
    for (auto &[name, st_entry] : entries)
        st_entry->print(indent + 2);
}

// void symbol_table::insert(string name, Type type, int line_no, bool is_initialized)
// {
//     if(entries.find(name) != entries.end()) delete entries[name];
//     entries[name] = new st_entry(name, type, line_no, this, is_initialized);
// }

void symbol_table::insert(string name, Type type, int line_no, bool is_initialized, string temporary)
{
    if(entries.find(name) != entries.end()) delete entries[name];
    entries[name] = new st_entry(name, type, line_no, this, is_initialized);
    entries[name]->temporary = temporary;
}

void symbol_table::add_global_entry(st_entry* entry){
    global_entries[entry->name] = entry;
}

st_entry* symbol_table::lookup_global_entry(string name){
    if(global_entries.find(name) != global_entries.end()) return global_entries[name];
    return nullptr;
}

symbol_table *symbol_table::get_parent_st()
{
    return parent_st;
}

symbol_table_class *symbol_table::get_parent_class_st()
{
    symbol_table *curr_table = this;
    while (curr_table != nullptr)
    {
        if (curr_table->get_symbol_table_type() == static_cast<int>(symbol_table_types::CLASS_ST))
            return dynamic_cast<symbol_table_class *>(curr_table);
        curr_table = curr_table->get_parent_st();
    }
    return nullptr;
}

void symbol_table_global::print(int indent)
{
    print_indent(indent);
    cout << "Global Symbol Table:\n";
    for (auto &[name, symbol_table_function] : functions)
    {
        printf("Function: %s\n", name.c_str());
        symbol_table_function->print(indent + 1);
    }
    printf("Classes:\n");
    for (auto &[name, symbol_table_class] : classes)
        symbol_table_class->print(indent + 1);
    print_indent(indent + 1);
    cout << "Entries:\n";
    for (auto &[name, st_entry] : entries)
        st_entry->print(indent + 2);
}

symbol_table_class *symbol_table_global::create_new_class(string name, symbol_table_class *parent_class)
{
    if (classes.find(name) != classes.end())
        delete classes[name];
    classes[name] = new symbol_table_class(name, parent_class, this);
    return classes[name];
}

symbol_table_function *symbol_table_global::create_new_function(string name)
{
    if (functions.find(name) != functions.end())
        delete functions[name];
    return functions[name] = new symbol_table_function(name, this);
}

symbol_table_class *symbol_table_global::lookup_class(string name)
{
    if (classes.find(name) != classes.end())
        return classes[name];
    return nullptr;
}

symbol_table_function *symbol_table_global::lookup_function(string name)
{   
    if (functions.find(name) != functions.end()) return functions[name];
    return nullptr;
}

// symbol_table_function(string name, symbol_table* parent_st): name(name), symbol_table(parent_st){}

void symbol_table_function::add_parameter(string name, Type type, int line_no)
{
    st_entry *entry = new st_entry(name, type,curr_offset, line_no, this, true);
    entries[name] = entry;
    parameters.push_back(entry);
    if(type.is_list||type.datatype=="str")
    {
        curr_offset += 8;
    }
    else if(type.is_class)
    {
        curr_offset += 8;

    }
    else if(type.datatype=="int")
    {
        curr_offset += 4;
    }
    else if(type.datatype=="float")
    {
        curr_offset += 4;
    }
    else if(type.datatype=="bool")
    {
        curr_offset += 1;
    }
    else{
        cout<<"Error: Invalid datatype\n";
    }
}

Type symbol_table_function::get_return_type()
{
    return return_type;
}

bool symbol_table_function::is_first_argument_self(){
    return (parameters.size() > 0 && parameters[0]->name == "self");
}

void symbol_table_function::set_return_type(Type type)
{
    return_type = type;
}

Type symbol_table_function::get_parameter_type_from_end(int index)
{
    if (index < parameters.size() && index >= 0)
        return parameters[parameters.size()-1-index]->get_datatype();
    else
    {
        cout << "Error: More number of arguments passed than required for function " << name << endl;
        exit(-1);
    }
}

symbol_table_function *symbol_table_class::lookup_function(string name)
{
    symbol_table_class* class_table = this;
    while(class_table != nullptr){
        if (class_table->functions.find(name) != class_table->functions.end()) return class_table->functions[name];
        class_table = class_table->parent_class;
    }    
    return nullptr;
}

symbol_table_function *symbol_table_class::create_new_function(string name)
{
    if (functions.find(name) != functions.end())
        delete functions[name];
    functions[name] = new symbol_table_function(name, this);
    return functions[name];
}

string symbol_table_function::get_name()
{
    return name;
}

void symbol_table_function::print(int indent)
{
    print_indent(indent);
    cout << "Function Symbol Table: " << name << endl;
    print_indent(indent + 1);
    cout << "Parameters:\n";
    print_indent(indent + 1);
    cout << "No. of Parameters: " << parameters.size() << endl;
    for (auto &st_entry : parameters)
        st_entry->print(indent + 2);
    print_indent(indent + 1);
    cout << "Entries:" << endl;
    for (auto &[name, st_entry] : entries)
        st_entry->print(indent + 2);
    print_indent(indent + 1);
    cout << "Return Type: " << return_type.datatype << " " << return_type.is_list << endl;
}

void symbol_table::insert(string name, Type type, int line_no, bool is_initialized){
    if(entries.find(name) != entries.end()) delete entries[name];
    entries[name] = new st_entry(name, type,curr_offset, line_no, this, is_initialized);
    // curr_offset += 0;
    if(type.is_function)
    {
        printf("Error: Function cannot be a class member\n");
        exit(-1);
    }
    else if(type.is_list||type.datatype=="str")
    {
        curr_offset += 8;
    }
    else if(type.is_class)
    {
        curr_offset += 8;

    }
    else if(type.datatype=="int")
    {
        curr_offset += 4;
    }
    else if(type.datatype=="float")
    {
        curr_offset += 4;
    }
    else if(type.datatype=="bool")
    {
        curr_offset += 1;
    }
    else{
        cout<<"Error: Invalid datatype\n";
    }
    /*TODO: need to update this when we need offset*/
}

st_entry *symbol_table_class::lookup_class_member(string name)
{
    symbol_table_class *table = this;
    if(entries.find(name) != entries.end()) 
    return entries[name];
    table = table->parent_class;
    if(table != nullptr) return table->lookup_class_member(name);
    return nullptr;
}

string symbol_table_class::get_name()
{
    return name;
}

symbol_table_class *symbol_table_class::get_parent_class()
{
    return parent_class;
}

void symbol_table_class::insert_parent_class_entries(){
    if(parent_class == nullptr) return;
    for(auto &[name, entry]: parent_class->entries){
        entries[name] = entry;
    } 
}
string st_entry::get_temporary()
{
    return temporary;
}

// int symbol_table_class::get_offset(){
//     return curr_offset;
// }
int symbol_table_function::get_agrument_size()
{
    int sz=0;
    for(auto parameter: parameters)
    {
        sz+=parameter->size;
    }
    return sz;
}
void symbol_table_class::add_init(){
    if(functions.find("__init__") == functions.end()){
        create_new_function("__init__");
        Type new_type;
        new_type.datatype = "None";
        functions["__init__"]->set_return_type(new_type);
    }
    return;
}

void symbol_table_class::print(int indent)
{
    print_indent(indent);
    cout << "Class Name: " << name << endl;
    if (parent_class != nullptr)
    {
        print_indent(indent + 1);
        cout << "Parent Class Name: " << parent_class->name << endl;
    }
    print_indent(indent + 1);
    cout << "Functions:\n";
    for (auto &[name, symbol_table_function] : functions)
        symbol_table_function->print(indent + 1);
    print_indent(indent + 1);
    cout << "Entries: \n"
         << endl;
    for (auto &[name, st_entry] : entries)
        st_entry->print(indent + 2);
    cout << endl;
}
int symbol_table_function::get_parameter_count()
{
    for(auto &param: parameters)
    {
        if(param->name == "self") 
        return parameters.size() - 1;
    }
    return parameters.size();
}

void symbol_table_global::make_csv()
{
    ofstream file;
    file.open("../output/Global.csv");
    file << "Systactic Category(token),Lexeme,Type,Line No,Offset\n";
    for (auto &[name, st_entry] : entries)
    {
        file << "Id,"<<st_entry->name << "," << st_entry->type.datatype<<(st_entry->type.is_list? "[]": "" )<< "," << st_entry->line_no << "," << st_entry->offset << "\n";
    }
     for(auto &[name,function]:functions)
    {
        function->make_csv("");
       file<<"Function,"<<name<<",(";
        for(int i = function->get_parameter_count()-1; i>=0; i--)
        {
            file<<function->get_parameter_type_from_end(i).datatype;
            if(function->get_parameter_type_from_end(i).is_list) file<<"[]";
            if(i!=0) file<<"*";
        }
        file<<")->"<<function->get_return_type().datatype;
        if(function->get_return_type().is_list) file<<"[]";
        file<<","<<(name=="len"?"Not Defined":to_string(function->get_line_no()))<<",None\n";
    }
      for(auto clas:classes)
    {
        file<<"Class,"<<clas.first<<",None,"<<clas.second->get_line_no()<<",None\n";
        clas.second->make_csv();
    }
    file.close();
}
void symbol_table_function::make_csv(){return;}
void symbol_table_function::make_csv(string str)
{
    // printf("Function: %s\n", name.c_str());
    if(name=="len")return;
    ofstream file;
    file.open("../output/"+ str+name + ".csv");
    file << "Systactic Category(token),Lexeme,Type,Line No,Offset\n";
    for (auto &[name, st_entry] : entries)
    {
        file << "Id,"<<st_entry->name << "," << st_entry->type.datatype<<(st_entry->type.is_list? "[]": "" )<< "," << st_entry->line_no << "," << st_entry->offset << "\n";
    }
  
    file.close();
}
void symbol_table_class::make_csv()
{
    ofstream file;
    file.open("../output/"+name + ".csv");
    file << "Systactic Category(token),Lexeme,Type,Line No,Offset\n";
    for (auto &[name, st_entry] : entries)
    {
        file << "Id,"<<st_entry->name << "," << st_entry->type.datatype<<(st_entry->type.is_list? "[]": "" )<< "," << st_entry->line_no << "," << st_entry->offset << "\n";
    }
    for(auto &[name, function]: functions)
    {
        function->make_csv(this->name+".");
        file<<"Function,"<<name<<",(";
        for(int i = function->get_parameter_count()-1; i>=0; i--)
        {
            file<<function->get_parameter_type_from_end(i).datatype;
            if(function->get_parameter_type_from_end(i).is_list) file<<"[]";
            if(i!=0) file<<"*";
        }
        file<<")->"<<function->get_return_type().datatype;
        if(function->get_return_type().is_list) file<<"[]";
        file<<","<<function->get_line_no()<<",None\n";
    }
        
}