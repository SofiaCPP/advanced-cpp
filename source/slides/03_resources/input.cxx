#include <iostream>
#include <fstream>

int main()
{
    for (std::ifstream f("input.cxx"); f; f.get())
    {
        std::cout.put(f.peek());
    }  // f is destroyed here

    return 0;
}
