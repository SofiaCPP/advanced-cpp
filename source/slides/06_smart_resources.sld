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

### Heap-allocated array
    
+++
+++ slide

### C-style resource
    
+++
+++ slide

### Custom deleter

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
