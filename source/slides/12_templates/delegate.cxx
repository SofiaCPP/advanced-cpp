#include <iostream>
#include <functional>
#include <memory>

namespace detail
{
    //@{ impl
    template <typename T>
    class DelegateImpl;

    template <typename R, typename... T>
    class DelegateImpl<R(T...)>
    {
    public:
        virtual ~DelegateImpl()
        { }

        virtual R Invoke(T&&...) const = 0;

        virtual DelegateImpl* Clone() const = 0;
    };
    //@} impl

    template <typename Function>
    class DelegateFun;

    //@{ delegate-fun
    template <typename R, typename... T>
    class DelegateFun<R(T...)> : public DelegateImpl<R(T...)> {
    public:
        typedef R(*FunctionPtr)(T...);
        DelegateFun(FunctionPtr function)
            : m_Function(function)
        {}

        virtual R Invoke(T&&... args) const {
            return m_Function(std::forward<T>(args)...);
        }

        virtual DelegateFun* Clone() const {
            return new DelegateFun(*this);
        }
    private:
        FunctionPtr m_Function;
    };
    //@} delegate-fun

    template <typename H, typename C, typename F>
    class DelegateMethod;

    //@{ delegate-method
    template <typename H, typename C, typename R, typename... T>
    class DelegateMethod<H, C, R(T...)> : public DelegateImpl<R(T...)> {
    public:
        typedef R(C::*MethodPtr)(T...);

        DelegateMethod(H instance, MethodPtr function)
            : m_Method(function)
            , m_Instance(instance)
        {}

        virtual R Invoke(T&&... args) const override {
            auto& instance = *m_Instance;
            return (instance.*m_Method)(std::forward<T>(args)...);
        }

        virtual DelegateMethod* Clone() const override {
            return new DelegateMethod(*this);
        }
    private:
        MethodPtr m_Method;
        H m_Instance;
    };
    //@} delegate-method

    template <typename H, typename C, typename F>
    class DelegateMethodConst;

    template <typename H, typename C, typename R, typename... T>
    class DelegateMethodConst<H, C, R(T...)> : public DelegateImpl<R(T...)>
    {
    public:
        typedef R(C::*MethodPtr)(T...) const;

        DelegateMethodConst(H instance, MethodPtr function)
            : m_Method(function)
            , m_Instance(instance)
        {}

        virtual R Invoke(T&&... args) const override
        {
            auto& instance = *m_Instance;
            return (instance.*m_Method)(std::forward<T>(args)...);
        }


        virtual DelegateMethodConst Clone() const
        {
            return new DelegateMethodConst(*this);
        }
    private:
        MethodPtr m_Method;
        H m_Instance;
    };
}

//@{ delegate
template <typename Function>
class Delegate;

template <typename R, typename... T>
class Delegate<R(T...)>
{
public:
    Delegate()
    {}
    //@} delegate

    //@{ delegate-ctor
    template <typename FunctionPtr>
    Delegate(FunctionPtr function)
        : m_Impl(new detail::DelegateFun<R(T...)>(function))
    {}

    template <typename H, typename C>
    Delegate(H instance, R(C::*method)(T...))
        : m_Impl(new detail::DelegateMethod<H, C, R(T...)>(instance, method))
    {}

    template <typename H, typename C>
    Delegate(H instance, R(C::*method)(T...) const)
        : m_Impl(new detail::DelegateMethodConst<H, C, R(T...)>(instance, method))
    {}
    //@} delegate-ctor

    //@{ delegate-value
    Delegate(Delegate& other)
        : m_Impl(other.m_Impl->Clone())
    {}

    Delegate(Delegate&&) = default;

    Delegate& operator=(Delegate& rhs)
    {
        if (this != &rhs)
        {
            m_Impl.reset(rhs.m_Impl->Clone());
        }
    }

    Delegate& operator=(Delegate&&) = default;
    //@} delegate-value

//@{ delegate
    R operator()(T&&... args) const
    {
        return m_Impl->Invoke(std::forward<T>(args)...);
    }

private:
    typedef std::unique_ptr<detail::DelegateImpl<R(T...)>> ImplPtr;

    ImplPtr m_Impl;
};
//@} delegate


float fun(int x, float y)
{
    return x + y;
}

class A
{
public:
    void method(const A& o) /*const*/
    {
        std::cout << (void*) this << ' ' << (void*)&o << std::endl;
    }
};

int main()
{
    Delegate<float(int, float)> d(&fun);
    auto r = d(4, 3.14f);
    std::cout << r << std::endl;
    A a;
    auto pa = std::make_shared<A>();
    Delegate<void(const A&)> m(&a, &A::method);
    Delegate<void(const A&)> m2(pa, &A::method);
    m(a);
    m2(*pa);
    auto x = m2;
    return 0;
}

