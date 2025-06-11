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

#ifndef YY_YY_TESTESINTATICO_TAB_H_INCLUDED
# define YY_YY_TESTESINTATICO_TAB_H_INCLUDED
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
    t_mais = 258,                  /* t_mais  */
    t_menos = 259,                 /* t_menos  */
    t_asteristico = 260,           /* t_asteristico  */
    t_barra = 261,                 /* t_barra  */
    t_maior = 262,                 /* t_maior  */
    t_menor = 263,                 /* t_menor  */
    t_igual = 264,                 /* t_igual  */
    t_exclamacao = 265,            /* t_exclamacao  */
    t_abrivetor = 266,             /* t_abrivetor  */
    t_fechavetor = 267,            /* t_fechavetor  */
    t_int = 268,                   /* t_int  */
    t_float = 269,                 /* t_float  */
    t_char = 270,                  /* t_char  */
    t_num = 271,                   /* t_num  */
    t_palavra = 272,               /* t_palavra  */
    t_palavranum = 273,            /* t_palavranum  */
    t_decimal = 274,               /* t_decimal  */
    t_varname = 275,               /* t_varname  */
    t_for = 276,                   /* t_for  */
    t_while = 277,                 /* t_while  */
    t_if = 278,                    /* t_if  */
    t_else = 279,                  /* t_else  */
    t_switch = 280,                /* t_switch  */
    t_case = 281,                  /* t_case  */
    t_default = 282,               /* t_default  */
    t_break = 283,                 /* t_break  */
    t_abrichave = 284,             /* t_abrichave  */
    t_fechachave = 285,            /* t_fechachave  */
    t_abriparentes = 286,          /* t_abriparentes  */
    t_fechaparentes = 287,         /* t_fechaparentes  */
    t_pontovirgula = 288,          /* t_pontovirgula  */
    t_doispontos = 289,            /* t_doispontos  */
    t_interrogacao = 290,          /* t_interrogacao  */
    t_class = 291,                 /* t_class  */
    t_construtor = 292,            /* t_construtor  */
    t_destrutor = 293,             /* t_destrutor  */
    t_func = 294,                  /* t_func  */
    t_return = 295,                /* t_return  */
    t_variavel = 296,              /* t_variavel  */
    t_espaco = 297,                /* t_espaco  */
    t_novalinha = 298              /* t_novalinha  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 10 "testesintatico.y"

  char* texto;
  long numero_inteiro;
  double numero_decimal;

#line 113 "testesintatico.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_TESTESINTATICO_TAB_H_INCLUDED  */
