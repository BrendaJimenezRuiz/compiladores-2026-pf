#ifndef __DRIVER_HPP__
#define __DRIVER_HPP__ 1

/* =====================================================================
   Driver.hpp — Coordina Scanner y Parser
   TODO (Vianney / Rojo): Completar con tabla de símbolos, tabla de
   tipos, generación de TAC, etc.
   ===================================================================== */

#include <string>
#include <istream>
#include <vector>

#include "Scanner.hpp"
#include "parser.tab.hh"

namespace C0 {

class Driver {
public:
    Driver() = default;
    virtual ~Driver();

    void parse(const std::string &filename);

    /* TODO Vianney/Rojo: ampliar con todo lo del Driver de referencia */
    void init() {}
    bool isInSymbol(std::string) { return false; }
    void addSymbol(std::string) {}
    std::string newTemp() { return "t"; }

private:
    void parse_helper(std::istream &stream);
    C0::Parser  *parser  = nullptr;
    C0::Scanner *scanner = nullptr;
};

} /* namespace C0 */
#endif
