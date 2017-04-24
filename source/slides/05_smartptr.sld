=== topic

# Smart Pointers

===
=== topic

## Contents

* What is a *smart pointer*
* `std::auto_ptr`
* `std::unique_ptr`
* reference counting
* `std::shared_ptr`
* other smart pointers

===
=== topic

## What is a *smart pointer* 

Object that behaves as a pointer by overloading `operator*()`
and `operator->()`

===
=== topic

    // the most simple SmartPointer
    template <typename T>
    class SmartPointer
    {
        public:
            T* operator->()
            {
                return m_Pointer;
            }

            T& operator* ()
            {
                return *m_Pointer;
            }
        private:
            T* m_Pointer;
    };

===
=== topic

## `operator->()`

Every time the compiler evaluates the `->` operator, until the right
side of the operator becomes a native pointer.

===
=== topic
## What are smart pointers useful for?

* Managing resources
* Expressing ownership semantic

===
=== topic

## Standard smart pointers

* `std::auto_ptr`
* `std::unique_ptr`
* `std::shared_ptr`
* `std::weak_ptr`
* `boost::intrusive_ptr`

===
=== topic
+++ slide
## `std::auto_ptr`

A smart pointer that frees the memory upon destruction.  In C++ 11 it was
removed from the language. It is fully replaced by `std::unique_ptr`
without any drawbacks

+++
+++ slide
## A simplified implementation of `std::auto_ptr`
    
+++
+++ slide

## The "smart pointer" part
::: snippet  05_smartptr/auto_ptr.hxx header smart_ptr footer
:::

+++
+++ slide
## The RAII part
::: snippet  05_smartptr/auto_ptr.hxx header RAII footer
:::

+++
+++ slide
## The bad parts
::: snippet 05_smartptr/auto_ptr.hxx header copy-assign footer
:::

+++
+++ slide

Due to the lack of move semantics in C++ 98, `std::auto_ptr` is forced
to transfer the ownership of the pointer during copy construction and
assignment. Also `std::auto_ptr` was copiable and assignable. You could
make a `std::vector<std::auto_ptr>`, but it would be completely
unpredictable - the standard does not require certain copy/assignment
guarantees for containers.


+++
===
=== topic
+++ slide

## `std::unique_ptr`

C++ 11 introduces `std::unique_ptr`

* it is not copyable
* it is moveable

+++
+++ slide

## A simplified implementation of `std::unique_ptr`
    
+++
+++ slide
## The "smart pointer" part
::: snippet 05_smartptr/unique_ptr.hxx header smart_ptr footer
:::

+++
+++ slide
## The RAII part
::: snippet 05_smartptr/unique_ptr.hxx header RAII footer
:::

+++
+++ slide
## The non-copyable part
::: snippet 05_smartptr/unique_ptr.hxx header copy footer
:::

+++
+++ slide
## The move part
::: snippet 05_smartptr/unique_ptr.hxx header move footer
:::

+++
+++ slide
#### `std::unique_ptr<T>` synopsis

* `unique_ptr()` default constructor
* `unique_ptr(Y*)` constructor - allows using pointers to
  `Derived` classes to be hold in `std::unique_ptr<Base>`

+++
+++ slide
  
* `T& operator* ()`
* `T* operator-> ()`
* `const T& operator* () const`
* `const T* operator-> () const`
* `T* get()` - get the underlying pointer
* `const T* get() const`


+++
+++ slide

* `T* release()` - get the underlying pointer and release
  ownership over it. Use it when you need to give up the ownership of the
  resource

* `void reset(T* new_pointer = nullptr)` - reset the underlying
  pointer to `new_pointer` and get ownership over it. Deletes the
  current pointer.

+++
+++ slide

* `explicit operator bool()` allows usage such as

    std::unique_ptr<T> p;
    if (p) {
        std::cout << *p << std::endl;
    }

+++
+++ slide
`std::unique_ptr` has a second template parameter

    template <typename T, typename Deleter = std::default_delete<T>>
    class unique_ptr
    {
        ~unique_ptr() {
            auto deleter = get_deleter();
            deleter(m_Pointer);
        }
    };

+++
+++ slide
## Bad
::: snippet 05_smartptr/unique_array.cxx bad
:::
Will make a `delete` to memory allocated with `new []`

+++
+++ slide
## Good
::: snippet 05_smartptr/unique_array.cxx good
:::

+++
+++ slide

`T& operator[](size_t index)` - allows array element access.  Only
`std::unique_ptr<T[]>` has this method. 

+++
+++ slide

## Custom deleter

    struct ReleaseDelete {
        template <typename T>
        void operator()(T* pointer) {
            pointer->Release();
        }
    };

    // ...
    std::unique_ptr<ID3D11Device, ReleaseDelete> device;

+++
+++ slide

Will be back to `unique_ptr` deleter when we get to:

* template typedefs
* template specialization

+++
+++ slide

## `std::unique_ptr` owns the resource it is pointing to

Use this to express ownership relation between types
    
+++
===
=== topic
+++ slide

## `std::shared_ptr` 

`std::shared_ptr` allows sharing of a resource. It is freed when the
last `std::shared_ptr` instance pointing to the resource is destroyed.
`std::shared_ptr` uses [Reference
Counting](http://en.wikipedia.org/wiki/Reference_counting).

+++
+++ slide

## Reference counting

A technique of storing the number of references, pointers, or handles to a
resource.

A garbage collection algorithm that uses these reference counts to
deallocate objects which are no longer referenced

+++
+++ slide

## Reference counting
![Reference counting](/advanced-cpp/slides/05_smartptr/RC.svg)

+++
+++ slide

#### Reference counting

    std::shared_ptr<int> t(new int(42));// pointer 0xff00 : rc 1
    std::shared_ptr<int> q = t;         // pointer 0xff00 : rc 2
    std::shared_ptr<int> p(new int(24));// pointer 0xfe00 : rc 1

    t = p;  // pointer 0xff00 : rc 1
            // pointer 0xfe00 : rc 2
            
    q = t;  // pointer 0xff00 : rc 0, so it is deleted
            // pointer 0xfe00 : rc 3

+++
+++ slide

#### Implementation of `std::shared_ptr`

The *reference count* and the *resource* need to be shared between all
instances. So they have to be on the heap.

+++
+++ slide
::: snippet 05_smartptr/shared_ptr.hxx ctor dtor member
:::

+++
+++ slide
::: snippet 05_smartptr/shared_ptr.hxx RC
:::

+++
+++ slide
::: snippet 05_smartptr/shared_ptr.hxx copy
:::

+++
+++ slide
::: snippet 05_smartptr/shared_ptr.hxx move
:::
+++

+++ slide
### `shared_ptr` is for sharing

Use a `shared_ptr` to express that the ownership of the resource is shared.

+++
+++ slide

### Reference Counting and cycles

If you have a cycle in the references between resources in
`std::shared_ptr`, these resources will never be freed.

+++
+++ slide

### How to handle cyclic references?

* manually by breaking the cycle
* use *weak* references

+++
+++ slide

#### `std::weak_ptr`

*Weak* references point to a resource, but do not prolong its lifetime.

+++
+++ slide

    std::weak_ptr<int> w;
    {
        std::shared_ptr<int> s = std::make_shared<int>(42);
        w = s;
    }
    if (auto pointer = w.lock()) {
        std::cout << *pointer << std::endl;
    } else {
        std::cout << "It's gone" << std::endl;
    }

+++
+++ slide

    template <typename T>
    class weak_ptr {
        // ...
        shared_ptr lock() {
            if (<It is still alive>) {
                return shared_ptr<T>(<for It>);
            }
            return shared_ptr();
        }
    };

+++

+++ slide
+++ slide

## So how does `shared_ptr` work?

+++
+++ slide

### Where is the reference count stored?

* as a member in the `shared_ptr`?
* as a static member in `shared_ptr<T>`?

+++
+++ slide

#### As a member?

    std::shared_ptr<int> q;
    {
        std::shared_ptr<int> p = std::make_shared<int>(42);
        q = p;
        // p gets destroyed here, but it can't reach within q
        // unless an expensive list of shared_ptr is stored
        // somewhere
    }

+++
+++ slide

#### As a static member?

    std::shared_ptr<int> p = std::make_shared<int>(42);
    std::shared_ptr<int> q = std::make_shared<int>(42);
    // oops, p and q have reference count 2, but actually point to
    // different resources

+++
+++ slide

#### In the heap as a shared object
![Shared Ptr](/advanced-cpp/slides/05_smartptr/shared_pointer.svg)

+++
+++ slide
#### `shared_ptr` price

* double indirection
    * can be optimized with a little higher memory usage
* extra memory allocation
    * worse - it is a small memory allocation, which are most wasteful

+++
+++ slide

### Use `std::make_shared`

* allocates a single block for object and reference count
    * the object is inplace constructed in the block
    * better *cache locality*

![Make Shared](/advanced-cpp/slides/05_smartptr/make_shared.svg)
    
+++
===

=== topic
+++ slide
## *Intrusive* reference counting

The reference count is stored in the resource (object) itself.

![Intrusive](/advanced-cpp/slides/05_smartptr/intrusive.svg)

+++
+++ slide

### `boost::intrusive_ptr`

* add a reference - calls `intrusive_ptr_add_ref(T*)`
* release a reference - calls `intrusive_ptr_release(T*)`

    class Renderer;

    void intrusive_ptr_add_ref(Renderer* r) {
        ++r->refs;
    }

    void intrusice_ptr_release(Renderer* r) {
        if (--r->refs == 0) {
            delete r;
        }
    }

+++
+++ slide

### When to use `intrusive_ptr`?

* some external APIs are already reference counted
    * OS, other languages
* more memory efficient than `shared_ptr`

+++
+++ slide

### `std???::intrusive_ptr`

There is no `std::intrusive_ptr` class, because `std::make_shared` gives you
almost the same thing.

+++
+++ slide

### *Almost*?

Using an `intrusive_ptr` allows you to temporary give up
using smart pointers, go down to `C` pointer and then go up
to an `intrusive_ptr`

+++
+++ slide

### `std::enable_shared_from_this<T>`

* allows creating a `shared_ptr` from `this`.
* **requires** that there is at least one shared_ptr pointing
  to the object
* works by having a `std::weak_ptr` inside the object for the
  object itself

+++
+++ slide

    class Renderer : public std::enable_shared_from_this<Renderer>
    {
    };

    std::shared_ptr<Renderer> get_the_shared_ptr(Renderer* r)
    {
        return r->shared_from_this();
    }

+++
===
=== topic
## No plain `new`

* `std::make_shared<T>` is the best way to create a shared pointer
* `C++`14 - `std::make_unique<T>` - creates an unique pointer

===
=== topic

## Other smart pointers

- [Facebook log and leak](https://github.com/facebook/folly) 
  - use 15 counts and when it reaches 16, log and leave it to leak
- [`link_ptr`](https://cs.chromium.org/chromium/src/base/memory/linked_ptr.h)

===
