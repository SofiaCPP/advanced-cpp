#include <type_traits>

//@{ convertible
template <typename To>
struct is_convertible_impl
{
    static std::true_type TryConvert(const To& x);
    static std::false_type TryConvert(...);
};

template <typename From, typename To>
struct is_convertible
    : decltype(is_convertible_impl<To>::TryConvert(*(From*) nullptr))
{
};
//@} convertible

struct Base
{
};
struct Der : Base
{
};

struct Cast
{
    operator Base(){};
};

int main()
{
    static_assert(is_convertible<int, double>::value, "int to double");
    static_assert(is_convertible<Der, Base>::value, "Derived to Base");
    static_assert(is_convertible<Cast, Base>::value, "Cast operator");

    return 0;
}
