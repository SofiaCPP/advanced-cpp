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

---
## Who am I?

Co-founder &amp; technical director of
    a(href='http://coherent-labs.com')  Coherent Labs

aside.notes.

    Coherent Labs is a game middleware company. We are making
    libraries and tools that game developers are using in their games.
    Previously I have been working in Masthead Studios on the
    Earthrise MMORPG.

---
# What are we going to talk about?

---
# C++

By C++ we are going always to understand the Standard C++.
    [Freely accessible draft](https://github.com/cplusplus/draft)

---
# Modern C++

The alternative title

aside.notes.

    C++ is not the same language any more. The new standard has
    changed the language significantly. What is more interesting that
    the whole C++ community has changed - there are at least two,
    three major conferances a year, backed by Microsoft, Google, etc.
    There are lots of talks, videos, articals for the new features in
    C++.  And C++ is gaing more and more speed - we are already
    expecting C++ '14 and C++ '17


---
# Practical C++
p The alternative-alternative title
p.

    The kind of C++ used in practice - it is converging with the
    modern C++.

aside.notes.

    The C++ that is used in day-to-day work is moving rapidly towards
    the modern C++, because compilers are developing much faster and
    developers are being actively educated for the new features in the
    language. And we are going to cover few area in which C++ doesn't
    shine yet.

---
### Why not Modern C++ then?

ul
    li Lots of information avaliable
    li Knowledge of the internals of the language
    li Patterns in the language

aside.notes.

    This course will not be just another praise of the great new
    features in C++11. There are plently of videos, lectures, blog
    posts about that. Instead we focus on the details of C++, how it
    works and how to use it.

---
### Contents (1)

ol
    li Overview of C++
    li Resource management
    li Move semantic
    li Smart pointers - auto_ptr, unique_ptr, shared_ptr
    li Namespaces, argument-dependent lookup
    li Designing of an API, shared libraries, pImpl

aside.notes.

    We are going through a brief overview of C++. Then probably the
    most difficult part of C++ - managing system resources - memory,
    file handles, sockets, etc. Then - the first C++11 feature - move
    semantic - allowing to move resources from object to object. We
    will see how smart pointer help us model resource ownership.
    Namespaces and ADL are often understimated featutes of the
    language. Then the first non-standard C++ practical topic - APIs
    and shared libraries.

---
### Contents (2)

ol(start = 7)
    li Error handling and exceptions
    li Lambda functions, generic functions (signals)
    li Templates and type-erasure
    li Static polymorphism and expression templates
    li Standard Library - strings and regular expressions
    li Standard Library - containers

aside.notes.

    Then we are going to the hard part - error handling and exceptions
    - the bastard feature of C++. Some fresh air with lambda
      functions, generic functions and a practical note with signals.
      Then we take a deep dive with generic programming - templates,
      type-erasure, static polymorhism and expression templates. The
      we are going in the land of the standard library. We start with
      strings and regular expressions, then containers.


---
### Contents (3)

ol(start = 13)
    li Standard Library - iterators and algorithms
    li Multithreaded and asynchronous programming
    li Inheritance and polymorphism
    li Memory management - custom allocators, pool allocators and DLLs
    li Libraries and tools
    li The future of C++

aside.notes.

    Then we are going deeper into the STL with iterators and
    algorithms. Multithreaded and asynchronous programming are next.
    Then we will see how inheritance and polymorhism actually work. At
    the end we'll going for a trip in the dark side of C++ - memory
    management. The desert is left for some usefull C++ libraries and
    where C++ is actually going.

---
img.stretch(src='00_intro/cxx_map.jpg')

---
---
    # Administrative

---
    ### Grading
    ul.fragment.fade-in
        li.fragment.fade-in Mid-term test 30%
        li.fragment.fade-in Final test 60%
        li.fragment.fade-in Taking part 10%

