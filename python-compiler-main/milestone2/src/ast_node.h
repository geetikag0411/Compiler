#include <bits/stdc++.h>
#include <unistd.h>
#include "symbol_table.hpp"
using namespace std;

class AST_Node
{
private:
    int line_no;
    string lexeme;
    int int_val;
    float real_val;
    string type;
    Type datatype;
    string category; // categories: KEYWORD, OPERATOR, NAME, DELIMITER, NUMBER, REAL_NUMBER
    bool is_terminal;
    int index;
    vector<class AST_Node *> children;

public:
    static int count;
    AST_Node(int line_no, string lexeme, string type, string category) : line_no(line_no), lexeme(lexeme), type(type), category(category)
    {
        is_terminal = true;
        datatype = {type, false};
        index = ++count;
    }
    AST_Node(int line_no, string type) : line_no(line_no), type(type)
    {
        is_terminal = false;
        index = ++count;
        datatype = {type, false};
    }
    AST_Node(Type datatype) : datatype(datatype) {}

    void set_list(bool val)
    {
        this->datatype.is_list = val;
    }
    Type get_datatype()
    {
        return datatype;
    }

    void set_datatype(Type datatype)
    {
        this->datatype = datatype;
    }

    void add_child(AST_Node *child)
    {
        children.push_back(child);
    }

    template <typename T, typename... Args>
    void add_children(T first_node, Args... args)
    {
        add_child(first_node);
        add_children(args...);
    }

    void add_children() {}

    void set_int_val(int int_val)
    {
        this->int_val = int_val;
    }

    void set_float_val(float real_val)
    {
        this->real_val = real_val;
    }

    int get_line_no()
    {
        return line_no;
    }

    int get_index()
    {
        return index;
    }

    void print_node()
    {
        cout << "line_no: " << line_no << ", lexeme: " << lexeme << ", type: " << type << endl;
    }

    string get_type()
    {
        return type;
    }

    string get_category()
    {
        return category;
    }

    string get_lexeme()
    {
        return lexeme;
    }
    void set_lexeme(string lexeme)
    {
        this->lexeme = lexeme;
    }

    Type compare_datatype(Type datatype2)
    {
        if (datatype.is_list != datatype2.is_list)
            return {"ERROR", 0};
        else if (datatype.datatype == datatype2.datatype)
            return datatype;
        else if ((datatype.datatype != "str") && (datatype2.datatype != "str"))
        {
            map<string, int> precedence = {{"bool", 0}, {"int", 1}, {"float", 2}, {"ERROR", 3}};
            if (precedence[datatype.datatype] > precedence[datatype2.datatype])
                return datatype;
            else
                return datatype2;
        }
        else return {"ERROR", 0};
    }

    void make_tree(string output_file_path)
    {
        FILE *output_file = freopen(output_file_path.c_str(), "w", stdout);
        if (!output_file)
        {
            cout << "Error: Unable to open " << output_file_path << "\n";
            return;
        }
        cout << "digraph G{\n";
        int ct = 0;

        this->index = ++ct;
        if (this->type != "STRING")
            cout << this->get_index() << " [label=\"" << this->type << " " << this->lexeme << "\\nLine" << this->line_no << "\"];" << endl;
        else
            cout << this->get_index() << " [label=\"" << this->type << "\"];" << endl;

        queue<AST_Node *> q;
        q.push(this);
        while (!q.empty())
        {
            AST_Node *curr = q.front();
            q.pop();
            for (auto &child : curr->children)
            {
                child->index = ++ct;
                if (child->is_terminal)
                {
                    cout << child->get_index() << " [label=\"" << child->get_category() << " " << (child->get_type() == "STRING" ? ("\\" + child->get_lexeme().substr(0, child->get_lexeme().size() - 1) + "\\" + child->lexeme[0]) : child->get_lexeme()) << "\\nLine" << child->get_line_no() << "\", shape=box, color=";
                    if (child->get_category() == "KEYWORD")
                        cout << "blue";
                    else if (child->get_category() == "OPERATOR")
                        cout << "red";
                    else if (child->get_category() == "NAME")
                        cout << "purple";
                    else if (child->get_category() == "DELIMITER")
                        cout << "green";
                    else if (child->get_category() == "STRING")
                        cout << "pink";
                    else
                        cout << "orange";
                    cout << "];" << endl;
                }
                else
                {
                    cout << child->get_index() << " [label=\"" << child->type << "\\nLine" << child->get_line_no() << "\"];" << endl;
                }
                cout << curr->get_index() << " -> " << child->get_index() << ";" << endl;
                q.push(child);
            }
        }
        cout << "}\n";
        fclose(output_file);

        return;
    }
    void change_line(int line_no)
    {
        this->line_no = line_no;
    }

    vector<class AST_Node *> get_children()
    {
        return children;
    }
};

// vector<AST_Node*> AST_Node::nodes;
// int AST_Node::count = 0;