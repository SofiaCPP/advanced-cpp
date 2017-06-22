+++ slide

# Custom allocators

+++
+++ slide

## Contents

* Using custom `new`/`delete`
* STL allocators
* Using custom allocators with STL
* HeapLayers
* Allocation schemes
* Custom allocators and tools

+++
+++ slide

Disclaimer: The standard memory allocation functions on each platform are pretty fast.
But they are very general purpose, so there are a lot of usages when they will be inefficient.
Use a custom allocator when you know there will be performance gain and measure!

+++
+++ slide

# Custom `new` / `delete`

+++
+++ slide

To change the global `operator new` and `operator delete`, one has to define them.

    #include <new>

    void* operator new(size_t size);
    void* operator new(std::size_t count, const std::nothrow_t& tag);
    void* operator new[](std::size_t count, const std::nothrow_t& tag);
    void* operator new[](size_t size);
    
    void operator delete(void* ptr);
    void operator delete(void* ptr, const std::nothrow_t& tag);
    void operator delete[](void* ptr);
    void operator delete[](void* ptr, const std::nothrow_t& tag);

+++
+++ slide

Same goes for `malloc`, `calloc`, `realloc` and `free`    

+++
+++ slide

It is easy, but it works at global level.

* There is no context about the allocation itself
  * not possible to have a more efficient implementation for a type
  * not possible to have a more efficient implementation for a usage pattern
  * not easy to have a different allocator in different subsystems
  * global state
* A library can change the allocator for the entire application
  * Not always a good idea

+++
+++ slide

Most applications have custom allocators.

* tcmalloc (Chromium and Android)
* jemalloc (Firefox and [Facebook](https://www.facebook.com/notes/facebook-engineering/scalable-memory-allocation-using-jemalloc/480222803919/))

Both have tools for:
* profiling
* leak detection
* corruption detection

+++
+++ slide

## Custom allocator per allocation

+++
+++ slide

    struct MyAllocator {
        void* Allocate(size_t size);
        void Free(void* pointer);
    };

    // Overload operator new
    void* operator new(size_t size, MyAllocator& allocator);

+++
+++ slide

    MyAllocator allocator;
    auto game = new (allocator) Game();

    delete game; /// ????
+++
+++ slide

There is no `delete (allocator) game;` syntax.
So one has to create its own.

    template <typename T>
    void destroy(T* pointer)
    {
        if (pointer) {
            pointer->~T();
        }
        // Deallocation?
    }

+++
+++ slide

From which allocator to free the memory?

* Each object has a pointer to the allocator that has allocated it
    * Expensive - a pointer per object is quite expensive - Think arrays of objects
    * Does not work with primitive types
* Prepend the address of the allocator before the allocated memory
    * Still relatively expensive - extra pointer for each allocation
    * Allignment
* Partition the address space and derive from the address the adress of the allocator
    * 0x0000 - 0x00FF - Allocator 0
    * 0x0100 - 0x01FF - Allocator 1
* Just keep the allocator pointer available and be careful
    * In practice it is rare to have a large number of allocators, so that is OK

+++
+++ slide

### Padding

    template <typename Allocator, typename T>
    void destroy(Allocator& allocator, T* pointer)
    {
        if (pointer) {
            pointer->~T();
            allocator.Free(pointer);
        }
    }

+++
+++ slide

Arrays?

    template <typename Allocator, typename T>
    void destroy_array(Allocator& allocator, T* pointer)
    {
        if (pointer) {
            // N - ????
            for (auto p = pointer + N - 1; p >= pointer; --p)
            {
                p->~T();
            }
            allocator.Free(pointer);
        }
    }

- extra argument or use `std::vector` or other dynamic array

+++
+++ slide

    #define RENDER_NEW new (gRenderAllocator)
    #define RENDER_DELETE(P) destroy(gRenderAllocator, P);

    auto texture = RENDER_NEW Texture("file.png");
    RENDER_DELETE(texture);

+++
+++ slide

Macros have additional benefits

    struct RenderAllocator {
        void* Allocator(size_t size, const char* file, int line);
    }
    void* operator new (size_t size, RenderAllocator& allocator, const char* file, int line);
    #define RENDER_NEW new(gRenderAllocator, __FILE__, __LINE__);

We can track the place of allocation of each memory block and dump leaks.

+++
+++ slide

Smart pointers with custom deleters help too.

    struct RenderDeleter {
        template <typename T>
        void operator()(T* pointer) {
            destroy(gRenderAllocator, pointer);
        }
    }

    template <typename T>
    using RenderUniquePtr = std::unique_ptr<T, RenderDeleter>;

    RenderUniquePtr texture{RENDER_NEW Texture("file.png")};

+++
+++ slide

# STL Allocator

+++
+++ slide

    template <typename T>
    class STLAllocator
    {
    public:
        typedef T value_type;
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;

        typedef T* pointer;
        typedef const T* const_pointer;

        typedef T& reference;
        typedef const T& const_reference;

+++
+++ slide

        pointer address(reference x) const
        {
            return &x;
        }

        const_pointer address(const_reference x) const
        {
            return &x;
        }

+++
+++ slide

        STLAllocator()
        {
        }

        STLAllocator(const STLAllocator&)
        {
        }

        template <typename U>
        STLAllocator(const U&)
        {
        }

        template <typename U>
        STLAllocator(const STLAllocator<U>&)
        {
        }
        
        template <typename U>
        struct rebind
        {
            typedef STLAllocator<U> other;
        };

+++
+++ slide

        void construct(pointer p, const_reference value)
        {
            new (p) T(value);
        }

    #if defined(__clang__) || (defined(__GNUC__) || defined(__GNUG__))
        template <typename U, typename... Args>
        void construct(U* p, Args&&... args)
        {
            new (const_cast<typename std::remove_cv<U>::type*>(p)) U(std::forward<Args>(args)...);
        }
    #else
        void construct(pointer p, value_type&& value)
        {
            new (p) value_type(std::forward<value_type>(value));
        }

        template <typename Other>
        void construct(pointer p, Other&& value)
        {
            new (p) value_type(std::forward<Other>(value));
        }
    #endif
+++
+++ slide
        void destroy(pointer p)
        {
            p->~T();
        }

        size_type max_size() const
        {
            return size_type(-1) / sizeof(T);
        }
+++
+++ slide

        pointer allocate(size_type n, const void* = 0)
        {
            return static_cast<pointer>(::operator new(n * sizeof(value_type)));
        }

        void deallocate(pointer p, size_type)
        {
            ::operator delete(p, Coherent::MemoryManagementGT::CoherentMemoryTag);
        }
+++
+++ slide
        bool equal(const STLAllocator& rhs) const
        {
            return true;
        }
    };
+++
+++ slide
    template <>
    class STLAllocator<void>
    {
    public:
        typedef void value_type;
        typedef void* pointer;
        typedef const void* const_pointer;

        template <typename T>
        struct rebind
        {
            typedef STLAllocator<T> other;
        } ;
    } ;
+++
+++ slide
    template <typename T>
    bool operator==(const STLAllocator<T>& lhs, const STLAllocator<T>& rhs)
    {
        return lhs.equal(rhs);
    }

    template <typename T>
    bool operator!=(const STLAllocator<T>& lhs, const STLAllocator<T>& rhs)
    {
        return !(lhs == rhs);
    }

+++
+++ slide

The cons of the STL allocator model
* Almost never `allocator<T>` allocates `T`s
  * it is rebound with `rebind`
* No state, no parameters
* `std::vector<int, A>` and `std::vector<int, B>` are completely different types
    * it is difficult to reuse functions for containers with different allocators
    * `shared_ptr`s can use different allocators without changing its type

* One of the key reasons for existence of [EASTL](https://github.com/electronicarts/EASTL)

+++
+++ slide
## Custom allocators

* [Linear, Temp, Pool](https://github.com/mtrebi/memory-allocators)
* [ScopeStacks](scopestacks_public.pdf)
* [Temporary](http://coherent-labs.com/blog/temporary-allocations-in-c/)

+++
+++ slide
# [HeapLayers](https://github.com/emeryberger/Heap-Layers)

* The idea is simple - layer allocators on top of each other to get the most simple and efficient implementations
* Each allocator allocates its memory using the parent allocator until 

+++
+++ slide

    template <typename ParentAllocator>
    struct DebugAllocator : private ParentAllocator {
        void* Allocate(size_t size) {
            auto realSize = addPadding(size);
            auto realMemory = ParentAllocator::Allocator(realSize);
            setPatterns(realMemory, realSize);
            return getUserMemory(realMemory, size);
        }
    };

    typedef DebugAllocator<PoolAllocator<MallocAllocator> MyAllocator;

+++
+++ slide
# Tools and custom allocators
+++
+++ slide

* *Address sanitizer* will not work with a custom allocator
  * It will not catch when you are corrupting memory
* External (OS) level memory allocator will not show the real allocation that is leaking
  * When a pool of objects is not freed, because of a object in the middle,
    the tool will show the first object that caused the pool to be allocated.

+++
+++ slide

* Add option for disabling / switching the custom memory allocators

+++
+++ slide

?

+++
