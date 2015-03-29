#include <iostream>
#include <cstdio>
#include <cstdlib>
#include "library.hxx"

void private_global()  { std::cout << "client" << std::endl;}

void* operator new (size_t s)
{
    std::printf("malloc client\n");
    return std::malloc(s);
}

void operator delete (void* p)
{
    std::printf("free client\n");
    std::free(p);
}

int main()
{
	library();
	private_global();
	return 0;
}


