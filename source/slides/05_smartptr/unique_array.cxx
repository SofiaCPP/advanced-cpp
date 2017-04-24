#include <memory>
#include <iostream>


//@{ lifetime
void print(const void* instance, const char* type, const char* msg)
{
    std::cout << type << ":\t" << instance << ":\t"
		<< msg << std::endl;
}

struct Lifetime
{
    Lifetime()
    {
        print(this, "Lifetime", "lives");
    }

    ~Lifetime()
    {
        print(this, "Lifetime", "dies");
    }
};
//@} lifetime

int main(int argc, char*[])
{
    if (argc != 1)
    {
        std::cout << "Bad:" << std::endl;
        //@{ bad
        std::unique_ptr<Lifetime> a(new Lifetime[2]);
        //std::cout << "Second: " << &a[1] << std::endl;
        //@} bad
    }
    else
    {
        std::cout << "Good:" << std::endl;
        //@{ good
        std::unique_ptr<Lifetime[]> a(new Lifetime[2]);
        std::cout << "Second: " << &a[1] << std::endl;
        //@} good
    }
    return 0;
}

