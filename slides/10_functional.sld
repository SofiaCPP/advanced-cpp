+++ slide

# Functional `C++`

+++
+++ slide

section

## Contents

* `C++` 98
* *lambda* functions
* `std::function`
* *signals* and *slots*

+++
+++ slide

## `C`-style

    void qsort(void* pointer, size_t count, size_t size,
        int (*comparator) (const void*, const void*));

+++
+++ slide

::: snippet 10_functional/qsort.cxx comparator sort
:::

+++
+++ slide

* does not work for *non-POD*
* needs a new function
* `C++'98` does not allow defining functions inside functions
* the functions does not allow to store state, unless it is global
* the function has to always be called indirectly through pointer
  * and will get called O(N*log*N) times for sorting *N* numbers


+++
+++ slide

## `C++`'98 style

    void sort(T begin, T end, C comparator);

+++
+++ slide

::: snippet  10_functional/sort98.cxx  comparator sort
:::


+++
+++ slide

* works for everything that has `operator <`
* needs a new function or functor
* you can store state
* the function can be inlined and optimized

+++
+++ slide

    template <typename T, typename P>
    T partition(T begin, T end, P unary_predicate);

    // partitions a range so that all X for which predicate(X) is true
    // precede all Y for which predicate(Y) is false

+++
+++ slide

::: snippet 10_functional/partition.cxx less-than

+++
+++ slide

::: snippet 10_functional/partition.cxx partition
:::

+++
+++ slide

* it is quite a lot of code
* `struct` can be defined inside a function
  * but such `struct`s can not be used for instantiating templates
    * the standard and `g++` say so
    * Visual Studio does not

+++
+++ slide

## `C++`11 style

+++
+++ slide

# lambda

+++
+++ slide

# lambda

Anonymous functions that can be defined inside functions and can access
variables defined outside the anonymous functions.


+++
+++ slide

### *lambda* expressions

    [capture](parameters) -> return_type { function_body }

+++
+++ slide

    std::vector<int> v;
    std::partition(v.begin(), v.end(), [](int x) {
        return x % 2 == 0;
    });
    std::for_each(v.begin(), v.end(), [&](int x) {
        std::cout << x << std::endl;
    });

+++
+++ slide

### *lambda* captures

* `[]` - no variables are captured
* `[x]` - x is captured by value
* `[&x]` - x is captured by ref
* `[&]` - any external variable is implicitly captured by ref
* `[=]` - any external variable is implicitly captured by value
* `[x, &y]` - x is captured by value, y - by reference

+++
+++ slide

### Captures

* pointers to *lambda* functions without captured variables are the same as
  pointer to non-member functions
* `this` can be captured only by value and only inside methods

+++
+++ slide

## Implementation of *lambda* functions

Most compilers generate a `struct` with a special name and `operator()`

* no captures - might generate a non-member function
* captures - the captured variables are members of the `struct`

+++
=== topic

+++ slide

## The future for lambda functions

+++
+++ slide

### Generic lambdas

    auto dbl = [](auto x) { return x + x; };

    std::vector<int> vi;
    std::transform(vi.begin(), vi.end(), vi.begin(), dbl);

    std::vector<std::string> vs;
    std::transform(vs.begin(), vs.end(), vs.begin(), dbl);

+++
+++ slide

### Initializers

    std::vector<int> vi;
    std::tranform(vi.begin(), vi.end(), vi.begin(),
    [value = 42](auto x) {
        return x + value;
    });
            
+++
+++ slide

### Capture by *move*

    auto ptr = std::make_unique<int>(42);
    std::vector<int> vi;
    std::tranform(vi.begin(), vi.end(), vi.begin(),
        [ptr = std::move(ptr)](auto x) {
            return x + *ptr;
    });

+++
===

=== topic
+++ slide

## Functions as first class citizen

+++
+++ slide

    std::vector<int> lengths;
    std::vector<string> strings;

    lengths.resize(strings.size());
    std::transform(strings.begin(), strings.end(), lengths.begin(),
        // ???
    );

+++
+++ slide

    std::transform(strings.begin(), strings.end(), lengths.begin(),
        std::string::length // ???
    );
    // No

+++
+++ slide

### Functions in `C++`

* *free* functions
* *methods*

    free_function(a, 42);

    object.method(42);

+++
+++ slide

    size_t get_length(const std::string& s) {
        return s.length();
    }

    std::transform(strings.begin(), strings.end(), lengths.begin(),
        get_length;
    );

+++
+++ slide

### `C++`98

    std::transform(strings.begin(), strings.end(), lengths.begin(),
        std::mem_fun_ref(&std::string::length);
    );

+++
+++ slide
            
### `std::mem_fun`

* works only for methods without arguments or a single argument
* the object has to be supplied via a pointer
* `std::mem_fun_ref` works with a reference
* **DEPRECATED**

+++
+++ slide

### Currying

+++
+++ slide

### `std::bind1st` and `std::bind2nd`

Bind the first (second) argument of a function to a fixed value and return a
function with one argument less.

**DEPRECATED**

+++
+++ slide

    std::vector<std::string> v;
    std::transform(v.begin(), v.end(), v.begin(),
        std::bind1st(std::plus<std::string>(), ";"));
    // "x" -> ";x"

    std::transform(v.begin(), v.end(), v.begin(),
        std::bind2st(std::plus<std::string>(), ";"));
    // "x" -> "x;"

+++
+++ slide

### `C++`11

+++
+++ slide

### `std::mem_fn`

Generalized version of `std::mem_fun`.

* handles arbitrary number of arguments
* the object can be passed by reference, plain or smart pointer.

+++
+++ slide

    typedef std::vector<std::shared_ptr<Players>> Players;
    void Transform(Players& players, const Transform& t)
    {
        std::for_each(players.begin(), players.end(),
                      std::mem_fn(&Player::TransformWith));
    }

+++
===
=== topic
+++ slide

# `std::bind`

+++
+++ slide

# `std::bind`

* binding any argument of a function to a fixed value
* reordering of arguments

+++
+++ slide

# `std::bind`

* former `boost::bind` - `boost` version is still *boosted* with extra features

+++
+++ slide

    template <typename Callback>
    std::shared_ptr<Button> make_button(Callback callback);
    
    struct Application {
        void Quit();
    };

    Application app;
    auto quit = make_button(std::bind(&Application::Quit, &app));

+++
+++ slide

Be sure that the *quit* button will not be clicked after `app` is destroyed.

+++
+++ slide

    std::shared_ptr<Application> app;
    auto quit = make_button(std::bind(&Application::Quit, app));

+++
+++ slide

## Arguments

    auto autosave = make_checkbox(std::bind(&Application::Autosave, app,
                                            std::placeholders::_1));
+++
+++ slide

`C#` delegates in C++.

+++
+++ slide

    void Function(std::string s, int n, Person p) {
        std::cout << p.name() << ": " << s;
        while (n-- > 0)
            std::cout << '!';
        std::cout << std::endl;
    }

    Person p("Yoda");
    auto mega_fun = std::bind(&Function, _2, _1, &p);

    mega_fun(3, "The Answer is 42");
    // Yoda: The answer is 42!!!

+++
===

=== topic

+++ slide

# `std::function`

+++
+++ slide

`std::function` is a generic function object.

+++
+++ slide

## Functions in C++

Let me count the ways ...

+++
+++ slide

### Free functions

::: snippet 10_functional/functions.cxx free
:::

+++
+++ slide

### Functors

::: snippet 10_functional/functions.cxx functor
:::

+++
+++ slide

### Methods

::: snippet 10_functional/functions.cxx method
:::

+++
+++ slide

### Pointer to functions

::: snippet 10_functional/functions.cxx pointer
:::

+++
+++ slide

### `std::function`

::: snippet 10_functional/functions.cxx function
:::

+++
+++ slide

### `std::function` with types

::: snippet 10_functional/functions.cxx function-ud
:::

+++
+++ slide

### `std::function std::bind`

::: snippet 10_functional/functions.cxx bind
:::

+++
===

=== topic
+++ slide
# Functions and tuples
+++
===

=== topic
+++ slide
# Functions in `C++11`
+++

+++ slide
    template <typename T>
    T plus(T lhs, T rhs) {
        return lhs + rhs;
    }
+++
+++ slide

    auto s = plus(2, 2);

+++
+++ slide

    Person p1;
    Person p2;
    auto s = plus(p1, p2)
+++
+++ slide
    struct Person
    {
        Household operator+(const Person&);
    }
+++
+++ slide
    ??? plus(Person lhs, Person rhs) {
        return lhs + rhs;
    }
+++
+++ slide

    auto plus(Person lhs, Person rhs) -> decltype(lhs + rhs)
    {
        return lhs + rhs;
    }

+++
===

=== topic
+++ slide
# Functions in `C++14`
+++

+++ slide
    ??? plus(Person lhs, Person rhs)
    {
        return lhs + rhs;
    }
+++
+++ slide

    auto plus(Person lhs, Person rhs)
    {
        return lhs + rhs;
    }

+++
+++ slide

* all returns must have the same type
  * single return


+++
===
