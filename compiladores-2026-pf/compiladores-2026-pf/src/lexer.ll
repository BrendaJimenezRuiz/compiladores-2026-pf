%{
#include <string>
#include <iostream>
using namespace std;

#include "Scanner.hpp"
#undef  YY_DECL
#define YY_DECL int C0::Scanner::yylex( C0::Parser::semantic_type * const lval, \
                                         C0::Parser::location_type *location )

using token = C0::Parser::token;

#define YY_NO_UNISTD_H
#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

%}

%option debug
%option nodefault
%option yyclass="C0::Scanner"
%option noyywrap
%option c++

/* =====================================================================
   Definiciones de patrones auxiliares
   ===================================================================== */

DIGITO          [0-9]
LETRA           [a-zA-Z_]
ENTERO          {DIGITO}+
FLOTANTE        {DIGITO}+"."{DIGITO}+([eE][+-]?{DIGITO}+)?
IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO})*
CADENA          \"([^\"\n\\]|\\.)*\"
CARACTER        \'([^\'\n\\]|\\.)\'

/* Comentarios */
COM_LINEA       "//"[^\n]*
COM_BLOQUE      "/*"([^*]|"*"+[^*/])*"*"+"/"

%%

%{
    yylval = lval;
    /* Propagar la location interna al parámetro del parser */
    *location = *loc;
%}



[ \t\r]+        {  }

\n              {
                    loc->lines();
                }



{COM_LINEA}     {  }

{COM_BLOQUE}    {
                    
                    for (int i = 0; yytext[i] != '\0'; i++)
                        if (yytext[i] == '\n') loc->lines();
                }



"int"           { return token::INT;    }
"float"         { return token::FLOAT;  }
"char"          { return token::CHAR;   }
"bool"          { return token::BOOL;   }

"if"            { return token::IF;     }
"else"          { return token::ELSE;   }
"while"         { return token::WHILE;  }
"for"           { return token::FOR;    }
"break"         { return token::BREAK;  }
"return"        { return token::RETURN; }

"def"           { return token::DEF;    }
"void"          { return token::VOID;   }
"struct"        { return token::STRUCT; }

"true"          {
                    yylval->build<std::string>(yytext);
                    return token::BOOLEANO;
                }
"false"         {
                    yylval->build<std::string>(yytext);
                    return token::BOOLEANO;
                }



{FLOTANTE}      {
                    yylval->build<std::string>(yytext);
                    return token::FLOTANTE;
                }

{ENTERO}        {
                    yylval->build<std::string>(yytext);
                    return token::NUMERO;
                }

{CADENA}        {
                    yylval->build<std::string>(yytext);
                    return token::STRING;
                }

{CARACTER}      {
                    yylval->build<std::string>(yytext);
                    return token::CARACTER;
                }



{IDENTIFICADOR} {
                    yylval->build<std::string>(yytext);
                    return token::ID;
                }



"=="            { return token::EQUAL;    }
"!="            { return token::DISTINCT; }
"<="            { return token::LE;       }
">="            { return token::GE;       }
"<"             { return token::LT;       }
">"             { return token::GT;       }

"&&"            { return token::AND;      }
"||"            { return token::OR;       }
"!"             { return token::NOT;      }

"++"            { return token::INC;      }
"--"            { return token::DEC;      }
"+"             { return token::MAS;      }
"-"             { return token::MENOS;    }
"*"             { return token::MUL;      }
"/"             { return token::DIV;      }
"%"             { return token::MOD;      }

"="             { return token::ASIG;     }



"("             { return token::LPAR;  }
")"             { return token::RPAR;  }
"{"             { return token::LKEY;  }
"}"             { return token::RKEY;  }
"["             { return token::LBRA;  }
"]"             { return token::RBRA;  }

";"             { return token::PYC;   }
","             { return token::COMA;  }
"."             { return token::PUNTO; }



.               {
                    cerr << "ERROR LXICO en lnea "
                         << loc->begin.line
                         << ", columna "
                         << loc->begin.column
                         << ": carcter no reconocido '"
                         << yytext << "'" << endl;
                }

%%
