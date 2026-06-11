#ifndef TABLE_H
#define TABLE_H

#include <string>
#include <vector>

namespace C0 {

    // 1. Representación de un Tipo en el compilador
    class Type {
    public:
        int id;
        std::string name;    // "int", "float", "char", "bool", "array", "struct" 
        int bytes;           // Tamaño en memoria 
        int base_type;       // Para arreglos (ej. int para un int[5]) 

        Type(int _id, std::string _name, int _bytes) 
            : id(_id), name(_name), bytes(_bytes), base_type(-1) {}
    };

    // 2. Representación de un Identificador (Variable/Función)
    class Symbol {
    public:
        std::string id;
        int dir;             // Desplazamiento relativo en memoria 
        int type;            // ID correspondiente en la Tabla de Tipos 
        std::string cat;     // "var", "arg", "func", "struct", "temp" 
        std::vector<int> args; // Tipos de los parámetros si es función

        Symbol(std::string _id) : id(_id), dir(-1), type(-1), cat("var") {}
    };

    // 3. Manejador de Ámbitos Sintácticos
    class Table {
    private:
        std::vector<C0::Symbol> symTab;
        std::vector<C0::Type> typeTab;

    public:
        Table();
        ~Table();
        
        void addSymbol(std::string id);
        void addType(std::string name, int bytes);
        bool isInSymbol(std::string id);
        
        void setDir(std::string id, int dir);
        void setType(std::string id, int type);
        void setArgs(std::string id, std::vector<int> args);

        int getDir(std::string id);
        int getType(std::string id);
        std::vector<int> getArgs(std::string id);
        std::vector<C0::Symbol> getSymTab();
    };
}

#endif