#include <iostream>
#include "unique_ptr.hxx"

int main () {
    unique_ptr<int> x(new int(42));
    if (x) {
        std::cout << "No nullptr\n";
    }
    return 0;
}
