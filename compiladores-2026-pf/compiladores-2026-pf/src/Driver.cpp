#include <fstream>
#include <iostream>
#include "Driver.hpp"

C0::Driver::~Driver() {
    delete scanner; scanner = nullptr;
    delete parser;  parser  = nullptr;
}

void C0::Driver::parse(const std::string &filename) {
    std::ifstream in(filename);
    if (!in.good()) {
        std::cerr << "No se pudo abrir: " << filename << std::endl;
        exit(EXIT_FAILURE);
    }
    parse_helper(in);
}

void C0::Driver::parse_helper(std::istream &stream) {
    delete scanner;
    scanner = new C0::Scanner(&stream);

    delete parser;
    parser = new C0::Parser(*scanner, *this);

    if (parser->parse() != 0)
        std::cerr << "Análisis fallido." << std::endl;
}
