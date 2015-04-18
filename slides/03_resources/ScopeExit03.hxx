#pragma once

struct ScopeExitBase
{
    ScopeExitBase() : _dismissed(false) {}

    ScopeExitBase(const ScopeExitBase& other) : _dismissed(other._dismissed)
    {
        other._dismissed = true;
    }

    ScopeExitBase& operator=(const ScopeExitBase& rhs)
    {
        if (this != &rhs)
        {
            _dismissed = rhs._dismissed;
            rhs._dismissed = true;
        }
    }

    ~ScopeExitBase() {}

protected:
    mutable bool _dismissed;
};

typedef const ScopeExitBase& ScopeExit;

template <typename Functor>
struct ScopeExitImpl : ScopeExitBase
{
    ScopeExitImpl(Functor functor) : _functor(functor) {}

    ~ScopeExitImpl()
    {
        if (!_dismissed)
        {
            _functor();
        }
    }

private:
    Functor _functor;
};

template <typename Instance, typename Functor>
struct ScopeExitImplMember : ScopeExitBase
{

    ScopeExitImplMember(Instance* instance, Functor functor)
        : _instance(instance), _functor(functor)
    {
    }

    ~ScopeExitImplMember()
    {
        if (!_dismissed)
        {
            (_instance->*_functor)();
        }
    }

private:
    Instance* _instance;
    Functor _functor;
};

template <typename Functor>
ScopeExitImpl<Functor> make_scope_exit(Functor functor)
{
    return ScopeExitImpl<Functor>(functor);
}

template <typename Instance, typename Functor>
ScopeExitImplMember<Instance, Functor> make_scope_exit(Instance instance,
                                                       Functor functor)
{
    return ScopeExitImplMember<Instance, Functor>(instance, functor);
}
