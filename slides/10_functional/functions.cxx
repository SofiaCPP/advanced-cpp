#include <iostream>
#include <functional>

//@{ free
void free_function(int x) { std::cout << "free function: " << x << std::endl; }
//@} free

//@{ functor
struct Functor
{
    void operator()(int x) const
    {
        std::cout << "functor " << this << ": " << x << std::endl;
    }
};
//@} functor

//@{ method
struct UserDefined
{
    void method(int x) const
    {
        std::cout << "method " << this << ": " << x << std::endl;
    }

    static void static_method(int x)
    {
        std::cout << "same as free but with access to internals" << std::endl;
    }
};
//@} method

//@{ free
void free_with_ud(const UserDefined& ud, int x)
{
    std::cout << "free with ud " << &ud << ": " << x << std::endl;
}
//@} free

int main()
{
    using namespace std::placeholders;

    //@{ free
    free_function(42);
    //@} free

    //@{ functor
    Functor functor;
    functor(42);
    //@} functor

    //@{ method
    UserDefined ud;
    ud.method(42);
    //@} method
    
    //@{ pointer
    typedef void (*FreeFunctionPtr)(int);
    FreeFunctionPtr ffp = &free_function;
    ffp(42);

    typedef void (UserDefined::*MethodPtr)(int) const;

    MethodPtr mp = &UserDefined::method;
    (ud.*mp)(42);
    UserDefined* udp = &ud;
    (udp->*mp)(42);
    //@} pointer

    //@{ function
    std::function<void(int)> generic = free_function;
    generic(24);

    generic = functor;
    generic(2);
    //@} function

    //@{ function-ud
    std::function<void(const UserDefined&, int)> ud_function =
        &UserDefined::method;

    ud_function(ud, 42);

    ud_function = &free_with_ud;
    ud_function(ud, 42);
    //@} function-ud
    
    //@{ bind
    generic = std::bind(&UserDefined::method, ud, _1);
    generic(4);

    generic = std::bind(&UserDefined::method, std::ref(ud), _1);
    generic(8);
    //@} bind

    return 0;
}
