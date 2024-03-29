/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 2 "parser.y"

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
    stack<string> op_3AC;
    // vector<string> curr_list_temporaries;
    void add_len_function(symbol_table_global* global_symbol_table){
        symbol_table_function* len_func = global_symbol_table->create_new_function("len");
        Type type;
        type.datatype = "any";
        type.is_list = true;
        len_func->add_parameter("a", type, 0);
        len_func->set_return_type({"int"});
                                                           
        auto len = new NonTerminal(0, "len");
        len->gen("len:");
        len->gen("begin function");
        len->gen("pushq", "$rbp");
        len->gen("$rbp","$rsp");
        len->gen("$rsp","$rsp","-",to_string(12+56));      
        len->gen("mov48","regs","-56($rbp)"); 
        len->gen("movq","16($rbp)","a");
        len->gen("a","a","-","4");
        len->gen("b","*a");
        len->gen("movq","b","$rax");
        len->gen("mov48","-56(rbp)","regs");
        len->gen("mov8","$rbp","$rsp");
        len->gen("popq", "$rbp");
        len->gen("ret");
        len->gen("end function");
        
        threeAC.push_back(len->get_code());
    }

    bool is_compatible_datatype(Type type_l, Type type_r)
    {
        if((type_l.datatype=="any"||type_r.datatype=="any")&&type_r.is_list&&type_l.is_list) return true;
        if(type_l.is_list != type_r.is_list) return false;
        if(type_l.datatype == type_r.datatype) return true;
        if((type_l.datatype == "int" || type_l.datatype == "float" || type_l.datatype == "bool") && (type_r.datatype == "int" || type_r.datatype == "float" || type_r.datatype == "bool")){ 
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

    int calculate_size(Type type){
        // TODO: what about list, 12 bytes?
        if(type.is_class) return type.class_table->get_offset();
        else if(type.datatype == "int" || type.datatype == "float") return 4;
        else if(type.datatype == "bool") return 1;
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
                cout << datatype.datatype << " " << datatype.is_list << " " << arg->get_datatype().datatype << " "  << arg->get_datatype().is_list << endl;
                cout<<"Function type mismatch for function " << curr_function.top()->get_name() << " at line no: " << arg->get_line_no() << endl;
                exit(1);
            }
        }
        auto datatype=arg->get_datatype();

        // arg->gen("param", arg->get_temporary());
        arg->gen("push"+to_string(calculate_size(datatype)), arg->get_temporary());
    }
    void relate_string(NonTerminal* result, NonTerminal* str1, NonTerminal* str2, string operation)
    {
        result->gen("pushq", str2->get_temporary());
        result->gen("pushq", str1->get_temporary());
        result->gen("call", "strcmp", "2");
        auto temp = NonTerminal::get_new_temporary();
        result->gen("$rsp", "$rsp", "+", "16");
        result->gen(temp, "$rax");
        if(operation=="==")
        {
            result->gen(result->set_temporary(), temp, "==", "0");
        }
        else if(operation=="!=")
        {
            result->gen(result->set_temporary(), temp, "!=", "0");
        }
        else if (operation =="<")
        {
            result->gen(result->set_temporary(), temp, "<", "0");
        }
        else if (operation ==">")
        {
            result->gen(result->set_temporary(), temp, ">", "0");
        }
        else if (operation =="<=")
        {
            result->gen(result->set_temporary(), temp, "<=", "0");
        }
        else if (operation ==">=")
        {
            result->gen(result->set_temporary(), temp, ">=", "0");
        }
    }

#line 231 "parser.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "parser.tab.h"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_FOR = 3,                        /* FOR  */
  YYSYMBOL_SEMICOLON = 4,                  /* SEMICOLON  */
  YYSYMBOL_KEYWORDS = 5,                   /* KEYWORDS  */
  YYSYMBOL_ASYNC = 6,                      /* ASYNC  */
  YYSYMBOL_AWAIT = 7,                      /* AWAIT  */
  YYSYMBOL_COMMENT = 8,                    /* COMMENT  */
  YYSYMBOL_DEDENT = 9,                     /* DEDENT  */
  YYSYMBOL_END = 10,                       /* END  */
  YYSYMBOL_FSTRING = 11,                   /* FSTRING  */
  YYSYMBOL_INDENT = 12,                    /* INDENT  */
  YYSYMBOL_MIDDLE = 13,                    /* MIDDLE  */
  YYSYMBOL_NAME = 14,                      /* NAME  */
  YYSYMBOL_NEWLINE = 15,                   /* NEWLINE  */
  YYSYMBOL_NUMBER = 16,                    /* NUMBER  */
  YYSYMBOL_MULTIPLY = 17,                  /* MULTIPLY  */
  YYSYMBOL_MODULO_EQUAL = 18,              /* MODULO_EQUAL  */
  YYSYMBOL_ERROR = 19,                     /* ERROR  */
  YYSYMBOL_START = 20,                     /* START  */
  YYSYMBOL_STRING = 21,                    /* STRING  */
  YYSYMBOL_TYPE = 22,                      /* TYPE  */
  YYSYMBOL_END_MARKER = 23,                /* END_MARKER  */
  YYSYMBOL_AND = 24,                       /* AND  */
  YYSYMBOL_OR = 25,                        /* OR  */
  YYSYMBOL_NOT = 26,                       /* NOT  */
  YYSYMBOL_COMMA = 27,                     /* COMMA  */
  YYSYMBOL_EQUAL_EQUAL = 28,               /* EQUAL_EQUAL  */
  YYSYMBOL_COLONEQUAL = 29,                /* COLONEQUAL  */
  YYSYMBOL_LEFT_SHIFT = 30,                /* LEFT_SHIFT  */
  YYSYMBOL_RIGHT_SHIFT = 31,               /* RIGHT_SHIFT  */
  YYSYMBOL_PLUS = 32,                      /* PLUS  */
  YYSYMBOL_MINUS = 33,                     /* MINUS  */
  YYSYMBOL_POWER = 34,                     /* POWER  */
  YYSYMBOL_DIVIDE = 35,                    /* DIVIDE  */
  YYSYMBOL_FLOOR_DIVIDE = 36,              /* FLOOR_DIVIDE  */
  YYSYMBOL_AT = 37,                        /* AT  */
  YYSYMBOL_MODULO = 38,                    /* MODULO  */
  YYSYMBOL_AND_KEYWORD = 39,               /* AND_KEYWORD  */
  YYSYMBOL_OR_KEYWORD = 40,                /* OR_KEYWORD  */
  YYSYMBOL_NOT_KEYWORD = 41,               /* NOT_KEYWORD  */
  YYSYMBOL_BITWISE_AND = 42,               /* BITWISE_AND  */
  YYSYMBOL_BITWISE_OR = 43,                /* BITWISE_OR  */
  YYSYMBOL_BITWISE_XOR = 44,               /* BITWISE_XOR  */
  YYSYMBOL_BITWISE_NOT = 45,               /* BITWISE_NOT  */
  YYSYMBOL_IN = 46,                        /* IN  */
  YYSYMBOL_IMPORT = 47,                    /* IMPORT  */
  YYSYMBOL_RANGE = 48,                     /* RANGE  */
  YYSYMBOL_YIELD = 49,                     /* YIELD  */
  YYSYMBOL_FROM = 50,                      /* FROM  */
  YYSYMBOL_ELSE = 51,                      /* ELSE  */
  YYSYMBOL_IF = 52,                        /* IF  */
  YYSYMBOL_IS = 53,                        /* IS  */
  YYSYMBOL_NOTEQUAL = 54,                  /* NOTEQUAL  */
  YYSYMBOL_LESS_THAN = 55,                 /* LESS_THAN  */
  YYSYMBOL_GREATER_THAN = 56,              /* GREATER_THAN  */
  YYSYMBOL_EQUAL = 57,                     /* EQUAL  */
  YYSYMBOL_LESS_THAN_EQUAL = 58,           /* LESS_THAN_EQUAL  */
  YYSYMBOL_COLON = 59,                     /* COLON  */
  YYSYMBOL_GREATER_THAN_EQUAL = 60,        /* GREATER_THAN_EQUAL  */
  YYSYMBOL_LEFT_SHIFT_EQUAL = 61,          /* LEFT_SHIFT_EQUAL  */
  YYSYMBOL_RIGHT_SHIFT_EQUAL = 62,         /* RIGHT_SHIFT_EQUAL  */
  YYSYMBOL_ATEQUAL = 63,                   /* ATEQUAL  */
  YYSYMBOL_FALSE_ = 64,                    /* FALSE_  */
  YYSYMBOL_TRUE_ = 65,                     /* TRUE_  */
  YYSYMBOL_NONE = 66,                      /* NONE  */
  YYSYMBOL_NONLOCAL = 67,                  /* NONLOCAL  */
  YYSYMBOL_CLOSE_BRACE = 68,               /* CLOSE_BRACE  */
  YYSYMBOL_BITWISE_OR_EQUAL = 69,          /* BITWISE_OR_EQUAL  */
  YYSYMBOL_BITWISE_AND_EQUAL = 70,         /* BITWISE_AND_EQUAL  */
  YYSYMBOL_OPEN_PAREN = 71,                /* OPEN_PAREN  */
  YYSYMBOL_CLOSE_PAREN = 72,               /* CLOSE_PAREN  */
  YYSYMBOL_POWER_EQUAL = 73,               /* POWER_EQUAL  */
  YYSYMBOL_MULTIPLY_EQUAL = 74,            /* MULTIPLY_EQUAL  */
  YYSYMBOL_PLUS_EQUAL = 75,                /* PLUS_EQUAL  */
  YYSYMBOL_MINUS_EQUAL = 76,               /* MINUS_EQUAL  */
  YYSYMBOL_ARROW = 77,                     /* ARROW  */
  YYSYMBOL_DOT = 78,                       /* DOT  */
  YYSYMBOL_ELLIPSIS = 79,                  /* ELLIPSIS  */
  YYSYMBOL_FLOOR_DIVIDE_EQUAL = 80,        /* FLOOR_DIVIDE_EQUAL  */
  YYSYMBOL_DIVIDE_EQUAL = 81,              /* DIVIDE_EQUAL  */
  YYSYMBOL_OPEN_BRACKET = 82,              /* OPEN_BRACKET  */
  YYSYMBOL_CLOSE_BRACKET = 83,             /* CLOSE_BRACKET  */
  YYSYMBOL_BITWISE_XOR_EQUAL = 84,         /* BITWISE_XOR_EQUAL  */
  YYSYMBOL_AS = 85,                        /* AS  */
  YYSYMBOL_ASSERT = 86,                    /* ASSERT  */
  YYSYMBOL_BREAK = 87,                     /* BREAK  */
  YYSYMBOL_CLASS = 88,                     /* CLASS  */
  YYSYMBOL_CONTINUE = 89,                  /* CONTINUE  */
  YYSYMBOL_DEF = 90,                       /* DEF  */
  YYSYMBOL_DEL = 91,                       /* DEL  */
  YYSYMBOL_ELIF = 92,                      /* ELIF  */
  YYSYMBOL_EXCEPT = 93,                    /* EXCEPT  */
  YYSYMBOL_FINALLY = 94,                   /* FINALLY  */
  YYSYMBOL_GLOBAL = 95,                    /* GLOBAL  */
  YYSYMBOL_LAMBDA = 96,                    /* LAMBDA  */
  YYSYMBOL_PASS = 97,                      /* PASS  */
  YYSYMBOL_RAISE = 98,                     /* RAISE  */
  YYSYMBOL_RETURN = 99,                    /* RETURN  */
  YYSYMBOL_TRY = 100,                      /* TRY  */
  YYSYMBOL_WHILE = 101,                    /* WHILE  */
  YYSYMBOL_WITH = 102,                     /* WITH  */
  YYSYMBOL_OPEN_BRACE = 103,               /* OPEN_BRACE  */
  YYSYMBOL_REAL_NUMBER = 104,              /* REAL_NUMBER  */
  YYSYMBOL_YYACCEPT = 105,                 /* $accept  */
  YYSYMBOL_file_input = 106,               /* file_input  */
  YYSYMBOL_newline_or_stmt_one_or_more = 107, /* newline_or_stmt_one_or_more  */
  YYSYMBOL_funcdef = 108,                  /* funcdef  */
  YYSYMBOL_funcdef_head = 109,             /* funcdef_head  */
  YYSYMBOL_parameters = 110,               /* parameters  */
  YYSYMBOL_func_return_type = 111,         /* func_return_type  */
  YYSYMBOL_typedargslist = 112,            /* typedargslist  */
  YYSYMBOL_stmt = 113,                     /* stmt  */
  YYSYMBOL_stmts = 114,                    /* stmts  */
  YYSYMBOL_simple_stmt = 115,              /* simple_stmt  */
  YYSYMBOL_small_stmt = 116,               /* small_stmt  */
  YYSYMBOL_global_stmt = 117,              /* global_stmt  */
  YYSYMBOL_comma_name_one_or_more = 118,   /* comma_name_one_or_more  */
  YYSYMBOL_small_stmt_semicolon_sep = 119, /* small_stmt_semicolon_sep  */
  YYSYMBOL_expr_stmt = 120,                /* expr_stmt  */
  YYSYMBOL_expr_3_or = 121,                /* expr_3_or  */
  YYSYMBOL_equal_testlist_star_expr = 122, /* equal_testlist_star_expr  */
  YYSYMBOL_testlist_star_expr = 123,       /* testlist_star_expr  */
  YYSYMBOL_augassign = 124,                /* augassign  */
  YYSYMBOL_flow_stmt = 125,                /* flow_stmt  */
  YYSYMBOL_return_stmt = 126,              /* return_stmt  */
  YYSYMBOL_compound_stmt = 127,            /* compound_stmt  */
  YYSYMBOL_if_head = 128,                  /* if_head  */
  YYSYMBOL_if_stmt = 129,                  /* if_stmt  */
  YYSYMBOL_elif_namedexpr_test_colon_suite_one_or_more = 130, /* elif_namedexpr_test_colon_suite_one_or_more  */
  YYSYMBOL_while_stmt = 131,               /* while_stmt  */
  YYSYMBOL_while_head = 132,               /* while_head  */
  YYSYMBOL_for_stmt = 133,                 /* for_stmt  */
  YYSYMBOL_for_head = 134,                 /* for_head  */
  YYSYMBOL_suite = 135,                    /* suite  */
  YYSYMBOL_namedexpr_test = 136,           /* namedexpr_test  */
  YYSYMBOL_test = 137,                     /* test  */
  YYSYMBOL_or_test = 138,                  /* or_test  */
  YYSYMBOL_and_test_star = 139,            /* and_test_star  */
  YYSYMBOL_and_test = 140,                 /* and_test  */
  YYSYMBOL_and_not_test_plus = 141,        /* and_not_test_plus  */
  YYSYMBOL_not_test = 142,                 /* not_test  */
  YYSYMBOL_not_plus_comparison = 143,      /* not_plus_comparison  */
  YYSYMBOL_comparison = 144,               /* comparison  */
  YYSYMBOL_comp_op_expr_plus = 145,        /* comp_op_expr_plus  */
  YYSYMBOL_comp_op = 146,                  /* comp_op  */
  YYSYMBOL_expr = 147,                     /* expr  */
  YYSYMBOL_r_expr = 148,                   /* r_expr  */
  YYSYMBOL_xor_expr = 149,                 /* xor_expr  */
  YYSYMBOL_x_expr = 150,                   /* x_expr  */
  YYSYMBOL_and_expr = 151,                 /* and_expr  */
  YYSYMBOL_a_expr = 152,                   /* a_expr  */
  YYSYMBOL_shift_expr = 153,               /* shift_expr  */
  YYSYMBOL_lr_shift = 154,                 /* lr_shift  */
  YYSYMBOL_arith_expr = 155,               /* arith_expr  */
  YYSYMBOL_pm_term = 156,                  /* pm_term  */
  YYSYMBOL_term = 157,                     /* term  */
  YYSYMBOL_op_fac = 158,                   /* op_fac  */
  YYSYMBOL_factor = 159,                   /* factor  */
  YYSYMBOL_power = 160,                    /* power  */
  YYSYMBOL_atom_expr = 161,                /* atom_expr  */
  YYSYMBOL_atom = 162,                     /* atom  */
  YYSYMBOL_string_one_or_more = 163,       /* string_one_or_more  */
  YYSYMBOL_testlist_comp = 164,            /* testlist_comp  */
  YYSYMBOL_comma_named_star_comma = 165,   /* comma_named_star_comma  */
  YYSYMBOL_named_star_or = 166,            /* named_star_or  */
  YYSYMBOL_comma_named_star = 167,         /* comma_named_star  */
  YYSYMBOL_exprlist = 168,                 /* exprlist  */
  YYSYMBOL_testlist = 169,                 /* testlist  */
  YYSYMBOL_classdef = 170,                 /* classdef  */
  YYSYMBOL_classdef_head = 171,            /* classdef_head  */
  YYSYMBOL_arglist = 172,                  /* arglist  */
  YYSYMBOL_comma_arg = 173,                /* comma_arg  */
  YYSYMBOL_argument = 174,                 /* argument  */
  YYSYMBOL_func_body_suite = 175,          /* func_body_suite  */
  YYSYMBOL_datatype = 176                  /* datatype  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int16 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  92
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   753

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  105
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  72
/* YYNRULES -- Number of rules.  */
#define YYNRULES  198
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  305

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   359


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   182,   182,   183,   186,   187,   188,   189,   192,   223,
     248,   267,   268,   271,   272,   278,   285,   293,   311,   315,
     318,   319,   322,   325,   326,   327,   330,   351,   374,   396,
     419,   420,   421,   424,   475,   490,   535,   536,   585,   595,
     603,   606,   614,   617,   618,   619,   620,   621,   622,   623,
     624,   625,   626,   627,   628,   632,   633,   634,   637,   644,
     654,   655,   656,   657,   658,   661,   665,   673,   685,   697,
     713,   723,   741,   756,   772,   778,   809,   835,   861,   912,
     921,   922,   925,   926,   942,   950,   951,   961,   962,   971,
     972,   982,   983,   992,   993,   996,  1004,  1013,  1038,  1041,
    1047,  1074,  1075,  1076,  1077,  1078,  1079,  1080,  1081,  1082,
    1083,  1088,  1101,  1104,  1117,  1120,  1133,  1136,  1149,  1152,
    1165,  1168,  1181,  1184,  1198,  1201,  1212,  1223,  1238,  1255,
    1269,  1272,  1283,  1294,  1309,  1325,  1326,  1342,  1343,  1344,
    1345,  1346,  1362,  1378,  1394,  1412,  1421,  1435,  1446,  1449,
    1450,  1466,  1467,  1483,  1531,  1573,  1595,  1618,  1681,  1730,
    1763,  1800,  1803,  1804,  1805,  1806,  1867,  1868,  1869,  1870,
    1871,  1872,  1876,  1877,  1880,  1891,  1897,  1898,  1899,  1901,
    1909,  1910,  1913,  1917,  1923,  1935,  1942,  1947,  1955,  1956,
    1957,  1958,  1961,  1962,  1965,  1971,  1972,  1975,  1987
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "FOR", "SEMICOLON",
  "KEYWORDS", "ASYNC", "AWAIT", "COMMENT", "DEDENT", "END", "FSTRING",
  "INDENT", "MIDDLE", "NAME", "NEWLINE", "NUMBER", "MULTIPLY",
  "MODULO_EQUAL", "ERROR", "START", "STRING", "TYPE", "END_MARKER", "AND",
  "OR", "NOT", "COMMA", "EQUAL_EQUAL", "COLONEQUAL", "LEFT_SHIFT",
  "RIGHT_SHIFT", "PLUS", "MINUS", "POWER", "DIVIDE", "FLOOR_DIVIDE", "AT",
  "MODULO", "AND_KEYWORD", "OR_KEYWORD", "NOT_KEYWORD", "BITWISE_AND",
  "BITWISE_OR", "BITWISE_XOR", "BITWISE_NOT", "IN", "IMPORT", "RANGE",
  "YIELD", "FROM", "ELSE", "IF", "IS", "NOTEQUAL", "LESS_THAN",
  "GREATER_THAN", "EQUAL", "LESS_THAN_EQUAL", "COLON",
  "GREATER_THAN_EQUAL", "LEFT_SHIFT_EQUAL", "RIGHT_SHIFT_EQUAL", "ATEQUAL",
  "FALSE_", "TRUE_", "NONE", "NONLOCAL", "CLOSE_BRACE", "BITWISE_OR_EQUAL",
  "BITWISE_AND_EQUAL", "OPEN_PAREN", "CLOSE_PAREN", "POWER_EQUAL",
  "MULTIPLY_EQUAL", "PLUS_EQUAL", "MINUS_EQUAL", "ARROW", "DOT",
  "ELLIPSIS", "FLOOR_DIVIDE_EQUAL", "DIVIDE_EQUAL", "OPEN_BRACKET",
  "CLOSE_BRACKET", "BITWISE_XOR_EQUAL", "AS", "ASSERT", "BREAK", "CLASS",
  "CONTINUE", "DEF", "DEL", "ELIF", "EXCEPT", "FINALLY", "GLOBAL",
  "LAMBDA", "PASS", "RAISE", "RETURN", "TRY", "WHILE", "WITH",
  "OPEN_BRACE", "REAL_NUMBER", "$accept", "file_input",
  "newline_or_stmt_one_or_more", "funcdef", "funcdef_head", "parameters",
  "func_return_type", "typedargslist", "stmt", "stmts", "simple_stmt",
  "small_stmt", "global_stmt", "comma_name_one_or_more",
  "small_stmt_semicolon_sep", "expr_stmt", "expr_3_or",
  "equal_testlist_star_expr", "testlist_star_expr", "augassign",
  "flow_stmt", "return_stmt", "compound_stmt", "if_head", "if_stmt",
  "elif_namedexpr_test_colon_suite_one_or_more", "while_stmt",
  "while_head", "for_stmt", "for_head", "suite", "namedexpr_test", "test",
  "or_test", "and_test_star", "and_test", "and_not_test_plus", "not_test",
  "not_plus_comparison", "comparison", "comp_op_expr_plus", "comp_op",
  "expr", "r_expr", "xor_expr", "x_expr", "and_expr", "a_expr",
  "shift_expr", "lr_shift", "arith_expr", "pm_term", "term", "op_fac",
  "factor", "power", "atom_expr", "atom", "string_one_or_more",
  "testlist_comp", "comma_named_star_comma", "named_star_or",
  "comma_named_star", "exprlist", "testlist", "classdef", "classdef_head",
  "arglist", "comma_arg", "argument", "func_body_suite", "datatype", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-227)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     275,  -227,   -35,  -227,  -227,  -227,  -227,   596,   649,   649,
     649,  -227,  -227,  -227,  -227,   140,   510,  -227,    16,  -227,
      23,    36,   596,  -227,  -227,    41,   302,  -227,   -18,  -227,
    -227,    51,  -227,    47,  -227,   628,  -227,  -227,  -227,   596,
    -227,  -227,   596,  -227,   649,  -227,  -227,   596,    46,   596,
      50,  -227,  -227,   649,   187,   649,    45,   649,    35,   649,
      48,   649,    27,   649,    75,   649,     8,  -227,   -22,    14,
      79,  -227,     2,    90,  -227,  -227,  -227,    59,  -227,  -227,
    -227,  -227,  -227,    80,    44,    98,  -227,    52,   -20,  -227,
     105,  -227,  -227,  -227,  -227,  -227,     5,   -32,   496,  -227,
    -227,   596,  -227,  -227,  -227,  -227,  -227,  -227,  -227,  -227,
    -227,  -227,  -227,  -227,  -227,   596,    74,    81,  -227,    88,
     114,  -227,   118,  -227,   187,   106,  -227,  -227,   125,  -227,
    -227,  -227,  -227,  -227,  -227,   112,  -227,   116,  -227,   120,
    -227,    87,  -227,  -227,    95,  -227,  -227,    86,  -227,  -227,
    -227,  -227,   649,   573,   144,   596,   649,   587,   149,   596,
    -227,   152,  -227,  -227,    83,   110,   154,   596,  -227,   596,
    -227,   142,  -227,  -227,     6,   156,  -227,   115,  -227,    11,
      49,    -5,   117,  -227,  -227,  -227,  -227,     2,     2,   123,
    -227,  -227,  -227,  -227,  -227,  -227,  -227,  -227,  -227,  -227,
    -227,  -227,  -227,  -227,  -227,  -227,  -227,  -227,  -227,   103,
     150,  -227,    96,  -227,  -227,   109,   119,    99,   469,   169,
     596,  -227,  -227,  -227,   596,   121,   127,   105,    90,   170,
    -227,   177,  -227,  -227,  -227,  -227,    49,     3,   141,   124,
    -227,   596,   164,  -227,  -227,    90,  -227,  -227,   372,   111,
    -227,  -227,   137,  -227,  -227,  -227,   138,   469,  -227,   139,
     596,   151,   148,   596,   173,  -227,   146,  -227,  -227,  -227,
    -227,    90,   399,     2,   157,   158,     2,    15,   596,  -227,
     596,  -227,  -227,  -227,     2,     2,  -227,   596,   160,  -227,
     128,  -227,   129,     2,  -227,   162,   159,     2,   165,   172,
       2,   166,  -227,     2,  -227
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,    79,   165,     6,   166,   173,     2,     0,     0,     0,
       0,    65,   170,   169,   168,     0,     0,    55,     0,    56,
       0,     0,    58,    74,   171,     0,     0,    63,     0,     7,
      18,    31,    25,     0,    23,    36,    24,    57,    19,     0,
      60,    61,     0,    62,     0,    42,    84,     0,    85,     0,
      89,    93,    94,     0,    98,     0,   112,     0,   116,     0,
     120,     0,   124,     0,   130,     0,   135,   148,   149,   151,
     167,    64,     0,     0,   165,    96,    95,   151,   145,   146,
     147,   162,   179,    82,     0,   175,   164,     0,     0,    10,
      26,    59,     1,     4,     3,     5,     0,     0,    32,    22,
      47,     0,    51,    52,    49,    48,    53,    45,    43,    44,
      54,    46,    50,    33,    40,     0,     0,     0,   182,     0,
      86,    87,    90,    91,    97,     0,   103,   107,   109,   106,
     102,   101,   105,   104,    99,   111,   114,   115,   118,   119,
     122,   123,   125,   126,   129,   131,   132,   136,   137,   138,
     140,   139,     0,     0,     0,     0,     0,     0,     0,     0,
     172,     0,    80,   184,   197,    34,     0,     0,   161,   178,
     174,   177,   163,   185,     0,     0,    27,    17,    11,     0,
       0,     0,     0,    30,    41,   183,    39,     0,     0,     0,
      88,    92,   100,   108,   110,   113,   117,   121,   127,   128,
     133,   134,   141,   142,   144,   143,   150,   159,   194,     0,
     190,   154,     0,   152,   158,     0,   153,     0,     0,     0,
       0,   153,    83,   180,   176,     0,     0,    28,     0,     0,
      12,     0,   195,     8,    14,    13,     0,    66,    72,     0,
     160,   191,   188,   156,   157,     0,   155,    21,     0,     0,
      35,   181,     0,   186,    29,    15,     0,     0,     9,     0,
       0,    67,     0,     0,   192,   189,    38,    81,    20,   198,
     187,     0,     0,     0,     0,     0,     0,     0,     0,   193,
       0,    16,   196,    68,     0,     0,    73,     0,     0,    37,
      71,    69,     0,     0,    70,     0,    76,     0,     0,    75,
       0,     0,    77,     0,    78
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -227,  -227,  -227,  -227,  -227,  -227,  -227,  -227,     7,   -49,
      10,  -227,  -227,    -1,   132,  -227,  -227,  -227,   -21,  -227,
    -227,  -227,  -227,  -227,  -227,   -81,  -227,  -227,  -227,  -227,
    -174,   -31,   -10,  -227,  -227,   180,  -227,   183,   227,   228,
    -227,   113,   -13,  -227,   184,  -227,   181,  -227,   190,  -227,
     191,  -227,   188,  -227,    -6,  -227,  -227,     0,  -227,   238,
    -227,  -148,  -227,  -227,  -227,  -227,  -227,   104,    -8,  -226,
      24,  -159
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,    25,    26,    27,    28,    97,   182,   179,   247,   248,
     162,    31,    32,   176,    33,    34,   113,   114,    35,   115,
      36,    37,    38,    39,    40,   261,    41,    42,    43,    44,
     163,    82,    45,    46,    47,    48,    49,    50,    51,    52,
      53,   134,    54,    55,    56,    57,    58,    59,    60,    61,
      62,    63,    64,    65,    66,    67,    68,    77,    70,    84,
     170,    85,   171,   119,   186,    71,    72,   209,   242,   210,
     233,   165
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      69,    91,    78,    79,    80,    83,    83,    29,   116,   164,
      30,   117,   152,   237,   238,   264,     2,   161,     4,   177,
     225,   223,   235,     5,    73,   148,    69,   180,     7,    83,
      88,   118,    83,    95,     8,     9,    30,    89,   229,   173,
     124,    92,   287,   149,   150,   181,   151,    10,   156,   153,
      90,   174,   264,    96,   259,    98,   154,   142,   143,   147,
     155,   234,    99,     2,   231,     4,    12,    13,    14,   255,
       5,   121,    69,    15,   123,     7,   251,   178,   226,   138,
     184,     8,     9,   230,    16,   157,   266,   288,   136,    17,
     140,    19,   158,   156,    10,   260,   159,    21,    69,   283,
     160,    22,   286,   202,   164,   185,    24,   145,   146,   167,
     290,   291,   281,    12,    13,    14,   168,   198,   199,   296,
      15,   203,   204,   299,   205,   169,   302,   200,   201,   304,
     157,    16,   175,   187,   189,   172,    17,   166,    19,   190,
     188,   159,   191,   208,    21,   212,   206,   208,    22,   217,
     213,   194,   193,    24,    74,   195,     4,   222,   211,    83,
     196,     5,   197,   216,   218,   219,     7,   220,   221,   224,
     227,   239,     8,     9,   228,   240,   236,   241,   245,   243,
      69,   244,   246,   249,   256,    10,   253,    69,    69,   257,
     232,   265,   262,   252,   269,   263,   270,   271,   273,   250,
     278,   295,   275,   280,    12,    13,    14,   276,   272,   294,
     298,    15,    81,   125,    83,   126,   284,   285,    69,   293,
     260,   297,    16,   301,   300,   303,   254,   120,    30,   274,
     183,   208,   122,   127,    75,    76,    69,   192,   137,   135,
     128,   129,   130,   131,    24,   132,   232,   133,    69,   139,
      83,   144,   141,   277,    87,   268,   279,    69,    30,   289,
     258,   215,     0,     0,     0,     0,     0,    30,   208,     0,
       0,     0,    69,    69,     0,     0,    69,   292,     1,   268,
       0,     0,    30,     0,    69,    69,     0,     0,     0,     2,
       3,     4,     0,    69,     0,     0,     5,    69,     6,     0,
      69,     7,     0,    69,     0,     1,     0,     8,     9,     0,
       0,     0,     0,     0,     0,     0,     2,    93,     4,     0,
      10,     0,     0,     5,     0,    94,     0,    11,     7,     0,
       0,     0,     0,     0,     8,     9,     0,     0,     0,    12,
      13,    14,     0,     0,     0,     0,    15,    10,     0,     0,
       0,     0,     0,     0,    11,     0,     0,    16,     0,     0,
       0,     0,    17,    18,    19,    20,    12,    13,    14,     0,
      21,     0,     0,    15,    22,     1,    23,     0,     0,    24,
       0,   267,     0,     0,    16,     0,     2,     0,     4,    17,
      18,    19,    20,     5,     0,     0,     0,    21,     7,     0,
       0,    22,     1,    23,     8,     9,    24,     0,   282,     0,
       0,     0,     0,     2,     0,     4,     0,    10,     0,     0,
       5,     0,     0,     0,    11,     7,     0,     0,     0,     0,
       0,     8,     9,     0,     0,     0,    12,    13,    14,     0,
       0,     0,     0,    15,    10,     0,     0,     0,     0,     0,
       0,    11,     0,     0,    16,     0,     0,     0,     0,    17,
      18,    19,    20,    12,    13,    14,     0,    21,     0,     0,
      15,    22,     1,    23,     0,     0,    24,     0,     0,     0,
       0,    16,     0,     2,     0,     4,    17,    18,    19,    20,
       5,     0,     0,     0,    21,     7,     0,     0,    22,     0,
      23,     8,     9,    24,     0,     0,     0,     0,     0,     0,
       2,     0,     4,     0,    10,     0,     0,     5,     0,     0,
       0,    11,     7,     0,    74,     0,     4,     0,     8,     9,
       0,     5,     0,    12,    13,    14,     7,     0,     0,     0,
      15,    10,     8,     9,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,    10,    17,    18,    19,    20,
      12,    13,    14,     0,    21,     0,     0,    15,    22,     0,
      23,     0,     0,    24,    12,    13,    14,     0,    16,     0,
       0,    15,     0,    17,     0,    19,     0,    74,     0,     4,
       0,    21,    16,    86,     5,    22,     0,     0,     0,     7,
      24,    74,     0,     4,     0,     8,     9,     0,     5,     0,
      74,     0,     4,     7,    24,     0,     0,     5,    10,     8,
       9,     0,     7,     0,     0,     0,     0,     0,     8,     9,
       0,     0,    10,     0,     0,     0,     0,    12,    13,    14,
       0,    10,     0,     0,    15,   207,   100,     0,     0,     0,
       0,    12,    13,    14,     0,    16,     0,     0,    15,   214,
      12,    13,    14,    74,     0,     4,     0,    15,     0,    16,
       5,     0,     0,     0,     0,     0,     0,    24,    16,     0,
       0,     8,     9,     0,     0,   101,     0,     0,     0,   102,
     103,    24,     0,     0,    10,     0,     0,   104,   105,     0,
      24,   106,   107,   108,   109,     0,     0,     0,   110,   111,
       0,     0,   112,    12,    13,    14,     0,     0,     0,     0,
      15,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    16,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    24
};

static const yytype_int16 yycheck[] =
{
       0,    22,     8,     9,    10,    15,    16,     0,    39,    14,
       0,    42,    34,   187,   188,   241,    14,    15,    16,    14,
      14,   169,   181,    21,    59,    17,    26,    59,    26,    39,
      14,    44,    42,    26,    32,    33,    26,    14,    27,    59,
      53,     0,    27,    35,    36,    77,    38,    45,    34,    71,
      14,    71,   278,    71,    51,     4,    78,    30,    31,    65,
      82,    66,    15,    14,    15,    16,    64,    65,    66,   228,
      21,    25,    72,    71,    24,    26,   224,    72,    72,    44,
     101,    32,    33,    72,    82,    71,   245,    72,    43,    87,
      42,    89,    78,    34,    45,    92,    82,    95,    98,   273,
      21,    99,   276,    17,    14,   115,   104,    32,    33,    29,
     284,   285,   271,    64,    65,    66,    72,    30,    31,   293,
      71,    35,    36,   297,    38,    27,   300,    32,    33,   303,
      71,    82,    27,    59,    46,    83,    87,    78,    89,    25,
      59,    82,    24,   153,    95,   155,   152,   157,    99,   159,
     156,    26,    46,   104,    14,    43,    16,   167,    14,   169,
      44,    21,    42,    14,    12,    82,    26,    57,    14,    27,
      14,    48,    32,    33,    59,    72,    59,    27,    59,    83,
     180,    72,    83,    14,    14,    45,    59,   187,   188,    12,
     180,    27,    51,    72,    83,    71,    59,    59,    59,   220,
      27,    72,    51,    57,    64,    65,    66,    59,   257,   290,
      51,    71,    72,    26,   224,    28,    59,    59,   218,    59,
      92,    59,    82,    51,    59,    59,   227,    47,   218,   260,
      98,   241,    49,    46,     7,     7,   236,   124,    57,    55,
      53,    54,    55,    56,   104,    58,   236,    60,   248,    59,
     260,    63,    61,   263,    16,   248,   264,   257,   248,   280,
     236,   157,    -1,    -1,    -1,    -1,    -1,   257,   278,    -1,
      -1,    -1,   272,   273,    -1,    -1,   276,   287,     3,   272,
      -1,    -1,   272,    -1,   284,   285,    -1,    -1,    -1,    14,
      15,    16,    -1,   293,    -1,    -1,    21,   297,    23,    -1,
     300,    26,    -1,   303,    -1,     3,    -1,    32,    33,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    14,    15,    16,    -1,
      45,    -1,    -1,    21,    -1,    23,    -1,    52,    26,    -1,
      -1,    -1,    -1,    -1,    32,    33,    -1,    -1,    -1,    64,
      65,    66,    -1,    -1,    -1,    -1,    71,    45,    -1,    -1,
      -1,    -1,    -1,    -1,    52,    -1,    -1,    82,    -1,    -1,
      -1,    -1,    87,    88,    89,    90,    64,    65,    66,    -1,
      95,    -1,    -1,    71,    99,     3,   101,    -1,    -1,   104,
      -1,     9,    -1,    -1,    82,    -1,    14,    -1,    16,    87,
      88,    89,    90,    21,    -1,    -1,    -1,    95,    26,    -1,
      -1,    99,     3,   101,    32,    33,   104,    -1,     9,    -1,
      -1,    -1,    -1,    14,    -1,    16,    -1,    45,    -1,    -1,
      21,    -1,    -1,    -1,    52,    26,    -1,    -1,    -1,    -1,
      -1,    32,    33,    -1,    -1,    -1,    64,    65,    66,    -1,
      -1,    -1,    -1,    71,    45,    -1,    -1,    -1,    -1,    -1,
      -1,    52,    -1,    -1,    82,    -1,    -1,    -1,    -1,    87,
      88,    89,    90,    64,    65,    66,    -1,    95,    -1,    -1,
      71,    99,     3,   101,    -1,    -1,   104,    -1,    -1,    -1,
      -1,    82,    -1,    14,    -1,    16,    87,    88,    89,    90,
      21,    -1,    -1,    -1,    95,    26,    -1,    -1,    99,    -1,
     101,    32,    33,   104,    -1,    -1,    -1,    -1,    -1,    -1,
      14,    -1,    16,    -1,    45,    -1,    -1,    21,    -1,    -1,
      -1,    52,    26,    -1,    14,    -1,    16,    -1,    32,    33,
      -1,    21,    -1,    64,    65,    66,    26,    -1,    -1,    -1,
      71,    45,    32,    33,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    82,    -1,    -1,    -1,    45,    87,    88,    89,    90,
      64,    65,    66,    -1,    95,    -1,    -1,    71,    99,    -1,
     101,    -1,    -1,   104,    64,    65,    66,    -1,    82,    -1,
      -1,    71,    -1,    87,    -1,    89,    -1,    14,    -1,    16,
      -1,    95,    82,    83,    21,    99,    -1,    -1,    -1,    26,
     104,    14,    -1,    16,    -1,    32,    33,    -1,    21,    -1,
      14,    -1,    16,    26,   104,    -1,    -1,    21,    45,    32,
      33,    -1,    26,    -1,    -1,    -1,    -1,    -1,    32,    33,
      -1,    -1,    45,    -1,    -1,    -1,    -1,    64,    65,    66,
      -1,    45,    -1,    -1,    71,    72,    18,    -1,    -1,    -1,
      -1,    64,    65,    66,    -1,    82,    -1,    -1,    71,    72,
      64,    65,    66,    14,    -1,    16,    -1,    71,    -1,    82,
      21,    -1,    -1,    -1,    -1,    -1,    -1,   104,    82,    -1,
      -1,    32,    33,    -1,    -1,    57,    -1,    -1,    -1,    61,
      62,   104,    -1,    -1,    45,    -1,    -1,    69,    70,    -1,
     104,    73,    74,    75,    76,    -1,    -1,    -1,    80,    81,
      -1,    -1,    84,    64,    65,    66,    -1,    -1,    -1,    -1,
      71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    82,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   104
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     3,    14,    15,    16,    21,    23,    26,    32,    33,
      45,    52,    64,    65,    66,    71,    82,    87,    88,    89,
      90,    95,    99,   101,   104,   106,   107,   108,   109,   113,
     115,   116,   117,   119,   120,   123,   125,   126,   127,   128,
     129,   131,   132,   133,   134,   137,   138,   139,   140,   141,
     142,   143,   144,   145,   147,   148,   149,   150,   151,   152,
     153,   154,   155,   156,   157,   158,   159,   160,   161,   162,
     163,   170,   171,    59,    14,   143,   144,   162,   159,   159,
     159,    72,   136,   137,   164,   166,    83,   164,    14,    14,
      14,   123,     0,    15,    23,   113,    71,   110,     4,    15,
      18,    57,    61,    62,    69,    70,    73,    74,    75,    76,
      80,    81,    84,   121,   122,   124,   136,   136,   147,   168,
     140,    25,   142,    24,   147,    26,    28,    46,    53,    54,
      55,    56,    58,    60,   146,   149,    43,   151,    44,   153,
      42,   155,    30,    31,   157,    32,    33,   159,    17,    35,
      36,    38,    34,    71,    78,    82,    34,    71,    78,    82,
      21,    15,   115,   135,    14,   176,    78,    29,    72,    27,
     165,   167,    83,    59,    71,    27,   118,    14,    72,   112,
      59,    77,   111,   119,   123,   137,   169,    59,    59,    46,
      25,    24,   146,    46,    26,    43,    44,    42,    30,    31,
      32,    33,    17,    35,    36,    38,   159,    72,   137,   172,
     174,    14,   137,   159,    72,   172,    14,   137,    12,    82,
      57,    14,   137,   166,    27,    14,    72,    14,    59,    27,
      72,    15,   115,   175,    66,   176,    59,   135,   135,    48,
      72,    27,   173,    83,    72,    59,    83,   113,   114,    14,
     123,   166,    72,    59,   118,   176,    14,    12,   175,    51,
      92,   130,    51,    71,   174,    27,   176,     9,   113,    83,
      59,    59,   114,    59,   136,    51,    59,   137,    27,   173,
      57,   176,     9,   135,    59,    59,   135,    27,    72,   123,
     135,   135,   137,    59,   130,    72,   135,    59,    51,   135,
      59,    51,   135,    59,   135
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_uint8 yyr1[] =
{
       0,   105,   106,   106,   107,   107,   107,   107,   108,   108,
     109,   110,   110,   111,   111,   112,   112,   112,   113,   113,
     114,   114,   115,   116,   116,   116,   117,   117,   118,   118,
     119,   119,   119,   120,   120,   120,   120,   120,   120,   121,
     121,   122,   123,   124,   124,   124,   124,   124,   124,   124,
     124,   124,   124,   124,   124,   125,   125,   125,   126,   126,
     127,   127,   127,   127,   127,   128,   129,   129,   129,   129,
     130,   130,   131,   131,   132,   133,   133,   133,   133,   134,
     135,   135,   136,   136,   137,   138,   138,   139,   139,   140,
     140,   141,   141,   142,   142,   143,   143,   144,   144,   145,
     145,   146,   146,   146,   146,   146,   146,   146,   146,   146,
     146,   147,   147,   148,   148,   149,   149,   150,   150,   151,
     151,   152,   152,   153,   153,   154,   154,   154,   154,   155,
     155,   156,   156,   156,   156,   157,   157,   158,   158,   158,
     158,   158,   158,   158,   158,   159,   159,   159,   159,   160,
     160,   160,   160,   161,   161,   161,   161,   161,   161,   161,
     161,   162,   162,   162,   162,   162,   162,   162,   162,   162,
     162,   162,   163,   163,   164,   164,   165,   165,   165,   166,
     167,   167,   168,   169,   170,   171,   171,   171,   172,   172,
     172,   172,   173,   173,   174,   175,   175,   176,   176
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     2,     2,     2,     1,     1,     4,     5,
       2,     2,     3,     2,     2,     3,     5,     1,     1,     1,
       2,     1,     2,     1,     1,     1,     2,     3,     2,     3,
       3,     1,     2,     2,     3,     5,     1,     7,     5,     2,
       1,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     2,
       1,     1,     1,     1,     1,     1,     4,     5,     7,     8,
       5,     4,     4,     7,     1,    11,     9,    12,    14,     1,
       1,     4,     1,     3,     1,     1,     2,     2,     3,     1,
       2,     2,     3,     1,     1,     2,     2,     2,     1,     2,
       3,     1,     1,     1,     1,     1,     1,     1,     2,     1,
       2,     2,     1,     3,     2,     2,     1,     3,     2,     2,
       1,     3,     2,     2,     1,     2,     2,     3,     3,     2,
       1,     2,     2,     3,     3,     1,     2,     2,     2,     2,
       2,     3,     3,     3,     3,     2,     2,     2,     1,     1,
       3,     1,     3,     3,     3,     4,     4,     4,     3,     3,
       4,     3,     2,     3,     2,     1,     1,     1,     1,     1,
       1,     1,     2,     1,     2,     1,     2,     1,     1,     1,
       2,     3,     1,     1,     2,     3,     5,     6,     2,     3,
       1,     2,     2,     3,     1,     1,     4,     1,     4
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 3: /* file_input: newline_or_stmt_one_or_more END_MARKER  */
#line 183 "parser.y"
                                         {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal);}
#line 1734 "parser.tab.c"
    break;

  case 4: /* newline_or_stmt_one_or_more: newline_or_stmt_one_or_more NEWLINE  */
#line 186 "parser.y"
                                                                 {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal);}
#line 1740 "parser.tab.c"
    break;

  case 5: /* newline_or_stmt_one_or_more: newline_or_stmt_one_or_more stmt  */
#line 187 "parser.y"
                                   { (yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));}
#line 1746 "parser.tab.c"
    break;

  case 6: /* newline_or_stmt_one_or_more: NEWLINE  */
#line 188 "parser.y"
          { (yyval.nonTerminal) = new NonTerminal(yylineno, "Newline");}
#line 1752 "parser.tab.c"
    break;

  case 7: /* newline_or_stmt_one_or_more: stmt  */
#line 189 "parser.y"
       {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 1758 "parser.tab.c"
    break;

  case 8: /* funcdef: funcdef_head parameters COLON func_body_suite  */
#line 192 "parser.y"
                                                        {
                                                            if((yyvsp[-3].nonTerminal)->get_lexeme() != "__init__" && (yyvsp[-3].nonTerminal)->get_lexeme() != "main"){
                                                                cout << "Return type not specified for function at line no: " << (yyvsp[-3].nonTerminal)->get_line_no() << endl;
                                                                exit(-1);
                                                            }
                                                            Type new_type;
                                                            new_type.datatype = "None";
                                                            curr_symbol_table->set_return_type(new_type);
                                                            curr_symbol_table->set_line_no((yyvsp[-3].nonTerminal)->get_line_no());
                                                            if(symbol_table_stack.size() == 0){
                                                                 cout << "trying to pop empty stack" << endl;
                                                                exit(-1);
                                                            }

                                                            (yyval.nonTerminal) = (yyvsp[-3].nonTerminal);     
                                                            (yyval.nonTerminal)->gen("pushq", "$rbp");
                                                            (yyval.nonTerminal)->gen("$rbp","$rsp");
                                                            (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));
                                                            //wrong need to subtract the of
                                                            (yyval.nonTerminal)->gen("$rsp","$rsp","-",to_string(curr_symbol_table->get_offset()+56));      
                                                            (yyval.nonTerminal)->gen("mov48","regs","-56(rbp)");                                      
                                                            (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
                                                            (yyval.nonTerminal)->gen("mov48","-56(rbp)","regs");
                                                            (yyval.nonTerminal)->gen("mov8","$rbp","$rsp");
                                                            (yyval.nonTerminal)->gen("popq", "$rbp");
                                                            (yyval.nonTerminal)->gen("ret");
                                                            (yyval.nonTerminal)->gen("end function");
                                                            threeAC.push_back((yyval.nonTerminal)->get_code());
                                                            symbol_table_stack.pop();
                                                            curr_symbol_table = symbol_table_stack.top();
                                                        }
#line 1794 "parser.tab.c"
    break;

  case 9: /* funcdef: funcdef_head parameters func_return_type COLON func_body_suite  */
#line 223 "parser.y"
                                                                    { 
                                                                        if(symbol_table_stack.size() == 0)
                                                                        {
                                                                            cout << "trying to pop empty stack" << endl; 
                                                                            exit(-1);
                                                                        }
                                                                        curr_symbol_table->set_line_no((yyvsp[-4].nonTerminal)->get_line_no());
                                                                        (yyval.nonTerminal) = (yyvsp[-4].nonTerminal);                                                       
                                                                        (yyval.nonTerminal)->gen("pushq", "$rbp");
                                                                        (yyval.nonTerminal)->gen("$rbp","$rsp");
                                                                        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
                                                                        (yyval.nonTerminal)->gen("$rsp","$rsp","-",to_string(curr_symbol_table->get_offset()+56));
                                                                        (yyval.nonTerminal)->gen("mov48","regs","-56(rbp)");
                                                                        (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
                                                                        (yyval.nonTerminal)->gen("mov48","-56(rbp)","regs");
                                                                        (yyval.nonTerminal)->gen("mov8","$rbp","$rsp");
                                                                        (yyval.nonTerminal)->gen("popq", "$rbp");
                                                                        (yyval.nonTerminal)->gen("ret");
                                                                        (yyval.nonTerminal)->gen("end function");
                                                                        symbol_table_stack.pop(); 
                                                                        threeAC.push_back((yyval.nonTerminal)->get_code());
                                                                        curr_symbol_table = symbol_table_stack.top();
                                                                    }
#line 1822 "parser.tab.c"
    break;

  case 10: /* funcdef_head: DEF NAME  */
#line 248 "parser.y"
                        {
                            auto func_symbol_table = curr_symbol_table->create_new_function((yyvsp[0].nonTerminal)->get_lexeme()); 
                            symbol_table_stack.push(func_symbol_table); 
                            (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme());
                            if(curr_symbol_table->get_symbol_table_type() == 2)
                            {
                                (yyval.nonTerminal)->gen(curr_symbol_table->get_name()+ "." + (yyvsp[0].nonTerminal)->get_lexeme() + ":");
                            }
                            else 
                            {
                                (yyval.nonTerminal)->gen((yyvsp[0].nonTerminal)->get_lexeme()+":");
                            }
                            (yyval.nonTerminal)->gen("begin function");
                            curr_symbol_table = func_symbol_table; 
                            
                            
                        }
#line 1844 "parser.tab.c"
    break;

  case 11: /* parameters: OPEN_PAREN CLOSE_PAREN  */
#line 267 "parser.y"
                                   {(yyval.nonTerminal) = new NonTerminal((yyvsp[-1].nonTerminal)->get_line_no());}
#line 1850 "parser.tab.c"
    break;

  case 12: /* parameters: OPEN_PAREN typedargslist CLOSE_PAREN  */
#line 268 "parser.y"
                                       {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal);}
#line 1856 "parser.tab.c"
    break;

  case 13: /* func_return_type: ARROW datatype  */
#line 271 "parser.y"
                                 {curr_symbol_table->set_return_type(*(yyvsp[0].type));}
#line 1862 "parser.tab.c"
    break;

  case 14: /* func_return_type: ARROW NONE  */
#line 272 "parser.y"
                {
                    Type type = {"None", 0}; 
                    curr_symbol_table->set_return_type(type);
                }
#line 1871 "parser.tab.c"
    break;

  case 15: /* typedargslist: NAME COLON datatype  */
#line 278 "parser.y"
                                    {
                                        (yyval.nonTerminal) = new NonTerminal((yyvsp[-2].nonTerminal)->get_line_no());
                                        auto offset= curr_symbol_table->get_offset();
                                        (yyval.nonTerminal)->gen("mov"+to_string(calculate_size(*(yyvsp[0].type))),to_string(offset + 16)+"(rbp)",(yyvsp[-2].nonTerminal)->get_lexeme());
                                        curr_symbol_table->add_parameter((yyvsp[-2].nonTerminal)->get_lexeme(),*(yyvsp[0].type),(yyvsp[-2].nonTerminal)->get_line_no());
                                        
                                    }
#line 1883 "parser.tab.c"
    break;

  case 16: /* typedargslist: typedargslist COMMA NAME COLON datatype  */
#line 285 "parser.y"
                                            {
                                                
                                                auto offset= curr_symbol_table->get_offset();
                                                (yyval.nonTerminal) = (yyvsp[-4].nonTerminal);
                                                (yyval.nonTerminal)->gen("mov"+to_string(calculate_size(*(yyvsp[0].type))),to_string(offset+16)+"(rbp)",(yyvsp[-2].nonTerminal)->get_lexeme());
                                                curr_symbol_table->add_parameter((yyvsp[-2].nonTerminal)->get_lexeme(),*(yyvsp[0].type),(yyvsp[-4].nonTerminal)->get_line_no());
                                                // $$->gen($3->get_lexeme(), "popparam");
                                            }
#line 1896 "parser.tab.c"
    break;

  case 17: /* typedargslist: NAME  */
#line 293 "parser.y"
       {
            (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
            if((yyvsp[0].nonTerminal)->get_lexeme() != "self")
            {
                cout << "datatype for function parameter " << (yyvsp[0].nonTerminal)->get_lexeme() <<  " not specified on line no: "<< (yyvsp[0].nonTerminal)->get_line_no() << "\n"; 
                exit(-1);
            }
            Type new_type;
            symbol_table_class* parent_class_st = curr_symbol_table->get_parent_class_st();
            new_type.datatype = parent_class_st->get_name();
            new_type.is_class = true;
            new_type.class_table = parent_class_st;
            auto offset= curr_symbol_table->get_offset();
            curr_symbol_table->add_parameter((yyvsp[0].nonTerminal)->get_lexeme(),new_type,(yyvsp[0].nonTerminal)->get_line_no());
            (yyval.nonTerminal)->gen("mov8",to_string(offset+16)+"(rbp)",(yyvsp[0].nonTerminal)->get_lexeme());
        }
#line 1917 "parser.tab.c"
    break;

  case 18: /* stmt: simple_stmt  */
#line 311 "parser.y"
                  {
                (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
                if(curr_symbol_table == global_symbol_table && curr_if_end_jump_label.empty() && curr_loop_end_jump_label.empty()) threeAC.push_back((yyvsp[0].nonTerminal)->get_code());
            }
#line 1926 "parser.tab.c"
    break;

  case 19: /* stmt: compound_stmt  */
#line 315 "parser.y"
                {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 1932 "parser.tab.c"
    break;

  case 20: /* stmts: stmts stmt  */
#line 318 "parser.y"
                  {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));}
#line 1938 "parser.tab.c"
    break;

  case 21: /* stmts: stmt  */
#line 319 "parser.y"
       {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 1944 "parser.tab.c"
    break;

  case 22: /* simple_stmt: small_stmt_semicolon_sep NEWLINE  */
#line 322 "parser.y"
                                              {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal);}
#line 1950 "parser.tab.c"
    break;

  case 23: /* small_stmt: expr_stmt  */
#line 325 "parser.y"
                      {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 1956 "parser.tab.c"
    break;

  case 24: /* small_stmt: flow_stmt  */
#line 326 "parser.y"
            {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 1962 "parser.tab.c"
    break;

  case 25: /* small_stmt: global_stmt  */
#line 327 "parser.y"
              {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 1968 "parser.tab.c"
    break;

  case 26: /* global_stmt: GLOBAL NAME  */
#line 330 "parser.y"
                            {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword not allowed in global scope" << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup((yyvsp[0].nonTerminal)->get_lexeme()) ;
    auto curr_entry = curr_symbol_table->lookup((yyvsp[0].nonTerminal)->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable already defined in current scope cannot be global in line no:" << (yyvsp[0].nonTerminal)->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable not defined in global scope at line no: "<<(yyvsp[0].nonTerminal)->get_line_no()<<endl;
    } 
}
#line 1994 "parser.tab.c"
    break;

  case 27: /* global_stmt: GLOBAL NAME comma_name_one_or_more  */
#line 351 "parser.y"
                                     {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword not allowed in global scope" << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup((yyvsp[-1].nonTerminal)->get_lexeme());
    auto curr_entry = curr_symbol_table->lookup((yyvsp[-1].nonTerminal)->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable already defined in current scope cannot be global in line no:" << (yyvsp[-1].nonTerminal)->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable not defined in global scope at line no: "<<(yyvsp[-1].nonTerminal)->get_line_no()<<endl;
    } 
}
#line 2020 "parser.tab.c"
    break;

  case 28: /* comma_name_one_or_more: COMMA NAME  */
#line 374 "parser.y"
                                    {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword not allowed in global scope" << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup((yyvsp[0].nonTerminal)->get_lexeme());
    auto curr_entry = curr_symbol_table->lookup((yyvsp[0].nonTerminal)->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable already defined in current scope cannot be global in line no:" << (yyvsp[0].nonTerminal)->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable not defined in global scope at line no: "<<(yyvsp[0].nonTerminal)->get_line_no()<<endl;
    } 

}
#line 2047 "parser.tab.c"
    break;

  case 29: /* comma_name_one_or_more: COMMA NAME comma_name_one_or_more  */
#line 396 "parser.y"
                                    {
    if(curr_symbol_table == global_symbol_table){
        cout << "Global keyword not allowed in global scope" << endl;
        exit(-1);
    }
    auto entry = global_symbol_table->lookup((yyvsp[-1].nonTerminal)->get_lexeme()); 
    auto curr_entry = curr_symbol_table->lookup((yyvsp[-1].nonTerminal)->get_lexeme());
    if(curr_entry != nullptr)
    {
        cout << "Variable already defined in current scope cannot be global in line no:" << (yyvsp[-1].nonTerminal)->get_line_no() << endl; 
        exit(-1);
    }
    else if(entry!= nullptr)
    {
        curr_symbol_table->add_global_entry(entry);
    }
    else
    {
        cout<<" Variable not defined in global scope at line no: "<<(yyvsp[-1].nonTerminal)->get_line_no()<<endl;
    } 
}
#line 2073 "parser.tab.c"
    break;

  case 30: /* small_stmt_semicolon_sep: small_stmt SEMICOLON small_stmt_semicolon_sep  */
#line 419 "parser.y"
                                                                        {(yyval.nonTerminal)=new NonTerminal((yyvsp[-2].nonTerminal)->get_line_no(), "SmallStmt");(yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));(yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));}
#line 2079 "parser.tab.c"
    break;

  case 31: /* small_stmt_semicolon_sep: small_stmt  */
#line 420 "parser.y"
             {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 2085 "parser.tab.c"
    break;

  case 32: /* small_stmt_semicolon_sep: small_stmt SEMICOLON  */
#line 421 "parser.y"
                       {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal);}
#line 2091 "parser.tab.c"
    break;

  case 33: /* expr_stmt: testlist_star_expr expr_3_or  */
#line 424 "parser.y"
                                        {
                                            if(!(yyvsp[-1].nonTerminal)->get_is_lvalue()){
                                                cout << "Left hand side of assignment is not a lvalue at line no: " << (yyvsp[0].nonTerminal)->get_line_no() << endl;
                                                exit(-1);
                                            }
                                            if((yyvsp[0].nonTerminal)->get_operator_type_augassign()==0)
                                            {
                                                if(!is_compatible_datatype((yyvsp[-1].nonTerminal)->get_datatype(), (yyvsp[0].nonTerminal)->get_datatype()))
                                                {
                                                    cout << "Type mismatch in assignment at line no: " << (yyvsp[0].nonTerminal)->get_line_no() << endl;
                                                    exit(0);
                                                }

                                            }
                                            else if((yyvsp[0].nonTerminal)->compare_datatype_expr3or((yyvsp[-1].nonTerminal)->get_datatype())==0)
                                            {
                                                cout << "Specified assignement not possible at line no: " << (yyvsp[0].nonTerminal)->get_line_no();
                                                exit(0);
                                            }

                                            (yyval.nonTerminal)=(yyvsp[0].nonTerminal);
                                            (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
                                            if((yyval.nonTerminal)->get_operator_type_augassign() == 0){ // assignment case
                                                if((yyvsp[-1].nonTerminal)->get_is_ptr()){                                                    
                                                        (yyval.nonTerminal)->gen("*"+(yyvsp[-1].nonTerminal)->get_temporary(),(yyvsp[0].nonTerminal)->get_temporary());
                                                }
                                                else{
                                                    (yyval.nonTerminal)->gen((yyvsp[-1].nonTerminal)->get_temporary(),(yyvsp[0].nonTerminal)->get_temporary());
                                                }
                                            }
                                            else{   // augmented assignment case
                                                if((yyvsp[-1].nonTerminal)->get_datatype().is_list){
                                                    cout << "Augmented assignment not possible for lists" << endl;
                                                    exit(-1);
                                                }
                                                string op = op_3AC.top();
                                                op.pop_back();
                                                if((yyvsp[-1].nonTerminal)->get_is_ptr()){
                                                    auto temp = NonTerminal::get_new_temporary();
                                                    (yyval.nonTerminal)->gen(temp, "*"+(yyvsp[-1].nonTerminal)->get_temporary(), op, (yyvsp[0].nonTerminal)->get_temporary());
                                                    (yyval.nonTerminal)->gen("*"+(yyvsp[-1].nonTerminal)->get_temporary(),temp);
                                                }
                                                else{
                                                    auto temp = NonTerminal::get_new_temporary();                                                    
                                                    (yyval.nonTerminal)->gen(temp, (yyvsp[-1].nonTerminal)->get_temporary(), op, (yyvsp[0].nonTerminal)->get_temporary());
                                                    (yyval.nonTerminal)->gen((yyvsp[-1].nonTerminal)->get_temporary(),temp);
                                                }
                                                op_3AC.pop();
                                            }

                                        }
#line 2147 "parser.tab.c"
    break;

  case 34: /* expr_stmt: NAME COLON datatype  */
#line 475 "parser.y"
                        {
   
                            if(curr_symbol_table->lookup((yyvsp[-2].nonTerminal)->get_lexeme()) != nullptr)
                            {
                                cout << "Variable redeclaration in same scope at line no: " << (yyvsp[-2].nonTerminal)->get_line_no() << endl; 
                                exit(-1);
                            }
                            if(curr_symbol_table->lookup_global_entry((yyvsp[-2].nonTerminal)->get_lexeme()) != nullptr)
                            {
                                cout << "Redeclaration of variable earlier stated to be Global at line no: " << (yyvsp[-2].nonTerminal)->get_line_no() << endl;
                                exit(-1);
                            }
                            // st_entry* global_entry  = (global_symbol_table->lookup($1->get_lexeme))
                            curr_symbol_table->insert((yyvsp[-2].nonTerminal)->get_lexeme(), *(yyvsp[0].type), (yyvsp[-2].nonTerminal)->get_line_no(), false);
                        }
#line 2167 "parser.tab.c"
    break;

  case 35: /* expr_stmt: NAME COLON datatype EQUAL testlist_star_expr  */
#line 490 "parser.y"
                                                {
                                                    (yyval.nonTerminal) = (yyvsp[-4].nonTerminal);
                                                    (yyval.nonTerminal)->copy_cur_temp((yyvsp[0].nonTerminal));
                                                    if(curr_symbol_table->lookup((yyvsp[-4].nonTerminal)->get_lexeme()) != nullptr){
                                                        cout << "Variable redeclaration in same scope at line no: " << (yyvsp[0].nonTerminal)->get_line_no() << endl;
                                                        exit(-1);
                                                    }
                                                    if(curr_symbol_table->lookup_global_entry((yyvsp[-4].nonTerminal)->get_lexeme()) != nullptr)
                                                    {
                                                        cout << "Redeclaration of variable earlier stated to be Global at line no: " << (yyvsp[-4].nonTerminal)->get_line_no() << endl;
                                                        exit(-1);
                                                    }
                                                    
                                                    if(!is_compatible_datatype(*(yyvsp[-2].type), (yyvsp[0].nonTerminal)->get_datatype())){
                                                        cout<<(yyvsp[-2].type)->datatype<<" "<<(yyvsp[0].nonTerminal)->get_datatype().datatype<<endl;
                                                        cout << "Type mismatch in assignment at line no: " << (yyvsp[0].nonTerminal)->get_line_no();
                                                        exit(-1);
                                                    }
                                                    
                                                    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
                                                    if((yyvsp[-2].type)->is_list){
                                                        (yyval.nonTerminal)->set_temporary((yyvsp[-4].nonTerminal)->get_lexeme());
                                                        (yyval.nonTerminal)->gen_list_code(calculate_size(*(yyvsp[-2].type)),(yyvsp[-4].nonTerminal)->get_temporary());
                                                        // $$->gen("pushl", to_string(curr_list_temporaries.size()*(calculate_size(*$3))+4));
                                                        // // $$->gen("stackpointer", "+xxx");
                                                        // $$->gen("call", "allocmem", "1");
                                                        // $$->gen("$rsp", "$rsp","+", "4");
                                                        // auto temp = NonTerminal::get_new_temporary();
                                                        // $$->gen(temp, "$rax");
                                                        // $$->gen("*"+temp, to_string(curr_list_temporaries.size()));
                                                        // $$->gen($1->get_temporary(), temp, "+", "4");

                                                        // for(int i=0;i<curr_list_temporaries.size();++i){
                                                        //     auto temp = NonTerminal::get_new_temporary();
                                                        //     // cout<<"line 399"<<$1->get_temporary()<<endl;
                                                        //     $$->gen(temp, $1->get_temporary(), "+", to_string(i*calculate_size(*$3)));
                                                        //     $$->gen("*"+temp, curr_list_temporaries[i]);
                                                        // }
                                                        // curr_list_temporaries.clear();
                                                    }
                                                    else{
                                                        (yyval.nonTerminal)->gen((yyvsp[-4].nonTerminal)->get_lexeme(), (yyvsp[0].nonTerminal)->get_temporary());
                                                    }
                                                    curr_symbol_table->insert((yyvsp[-4].nonTerminal)->get_lexeme(), *(yyvsp[-2].type), (yyvsp[-4].nonTerminal)->get_line_no(), true);
                                                }
#line 2217 "parser.tab.c"
    break;

  case 36: /* expr_stmt: testlist_star_expr  */
#line 535 "parser.y"
                     { (yyval.nonTerminal) =(yyvsp[0].nonTerminal);}
#line 2223 "parser.tab.c"
    break;

  case 37: /* expr_stmt: atom DOT NAME COLON datatype EQUAL testlist_star_expr  */
#line 536 "parser.y"
                                                        {
                                                            if((yyvsp[-6].nonTerminal)->get_lexeme() != "self"){
                                                                cout << "Attribute assignment to non self variable at line no: " << (yyvsp[-6].nonTerminal)->get_line_no();
                                                                exit(-1);
                                                            }
                                                            if((yyvsp[-6].nonTerminal)->get_datatype().is_class == false)
                                                            {
                                                                cout << "Attribute assignment to non class variable at line no: " << (yyvsp[-6].nonTerminal)->get_line_no();
                                                                exit(-1);
                                                            }
                                                            symbol_table_class* class_table = curr_symbol_table->get_parent_class_st();
                                                            int offset = class_table->get_offset();
                                                            class_table->insert((yyvsp[-4].nonTerminal)->get_lexeme(), *(yyvsp[-2].type), (yyvsp[0].nonTerminal)->get_line_no(), true);
                                                            if(!is_compatible_datatype(*(yyvsp[-2].type), (yyvsp[0].nonTerminal)->get_datatype())){
                                                                
                                                                cout << "Type mismatch in assignment at line no: " << (yyvsp[0].nonTerminal)->get_line_no();
                                                                exit(-1);
                                                            }
                                                            (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
                                                            auto temp = NonTerminal::get_new_temporary();
                                                            (yyval.nonTerminal)->gen(temp, (yyvsp[-6].nonTerminal)->get_temporary(), "+", to_string(offset));
                                                            (yyval.nonTerminal)->copy_cur_temp((yyvsp[0].nonTerminal));
                                                            if((yyvsp[-2].type)->is_list){
                                                                (yyval.nonTerminal)->set_temporary((yyvsp[-6].nonTerminal)->get_lexeme());
                                                                (yyval.nonTerminal)->gen_list_code(calculate_size(*(yyvsp[-2].type)),"*"+temp);
                                                                // $$->gen("pushl", to_string(curr_list_temporaries.size()*calculate_size(*$5) + 4));
                                                                // // $$->gen("stackpointer", "+xxx");
                                                                // $$->gen("call", "allocmem", "1");
                                                                // $$->gen("$rsp", "$rsp","+", "4");
                                                                // auto temp2 = NonTerminal::get_new_temporary();
                                                                // $$->gen(temp2, "$rax");
                                                                // $$->gen("*"+temp2, to_string(curr_list_temporaries.size()));
                                                                // $$->gen("*"+temp, temp2, "+", "4");                        

                                                                // for(int i=0;i<curr_list_temporaries.size();++i){
                                                                //     auto temp2 = NonTerminal::get_new_temporary();
                                                                //     // cout<<"line 399"<<$1->get_temporary()<<endl;
                                                                //     $$->gen(temp2, "*"+temp, "+", to_string(i*calculate_size(*$5)));
                                                                //     $$->gen("*"+temp2, curr_list_temporaries[i]);
                                                                // }
                                                                // curr_list_temporaries.clear();
                                                            }
                                                            else if((yyvsp[-2].type)->datatype == "str"){
                                                                (yyval.nonTerminal)->gen("*"+temp, (yyvsp[0].nonTerminal)->get_temporary());
                                                            }
                                                            else{
                                                                (yyval.nonTerminal)->gen("*"+temp, (yyvsp[0].nonTerminal)->get_temporary());
                                                            }
                                                        }
#line 2277 "parser.tab.c"
    break;

  case 38: /* expr_stmt: atom DOT NAME COLON datatype  */
#line 585 "parser.y"
                                {
                                    if((yyvsp[-4].nonTerminal)->get_lexeme() != "self"){
                                        cout << "Attribute assignment to non self variable at line no: " << (yyvsp[-4].nonTerminal)->get_line_no();
                                        exit(-1);
                                    }
                                    symbol_table_class* class_table = curr_symbol_table->get_parent_class_st();
                                    class_table->insert((yyvsp[-2].nonTerminal)->get_lexeme(), *(yyvsp[0].type), (yyvsp[-2].nonTerminal)->get_line_no(), false);
                                }
#line 2290 "parser.tab.c"
    break;

  case 39: /* expr_3_or: augassign testlist  */
#line 595 "parser.y"
                                { 
                                    (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
                                    int check=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_operator_type_augassign());
                                    if(!check){
                                        cout << "Specified augmented assignment not possible at line no: " << (yyvsp[-1].nonTerminal)->get_line_no()<< endl; exit(-1);
                                    }
                                    (yyval.nonTerminal)->set_operator_type_augassign((yyvsp[-1].nonTerminal)->get_operator_type_augassign());
                                }
#line 2303 "parser.tab.c"
    break;

  case 40: /* expr_3_or: equal_testlist_star_expr  */
#line 603 "parser.y"
                           { (yyval.nonTerminal) = (yyvsp[0].nonTerminal); }
#line 2309 "parser.tab.c"
    break;

  case 41: /* equal_testlist_star_expr: EQUAL testlist_star_expr  */
#line 606 "parser.y"
                                                    { 
                                                        (yyval.nonTerminal)=(yyvsp[0].nonTerminal);
                                                        (yyval.nonTerminal)->set_operator_type_augassign(0);
                                                        op_3AC.push("=");
                                                        
                                                    }
#line 2320 "parser.tab.c"
    break;

  case 42: /* testlist_star_expr: test  */
#line 614 "parser.y"
                         {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 2326 "parser.tab.c"
    break;

  case 43: /* augassign: PLUS_EQUAL  */
#line 617 "parser.y"
                      {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(3);op_3AC.push("+=");}
#line 2332 "parser.tab.c"
    break;

  case 44: /* augassign: MINUS_EQUAL  */
#line 618 "parser.y"
              {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(1);op_3AC.push("-=");}
#line 2338 "parser.tab.c"
    break;

  case 45: /* augassign: MULTIPLY_EQUAL  */
#line 619 "parser.y"
                 {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(1);op_3AC.push("*=");}
#line 2344 "parser.tab.c"
    break;

  case 46: /* augassign: DIVIDE_EQUAL  */
#line 620 "parser.y"
               {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(1);op_3AC.push("/=");}
#line 2350 "parser.tab.c"
    break;

  case 47: /* augassign: MODULO_EQUAL  */
#line 621 "parser.y"
               {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(1);op_3AC.push("%=");}
#line 2356 "parser.tab.c"
    break;

  case 48: /* augassign: BITWISE_AND_EQUAL  */
#line 622 "parser.y"
                   {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(2);op_3AC.push("&=");}
#line 2362 "parser.tab.c"
    break;

  case 49: /* augassign: BITWISE_OR_EQUAL  */
#line 623 "parser.y"
                   {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(2);op_3AC.push("|=");}
#line 2368 "parser.tab.c"
    break;

  case 50: /* augassign: BITWISE_XOR_EQUAL  */
#line 624 "parser.y"
                    {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(2);op_3AC.push("^=");}
#line 2374 "parser.tab.c"
    break;

  case 51: /* augassign: LEFT_SHIFT_EQUAL  */
#line 625 "parser.y"
                   {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(2);op_3AC.push("<<=");}
#line 2380 "parser.tab.c"
    break;

  case 52: /* augassign: RIGHT_SHIFT_EQUAL  */
#line 626 "parser.y"
                    {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(2);op_3AC.push(">>=");}
#line 2386 "parser.tab.c"
    break;

  case 53: /* augassign: POWER_EQUAL  */
#line 627 "parser.y"
              {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(1);op_3AC.push("*=");}
#line 2392 "parser.tab.c"
    break;

  case 54: /* augassign: FLOOR_DIVIDE_EQUAL  */
#line 628 "parser.y"
                     {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_operator_type_augassign(1);op_3AC.push("//=");}
#line 2398 "parser.tab.c"
    break;

  case 55: /* flow_stmt: BREAK  */
#line 632 "parser.y"
                 { (yyval.nonTerminal) = (yyvsp[0].nonTerminal); (yyval.nonTerminal)->gen("goto", curr_loop_end_jump_label.top()); }
#line 2404 "parser.tab.c"
    break;

  case 56: /* flow_stmt: CONTINUE  */
#line 633 "parser.y"
           {(yyval.nonTerminal)=(yyvsp[0].nonTerminal); (yyval.nonTerminal)->gen("goto", curr_loop_start_jump_label.top());}
#line 2410 "parser.tab.c"
    break;

  case 57: /* flow_stmt: return_stmt  */
#line 634 "parser.y"
              {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 2416 "parser.tab.c"
    break;

  case 58: /* return_stmt: RETURN  */
#line 637 "parser.y"
                    {
                        (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), "Return");
                        (yyval.nonTerminal)->gen("mov48","-56(rbp)","regs");
                        (yyval.nonTerminal)->gen("mov8","$rbp","$rsp");
                        (yyval.nonTerminal)->gen("popq", "$rbp");
                        (yyval.nonTerminal)->gen("ret");
                    }
#line 2428 "parser.tab.c"
    break;

  case 59: /* return_stmt: RETURN testlist_star_expr  */
#line 644 "parser.y"
                            {
    (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
    (yyval.nonTerminal)->gen("movq", (yyvsp[0].nonTerminal)->get_temporary(),"$rax");
    (yyval.nonTerminal)->gen("mov48","-56(rbp)","regs");
    (yyval.nonTerminal)->gen("mov8","$rbp","$rsp");
    (yyval.nonTerminal)->gen("popq", "$rbp");
    (yyval.nonTerminal)->gen("ret");
}
#line 2441 "parser.tab.c"
    break;

  case 60: /* compound_stmt: if_stmt  */
#line 654 "parser.y"
                       {(yyval.nonTerminal) = (yyvsp[0].nonTerminal); if(curr_symbol_table == global_symbol_table) threeAC.push_back((yyval.nonTerminal)->get_code());}
#line 2447 "parser.tab.c"
    break;

  case 61: /* compound_stmt: while_stmt  */
#line 655 "parser.y"
             {(yyval.nonTerminal) = (yyvsp[0].nonTerminal); if(curr_symbol_table == global_symbol_table) threeAC.push_back((yyval.nonTerminal)->get_code());}
#line 2453 "parser.tab.c"
    break;

  case 62: /* compound_stmt: for_stmt  */
#line 656 "parser.y"
           {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);if(curr_symbol_table == global_symbol_table) threeAC.push_back((yyval.nonTerminal)->get_code());}
#line 2459 "parser.tab.c"
    break;

  case 63: /* compound_stmt: funcdef  */
#line 657 "parser.y"
          {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2465 "parser.tab.c"
    break;

  case 64: /* compound_stmt: classdef  */
#line 658 "parser.y"
           {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2471 "parser.tab.c"
    break;

  case 65: /* if_head: IF  */
#line 661 "parser.y"
            {
    curr_if_end_jump_label.push(NonTerminal::get_new_label());
}
#line 2479 "parser.tab.c"
    break;

  case 66: /* if_stmt: if_head namedexpr_test COLON suite  */
#line 665 "parser.y"
                                            {
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-2].nonTerminal)->get_line_no(), "If");
    (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-2].nonTerminal)->get_temporary()+")", "goto", curr_if_end_jump_label.top());
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen(curr_if_end_jump_label.top());
    curr_if_end_jump_label.pop();                                                
}
#line 2492 "parser.tab.c"
    break;

  case 67: /* if_stmt: if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more  */
#line 673 "parser.y"
                                                                                 {
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-3].nonTerminal)->get_line_no(), "If");
    (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
    string label_elif = NonTerminal::get_new_label();
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-3].nonTerminal)->get_temporary()+")", "goto", label_elif);
    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    (yyval.nonTerminal)->gen("goto", curr_if_end_jump_label.top());
    (yyval.nonTerminal)->gen(label_elif);
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen(curr_if_end_jump_label.top());
    curr_if_end_jump_label.pop();
}
#line 2509 "parser.tab.c"
    break;

  case 68: /* if_stmt: if_head namedexpr_test COLON suite ELSE COLON suite  */
#line 685 "parser.y"
                                                       {
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-5].nonTerminal)->get_line_no(), "If");
    (yyval.nonTerminal)->copy_code((yyvsp[-5].nonTerminal));
    string label_else = NonTerminal::get_new_label();
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-5].nonTerminal)->get_temporary()+")", "goto", label_else);
    (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
    (yyval.nonTerminal)->gen("goto", curr_if_end_jump_label.top());
    (yyval.nonTerminal)->gen(label_else);
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen(curr_if_end_jump_label.top());
    curr_if_end_jump_label.pop();
}
#line 2526 "parser.tab.c"
    break;

  case 69: /* if_stmt: if_head namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more ELSE COLON suite  */
#line 697 "parser.y"
                                                                                                  {
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-6].nonTerminal)->get_line_no(), "If");
    (yyval.nonTerminal)->copy_code((yyvsp[-6].nonTerminal));
    string label_elif = NonTerminal::get_new_label();
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-6].nonTerminal)->get_temporary()+")", "goto", label_elif);
    (yyval.nonTerminal)->copy_code((yyvsp[-4].nonTerminal));
    (yyval.nonTerminal)->gen("goto", curr_if_end_jump_label.top());
    (yyval.nonTerminal)->gen(label_elif);
    (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen(curr_if_end_jump_label.top());
    curr_if_end_jump_label.pop();
}
#line 2544 "parser.tab.c"
    break;

  case 70: /* elif_namedexpr_test_colon_suite_one_or_more: ELIF namedexpr_test COLON suite elif_namedexpr_test_colon_suite_one_or_more  */
#line 713 "parser.y"
                                                                                                                          {
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-3].nonTerminal)->get_line_no(), "elif");
    (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
    string label_elif = NonTerminal::get_new_label();
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-3].nonTerminal)->get_temporary()+")", "goto", label_elif);
    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    (yyval.nonTerminal)->gen("goto", curr_if_end_jump_label.top());
    (yyval.nonTerminal)->gen(label_elif);
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
}
#line 2559 "parser.tab.c"
    break;

  case 71: /* elif_namedexpr_test_colon_suite_one_or_more: ELIF namedexpr_test COLON suite  */
#line 723 "parser.y"
                                  {
        // if(symbol_table_stack.size() == 0)
        // {
        //     cout << "trying to pop empty stack" << endl; exit(-1);
        // } 
        // symbol_table_stack.pop(); 
        // curr_symbol_table = symbol_table_stack.top();
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-2].nonTerminal)->get_line_no(), "elif");
    (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));
    string label_elif = NonTerminal::get_new_label();
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-2].nonTerminal)->get_temporary()+")", "goto", label_elif);
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen("goto", curr_if_end_jump_label.top());
    (yyval.nonTerminal)->gen(label_elif);

    }
#line 2580 "parser.tab.c"
    break;

  case 72: /* while_stmt: while_head namedexpr_test COLON suite  */
#line 741 "parser.y"
                                                   {
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-2].nonTerminal)->get_line_no(), "While");

    string label_start = curr_loop_start_jump_label.top();
    (yyval.nonTerminal)->gen_new_label(label_start);
        (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));

    curr_loop_start_jump_label.pop();
    string label_end = curr_loop_end_jump_label.top();
    curr_loop_end_jump_label.pop();
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-2].nonTerminal)->get_temporary()+")", "goto", label_end);
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen("goto", label_start);
    (yyval.nonTerminal)->gen_new_label(label_end);
}
#line 2600 "parser.tab.c"
    break;

  case 73: /* while_stmt: while_head namedexpr_test COLON suite ELSE COLON suite  */
#line 756 "parser.y"
                                                        {
    (yyval.nonTerminal)=new NonTerminal((yyvsp[-5].nonTerminal)->get_line_no(), "While");
    string label_start = curr_loop_start_jump_label.top();
    curr_loop_start_jump_label.pop();
    (yyval.nonTerminal)->gen_new_label(label_start);
        (yyval.nonTerminal)->copy_code((yyvsp[-5].nonTerminal));

    string label_end = curr_loop_end_jump_label.top();
    curr_loop_end_jump_label.pop();
    (yyval.nonTerminal)->gen("if not", "("+(yyvsp[-5].nonTerminal)->get_temporary()+")", "goto", label_end);
    (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
    (yyval.nonTerminal)->gen("goto", label_start);
    (yyval.nonTerminal)->gen_new_label(label_end);
    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
}
#line 2620 "parser.tab.c"
    break;

  case 74: /* while_head: WHILE  */
#line 772 "parser.y"
                  {
        curr_loop_start_jump_label.push(NonTerminal::get_new_label());
        curr_loop_end_jump_label.push(NonTerminal::get_new_label());
    }
#line 2629 "parser.tab.c"
    break;

  case 75: /* for_stmt: for_head exprlist IN RANGE OPEN_PAREN test COMMA test CLOSE_PAREN COLON suite  */
#line 778 "parser.y"
                                                                                        {
        if(!(yyvsp[-9].nonTerminal)->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no "<<(yyvsp[-9].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        if(!((yyvsp[-5].nonTerminal)->get_datatype().datatype == "int"||(yyvsp[-5].nonTerminal)->get_datatype().datatype=="bool")||(yyvsp[-5].nonTerminal)->get_datatype().is_list){
            cout << "Range should have integer arguments at line no "<<(yyvsp[-5].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        if(!((yyvsp[-3].nonTerminal)->get_datatype().datatype == "int"||(yyvsp[-3].nonTerminal)->get_datatype().datatype=="bool")||(yyvsp[-3].nonTerminal)->get_datatype().is_list){
            cout << "Range should have integer arguments at line no "<<(yyvsp[-3].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }

        (yyval.nonTerminal)=new NonTerminal((yyvsp[-9].nonTerminal)->get_line_no(), "For");
        (yyval.nonTerminal)->copy_code((yyvsp[-9].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-5].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
        (yyval.nonTerminal)->gen((yyvsp[-9].nonTerminal)->get_temporary(), (yyvsp[-5].nonTerminal)->get_temporary(), "-", "1");
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        (yyval.nonTerminal)->gen_new_label(label_start);
        (yyval.nonTerminal)->gen((yyvsp[-9].nonTerminal)->get_temporary(), (yyvsp[-9].nonTerminal)->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        (yyval.nonTerminal)->gen("if", "("+(yyvsp[-9].nonTerminal)->get_temporary()+ ">="+ (yyvsp[-3].nonTerminal)->get_temporary()+")", "goto", label_end);
        (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
        (yyval.nonTerminal)->gen("goto", label_start);
        (yyval.nonTerminal)->gen_new_label(label_end);
        // $$->print_code();
    }
#line 2665 "parser.tab.c"
    break;

  case 76: /* for_stmt: for_head exprlist IN RANGE OPEN_PAREN test CLOSE_PAREN COLON suite  */
#line 809 "parser.y"
                                                                    {
        if(!(yyvsp[-7].nonTerminal)->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no "<<(yyvsp[-7].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        if(!((yyvsp[-3].nonTerminal)->get_datatype().datatype == "int"||(yyvsp[-3].nonTerminal)->get_datatype().datatype=="bool")||(yyvsp[-3].nonTerminal)->get_datatype().is_list){
        cout << "Range should have integer arguments at line no "<<(yyvsp[-3].nonTerminal)->get_line_no()<<endl;
        exit(-1);
        }

        (yyval.nonTerminal)=new NonTerminal((yyvsp[-7].nonTerminal)->get_line_no(), "For");
        (yyval.nonTerminal)->copy_code((yyvsp[-7].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
        (yyval.nonTerminal)->gen((yyvsp[-7].nonTerminal)->get_temporary(), "-1");
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        (yyval.nonTerminal)->gen_new_label(label_start);
        (yyval.nonTerminal)->gen((yyvsp[-7].nonTerminal)->get_temporary(), (yyvsp[-7].nonTerminal)->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        (yyval.nonTerminal)->gen("if", "("+(yyvsp[-7].nonTerminal)->get_temporary()+ ">="+ (yyvsp[-3].nonTerminal)->get_temporary()+")", "goto", label_end);
        (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
        (yyval.nonTerminal)->gen("goto", label_start);
        (yyval.nonTerminal)->gen_new_label(label_end); 
        // $$->print_code();
    }
#line 2696 "parser.tab.c"
    break;

  case 77: /* for_stmt: for_head exprlist IN RANGE OPEN_PAREN test CLOSE_PAREN COLON suite ELSE COLON suite  */
#line 835 "parser.y"
                                                                                       {
        if(!(yyvsp[-10].nonTerminal)->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no "<<(yyvsp[-10].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        if(!((yyvsp[-6].nonTerminal)->get_datatype().datatype == "int"||(yyvsp[-6].nonTerminal)->get_datatype().datatype=="bool")||(yyvsp[-6].nonTerminal)->get_datatype().is_list){
        cout << "Range should have integer arguments at line no "<<(yyvsp[-6].nonTerminal)->get_line_no()<<endl;
        exit(-1);
    }
        (yyval.nonTerminal)=new NonTerminal((yyvsp[-10].nonTerminal)->get_line_no(), "For");
        (yyval.nonTerminal)->copy_code((yyvsp[-10].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-6].nonTerminal));
        (yyval.nonTerminal)->gen((yyvsp[-10].nonTerminal)->get_temporary(), "-1");
        auto label_start = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        (yyval.nonTerminal)->gen_new_label(label_start);
        (yyval.nonTerminal)->gen((yyvsp[-10].nonTerminal)->get_temporary(), (yyvsp[-10].nonTerminal)->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        (yyval.nonTerminal)->gen("if", "("+(yyvsp[-10].nonTerminal)->get_temporary()+ ">="+ (yyvsp[-6].nonTerminal)->get_temporary()+")", "goto", label_end);
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
        (yyval.nonTerminal)->gen("goto", label_start);
        (yyval.nonTerminal)->gen_new_label(label_end);
        (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal)); 
        // $$->print_code();
    }
#line 2727 "parser.tab.c"
    break;

  case 78: /* for_stmt: for_head exprlist IN RANGE OPEN_PAREN test COMMA test CLOSE_PAREN COLON suite ELSE COLON suite  */
#line 861 "parser.y"
                                                                                                 {
        if(!(yyvsp[-12].nonTerminal)->get_is_lvalue()){
            cout<<"Left hand side of for loop should be a lvalue at line no "<<(yyvsp[-12].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        if(!((yyvsp[-8].nonTerminal)->get_datatype().datatype == "int"||(yyvsp[-8].nonTerminal)->get_datatype().datatype=="bool")||(yyvsp[-8].nonTerminal)->get_datatype().is_list){
            cout << "Range should have integer arguments at line no "<<(yyvsp[-8].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        if(!((yyvsp[-6].nonTerminal)->get_datatype().datatype == "int"||(yyvsp[-6].nonTerminal)->get_datatype().datatype=="bool")||(yyvsp[-6].nonTerminal)->get_datatype().is_list){
            cout << "Range should have integer arguments at line no "<<(yyvsp[-6].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        (yyval.nonTerminal)=new NonTerminal((yyvsp[-12].nonTerminal)->get_line_no(), "For");
        (yyval.nonTerminal)->copy_code((yyvsp[-12].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-8].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-6].nonTerminal));
        (yyval.nonTerminal)->gen((yyvsp[-12].nonTerminal)->get_temporary(), (yyvsp[-8].nonTerminal)->get_temporary(), "-", "1");
        auto label = curr_loop_start_jump_label.top();
        curr_loop_start_jump_label.pop();
        (yyval.nonTerminal)->gen_new_label(label);
        (yyval.nonTerminal)->gen((yyvsp[-12].nonTerminal)->get_temporary(), (yyvsp[-12].nonTerminal)->get_temporary(), "+", "1");
        string label_end = curr_loop_end_jump_label.top();
        curr_loop_end_jump_label.pop();
        (yyval.nonTerminal)->gen("if", "("+(yyvsp[-12].nonTerminal)->get_temporary()+ ">="+ (yyvsp[-6].nonTerminal)->get_temporary()+")", "goto", label_end);
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
        (yyval.nonTerminal)->gen("goto", label);
        (yyval.nonTerminal)->gen_new_label(label_end);
        (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal)); 
        // $$->print_code();
    }
#line 2763 "parser.tab.c"
    break;

  case 79: /* for_head: FOR  */
#line 912 "parser.y"
             {
    string label_start = NonTerminal::get_new_label();
    string label_end = NonTerminal::get_new_label();
    curr_loop_start_jump_label.push(label_start);
    curr_loop_end_jump_label.push(label_end);
}
#line 2774 "parser.tab.c"
    break;

  case 80: /* suite: simple_stmt  */
#line 921 "parser.y"
                   {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 2780 "parser.tab.c"
    break;

  case 81: /* suite: NEWLINE INDENT stmts DEDENT  */
#line 922 "parser.y"
                               {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal);}
#line 2786 "parser.tab.c"
    break;

  case 82: /* namedexpr_test: test  */
#line 925 "parser.y"
                     {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2792 "parser.tab.c"
    break;

  case 83: /* namedexpr_test: test COLONEQUAL test  */
#line 926 "parser.y"
                       {
    if(!(yyvsp[-2].nonTerminal)->get_is_lvalue()){
        cout << "Left hand side of walrus operator is not a lvalue at line no: " << (yyvsp[0].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen((yyvsp[-2].nonTerminal)->get_temporary(), (yyvsp[0].nonTerminal)->get_temporary());
    (yyval.nonTerminal)->set_temporary((yyvsp[-2].nonTerminal)->get_temporary());
    (yyval.nonTerminal)->set_is_lvalue(false); 
    auto type=(yyvsp[-2].nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
if(type.datatype == "ERROR"){cout << "Datatypes of both sides of := are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl; exit(-1);} 
(yyval.nonTerminal)->set_datatype(type);}
#line 2810 "parser.tab.c"
    break;

  case 84: /* test: or_test  */
#line 942 "parser.y"
              {
    (yyval.nonTerminal)=(yyvsp[0].nonTerminal);
    
    // $$->print_code();
    // cout << "\n\n\n";
}
#line 2821 "parser.tab.c"
    break;

  case 85: /* or_test: and_test  */
#line 950 "parser.y"
                  {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2827 "parser.tab.c"
    break;

  case 86: /* or_test: and_test_star and_test  */
#line 951 "parser.y"
                          {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    (yyval.nonTerminal)->set_datatype({"bool",false});

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "or", (yyvsp[0].nonTerminal)->get_temporary());    
}
#line 2840 "parser.tab.c"
    break;

  case 87: /* and_test_star: and_test OR  */
#line 961 "parser.y"
                            {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false);  (yyval.nonTerminal)->set_datatype({"bool",false});}
#line 2846 "parser.tab.c"
    break;

  case 88: /* and_test_star: and_test_star and_test OR  */
#line 962 "parser.y"
                            {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);
    (yyval.nonTerminal)->set_datatype({"bool",false});
    
    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "or", (yyvsp[-1].nonTerminal)->get_temporary());
}
#line 2859 "parser.tab.c"
    break;

  case 89: /* and_test: not_test  */
#line 971 "parser.y"
                   {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2865 "parser.tab.c"
    break;

  case 90: /* and_test: and_not_test_plus not_test  */
#line 972 "parser.y"
                             {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    (yyval.nonTerminal)->set_datatype({"bool",false});
    
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "and", (yyvsp[0].nonTerminal)->get_temporary());
}
#line 2878 "parser.tab.c"
    break;

  case 91: /* and_not_test_plus: not_test AND  */
#line 982 "parser.y"
                                 {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false); (yyval.nonTerminal)->set_datatype({"bool",false});}
#line 2884 "parser.tab.c"
    break;

  case 92: /* and_not_test_plus: and_not_test_plus not_test AND  */
#line 983 "parser.y"
                                     {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);
    (yyval.nonTerminal)->set_datatype({"bool",false});
    
    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "and", (yyvsp[-1].nonTerminal)->get_temporary());
}
#line 2897 "parser.tab.c"
    break;

  case 93: /* not_test: not_plus_comparison  */
#line 992 "parser.y"
                                {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2903 "parser.tab.c"
    break;

  case 94: /* not_test: comparison  */
#line 993 "parser.y"
                {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2909 "parser.tab.c"
    break;

  case 95: /* not_plus_comparison: NOT comparison  */
#line 996 "parser.y"
                                      {
    (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
    (yyval.nonTerminal)->set_is_lvalue(false);
    (yyval.nonTerminal)->set_datatype({"bool",false});
    
    auto old_temp = (yyvsp[0].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "not", old_temp);  /*TODO: is "not" as operator fine?*/
}
#line 2922 "parser.tab.c"
    break;

  case 96: /* not_plus_comparison: NOT not_plus_comparison  */
#line 1004 "parser.y"
                            {
    (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
    (yyval.nonTerminal)->set_datatype({"bool",false});
    
    auto old_temp = (yyvsp[0].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "not", old_temp);  /*TODO: is "not" as operator fine?*/
}
#line 2934 "parser.tab.c"
    break;

  case 97: /* comparison: comp_op_expr_plus expr  */
#line 1013 "parser.y"
                                   {
    (yyval.nonTerminal)=(yyvsp[-1].nonTerminal);
    Type type;
    if((op_3AC.top()=="=="||op_3AC.top()=="!=" )&&  (yyvsp[-1].nonTerminal)->get_datatype().is_class && (yyvsp[0].nonTerminal)->get_datatype().is_class){
       printf("class comparison\n");
        type.datatype="bool";
    }
    else if((yyvsp[-1].nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype()).datatype == "ERROR"){
        cout << "Datatypes of both sides of comparison operator are not same on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    type=(yyvsp[-1].nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    (yyval.nonTerminal)->set_datatype({"bool"});
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    if(type.datatype=="str")
    {
        relate_string((yyval.nonTerminal),(yyvsp[-1].nonTerminal),(yyvsp[0].nonTerminal),op_3AC.top());
    }
    else
    {
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[0].nonTerminal)->get_temporary());
    }
    op_3AC.pop();
}
#line 2964 "parser.tab.c"
    break;

  case 98: /* comparison: expr  */
#line 1038 "parser.y"
       {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 2970 "parser.tab.c"
    break;

  case 99: /* comp_op_expr_plus: expr comp_op  */
#line 1041 "parser.y"
                                {
    (yyval.nonTerminal)=(yyvsp[-1].nonTerminal);
    (yyval.nonTerminal)->set_is_lvalue(false);

    op_3AC.push((yyvsp[0].nonTerminal)->get_lexeme());
}
#line 2981 "parser.tab.c"
    break;

  case 100: /* comp_op_expr_plus: comp_op_expr_plus expr comp_op  */
#line 1047 "parser.y"
                                 {
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    Type type;
    if((op_3AC.top()=="=="||op_3AC.top()=="!=" )&&  (yyvsp[-2].nonTerminal)->get_datatype().is_class && (yyvsp[-1].nonTerminal)->get_datatype().is_class){
        type.datatype="bool";
    }
    else if((yyvsp[-2].nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype()).datatype == "ERROR"){
        cout << "Datatypes of both sides of comparison operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    type=(yyvsp[-2].nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    (yyval.nonTerminal)->set_datatype({"bool"}); 
    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    if(type.datatype=="str")
    {
        relate_string((yyval.nonTerminal),(yyvsp[-2].nonTerminal),(yyvsp[-1].nonTerminal),op_3AC.top());
    }
    else
    {
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[-1].nonTerminal)->get_temporary());
    }
    op_3AC.pop();
    op_3AC.push((yyvsp[0].nonTerminal)->get_lexeme());
}
#line 3011 "parser.tab.c"
    break;

  case 101: /* comp_op: GREATER_THAN  */
#line 1074 "parser.y"
                      {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3017 "parser.tab.c"
    break;

  case 102: /* comp_op: LESS_THAN  */
#line 1075 "parser.y"
            {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3023 "parser.tab.c"
    break;

  case 103: /* comp_op: EQUAL_EQUAL  */
#line 1076 "parser.y"
              {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3029 "parser.tab.c"
    break;

  case 104: /* comp_op: GREATER_THAN_EQUAL  */
#line 1077 "parser.y"
                     {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3035 "parser.tab.c"
    break;

  case 105: /* comp_op: LESS_THAN_EQUAL  */
#line 1078 "parser.y"
                    {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3041 "parser.tab.c"
    break;

  case 106: /* comp_op: NOTEQUAL  */
#line 1079 "parser.y"
            {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3047 "parser.tab.c"
    break;

  case 107: /* comp_op: IN  */
#line 1080 "parser.y"
        {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3053 "parser.tab.c"
    break;

  case 108: /* comp_op: NOT IN  */
#line 1081 "parser.y"
          {(yyval.nonTerminal) = (yyvsp[0].nonTerminal); (yyval.nonTerminal)->set_lexeme((yyvsp[-1].nonTerminal)->get_lexeme() + (yyvsp[0].nonTerminal)->get_lexeme()); /*TODO: chances of making mistakes, should use alternate strategy?*/}
#line 3059 "parser.tab.c"
    break;

  case 109: /* comp_op: IS  */
#line 1082 "parser.y"
        {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3065 "parser.tab.c"
    break;

  case 110: /* comp_op: IS NOT  */
#line 1083 "parser.y"
           {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_lexeme((yyvsp[-1].nonTerminal)->get_lexeme() + (yyvsp[0].nonTerminal)->get_lexeme()); /*TODO: chances of making mistakes, should use alternate strategy?*/}
#line 3071 "parser.tab.c"
    break;

  case 111: /* expr: r_expr xor_expr  */
#line 1088 "parser.y"
                         {
    cout<<"expr\n";(yyval.nonTerminal)=(yyvsp[-1].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"||datatype.datatype=="float"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);cout<<datatype.datatype<<endl;

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "|", (yyvsp[0].nonTerminal)->get_temporary());
}
#line 3089 "parser.tab.c"
    break;

  case 112: /* expr: xor_expr  */
#line 1101 "parser.y"
            {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 3095 "parser.tab.c"
    break;

  case 113: /* r_expr: r_expr xor_expr BITWISE_OR  */
#line 1104 "parser.y"
                                    {
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Bitwise or operator cannot be applied on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "|", (yyvsp[-1].nonTerminal)->get_temporary());
}
#line 3113 "parser.tab.c"
    break;

  case 114: /* r_expr: xor_expr BITWISE_OR  */
#line 1117 "parser.y"
                       {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false);auto datatype=(yyval.nonTerminal)->get_datatype();if(!(datatype.datatype == "int"||datatype.datatype=="bool")){cout << "Bitwise or operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl; exit(-1);}}
#line 3119 "parser.tab.c"
    break;

  case 115: /* xor_expr: x_expr and_expr  */
#line 1120 "parser.y"
                           {
    (yyval.nonTerminal)=(yyvsp[-1].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Bitwise xor operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "^", (yyvsp[0].nonTerminal)->get_temporary());
}
#line 3137 "parser.tab.c"
    break;

  case 116: /* xor_expr: and_expr  */
#line 1133 "parser.y"
            {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3143 "parser.tab.c"
    break;

  case 117: /* x_expr: x_expr and_expr BITWISE_XOR  */
#line 1136 "parser.y"
                                     {
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Bitwise xor operator cannot be applied on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "^", (yyvsp[-1].nonTerminal)->get_temporary());
}
#line 3161 "parser.tab.c"
    break;

  case 118: /* x_expr: and_expr BITWISE_XOR  */
#line 1149 "parser.y"
                         {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal);(yyval.nonTerminal)->set_is_lvalue(false); auto datatype=(yyval.nonTerminal)->get_datatype();if(!(datatype.datatype == "int"||datatype.datatype=="bool")){cout << "Bitwise xor operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl; exit(-1);}}
#line 3167 "parser.tab.c"
    break;

  case 119: /* and_expr: a_expr shift_expr  */
#line 1152 "parser.y"
                             {
    (yyval.nonTerminal)=(yyvsp[-1].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Bitwise and operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "&", (yyvsp[0].nonTerminal)->get_temporary());
}
#line 3185 "parser.tab.c"
    break;

  case 120: /* and_expr: shift_expr  */
#line 1165 "parser.y"
                {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3191 "parser.tab.c"
    break;

  case 121: /* a_expr: a_expr shift_expr BITWISE_AND  */
#line 1168 "parser.y"
                                         {
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Bitwise and operator cannot be applied on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, "&", (yyvsp[-1].nonTerminal)->get_temporary());
}
#line 3209 "parser.tab.c"
    break;

  case 122: /* a_expr: shift_expr BITWISE_AND  */
#line 1181 "parser.y"
                             {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false);auto datatype=(yyval.nonTerminal)->get_datatype();if(!(datatype.datatype == "int"||datatype.datatype=="bool")){cout << "Bitwise and operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl; exit(-1);}}
#line 3215 "parser.tab.c"
    break;

  case 123: /* shift_expr: lr_shift arith_expr  */
#line 1184 "parser.y"
                                    {
    (yyval.nonTerminal)=(yyvsp[-1].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Left shift operator cannot be applied on line, arith expr has type"<<(yyvsp[0].nonTerminal)->get_datatype().datatype<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[0].nonTerminal)->get_temporary());
    op_3AC.pop();
}
#line 3234 "parser.tab.c"
    break;

  case 124: /* shift_expr: arith_expr  */
#line 1198 "parser.y"
              {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3240 "parser.tab.c"
    break;

  case 125: /* lr_shift: arith_expr LEFT_SHIFT  */
#line 1201 "parser.y"
                                 {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    (yyval.nonTerminal)->set_is_lvalue(false);
    auto datatype=(yyval.nonTerminal)->get_datatype();
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Left shift operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push("<<");
}
#line 3256 "parser.tab.c"
    break;

  case 126: /* lr_shift: arith_expr RIGHT_SHIFT  */
#line 1212 "parser.y"
                             {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    (yyval.nonTerminal)->set_is_lvalue(false);
    auto datatype=(yyval.nonTerminal)->get_datatype();
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Right shift operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push(">>");
}
#line 3272 "parser.tab.c"
    break;

  case 127: /* lr_shift: lr_shift arith_expr LEFT_SHIFT  */
#line 1223 "parser.y"
                                 {
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Left shift operator cannot be applied on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push("<<");
}
#line 3292 "parser.tab.c"
    break;

  case 128: /* lr_shift: lr_shift arith_expr RIGHT_SHIFT  */
#line 1238 "parser.y"
                                  {
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(!(datatype.datatype == "int"||datatype.datatype=="bool")){
        cout << "Left shift operator cannot be applied on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push(">>");
}
#line 3312 "parser.tab.c"
    break;

  case 129: /* arith_expr: pm_term term  */
#line 1255 "parser.y"
                        {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[0].nonTerminal)->get_temporary());
    op_3AC.pop();  
}
#line 3331 "parser.tab.c"
    break;

  case 130: /* arith_expr: term  */
#line 1269 "parser.y"
        {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 3337 "parser.tab.c"
    break;

  case 131: /* pm_term: term PLUS  */
#line 1272 "parser.y"
                    {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    (yyval.nonTerminal)->set_is_lvalue(false);
    auto datatype=(yyval.nonTerminal)->get_datatype();
    if(datatype.datatype=="ERROR"){
        cout << "Addition operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push("+");
}
#line 3353 "parser.tab.c"
    break;

  case 132: /* pm_term: term MINUS  */
#line 1283 "parser.y"
                 {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    (yyval.nonTerminal)->set_is_lvalue(false);
    auto datatype=(yyval.nonTerminal)->get_datatype();
    if(datatype.datatype=="str"||datatype.datatype=="ERROR"){
        cout << "Addition operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }

    op_3AC.push("-");
}
#line 3369 "parser.tab.c"
    break;

  case 133: /* pm_term: pm_term term PLUS  */
#line 1294 "parser.y"
                    {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push("+");   
}
#line 3389 "parser.tab.c"
    break;

  case 134: /* pm_term: pm_term term MINUS  */
#line 1309 "parser.y"
                          {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push("-");
}
#line 3408 "parser.tab.c"
    break;

  case 135: /* term: factor  */
#line 1325 "parser.y"
             {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3414 "parser.tab.c"
    break;

  case 136: /* term: op_fac factor  */
#line 1326 "parser.y"
                 {
    (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);
    
    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    auto old_temp = (yyvsp[-1].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[0].nonTerminal)->get_temporary());
    op_3AC.pop();
}
#line 3433 "parser.tab.c"
    break;

  case 137: /* op_fac: factor MULTIPLY  */
#line 1342 "parser.y"
                        {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false); op_3AC.push("*");}
#line 3439 "parser.tab.c"
    break;

  case 138: /* op_fac: factor DIVIDE  */
#line 1343 "parser.y"
                 {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false); op_3AC.push("/");}
#line 3445 "parser.tab.c"
    break;

  case 139: /* op_fac: factor MODULO  */
#line 1344 "parser.y"
                 {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false); op_3AC.push("%");}
#line 3451 "parser.tab.c"
    break;

  case 140: /* op_fac: factor FLOOR_DIVIDE  */
#line 1345 "parser.y"
                         {(yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->set_is_lvalue(false); op_3AC.push("//");}
#line 3457 "parser.tab.c"
    break;

  case 141: /* op_fac: op_fac factor MULTIPLY  */
#line 1346 "parser.y"
                            {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);
    (yyval.nonTerminal)->set_operator_type_augassign(1);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp = (yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp, op_3AC.top(), (yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push("*");
}
#line 3478 "parser.tab.c"
    break;

  case 142: /* op_fac: op_fac factor DIVIDE  */
#line 1362 "parser.y"
                         {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);
    (yyval.nonTerminal)->set_operator_type_augassign(1);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp=(yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp,op_3AC.top(),(yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push("/");
}
#line 3499 "parser.tab.c"
    break;

  case 143: /* op_fac: op_fac factor MODULO  */
#line 1378 "parser.y"
                         {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);
    (yyval.nonTerminal)->set_operator_type_augassign(1);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp=(yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), old_temp,op_3AC.top(),(yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push("%");
}
#line 3520 "parser.tab.c"
    break;

  case 144: /* op_fac: op_fac factor FLOOR_DIVIDE  */
#line 1394 "parser.y"
                                 {
    (yyval.nonTerminal) = (yyvsp[-2].nonTerminal);
    auto datatype=(yyval.nonTerminal)->compare_datatype((yyvsp[-1].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Datatypes of both sides of operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);
    (yyval.nonTerminal)->set_operator_type_augassign(1);

    (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
    auto old_temp=(yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),old_temp,op_3AC.top(),(yyvsp[-1].nonTerminal)->get_temporary());
    op_3AC.pop();
    op_3AC.push("//");
}
#line 3541 "parser.tab.c"
    break;

  case 145: /* factor: PLUS factor  */
#line 1412 "parser.y"
                    {
    (yyval.nonTerminal) =(yyvsp[0].nonTerminal);
    auto datatype=(yyvsp[0].nonTerminal)->get_datatype();
    if(datatype.datatype=="ERROR"){
        cout << "Unary plus operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);
}
#line 3555 "parser.tab.c"
    break;

  case 146: /* factor: MINUS factor  */
#line 1421 "parser.y"
                {
    // cout<<$2->get_lexeme()<<endl;
    (yyval.nonTerminal) =(yyvsp[0].nonTerminal);
    auto datatype=(yyvsp[0].nonTerminal)->get_datatype();
    if(datatype.datatype=="ERROR"||datatype.datatype=="str")
    {
        cout << "Unary minus operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl; 
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),"-",(yyvsp[0].nonTerminal)->get_temporary());

}
#line 3574 "parser.tab.c"
    break;

  case 147: /* factor: BITWISE_NOT factor  */
#line 1435 "parser.y"
                       {(yyval.nonTerminal) =(yyvsp[0].nonTerminal);
    (yyval.nonTerminal)->set_is_lvalue(false);
    auto datatype=(yyvsp[0].nonTerminal)->get_datatype();
    if(!(datatype.datatype=="bool"&&datatype.datatype=="int")){
        cout << "Bitwise not operator cannot be applied on line "<<(yyvsp[-1].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),"~",(yyvsp[0].nonTerminal)->get_temporary());
}
#line 3590 "parser.tab.c"
    break;

  case 148: /* factor: power  */
#line 1446 "parser.y"
        {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 3596 "parser.tab.c"
    break;

  case 149: /* power: atom_expr  */
#line 1449 "parser.y"
                    {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);/*$1->print_code();*/}
#line 3602 "parser.tab.c"
    break;

  case 150: /* power: atom_expr POWER factor  */
#line 1450 "parser.y"
                            {
    // $1->print_code();
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    auto temp=(yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->set_is_lvalue(false);
    auto datatype= (yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Datatypes of both sides of power operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),temp,"**",(yyvsp[0].nonTerminal)->get_temporary());
    
}
#line 3623 "parser.tab.c"
    break;

  case 151: /* power: atom  */
#line 1466 "parser.y"
       {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 3629 "parser.tab.c"
    break;

  case 152: /* power: atom POWER factor  */
#line 1467 "parser.y"
                    {
    (yyval.nonTerminal)=(yyvsp[-2].nonTerminal);
    auto temp=(yyvsp[-2].nonTerminal)->get_temporary();
    (yyval.nonTerminal)->set_is_lvalue(false);
    auto datatype= (yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype());
    if(datatype.datatype == "ERROR"||datatype.datatype=="str"){
        cout << "Datatypes of both sides of power operator are not same on line "<<(yyvsp[-2].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.nonTerminal)->set_datatype(datatype);

    (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
    (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),temp,"**",(yyvsp[0].nonTerminal)->get_temporary());
    }
#line 3648 "parser.tab.c"
    break;

  case 153: /* atom_expr: atom DOT NAME  */
#line 1483 "parser.y"
                         {
        Type type = (yyvsp[-2].nonTerminal)->get_datatype();
        if(!type.is_class){
            cout << "Type " << type.datatype << " is not a class at line no " <<(yyvsp[0].nonTerminal)->get_line_no()<< endl;
            exit(-1);
        }
        // printf("%s",type.datatype.c_str());
        st_entry* entry = type.class_table->lookup_class_member((yyvsp[0].nonTerminal)->get_lexeme());
        if(entry == nullptr){
            symbol_table_function* function_table = type.class_table->lookup_function((yyvsp[0].nonTerminal)->get_lexeme());
            if(function_table == nullptr){
                // no etry no function
                cout << "Class " << type.datatype << " has no member named " << (yyvsp[0].nonTerminal)->get_lexeme() <<" at line no: "<<(yyvsp[-2].nonTerminal)->get_line_no()<< endl;
                exit(-1);
            }
            //function
            Type new_type;
            new_type.datatype = (yyvsp[0].nonTerminal)->get_lexeme();
            new_type.is_function = true;
            new_type.function_table = function_table;
            is_print_function.push(false);
            curr_function.push(function_table);
            curr_return_type.push(function_table->get_return_type());
            if(function_table->is_first_argument_self())
            function_arg_counter.push(1);
            else
            function_arg_counter.push(0);
            (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme(), new_type);
            (yyval.nonTerminal)->set_temporary((yyvsp[-2].nonTerminal)->get_temporary());
            (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));
        }
        else{
            //entry
            (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme(), entry->get_datatype());
            (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));
            (yyval.nonTerminal)->set_is_lvalue(true);
            if(entry->get_datatype().is_class||entry->get_datatype().is_list)
            {
                (yyval.nonTerminal)->set_is_ptr(true);
            }
            (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyvsp[-2].nonTerminal)->get_temporary(),"+",to_string(entry->get_offset()));
            
            (yyval.nonTerminal)->set_temporary("*"+(yyval.nonTerminal)->get_temporary());
            
        }
    // $$->print_code();
    }
#line 3700 "parser.tab.c"
    break;

  case 154: /* atom_expr: atom_expr DOT NAME  */
#line 1531 "parser.y"
                     {
    // cout<<"atom_expr DOT NAME\n";
        Type type = (yyvsp[-2].nonTerminal)->get_datatype();
        if(!type.is_class){
            cout << "Type " << type.datatype << " is not a class at line no " << (yyvsp[0].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        st_entry* entry = type.class_table->lookup_class_member((yyvsp[0].nonTerminal)->get_lexeme());
        if(entry == nullptr){
            symbol_table_function* function_table = type.class_table->lookup_function((yyvsp[0].nonTerminal)->get_lexeme());
            if(function_table == nullptr){
                cout << "Class " << type.datatype << " has no member named " << (yyvsp[-2].nonTerminal)->get_lexeme() << "at line no: " << (yyvsp[-2].nonTerminal)->get_lexeme() << endl;
                exit(-1);
            }
            Type new_type;
            new_type.datatype = (yyvsp[0].nonTerminal)->get_lexeme();
            new_type.is_function = true;
            is_print_function.push(false);
            new_type.function_table = function_table;
            curr_function.push(function_table);
            curr_return_type.push(function_table->get_return_type());
            if(function_table->is_first_argument_self())
            function_arg_counter.push(1);
            else
            function_arg_counter.push(0);
            (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme(), new_type);
            (yyval.nonTerminal)->set_temporary((yyvsp[-2].nonTerminal)->get_temporary());
            (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));
        }
        else{
            (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme(), entry->get_datatype());
            (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));
            (yyval.nonTerminal)->set_is_lvalue(true);
            if(entry->get_datatype().is_class || entry->get_datatype().is_list)
            {
                (yyval.nonTerminal)->set_is_ptr(true);
            }
            (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyvsp[-2].nonTerminal)->get_temporary(),"+",to_string(entry->get_offset()));
            (yyval.nonTerminal)->set_temporary("*"+(yyval.nonTerminal)->get_temporary());
        }
    }
#line 3746 "parser.tab.c"
    break;

  case 155: /* atom_expr: atom OPEN_BRACKET test CLOSE_BRACKET  */
#line 1573 "parser.y"
                                       {
        Type type = (yyvsp[-3].nonTerminal)->get_datatype();
        if(!type.is_list){
            cout << "Type " << type.datatype << " is not a list" << endl;
            exit(-1);
        }
        if(!((yyvsp[-1].nonTerminal)->get_datatype().datatype == "int" ||(yyvsp[-1].nonTerminal)->get_datatype().datatype == "bool")||(yyvsp[-1].nonTerminal)->get_datatype().is_list)
        {
            cout << "Index of list should be of type int or bool at line no "<<(yyvsp[-1].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        type.is_list = false;
        (yyval.nonTerminal) = new NonTerminal((yyvsp[-1].nonTerminal)->get_line_no(), type);
        (yyval.nonTerminal)->set_is_lvalue(true);
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
        (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyvsp[-1].nonTerminal)->get_temporary(),"*",to_string(calculate_size(type)));
        auto old_temp = (yyval.nonTerminal)->get_temporary();
        (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyvsp[-3].nonTerminal)->get_temporary(),"+",old_temp);
        (yyval.nonTerminal)->set_temporary("*"+(yyval.nonTerminal)->get_temporary());        
}
#line 3772 "parser.tab.c"
    break;

  case 156: /* atom_expr: atom_expr OPEN_BRACKET test CLOSE_BRACKET  */
#line 1595 "parser.y"
                                             {
        Type type = (yyvsp[-3].nonTerminal)->get_datatype();
        if(!type.is_list){
            cout << "Type " << type.datatype << " is not a list" << endl;
            exit(-1);
        }
        if(!((yyvsp[-1].nonTerminal)->get_datatype().datatype == "int" ||(yyvsp[-1].nonTerminal)->get_datatype().datatype == "bool")||(yyvsp[-1].nonTerminal)->get_datatype().is_list)
        {
            cout << "Index of list should be of type int or bool at line no "<<(yyvsp[-1].nonTerminal)->get_line_no()<<endl;
            exit(-1);
        }
        type.is_list = false;
        (yyval.nonTerminal) = new NonTerminal((yyvsp[-1].nonTerminal)->get_line_no(), type);
        (yyval.nonTerminal)->set_is_lvalue(true);
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));
        (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
        (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyvsp[-1].nonTerminal)->get_temporary(),"*",to_string(calculate_size(type)));
        auto old_temp = (yyval.nonTerminal)->get_temporary();
        (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyvsp[-3].nonTerminal)->get_temporary(),"+",old_temp);
        (yyval.nonTerminal)->set_temporary("*"+(yyval.nonTerminal)->get_temporary());  
    }
#line 3798 "parser.tab.c"
    break;

  case 157: /* atom_expr: atom OPEN_PAREN arglist CLOSE_PAREN  */
#line 1618 "parser.y"
                                      {
    // $3->print_code();
    if(is_print_function.top())
    {
        // is_print_function = false;
        (yyval.nonTerminal) = new NonTerminal((yyvsp[-1].nonTerminal)->get_line_no(), {"None",false,false,false,nullptr,nullptr});
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));        
        (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
        // $$->gen("stackpointer", "+xxx");

        (yyval.nonTerminal)->gen("call", "print", "1");        
        (yyval.nonTerminal)->gen("$rsp","$rsp","+",to_string(calculate_size((yyvsp[-1].nonTerminal)->get_datatype()))); 
    }
    else
    {
        Type type = (yyvsp[-3].nonTerminal)->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << (yyvsp[-3].nonTerminal)->get_lexeme() << " is not a function at line no "<<(yyvsp[-3].nonTerminal)->get_line_no() << endl;
            exit(-1);
        }
        int top = function_arg_counter.top();//how many paramenters we have matched
        int top2 = top;
        if(type.function_table->is_first_argument_self())
        { --top;}
        if(top != type.function_table->get_parameter_count()){
            cout << "Use of Function " << (yyvsp[-3].nonTerminal)->get_lexeme() << " does not match with its definition at line no"<<(yyvsp[0].nonTerminal)->get_line_no() << endl;
            exit(-1);
        }
        (yyval.nonTerminal) = new NonTerminal((yyvsp[-1].nonTerminal)->get_line_no(), curr_return_type.top());
        (yyval.nonTerminal)->copy_code((yyvsp[-3].nonTerminal));        
        (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));
        if(type.function_table->is_first_argument_self())
        {
            if((yyvsp[-3].nonTerminal)->get_temporary() == "" && type.function_table->get_name()=="__init__"){
                (yyval.nonTerminal)->gen("pushl", to_string(type.function_table->get_parent_st()->get_offset()));
                // $$->gen("stackpointer", "+xxx");
                (yyval.nonTerminal)->gen("call", "allocmem", "1");
                (yyval.nonTerminal)->gen("$rsp", "$rsp","-","4");
                (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "$rax");
                (yyval.nonTerminal)->gen("pushq", (yyval.nonTerminal)->get_temporary());
            }
            else (yyval.nonTerminal)->gen("pushq",(yyvsp[-3].nonTerminal)->get_temporary());
        }
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            (yyval.nonTerminal)->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), to_string(top2));
        }
        else
        {
            (yyval.nonTerminal)->gen("call", type.function_table->get_name(), to_string(top2));
        }       
        (yyval.nonTerminal)->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
        if(curr_return_type.top().datatype != "None" && type.function_table->get_name()!="__init__"){
            (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "$rax");
        }
        curr_return_type.pop();
        curr_function.pop();  
    }
    function_arg_counter.pop();
    is_print_function.pop();
    }
#line 3866 "parser.tab.c"
    break;

  case 158: /* atom_expr: atom OPEN_PAREN CLOSE_PAREN  */
#line 1681 "parser.y"
                              {
    if(is_print_function.top())
    {
        // is_print_function = false;
        /*TODO: print function should have exactly one argument right?*/
        cout << "Print function should have exactly one argument" << endl;
        exit(-1);
        // $$ = new NonTerminal($3->get_line_no(), {"None",false,false,false,nullptr,nullptr});
    }
    else
    {
        Type type = (yyvsp[-2].nonTerminal)->get_datatype(); 
        if(!type.is_function){
            cout << (yyvsp[-2].nonTerminal)->get_lexeme() << " is not a function" << endl;
            exit(-1);
        }
        if(type.function_table->get_parameter_count() != 0){
            cout << "Use of Function " << (yyvsp[-2].nonTerminal)->get_lexeme() << " does not match with its definition" << endl;
            exit(-1);
        }
        (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), curr_return_type.top());
        if((yyvsp[-2].nonTerminal)->get_temporary() == "" && type.function_table->get_name()=="__init__"){
            (yyval.nonTerminal)->gen("pushl", to_string(type.function_table->get_parent_st()->get_offset()));
            // $$->gen("stackpointe", "+xxx");
            (yyval.nonTerminal)->gen("call", "allocmem", "1");
            (yyval.nonTerminal)->gen("$rsp", "$rsp","-","4");
            (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "rax");
            (yyval.nonTerminal)->gen("pushq", (yyval.nonTerminal)->get_temporary());
        }
        else if(type.function_table->is_first_argument_self()) (yyval.nonTerminal)->gen("pushq",(yyvsp[-2].nonTerminal)->get_temporary());
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            (yyval.nonTerminal)->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), "1");
        }
        else
        {
            (yyval.nonTerminal)->gen("call", type.function_table->get_name(), "0");
        }       
        (yyval.nonTerminal)->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
        if(curr_return_type.top().datatype != "None" && type.function_table->get_name()!="__init__")
            (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "$rax");
        curr_return_type.pop();
        curr_function.pop();        
    }  
    function_arg_counter.pop();
    is_print_function.pop();
    }
#line 3920 "parser.tab.c"
    break;

  case 159: /* atom_expr: atom_expr OPEN_PAREN CLOSE_PAREN  */
#line 1730 "parser.y"
                                   {
    // $1->print_code();
    Type type = (yyvsp[-2].nonTerminal)->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
    if(!type.is_function){
        cout << (yyvsp[-2].nonTerminal)->get_lexeme() << " is not a function" << endl;
        exit(-1);
    }
    if(type.function_table->get_parameter_count() != 0){
        cout << "Use of Function " << (yyvsp[-2].nonTerminal)->get_lexeme() << " does not match with its definition" << endl;
        exit(-1);
    }
    (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), curr_return_type.top());
    if(type.function_table->is_first_argument_self())
    (yyval.nonTerminal)->gen("pushq",(yyvsp[-2].nonTerminal)->get_temporary());
    // $$->gen("stackpointer", "+xxx");
    auto parent_sym_table= type.function_table->get_parent_st();
    if(parent_sym_table->get_symbol_table_type()==2)
    {
        (yyval.nonTerminal)->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), "1");
    }
    else
    {
        (yyval.nonTerminal)->gen("call", type.function_table->get_name(), "0");
    }       
    (yyval.nonTerminal)->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
    if(curr_return_type.top().datatype != "None")
        (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "$rax");
    curr_return_type.pop();
    curr_function.pop();    
    function_arg_counter.pop();
    is_print_function.pop();
}
#line 3957 "parser.tab.c"
    break;

  case 160: /* atom_expr: atom_expr OPEN_PAREN arglist CLOSE_PAREN  */
#line 1763 "parser.y"
                                            {
    // cout<<"line 1adf"<<endl;
        Type type = (yyvsp[-3].nonTerminal)->get_datatype();  // TODO: probably won't be needed if things already checked in 'atom' and 'arglist'pe();
        if(!type.is_function){
            cout << (yyvsp[-3].nonTerminal)->get_lexeme() << " is not a function" << endl;
            exit(-1);
        }
        int top = function_arg_counter.top();
        int top2 = top;
        if(type.function_table->is_first_argument_self()) { --top;}
        if(top != type.function_table->get_parameter_count()){
            cout << "Use of Function " << (yyvsp[-3].nonTerminal)->get_lexeme() << " does not match with its definition at line no"<<(yyvsp[0].nonTerminal)->get_line_no() << endl;
            exit(-1);
        }
        (yyval.nonTerminal) = new NonTerminal((yyvsp[-1].nonTerminal)->get_line_no(), curr_return_type.top());  
        if(type.function_table->is_first_argument_self())
        (yyval.nonTerminal)->gen("pushq",(yyvsp[-3].nonTerminal)->get_temporary());
        // $$->gen("stackpointer", "+xxx");
        auto parent_sym_table= type.function_table->get_parent_st();
        if(parent_sym_table->get_symbol_table_type()==2)
        {
            (yyval.nonTerminal)->gen("call", parent_sym_table->get_name()+"."+type.function_table->get_name(), to_string(top2));
        }
        else
        {
            (yyval.nonTerminal)->gen("call", type.function_table->get_name(), to_string(top2));
        }       
        (yyval.nonTerminal)->gen("$rsp", "$rsp", "+", to_string(type.function_table->get_agrument_size()));
        if(curr_return_type.top().datatype != "None")
            (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(), "$rax"); 
        curr_return_type.pop();
        curr_function.pop(); 
        function_arg_counter.pop();  
        is_print_function.pop();
}
#line 3997 "parser.tab.c"
    break;

  case 161: /* atom: OPEN_PAREN testlist_comp CLOSE_PAREN  */
#line 1800 "parser.y"
                                            {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal);cout<<(yyval.nonTerminal)->get_datatype().datatype<<endl; 
// curr_list_temporaries.pop_back();
}
#line 4005 "parser.tab.c"
    break;

  case 162: /* atom: OPEN_PAREN CLOSE_PAREN  */
#line 1803 "parser.y"
                            {(yyval.nonTerminal)=new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(),{"",false,false,false,nullptr,nullptr}); }
#line 4011 "parser.tab.c"
    break;

  case 163: /* atom: OPEN_BRACKET testlist_comp CLOSE_BRACKET  */
#line 1804 "parser.y"
                                            {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal);(yyval.nonTerminal)->set_list(true);}
#line 4017 "parser.tab.c"
    break;

  case 164: /* atom: OPEN_BRACKET CLOSE_BRACKET  */
#line 1805 "parser.y"
                                {(yyval.nonTerminal)=new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), {"",true,false,false,nullptr,nullptr});}
#line 4023 "parser.tab.c"
    break;

  case 165: /* atom: NAME  */
#line 1806 "parser.y"
      {
        if((yyvsp[0].nonTerminal)->get_lexeme() == "print"){
            // is_print_function = true;
            Type new_type;
            new_type.datatype = (yyvsp[0].nonTerminal)->get_lexeme();
            new_type.is_function = true;
            is_print_function.push(true);
            new_type.function_table = nullptr;
            function_arg_counter.push(0);
            (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme(), new_type);
        }
        else{
            st_entry* entry = curr_symbol_table->lookup_all((yyvsp[0].nonTerminal)->get_lexeme());
            if(entry == nullptr){
                symbol_table_function* function_table = global_symbol_table->lookup_function((yyvsp[0].nonTerminal)->get_lexeme());
                // cout<<"fjlakdjsf"<<endl;
                if(function_table == nullptr){
                    symbol_table_class* class_table = global_symbol_table->lookup_class((yyvsp[0].nonTerminal)->get_lexeme());
                    if(class_table == nullptr)
                    {    
                        cout << "Variable " << (yyvsp[0].nonTerminal)->get_lexeme() << " used before declaration at line no: " << (yyvsp[0].nonTerminal)->get_line_no() << endl;
                        exit(-1);
                    }
                    Type new_type;
                    new_type.datatype = (yyvsp[0].nonTerminal)->get_lexeme();
                    new_type.is_function = true;
                    is_print_function.push(false);
                    new_type.function_table = class_table->lookup_function("__init__");
                    curr_function.push(new_type.function_table);
                    Type class_type;
                    class_type.datatype = (yyvsp[0].nonTerminal)->get_lexeme();
                    class_type.class_table = class_table;
                    class_type.is_class = true;
                    curr_return_type.push(class_type);
                    function_arg_counter.push(1);
                    (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme(), new_type);
                    
                }
                else{
                    Type new_type;
                    new_type.datatype = (yyvsp[0].nonTerminal)->get_lexeme();
                    new_type.is_function = true;
                    is_print_function.push(false);
                    new_type.function_table = function_table;
                    curr_function.push(function_table);
                    curr_return_type.push(function_table->get_return_type());
                    if(curr_function.top()->is_first_argument_self())
                    function_arg_counter.push(1);
                    else
                    function_arg_counter.push(0);
                    (yyval.nonTerminal) = new NonTerminal((yyvsp[0].nonTerminal)->get_line_no(), (yyvsp[0].nonTerminal)->get_lexeme(), new_type);
                }                
            }
            else{
                (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
                (yyval.nonTerminal)->set_is_lvalue(true);
                (yyval.nonTerminal)->set_datatype(entry->get_datatype());
                (yyval.nonTerminal)->set_temporary((yyval.nonTerminal)->get_lexeme());
            }
        }  
    }
#line 4089 "parser.tab.c"
    break;

  case 166: /* atom: NUMBER  */
#line 1867 "parser.y"
         {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_datatype({"int",false}); (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyval.nonTerminal)->get_lexeme());}
#line 4095 "parser.tab.c"
    break;

  case 167: /* atom: string_one_or_more  */
#line 1868 "parser.y"
                        {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 4101 "parser.tab.c"
    break;

  case 168: /* atom: NONE  */
#line 1869 "parser.y"
        {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_datatype({"None",false});}
#line 4107 "parser.tab.c"
    break;

  case 169: /* atom: TRUE_  */
#line 1870 "parser.y"
            {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_datatype({"bool",false});(yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyval.nonTerminal)->get_lexeme());}
#line 4113 "parser.tab.c"
    break;

  case 170: /* atom: FALSE_  */
#line 1871 "parser.y"
            {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_datatype({"bool",false});(yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyval.nonTerminal)->get_lexeme());}
#line 4119 "parser.tab.c"
    break;

  case 171: /* atom: REAL_NUMBER  */
#line 1872 "parser.y"
                {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_datatype({"float",false});(yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyval.nonTerminal)->get_lexeme());}
#line 4125 "parser.tab.c"
    break;

  case 172: /* string_one_or_more: string_one_or_more STRING  */
#line 1876 "parser.y"
                                                {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal);auto temp = (yyvsp[-1].nonTerminal)-> get_temporary();(yyval.nonTerminal)->set_lexeme((yyvsp[-1].nonTerminal)->get_lexeme() + (yyvsp[0].nonTerminal)->get_lexeme()); (yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),temp,"+",(yyvsp[0].nonTerminal)->get_lexeme());}
#line 4131 "parser.tab.c"
    break;

  case 173: /* string_one_or_more: STRING  */
#line 1877 "parser.y"
            {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_datatype({"str",false});(yyval.nonTerminal)->gen((yyval.nonTerminal)->set_temporary(),(yyval.nonTerminal)->get_lexeme());}
#line 4137 "parser.tab.c"
    break;

  case 174: /* testlist_comp: named_star_or comma_named_star_comma  */
#line 1880 "parser.y"
                                                    {
    if((yyvsp[0].nonTerminal)->get_datatype().datatype == "COMMA"){
        (yyval.nonTerminal) =(yyvsp[-1].nonTerminal);
    }
    else{
        (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);
        (yyval.nonTerminal)->set_datatype((yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype()));
        (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));
        (yyval.nonTerminal)->copy_cur_temp((yyvsp[0].nonTerminal));
    }
}
#line 4153 "parser.tab.c"
    break;

  case 175: /* testlist_comp: named_star_or  */
#line 1891 "parser.y"
                {
    (yyval.nonTerminal) =(yyvsp[0].nonTerminal);
}
#line 4161 "parser.tab.c"
    break;

  case 176: /* comma_named_star_comma: comma_named_star COMMA  */
#line 1897 "parser.y"
                                                {(yyval.nonTerminal)=(yyvsp[-1].nonTerminal);}
#line 4167 "parser.tab.c"
    break;

  case 177: /* comma_named_star_comma: comma_named_star  */
#line 1898 "parser.y"
                    {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);}
#line 4173 "parser.tab.c"
    break;

  case 178: /* comma_named_star_comma: COMMA  */
#line 1899 "parser.y"
        {(yyval.nonTerminal) = (yyvsp[0].nonTerminal);(yyval.nonTerminal)->set_datatype({"COMMA",false});}
#line 4179 "parser.tab.c"
    break;

  case 179: /* named_star_or: namedexpr_test  */
#line 1901 "parser.y"
                                {
    (yyval.nonTerminal) =(yyvsp[0].nonTerminal);
    cout<<(yyvsp[0].nonTerminal)->get_temporary()<<"->"<<(yyvsp[0].nonTerminal)->get_datatype().datatype<<endl;
    // curr_list_temporaries.push_back($1->get_temporary());    
}
#line 4189 "parser.tab.c"
    break;

  case 180: /* comma_named_star: COMMA named_star_or  */
#line 1909 "parser.y"
                                        {(yyval.nonTerminal)= (yyvsp[0].nonTerminal); }
#line 4195 "parser.tab.c"
    break;

  case 181: /* comma_named_star: comma_named_star COMMA named_star_or  */
#line 1910 "parser.y"
                                        {(yyval.nonTerminal)=(yyvsp[-2].nonTerminal); (yyval.nonTerminal)->copy_code((yyvsp[0].nonTerminal));(yyval.nonTerminal)->curr_list_temporaries_push((yyvsp[0].nonTerminal)->get_temporary()); (yyval.nonTerminal)->set_datatype((yyval.nonTerminal)->compare_datatype((yyvsp[0].nonTerminal)->get_datatype()));}
#line 4201 "parser.tab.c"
    break;

  case 182: /* exprlist: expr  */
#line 1913 "parser.y"
               {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 4207 "parser.tab.c"
    break;

  case 183: /* testlist: test  */
#line 1917 "parser.y"
               {(yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 4213 "parser.tab.c"
    break;

  case 184: /* classdef: classdef_head suite  */
#line 1923 "parser.y"
                              {
    (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
    if(symbol_table_stack.size() == 0){
        cout << "trying to pop empty stack" << endl;
        exit(-1);
    }
    symbol_table_stack.top()->add_init();
    symbol_table_stack.pop();
    curr_symbol_table=symbol_table_stack.top();
}
#line 4228 "parser.tab.c"
    break;

  case 185: /* classdef_head: CLASS NAME COLON  */
#line 1935 "parser.y"
                                {
    auto new_class = curr_symbol_table->create_new_class((yyvsp[-1].nonTerminal)->get_lexeme(), nullptr);
    cout<<(yyvsp[-1].nonTerminal)->get_line_no()<<endl;
    new_class->set_line_no((yyvsp[-1].nonTerminal)->get_line_no());
    symbol_table_stack.push(new_class); curr_symbol_table = new_class;
    
}
#line 4240 "parser.tab.c"
    break;

  case 186: /* classdef_head: CLASS NAME OPEN_PAREN CLOSE_PAREN COLON  */
#line 1942 "parser.y"
                                          {
    auto new_class = curr_symbol_table->create_new_class((yyvsp[-3].nonTerminal)->get_lexeme(), nullptr);
    new_class->set_line_no((yyvsp[-3].nonTerminal)->get_line_no());
    symbol_table_stack.push(new_class); curr_symbol_table = new_class;
}
#line 4250 "parser.tab.c"
    break;

  case 187: /* classdef_head: CLASS NAME OPEN_PAREN NAME CLOSE_PAREN COLON  */
#line 1947 "parser.y"
                                               {
    auto parent_class = curr_symbol_table->lookup_class((yyvsp[-2].nonTerminal)->get_lexeme()); /*if(parent_class == nullptr){cout << "Base class not defined\n";}*/
    auto new_class = curr_symbol_table->create_new_class((yyvsp[-4].nonTerminal)->get_lexeme(), parent_class);
    new_class->set_line_no((yyvsp[-4].nonTerminal)->get_line_no());
    symbol_table_stack.push(new_class); curr_symbol_table = new_class;
}
#line 4261 "parser.tab.c"
    break;

  case 188: /* arglist: argument comma_arg  */
#line 1955 "parser.y"
                            {push_argument((yyvsp[-1].nonTerminal)); (yyval.nonTerminal) = (yyvsp[0].nonTerminal); (yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));}
#line 4267 "parser.tab.c"
    break;

  case 189: /* arglist: argument comma_arg COMMA  */
#line 1956 "parser.y"
                           {push_argument((yyvsp[-2].nonTerminal)); (yyval.nonTerminal) = (yyvsp[-1].nonTerminal); (yyval.nonTerminal)->copy_code((yyvsp[-2].nonTerminal));}
#line 4273 "parser.tab.c"
    break;

  case 190: /* arglist: argument  */
#line 1957 "parser.y"
            {push_argument((yyvsp[0].nonTerminal)); (yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 4279 "parser.tab.c"
    break;

  case 191: /* arglist: argument COMMA  */
#line 1958 "parser.y"
                    {push_argument((yyvsp[-1].nonTerminal)); (yyval.nonTerminal) = (yyvsp[-1].nonTerminal);}
#line 4285 "parser.tab.c"
    break;

  case 192: /* comma_arg: COMMA argument  */
#line 1961 "parser.y"
                            {push_argument((yyvsp[0].nonTerminal)); (yyval.nonTerminal)=(yyvsp[0].nonTerminal);}
#line 4291 "parser.tab.c"
    break;

  case 193: /* comma_arg: COMMA argument comma_arg  */
#line 1962 "parser.y"
                            {push_argument((yyvsp[-1].nonTerminal));(yyval.nonTerminal)=(yyvsp[0].nonTerminal);(yyval.nonTerminal)->copy_code((yyvsp[-1].nonTerminal));}
#line 4297 "parser.tab.c"
    break;

  case 194: /* argument: test  */
#line 1965 "parser.y"
                {
    (yyval.nonTerminal) = (yyvsp[0].nonTerminal);
}
#line 4305 "parser.tab.c"
    break;

  case 195: /* func_body_suite: simple_stmt  */
#line 1971 "parser.y"
                             { (yyval.nonTerminal) = (yyvsp[0].nonTerminal); }
#line 4311 "parser.tab.c"
    break;

  case 196: /* func_body_suite: NEWLINE INDENT stmts DEDENT  */
#line 1972 "parser.y"
                              { (yyval.nonTerminal) = (yyvsp[-1].nonTerminal); }
#line 4317 "parser.tab.c"
    break;

  case 197: /* datatype: NAME  */
#line 1975 "parser.y"
               {
    (yyval.type) = new Type; (yyval.type)->datatype = (yyvsp[0].nonTerminal)->get_lexeme(); 
    (yyval.type)->is_list = false;
    if(!((yyvsp[0].nonTerminal)->get_lexeme() == "int" || (yyvsp[0].nonTerminal)->get_lexeme() == "float" || (yyvsp[0].nonTerminal)->get_lexeme() == "bool" || (yyvsp[0].nonTerminal)->get_lexeme() == "str")){
        (yyval.type)->is_class=true;
        (yyval.type)->class_table=global_symbol_table->lookup_class((yyvsp[0].nonTerminal)->get_lexeme());
        if((yyval.type)->class_table == nullptr){
            printf("Class %s not defined\n",(yyvsp[0].nonTerminal)->get_lexeme().c_str());
            exit(-1);
        }
    }
}
#line 4334 "parser.tab.c"
    break;

  case 198: /* datatype: NAME OPEN_BRACKET NAME CLOSE_BRACKET  */
#line 1987 "parser.y"
                                       {
    if((yyvsp[-3].nonTerminal)->get_lexeme() != "list"){
        cout << "Illegal type declaration at line no: " << (yyvsp[-3].nonTerminal)->get_line_no() << endl;
        exit(-1);
    }
    (yyval.type) = new Type; (yyval.type)->datatype = (yyvsp[-1].nonTerminal)->get_lexeme(); (yyval.type)->is_list=true;
    if(!((yyvsp[-1].nonTerminal)->get_lexeme() == "int" || (yyvsp[-1].nonTerminal)->get_lexeme() == "float" || (yyvsp[-1].nonTerminal)->get_lexeme() == "bool" || (yyvsp[-1].nonTerminal)->get_lexeme() == "str")){
        (yyval.type)->is_class=true;
        (yyval.type)->class_table=global_symbol_table->lookup_class((yyvsp[-3].nonTerminal)->get_lexeme());
        if((yyval.type)->class_table == nullptr){
            printf("Class %s not defined\n",(yyvsp[-3].nonTerminal)->get_lexeme().c_str());
            exit(-1);
        }
    }
}
#line 4354 "parser.tab.c"
    break;


#line 4358 "parser.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 2004 "parser.y"


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
    cout << "--input <input-file>: Specify the input program file" << endl;
    cout << "--output <output-file>: Specify the output dot file" << endl;
    cout << "--verbose: Generate additional details about parsing in \"verbose.log\" file" << endl;
    cout << "--help: Print this help" << endl;
}
void print_threeAC()
{
     ofstream file;
    file.open("../output/ThreeAC.txt");
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
    // string output_file_path = "tree.dot";
    for(int i = 1; i < argc; ++i){
        if(string(argv[i]) == "--help"){
            print_help();
            return 0;
        }
        else if(string(argv[i]) == "--verbose") {
            verbose = true;
            yydebug = 1; 
            string error_file_path = "temp";
            freopen(error_file_path.c_str(), "w", stderr); 
        }
        else if(string(argv[i]) == "--input"){
            if(++i < argc) input_file_path = argv[i];
            else{
                cerr << "Error: No input file provided" << endl;
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
    print_threeAC();
    global_symbol_table->make_csv();
    // global_symbol_table->print();
    // cout << function_arg_counter.size() << endl;
    // root->make_tree(output_file_path);

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
