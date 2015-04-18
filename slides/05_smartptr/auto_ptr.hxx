#pragma once

//@{ header
template <typename T>
class auto_ptr {
//@} header
	
	
	//@{ RAII
	auto_ptr()
		: m_Pointer(nullptr)
	{}
	
	auto_ptr(T* pointer)
		: m_Pointer(pointer)
	{}

	~auto_ptr()
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

	//@{ copy-assign
	// copy ctor changes the original!!!
	auto_ptr(auto_ptr& o) : m_Pointer(o.m_Pointer) {
		o.m_Pointer = nullptr;
	}

	// assignment changes the original!!!
	auto_ptr& operator=(auto_ptr& rhs) {
		if (this != &rhs) {
			delete m_Pointer;
			m_Pointer = rhs.m_Pointer;
			rhs.m_Pointer = nullptr;
		}
		return *this;
	}
	//@} copy-assign

//@{ footer
	T* m_Pointer;
};
//@} footer
