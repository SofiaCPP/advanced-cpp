=== topic

# "Smart" Resource Management

===
=== topic

## Contents

1. Ownership
2. Sharing
3. Using / Pointing

===
=== topic
+++ slide

## Ownership

+++
+++ slide
    
Ownership is best expressed with `std::unique_ptr`.

+++
+++ slide

### Heap-allocated object
    
+++
+++ slide

    class Logger {
        private:
            std::unique_ptr<ILogTarget> _Target;
    };

+++
+++ slide

### Heap-allocated array

+++
+++ slide

    int hash(const char* name) {
        std::ifstream input(name, std::ios::binary);
        const auto size = 4096;
        std::unique_ptr<char[]> buffer(new char[size]);
        int h = 42;
        while (input) {
            input.read(buffer.get(), size);
            h = h + buffer[42] % 42;
        }
        return h;
    }
    
+++
+++ slide

### C-style resource
    
+++
+++ slide

#### How to own a `FILE*`

It is the same as every other resource:

* obtain - `fopen`
* return - `fclose`

+++
+++ slide

    struct FCloserDeleter
    {
        void operator()(FILE* file) const
        {
            if (file)
            {
                fclose(file);
            }
        }
    };

    typedef std::unique_ptr<FILE, FCloserDeleter> FilePtr;

+++
+++ slide

### Custom deleter

+++
+++ slide

### Directly using a deleter

+++
+++ slide

    template <typename T>
    using UniqueReleasePtr<T> = std::unique_ptr<T, ReleaseDeleter>;

    template <typename T>
    using UniqueDestroyPtr<T> = std::unique_ptr<T, DestroyDeleter>;

+++
+++ slide

    namespace std
    {
    template <>
    struct default_delete<ID3DDevice>
    {
        void operator()(ID3DDevice* ptr) const
        {
            ptr->Release();
        }
    }
    }
    
+++
+++ slide

### `owner`

Presented in 
[A brief introduction to C++’s model for type and resource safety][resources]

[resources]: http://www.stroustrup.com/resource-model.pdf

+++
+++ slide

Implemented in:

    template <class T>
    using owner = T;

(https://github.com/Microsoft/GSL/blob/master/include/gsl/gsl#L55)

+++
+++ slide

Static checkers:

- [`clang-tidy`](http://clang.llvm.org/extra/clang-tidy/)
- [Visual Studio][VS]

[VS]: https://blogs.msdn.microsoft.com/vcblog/2015/12/03/c-core-guidelines-checkers-available-for-vs-2015-update-1/

+++
===
=== topic
+++ slide

## Sharing

+++
+++ slide

- Use `intrusive_ptr` or `shared_ptr`

+++
===
=== topic
+++ slide
## Using / Pointing
+++
+++ slide

- Use a plain pointer
  - [`not_null`](https://github.com/Microsoft/GSL/blob/master/include/gsl/gsl#L72)
- Use a reference
+++
===
