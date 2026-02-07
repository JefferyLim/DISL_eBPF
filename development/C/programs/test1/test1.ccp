#include <stdbool.h>
#include <stdint.h>

bool function2(uint64_t arg);

bool function(uint64_t arg) {
    
    for(unsigned long int i = 2; i < arg; i++)
        if (arg % i == 0)
            return false;
    
    function2(5);
    return true;
}

bool function2(uint64_t arg) {

    return arg + 6;
}
