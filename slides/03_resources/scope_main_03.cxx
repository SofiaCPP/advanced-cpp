#include <iostream>

#include "ScopeExit03.hxx"

void do_exit() { std::cout << "bye, bye" << std::endl; }

int main()
{
    ScopeExit exit = make_scope_exit(&do_exit);
    return 0;
}
