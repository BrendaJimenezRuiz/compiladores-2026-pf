#include <iostream>
#include <cstdlib>
#include "Driver.hpp"

int main(int argc, char **argv) {
    if (argc != 2) {
        std::cerr << "Uso: ./compiler <archivo.txt>" << std::endl;
        return EXIT_FAILURE;
    }
    C0::Driver driver;
    driver.parse(argv[1]);
    return EXIT_SUCCESS;
}
