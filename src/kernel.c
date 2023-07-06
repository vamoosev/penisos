#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "term.h"

void main() {
    init_terminal();

    terminal_writestring("Hello, kernel World!\n");

}