#include <iostream>
#include <stdexcept>

//@{ lifetime
void print(const void* instance, const char* type, const char* msg)
{
    std::cout << type << ":\t" << instance << ":\t" << msg << std::endl;
}

struct Lifetime
{
    Lifetime() { print(this, "Lifetime", "lives"); }

    ~Lifetime() { print(this, "Lifetime", "dies"); }
};
//@} lifetime

//@{ never-member
struct NeverMember
{

    NeverMember()
    {
        print(this, "NeverMember", "is about to live");
        throw std::runtime_error("not this time");
    }

    ~NeverMember() { print(this, "NeverMember", "dies"); }

    Lifetime _lifetime;
};
//@} never-member

//@{ never-base
struct NeverBase : Lifetime
{

    NeverBase()
    {
        print(this, "NeverMember", "is about to live");
        throw std::runtime_error("not this time");
    }

    ~NeverBase() { print(this, "NeverMember", "dies"); }
};
//@} never-base

//@{ leak
struct Leaking
{
    Leaking() : _lifetime(new Lifetime)
    {
        print(this, "Leaking", "lives");
        throw std::runtime_error("it all goes wrong");
    }

    ~Leaking()
    {
        print(this, "Leaking", "dies");
        delete _lifetime;
    }
    Lifetime* _lifetime;
};
//@} leak

//@{ reference
// returning the object by value
Lifetime CreateObject() { return Lifetime(); }
//@} reference

int main()
{
    {
        std::cout << "Lifetime" << std::endl;
        Lifetime a;
    }
    try
    {
        std::cout << "NeverMember" << std::endl;
        NeverMember nm;
    }
    catch (std::exception& e)
    {
        std::cout << "exception: " << e.what() << std::endl;
    }

    try
    {
        std::cout << "NeverBase" << std::endl;
        NeverBase nb;
    }
    catch (std::exception& e)
    {
        std::cout << "exception: " << e.what() << std::endl;
    }

    {
        std::cout << "Lifetime ref" << std::endl;
        //@{ reference
        // storing only a local reference
        const Lifetime& ref = CreateObject();
        std::cout << "Reference to " << &ref << std::endl;
        //@} reference
    }

    try
    {
        Leaking leak;
    }
    catch (std::exception& e)
    {
        std::cout << "exception: " << e.what() << std::endl;
    }

    return 0;
}
