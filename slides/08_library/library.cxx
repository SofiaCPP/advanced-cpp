#include <iostream>
#include <cstdlib>
#include <cstdio>

#include "library.hxx"

void private_global();

void* operator new (size_t s)
{
    std::printf("malloc lib\n");
    return std::malloc(s);
}

void operator delete (void* p)
{
    std::printf("free lib\n");
    std::free(p);
}

void library()
{
	std::cout << "function in library" << std::endl;
    int *p = new int(42);
    delete p;
}

