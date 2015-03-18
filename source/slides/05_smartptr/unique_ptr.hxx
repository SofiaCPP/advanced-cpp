#pragma once

//@{ header
template <typename T>
struct unique_ptr {
//@} header
    
    //@{ RAII
    unique_ptr()
        : m_Pointer(nullptr)
    {}
    
    unique_ptr(T* pointer)
        : m_Pointer(pointer)
    {}

    ~unique_ptr()
    {
        delete m_Pointer;
    }
    //@} RAII

    //@{ smart_ptr
    T* operator->()
    {
        return m_Pointer;
    }

    T& operator* ()
    {
        return *m_Pointer;
    }
    //@} smart_ptr

    //@{ move
    unique_ptr(unique_ptr&& o)
        : m_Pointer(o.m_Pointer)
    {
        o.m_Pointer = nullptr;
    }

    unique_ptr& operator=(unique_ptr&& rhs)
    {
        if (this != &rhs) {
            delete m_Pointer;
            m_Pointer = rhs.m_Pointer;
            rhs.m_Pointer = nullptr;
        }
        return *this;
    }
    //@} move

    //@{ copy
    unique_ptr(const unique_ptr& o) = delete;
    unique_ptr& operator= (const unique_ptr& rhs) = delete;
    //@} copy

    explicit operator bool() const {
        return m_Pointer != nullptr;
    }

//@{ footer
    T* m_Pointer;
};
//@} footer
