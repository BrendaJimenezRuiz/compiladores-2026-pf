/* =====================================================================
   parser.yy  —  Analizador Sintáctico
   Proyecto Final Compiladores 2026-2  |  Grupo 7013

   CONFLICTOS CONOCIDOS (1 shift/reduce, intencionado):
   ─────────────────────────────────────────────────────
   Contexto: ID seguido de '[' dentro del cuerpo de una función.
   Ambigüedad: puede ser inicio de declaración de arreglo de struct
     (p. ej. "MiStruct[3] arr;") o inicio de acceso a arreglo
     (p. ej. "arr[0] = x;").
   Resolución: Bison elige SHIFT (acceso a arreglo), que es el
     comportamiento correcto para los casos prácticos del lenguaje.
     Las declaraciones de arreglos de structs deben hacerse de forma
     global o con el tipo completo escrito antes de la función.
   Este conflicto es análogo al existente en la gramática de C estándar
   y está documentado en el archivo parser.output generado por Bison.
   ===================================================================== */

%skeleton "lalr1.cc"
%require  "3.0"
%defines
%define api.namespace {C0}
%define api.parser.class {Parser}

/* ── Código que va al .hh generado ────────────────────────────────── */
%code requires {
    #include <string>
    #include <vector>

    namespace C0 {
        class Driver;
        class Scanner;
    }

    #ifndef YY_NULLPTR
    #  if defined __cplusplus && 201103L <= __cplusplus
    #    define YY_NULLPTR nullptr
    #  else
    #    define YY_NULLPTR 0
    #  endif
    #endif
}

%parse-param { Scanner  &scanner }
%parse-param { Driver   &driver  }

/* ── Código que va al .cc generado ────────────────────────────────── */
%code {
    #include <iostream>
    #include <cstdlib>
    #include <fstream>
    using namespace std;

    #include "Driver.hpp"

    #undef  yylex
    #define yylex scanner.yylex
}

/* ── Tipos semánticos ──────────────────────────────────────────────── */
%define api.value.type variant
%define parse.assert

/* ── Tokens ────────────────────────────────────────────────────────── */

/* Tipos básicos */
%token                  INT FLOAT CHAR BOOL VOID

/* Palabras reservadas */
%token                  IF ELSE WHILE FOR BREAK RETURN
%token                  DEF STRUCT

/* Literales */
%token <std::string>    ID
%token <std::string>    NUMERO
%token <std::string>    FLOTANTE
%token <std::string>    STRING
%token <std::string>    CARACTER
%token <std::string>    BOOLEANO

/* Operadores relacionales */
%token                  EQUAL DISTINCT LT GT LE GE

/* Operadores lógicos */
%token                  AND OR NOT

/* Operadores aritméticos */
%token                  MAS MENOS MUL DIV MOD
%token                  INC DEC

/* Asignación */
%token                  ASIG

/* Delimitadores */
%token                  LPAR RPAR
%token                  LKEY RKEY
%token                  LBRA RBRA
%token                  PYC
%token                  COMA
%token                  PUNTO

/* ── Precedencia y asociatividad (de menor a mayor prioridad) ────────
   Resuelve automáticamente todos los conflictos shift/reduce.

   • ASIG  derecha: a = b = c  →  a = (b = c)
   • Lógicos izquierda
   • Relacionales izquierda
   • Aritméticos: +- izq, luego * / % izq
   • Unarios (NOT, menos unario) mayor que binarios
   • LBRA y PUNTO para indexación/acceso: máxima entre los de expr
   • Dangling-else: ELSE tiene mayor prec. que IFX (if sin else),
     entonces el parser siempre hace shift en ELSE → asocia al if
     más interno (comportamiento estándar de C)
   ─────────────────────────────────────────────────────────────────── */
%right                  ASIG
%left                   OR
%left                   AND
%left                   EQUAL DISTINCT
%left                   LT GT LE GE
%left                   MAS MENOS
%left                   MUL DIV MOD
%right                  NOT UMENOS
%left                   INC DEC
%left                   LBRA PUNTO
%nonassoc               IFX
%nonassoc               ELSE

/* ── Tipos de no-terminales ──────────────────────────────────────────
   Todos como std::string por ahora; Vianney y Rojo los cambiarán
   a Expresion, int, vector<int>, etc. según sus estructuras.
   ─────────────────────────────────────────────────────────────────── */
%type <std::string>     expresion
%type <std::string>     lvalue
%type <std::string>     acceso_arreglo
%type <std::string>     acceso_struct
%type <std::string>     tipo
%type <std::string>     tipo_base

%locations
%start programa

%%

/* =====================================================================
   PROGRAMA
   P → H  (declaraciones globales y funciones)
   ===================================================================== */

programa
    : declaraciones funciones
      { /* TODO semántica: todo procesado */ }
    | funciones
      { /* TODO semántica: sin declaraciones globales */ }
    ;

/* =====================================================================
   DECLARACIONES  (globales o locales — misma gramática)
   H → D H | ε
   D → T L ;  |  struct id { D } [L] ;
   ===================================================================== */

declaraciones
    : declaraciones declaracion
    | declaracion
    ;

declaracion
    : declaracion_variable
    | declaracion_struct
    ;

/* ─── D → T L ; ──────────────────────────────────────────────────── */
declaracion_variable
    : tipo lista_ids PYC
      { /* TODO semántica: registrar variables con tipo en PilaTs.top() */ }
    ;

/* ─── Tipo  T → B A ──────────────────────────────────────────────── */
tipo
    : tipo_base dimensiones
      { /* TODO semántica: T.tipo = construir con tipo_base + dimensiones */ $$ = ""; }
    ;

tipo_base
    : INT    { /* TODO: tablaTipos.getId("int")   */ $$ = "int";   }
    | FLOAT  { /* TODO: tablaTipos.getId("float") */ $$ = "float"; }
    | CHAR   { /* TODO: tablaTipos.getId("char")  */ $$ = "char";  }
    | BOOL   { /* TODO: tablaTipos.getId("bool")  */ $$ = "bool";  }
    | ID     { /* TODO: verificar struct declarado */ $$ = $1;     }
    ;

/* A → [ num ] A | ε */
dimensiones
    : dimensiones LBRA NUMERO RBRA
      { /* TODO semántica: A.tipo = tablaTipos.add(num, A1.tipo, "array") */ }
    | /* ε */
    ;

/* L → id | L , id */
lista_ids
    : ID
      { /* TODO semántica: verificar duplicado, PilaTs.top().add(id, dir, tipo, "var") */ }
    | lista_ids COMA ID
      { /* TODO semántica: verificar duplicado, PilaTs.top().add(id, dir, tipo, "var") */ }
    ;

/* ─── D → struct id { D } [L] ; ─────────────────────────────────── */
declaracion_struct
    : STRUCT ID LKEY campos_struct RKEY lista_ids_opt PYC
      { /* TODO semántica: construir tipo struct, registrar en tablaTipos y PilaTs.bottom() */ }
    ;

campos_struct
    : campos_struct declaracion_variable
    | declaracion_variable
    ;

lista_ids_opt
    : lista_ids
    | /* ε */
    ;

/* =====================================================================
   FUNCIONES
   D → def T id ( F ) { D* S* }
   ===================================================================== */

funciones
    : funciones funcion
    | funcion
    ;

funcion
    : DEF tipo_retorno ID LPAR parametros RPAR
      LKEY cuerpo_funcion RKEY
      { /* TODO semántica: PilaTs.pop(), registrar func en tabla global, label(PilaLabelNext) */ }
    ;

tipo_retorno
    : tipo  { /* TODO semántica: tipoFuncActual = T.tipo  */ }
    | VOID  { /* TODO semántica: tipoFuncActual = void    */ }
    ;

/* ── Parámetros  F → G | ε ───────────────────────────────────────── */
parametros
    : lista_parametros
      { /* TODO semántica: F.lista = G.lista */ }
    | /* ε */
      { /* TODO semántica: F.lista = nuevaLista() */ }
    ;

lista_parametros
    : lista_parametros COMA tipo ID
      { /* TODO semántica: verificar dup, agregar arg, G.lista.add(T.tipo) */ }
    | tipo ID
      { /* TODO semántica: verificar dup, G.lista = nuevaLista(), agregar arg */ }
    ;

/* ── Cuerpo de función: declaraciones locales seguidas de sentencias  */
/* Se manejan en una sola lista para evitar el conflicto shift/reduce
   que surge cuando ambas empiezan con ID (tipo struct o expresión).    */
cuerpo_funcion
    : items_funcion
    | /* ε */
    ;

items_funcion
    : items_funcion item_funcion
    | item_funcion
    ;

/* Un ítem es o bien una declaración de variable o una sentencia.
   Para tipos básicos (int/float/char/bool), el lookahead basta para
   decidir. Para ID (struct), puede haber ambigüedad:
     - 'MiStruct a;'  → declaración
     - 'a = 5;'       → sentencia
   Bison la resuelve con shift (toma la declaración), que es correcto
   porque las palabras reservadas van ANTES del identificador.          */
item_funcion
    : declaracion_variable
    | sentencia
    ;

/* =====================================================================
   SENTENCIAS
   ===================================================================== */

sentencia
    : sent_asignacion
    | sent_if
    | sent_while
    | sent_for
    | sent_break
    | sent_return
    | sent_llamada PYC
    | PYC
    ;

/* ─── Asignación  S → lvalue = E ; ──────────────────────────────── */
sent_asignacion
    : lvalue ASIG expresion PYC
      { /* TODO semántica: verificar tipos, genCode(lvalue = reducir(E)) */ }
    ;

lvalue
    : ID            { /* TODO: verificar declarado */ $$ = $1; }
    | acceso_arreglo { $$ = $1; }
    | acceso_struct  { $$ = $1; }
    ;

/* ─── If / If-Else  (dangling-else por precedencia) ─────────────── */
sent_if
    : IF LPAR expresion RPAR bloque_o_sent %prec IFX
      { /* TODO semántica: PilaTrue/False, genCode if/goto, labels */ }
    | IF LPAR expresion RPAR bloque_o_sent ELSE bloque_o_sent
      { /* TODO semántica: PilaTrue/False/Next, genCode if/goto, labels */ }
    ;

/* ─── While ──────────────────────────────────────────────────────── */
sent_while
    : WHILE LPAR expresion RPAR bloque_o_sent
      { /* TODO semántica: PilaLabelNext/True/False/Break, labels, genCode */ }
    ;

/* ─── For  S → for ( init ; cond ; incr ) S ─────────────────────── */
sent_for
    : FOR LPAR init_for PYC expresion PYC incremento_for RPAR bloque_o_sent
      { /* TODO semántica: PilaLabelNext/True/False/Inc/Break, labels, genCode */ }
    ;

init_for
    : ID ASIG expresion
      { /* TODO semántica: asignación sin PYC */ }
    | /* ε */
    ;

incremento_for
    : ID ASIG expresion
      { /* TODO semántica: asignación sin PYC */ }
    | ID INC
      { /* TODO semántica: genCode(id = id + 1) */ }
    | ID DEC
      { /* TODO semántica: genCode(id = id - 1) */ }
    | /* ε */
    ;

/* ─── Break ──────────────────────────────────────────────────────── */
sent_break
    : BREAK PYC
      { /* TODO semántica: verificar dentro de bucle, genCode(goto PilaBreak.top()) */ }
    ;

/* ─── Return ─────────────────────────────────────────────────────── */
sent_return
    : RETURN expresion PYC
      { /* TODO semántica: verificar tipo == tipoFuncActual, genCode(return E.dir) */ }
    | RETURN PYC
      { /* TODO semántica: verificar función void, genCode(return) */ }
    ;

/* ─── Llamada a función como sentencia ───────────────────────────── */
sent_llamada
    : ID LPAR argumentos RPAR
      { /* TODO semántica: verificar func, args coinciden, genCode(call id, N) */ }
    ;

/* ─── Bloque o sentencia simple ──────────────────────────────────── */
bloque_o_sent
    : LKEY items_funcion RKEY
    | LKEY RKEY
    | sentencia
    ;

/* =====================================================================
   EXPRESIONES
   La precedencia de los operadores está declarada arriba con
   %left / %right, por lo que una sola regla recursiva izquierda
   basta — Bison construye el árbol correcto automáticamente.
   ===================================================================== */

expresion
    /* Aritméticas */
    : expresion MAS    expresion  { /* TODO: driver.add   */ $$ = ""; }
    | expresion MENOS  expresion  { /* TODO: driver.sub   */ $$ = ""; }
    | expresion MUL    expresion  { /* TODO: driver.mul   */ $$ = ""; }
    | expresion DIV    expresion  { /* TODO: driver.div   */ $$ = ""; }
    | expresion MOD    expresion  { /* TODO: driver.mod   */ $$ = ""; }

    /* Relacionales */
    | expresion EQUAL    expresion { /* TODO: driver.equal    */ $$ = ""; }
    | expresion DISTINCT expresion { /* TODO: driver.distinct */ $$ = ""; }
    | expresion LT       expresion { /* TODO: driver.lt       */ $$ = ""; }
    | expresion GT       expresion { /* TODO: driver.gt       */ $$ = ""; }
    | expresion LE       expresion { /* TODO: driver.le       */ $$ = ""; }
    | expresion GE       expresion { /* TODO: driver.ge       */ $$ = ""; }

    /* Lógicas */
    | expresion AND expresion { /* TODO: driver._and */ $$ = ""; }
    | expresion OR  expresion { /* TODO: driver._or  */ $$ = ""; }
    | NOT expresion           { /* TODO: driver._not */ $$ = ""; }

    /* Menos unario */
    | MENOS expresion %prec UMENOS { /* TODO: driver.neg */ $$ = ""; }

    /* Agrupación */
    | LPAR expresion RPAR { $$ = $2; }

    /* Literales */
    | NUMERO   { $$ = $1; }
    | FLOTANTE { $$ = $1; }
    | BOOLEANO { $$ = $1; }
    | CARACTER { $$ = $1; }
    | STRING   { $$ = $1; }

    /* Identificador simple */
    | ID       { /* TODO: driver.ident($1) */ $$ = $1; }

    /* Acceso a arreglo como expresión  E → C */
    | acceso_arreglo
      { /* TODO: t=newTemp(); genCode(t = C.base[C.dir]); E.tipo=C.tipo */ $$ = $1; }

    /* Acceso a struct como expresión  E → Z */
    | acceso_struct
      { /* TODO: t=newTemp(); genCode(t = Z.base[Z.dir]); E.tipo=Z.tipo */ $$ = $1; }

    /* Llamada a función como expresión  E → id ( N ) */
    | ID LPAR argumentos RPAR
      { /* TODO: verificar func, args, t=newTemp(), genCode(t = call id, N) */ $$ = $1; }

    /* Incremento/decremento */
    | ID INC { /* TODO: genCode(id = id + 1), retornar id */ $$ = $1; }
    | ID DEC { /* TODO: genCode(id = id - 1), retornar id */ $$ = $1; }
    ;

/* =====================================================================
   ACCESO A ARREGLO  (no-terminal C de la DDS)
   C → id [ E ]
   C → C  [ E ]
   ===================================================================== */

acceso_arreglo
    : ID LBRA expresion RBRA
      { /* TODO: verificar tipo array, E.tipo==int, t=newTemp(), genCode */ $$ = $1; }
    | acceso_arreglo LBRA expresion RBRA
      { /* TODO: multidimensional, t1=newTemp(), t2=newTemp(), genCode   */ $$ = $1; }
    ;

/* =====================================================================
   ACCESO A STRUCT  (no-terminal Z de la DDS)
   Z → id
   Z → Z . id
   ===================================================================== */

acceso_struct
    : ID PUNTO ID
      { /* TODO: verificar tipo struct, t=newTemp(), genCode(t = id + ts.getDir(campo)) */
        $$ = $1; }
    | acceso_struct PUNTO ID
      { /* TODO: struct anidado */ $$ = $1; }
    ;

/* =====================================================================
   ARGUMENTOS EN LLAMADA A FUNCIÓN  (no-terminales N y M de la DDS)
   N → M | ε
   M → E | M , E
   ===================================================================== */

argumentos
    : lista_argumentos
      { /* TODO semántica: N.lista = M.lista */ }
    | /* ε */
      { /* TODO semántica: N.lista = nulo */ }
    ;

lista_argumentos
    : expresion
      { /* TODO: M.lista = nuevaLista(), M.lista.add(E.tipo), genCode(param E.dir) */ }
    | lista_argumentos COMA expresion
      { /* TODO: M.lista.add(E.tipo), genCode(param E.dir) */ }
    ;

%%

/* ── Reporte de errores sintácticos ──────────────────────────────── */
void C0::Parser::error( const location_type &l, const std::string &msg )
{
    std::cerr << "ERROR SINTÁCTICO en línea " << l.begin.line
              << ", columna "                  << l.begin.column
              << ": "                          << msg
              << std::endl;
}
