/* =====================================================================
   NOTA PARA EL EQUIPO:
   Este archivo es un fragmento de referencia. Los tokens declarados
   aquí deben coincidir con los %token que declares en parser.yy.
   ===================================================================== */

/*
   Tokens que el lexer.ll retorna — declara estos en tu parser.yy:

   ── Tipos básicos ─────────────────────────────────────────────────
   %token                  INT FLOAT CHAR BOOL VOID

   ── Palabras reservadas ───────────────────────────────────────────
   %token                  IF ELSE WHILE FOR BREAK RETURN
   %token                  DEF STRUCT

   ── Literales (llevan valor semántico) ────────────────────────────
   %token <std::string>    ID
   %token <std::string>    NUMERO
   %token <std::string>    FLOTANTE
   %token <std::string>    STRING
   %token <std::string>    CARACTER
   %token <std::string>    BOOLEANO

   ── Operadores relacionales ───────────────────────────────────────
   %token                  EQUAL DISTINCT LT GT LE GE

   ── Operadores lógicos ────────────────────────────────────────────
   %token                  AND OR NOT

   ── Operadores aritméticos ────────────────────────────────────────
   %token                  MAS MENOS MUL DIV MOD
   %token                  INC DEC

   ── Asignación ───────────────────────────────────────────────────
   %token                  ASIG

   ── Delimitadores ────────────────────────────────────────────────
   %token                  LPAR RPAR       // ( )
   %token                  LKEY RKEY       // { }
   %token                  LBRA RBRA       // [ ]
   %token                  PYC             // ;
   %token                  COMA            // ,
   %token                  PUNTO           // .
*/

#ifndef __SCANNER_HPP__
#define __SCANNER_HPP__ 1

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "parser.tab.hh"
#include "location.hh"

namespace C0 {

class Scanner : public yyFlexLexer {
public:

    Scanner(std::istream *in) : yyFlexLexer(in)
    {
        loc = new C0::Parser::location_type();
    };

    // Evita la advertencia de override de función virtual
    using FlexLexer::yylex;

    virtual
    int yylex( C0::Parser::semantic_type * const lval,
               C0::Parser::location_type *location );
    // YY_DECL definido en lexer.ll
    // El cuerpo del método lo genera flex en lex.yy.cc

private:
    /* puntero a yylval */
    C0::Parser::semantic_type *yylval = nullptr;
    /* puntero a location */
    C0::Parser::location_type *loc    = nullptr;
};

} /* end namespace C0 */

#endif /* END __SCANNER_HPP__ */
