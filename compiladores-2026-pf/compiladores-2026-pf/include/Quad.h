#ifndef QUAD_H
#define QUAD_H

#include <string>

namespace C0 {
    class Quad {
    public:
        std::string op;   // Operador: "+", "-", "goto", "if", "label", "=" 
        std::string arg1; // Argumento 1 
        std::string arg2; // Argumento 2 
        std::string res;  // Resultado o etiqueta de destino 

        Quad(std::string o, std::string a1, std::string a2, std::string r)
            : op(o), arg1(a1), arg2(a2), res(r) {}
    };
}
#endif