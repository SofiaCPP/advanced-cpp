//@{ delegate-fun
template <typename Function>
class DelegateFun;

template <typename R, typename... T>
class DelegateFun<R(T...)>
{
public:
    typedef R(*FunctionPtr)(T...);
    DelegateFun(FunctionPtr function)
        : m_Function(function)
    {}

    R operator()(T... args) const
    {
        return m_Function(std::forward<T>(args)...);
    }
private:
    FunctionPtr m_Function;
};
//@} delegate-fun

//@{ delegate-method
template <typename C, typename F>
class DelegateMethod;

template <typename C, typename R, typename... T>
class DelegateMethod<C, R(T...)>
{
public:
    typedef R(C::*MethodPtr)(T...);

    DelegateMethod(C* instance, MethodPtr function)
        : m_Method(function)
        , m_Instance(instance)
    {}

    R operator()(T... args) const
    {
        return (m_Instance->*m_Method)(std::forward<T>(args)...);
    }
private:
    MethodPtr m_Method;
    C* m_Instance;
};
//@} delegate-method

//@{ delegate-const-method
template <typename C, typename F>
class DelegateMethodConst;

template <typename C, typename R, typename... T>
class DelegateMethodConst<C, R(T...)>
{
public:
    typedef R(C::*MethodPtr)(T...) const;

    DelegateMethodConst(C* instance, MethodPtr function)
        : m_Method(function)
        , m_Instance(instance)
    {}

    R operator()(T... args) const
    {
        return (m_Instance->*m_Method)(std::forward<T>(args)...);
    }
private:
    MethodPtr m_Method;
    C* m_Instance;
};
//@} delegate-const-method

//@{ functions
float fun(int x, float y)
{
    return x + y;
}

class A
{
public:
    float method(int x, float y) const
    {
        std::cout << (void*) this << std::endl;
        return y - x;
    }
};
//@} functions

int main()
{
    //@{ usage
    DelegateFun<float(int, float)> d(&fun);
    auto r = d(4, 3.14f);
    std::cout << r << std::endl;
    A a;
    DelegateMethodConst<A, float(int, float)> m(&a, &A::method);
    m(4, 3.14f);
    //@} usage
    return 0;
}

