#pragma once

template <typename T>
class SharedPtr
{
public:
    //@{ ctor
    SharedPtr()
        : m_RC(nullptr)
        , m_Pointer(nullptr)
    {}

    SharedPtr(T* pointer)
        : m_RC(new int(1))
        , m_Pointer(pointer)
    {
    }
    //@} ctor

    //@{ copy
    SharedPtr(const SharedPtr& o)
        : m_RC(o.m_RC)
        , m_Pointer(o.m_Pointer)
    {
        AddReference();
    }

    SharedPtr& operator=(const SharedPtr& rhs)
    {
        if (this != &rhs)
        {
            RemoveReference();
            m_RC = rhs.m_RC;
            m_Pointer = rhs.m_Pointer;
            AddReference();
        }
        return *this;
    }
    //@} copy

    //@{ move
    SharedPtr(SharedPtr&& o)
        : m_RC(pointer.m_RC)
        , m_Pointer(pointer.m_Pointer)
    {
        o.m_RC = nullptr;
        o.m_Pointer = nullptr;
    }

    SharedPtr& operator=(SharedPtr&& rhs)
    {
        if (this != &rhs) {
            RemoveReference();
            m_RC = rhs.m_RC;
            m_Pointer = rhs.m_Pointer;
            rhs.m_RC = nullptr;
            rhs.m_Pointer = nullptr;
        }
        return *this;
    }
    //@} move

    //@{ dtor
    ~SharedPtr()
    {
        RemoveReference();
    }
    //@} dtor

private:

    //@{ RC
    void RemoveReference()
    {
        if (m_RC && --*m_RC == 0)
        {
            delete m_Pointer;
            delete m_RC;
        }
    }
    void AddReference()
    {
        ++*m_RC;
    }
    //@} RC
    
    //@{ member
    int* m_RC;
    T* m_Pointer;
    //@} member
};

