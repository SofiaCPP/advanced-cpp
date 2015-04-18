//@{ headers
#include <iostream>
#include <algorithm>
#include <iterator>
#include <vector>
//@} headers

int main()
{
    std::vector<int> v;

    typedef std::istream_iterator<int> int_iterator;

    //@{ output
    std::copy(int_iterator(std::cin), int_iterator(), std::back_inserter(v));

    std::sort(v.begin(), v.end());

    std::copy(v.begin(), v.end(),
            std::ostream_iterator<int>(std::cout, "\n"));
    //@} output

    return 0;
}

