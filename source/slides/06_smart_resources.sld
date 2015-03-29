=== topic

# "Smart" Resource Menagement

===
=== topic

## Contents

1. Ownership
2. Sharing

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

### Custom deleter

+++
+++ slide

+++
+++ slide

### Directly deleter

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
+++
===
