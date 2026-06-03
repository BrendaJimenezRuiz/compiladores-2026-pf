# =====================================================================
# Makefile — Proyecto Final Compiladores 2026-2 | Grupo 7013
# =====================================================================

CXX      = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -g

SRC     = src
INCLUDE = include
OUTPUT  = output

# Bison y Flex generan estos archivos
PARSER_CC  = $(SRC)/parser.tab.cc
PARSER_HH  = $(INCLUDE)/parser.tab.hh
LEXER_CC   = $(SRC)/lex.yy.cc

# Fuentes C++ del proyecto (excluye los generados)
SOURCES = $(SRC)/Driver.cpp $(SRC)/main.cpp

# Todos los .cc que se compilarán
ALL_CC  = $(PARSER_CC) $(LEXER_CC) $(SOURCES)

TARGET  = $(OUTPUT)/compiler

INCLUDES = -I$(INCLUDE) -I$(SRC)

.PHONY: all clean run

all: $(OUTPUT) $(TARGET)

$(OUTPUT):
	mkdir -p $(OUTPUT)

# 1. Generar parser con Bison
$(PARSER_CC) $(PARSER_HH): $(SRC)/parser.yy
	bison -d -v $(SRC)/parser.yy \
	      --defines=$(PARSER_HH) \
	      --output=$(PARSER_CC)

# 2. Generar lexer con Flex
$(LEXER_CC): $(SRC)/lexer.ll $(PARSER_HH)
	flex --outfile=$(LEXER_CC) $(SRC)/lexer.ll

# 3. Compilar todo junto
$(TARGET): $(ALL_CC)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ $^

clean:
	rm -f $(PARSER_CC) $(PARSER_HH) $(LEXER_CC)
	rm -f $(SRC)/*.o $(SRC)/*.d $(SRC)/parser.output
	rm -f $(TARGET)
	@echo "Limpieza completa."

# Ejecutar con un archivo de prueba
run: all
	./$(TARGET) tests/prueba_valida.txt
