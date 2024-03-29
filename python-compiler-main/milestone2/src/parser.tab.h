/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    FOR = 258,                     /* FOR  */
    SEMICOLON = 259,               /* SEMICOLON  */
    KEYWORDS = 260,                /* KEYWORDS  */
    ASYNC = 261,                   /* ASYNC  */
    AWAIT = 262,                   /* AWAIT  */
    COMMENT = 263,                 /* COMMENT  */
    DEDENT = 264,                  /* DEDENT  */
    END = 265,                     /* END  */
    FSTRING = 266,                 /* FSTRING  */
    INDENT = 267,                  /* INDENT  */
    MIDDLE = 268,                  /* MIDDLE  */
    NAME = 269,                    /* NAME  */
    NEWLINE = 270,                 /* NEWLINE  */
    NUMBER = 271,                  /* NUMBER  */
    MULTIPLY = 272,                /* MULTIPLY  */
    MODULO_EQUAL = 273,            /* MODULO_EQUAL  */
    ERROR = 274,                   /* ERROR  */
    START = 275,                   /* START  */
    STRING = 276,                  /* STRING  */
    TYPE = 277,                    /* TYPE  */
    END_MARKER = 278,              /* END_MARKER  */
    AND = 279,                     /* AND  */
    OR = 280,                      /* OR  */
    NOT = 281,                     /* NOT  */
    COMMA = 282,                   /* COMMA  */
    EQUAL_EQUAL = 283,             /* EQUAL_EQUAL  */
    COLONEQUAL = 284,              /* COLONEQUAL  */
    LEFT_SHIFT = 285,              /* LEFT_SHIFT  */
    RIGHT_SHIFT = 286,             /* RIGHT_SHIFT  */
    PLUS = 287,                    /* PLUS  */
    MINUS = 288,                   /* MINUS  */
    POWER = 289,                   /* POWER  */
    DIVIDE = 290,                  /* DIVIDE  */
    FLOOR_DIVIDE = 291,            /* FLOOR_DIVIDE  */
    AT = 292,                      /* AT  */
    MODULO = 293,                  /* MODULO  */
    AND_KEYWORD = 294,             /* AND_KEYWORD  */
    OR_KEYWORD = 295,              /* OR_KEYWORD  */
    NOT_KEYWORD = 296,             /* NOT_KEYWORD  */
    BITWISE_AND = 297,             /* BITWISE_AND  */
    BITWISE_OR = 298,              /* BITWISE_OR  */
    BITWISE_XOR = 299,             /* BITWISE_XOR  */
    BITWISE_NOT = 300,             /* BITWISE_NOT  */
    IN = 301,                      /* IN  */
    IMPORT = 302,                  /* IMPORT  */
    RANGE = 303,                   /* RANGE  */
    YIELD = 304,                   /* YIELD  */
    FROM = 305,                    /* FROM  */
    ELSE = 306,                    /* ELSE  */
    IF = 307,                      /* IF  */
    IS = 308,                      /* IS  */
    NOTEQUAL = 309,                /* NOTEQUAL  */
    LESS_THAN = 310,               /* LESS_THAN  */
    GREATER_THAN = 311,            /* GREATER_THAN  */
    EQUAL = 312,                   /* EQUAL  */
    LESS_THAN_EQUAL = 313,         /* LESS_THAN_EQUAL  */
    COLON = 314,                   /* COLON  */
    GREATER_THAN_EQUAL = 315,      /* GREATER_THAN_EQUAL  */
    LEFT_SHIFT_EQUAL = 316,        /* LEFT_SHIFT_EQUAL  */
    RIGHT_SHIFT_EQUAL = 317,       /* RIGHT_SHIFT_EQUAL  */
    ATEQUAL = 318,                 /* ATEQUAL  */
    FALSE_ = 319,                  /* FALSE_  */
    TRUE_ = 320,                   /* TRUE_  */
    NONE = 321,                    /* NONE  */
    NONLOCAL = 322,                /* NONLOCAL  */
    CLOSE_BRACE = 323,             /* CLOSE_BRACE  */
    BITWISE_OR_EQUAL = 324,        /* BITWISE_OR_EQUAL  */
    BITWISE_AND_EQUAL = 325,       /* BITWISE_AND_EQUAL  */
    OPEN_PAREN = 326,              /* OPEN_PAREN  */
    CLOSE_PAREN = 327,             /* CLOSE_PAREN  */
    POWER_EQUAL = 328,             /* POWER_EQUAL  */
    MULTIPLY_EQUAL = 329,          /* MULTIPLY_EQUAL  */
    PLUS_EQUAL = 330,              /* PLUS_EQUAL  */
    MINUS_EQUAL = 331,             /* MINUS_EQUAL  */
    ARROW = 332,                   /* ARROW  */
    DOT = 333,                     /* DOT  */
    ELLIPSIS = 334,                /* ELLIPSIS  */
    FLOOR_DIVIDE_EQUAL = 335,      /* FLOOR_DIVIDE_EQUAL  */
    DIVIDE_EQUAL = 336,            /* DIVIDE_EQUAL  */
    OPEN_BRACKET = 337,            /* OPEN_BRACKET  */
    CLOSE_BRACKET = 338,           /* CLOSE_BRACKET  */
    BITWISE_XOR_EQUAL = 339,       /* BITWISE_XOR_EQUAL  */
    AS = 340,                      /* AS  */
    ASSERT = 341,                  /* ASSERT  */
    BREAK = 342,                   /* BREAK  */
    CLASS = 343,                   /* CLASS  */
    CONTINUE = 344,                /* CONTINUE  */
    DEF = 345,                     /* DEF  */
    DEL = 346,                     /* DEL  */
    ELIF = 347,                    /* ELIF  */
    EXCEPT = 348,                  /* EXCEPT  */
    FINALLY = 349,                 /* FINALLY  */
    GLOBAL = 350,                  /* GLOBAL  */
    LAMBDA = 351,                  /* LAMBDA  */
    PASS = 352,                    /* PASS  */
    RAISE = 353,                   /* RAISE  */
    RETURN = 354,                  /* RETURN  */
    TRY = 355,                     /* TRY  */
    WHILE = 356,                   /* WHILE  */
    WITH = 357,                    /* WITH  */
    OPEN_BRACE = 358,              /* OPEN_BRACE  */
    REAL_NUMBER = 359              /* REAL_NUMBER  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 162 "parser.y"

    class NonTerminal* node;
    struct Type* type;
    class NonTerminal* nonTerminal;

#line 174 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
