---
title: "Introduction to Advanced C++ course"
date: 2015-02-27 01:29:34
draft: false
outputs:
    - Reveal
---

# Advanced C++

FMI 2015

Dimitar Trendafilov

---

```cpp
int main() {
    std::printf("The answer is %d\n", 24);
    return 0;
}
```

---
## Who am I?

Co-founder and technical director of [Coherent Labs](https://coherent-labs.com)

{{% note %}}

Coherent Labs is a game middleware company. We are making libraries and tools
that game developers are using in their games. Previously I have been working in
Masthead Studios on the Earthrise MMORPG.

{{% /note %}}

---
# What are we going to talk about?

---
# C++

By C++ we are going always to understand the Standard C++. [Freely accessible
draft](https://github.com/cplusplus/draft)

---
# Modern C++

The alternative title


{{% note %}}

C++ is not the same language any more. The new standard has changed the language
significantly. What is more interesting that the whole C++ community has changed
- there are at least two, three major conferences a year, backed by Microsoft,
  Google, etc. There are lots of talks, videos, articles for the new features in
  C++.  And C++ is gaining more and more speed - we are already expecting C++
  '14 and C++ '17

{{% /note %}}

---
# Practical C++

The alternative-alternative title

The kind of C++ used in practice - it is converging with the modern C++.


{{% note %}}

The C++ that is used in day-to-day work is moving rapidly towards the modern
C++, because compilers are developing much faster and developers are being
actively educated for the new features in the language. And we are going to
cover few area in which C++ doesn't shine yet.

{{% /note %}}

---
### Why not Modern C++ then?

- Lots of information available
- Knowledge of the internals of the language
- Patterns in the language

{{% note %}}

This course will not be just another praise of the great new features in C++11.
There are plenty of videos, lectures, blog posts about that. Instead we focus
on the details of C++, how it works and how to use it.

{{% /note %}}

---
### Contents (1)

1. Overview of C++
2. Resource management
3. Move semantic
4. Smart pointers - `auto_ptr`, `unique_ptr`, `shared_ptr`
5. Namespaces, argument-dependent lookup
6. Designing of an API, shared libraries, pImpl

{{% note %}}

We are going through a brief overview of C++. Then probably the most difficult
part of C++ - managing system resources - memory, file handles, sockets, etc.
Then - the first C++11 feature - move semantic - allowing to move resources from
object to object. We will see how smart pointer help us model resource
ownership. Namespaces and ADL are often underestimated features of the language.
Then the first non-standard C++ practical topic - APIs and shared libraries.

{{% /note %}}

---
### Contents (2)

7. Error handling and exceptions
8. Lambda functions, generic functions (signals)
9. Templates and type-erasure
10. Static polymorphism and expression templates
11. Standard Library - strings and regular expressions
12. Standard Library - containers

{{% note %}}

Then we are getting to the hard part - error handling and exceptions -  the
bastard feature of C++. Some fresh air with lambda functions, generic functions
and a practical note with signals. Then we take a deep dive with generic
programming - templates, type-erasure, static polymorphism and expression
templates. The we are going in the land of the standard library. We start with
strings and regular expressions, then containers.

{{% /note %}}


---
### Contents (3)

13. Standard Library - iterators and algorithms
14. Multithreaded and asynchronous programming
15. Inheritance and polymorphism
16. Memory management - custom allocators, pool allocators and DLLs
17. Libraries and tools
18. The future of C++

{{% note %}}

Then we are going deeper into the STL with iterators and algorithms.
Multithreaded and asynchronous programming are next. Then we will see how
inheritance and polymorphism actually work. At the end we'll going for a trip in
the dark side of C++ - memory management. The desert is left for some useful C++
libraries and where C++ is actually going.

{{% /note %}}

---
![C++ Map](/advanced-cpp/slides/00_intro/cxx_map.jpg)

---
# Administrative

---
## Grading

- Mid-term test 30%
- Final test 60%
- Taking part 10%

---
# ?
