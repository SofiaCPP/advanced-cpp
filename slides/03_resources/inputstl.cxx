#include <iostream>
#include <fstream>
#include <algorithm>
#include <iterator>

int main()
{
    typedef std::istreambuf_iterator<char> ichar_iterator;
    typedef std::ostreambuf_iterator<char> ochar_iterator;

    std::copy(ichar_iterator(std::ifstream("input.cxx").rdbuf()),
              ichar_iterator(),
              ochar_iterator(std::cout.rdbuf()));  // f is destroyed here ;

    return 0;
}
