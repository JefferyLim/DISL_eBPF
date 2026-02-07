#include <stdbool.h>
#include <stdint.h>

bool lol(uint64_t arg) {
    
    if(arg <= 1){
        return false;
    }else{
        for(int i = 2; i * i <= arg; i++){
            if(arg % i == 0){
                return false;
            }
        }
    }

    return true;
}