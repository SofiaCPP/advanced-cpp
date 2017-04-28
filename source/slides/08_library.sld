section
    h1 Library API Design

section
    h2 What is an API
    p Application Program Interface
    p The set of functions and types that a library provides

section
    h2 Contents
    ul
      li Kinds of libraries
       ul
         li Header only
         li Static
         li Dynamic/shared
      li Symbol linkage
      li interfaces
      li Heap allocated objects
      li std::cross library

section
  h2 Header only libraries
  p A collection of header files

section
  :markdown
    ### Pros

    * Very easy to use - just copy the files and `#include`
    * No overhead at all - even some calls  might get inlined
  
section
    h3 Cons
    ul
      li No isolation at all - the client sees all implementation details
      li Changes in the library require recompiles
      li Difficult to use with non-open-source licenses
      li May significantly increase compilation time
      li Tends to creep all over the place

section
  h2 Static Libraries
  p An archive of object files

section
  h3 Pros
  ul
    li Relatively easy to use - include and link
    li No overhead, some calls might be inlined if we are using optimizing
      | linker

section
    h3 Cons
    ul
      li.

        The compiler options must match perfectly between the library and the
        clients

      li Changing the library requires recompilation of the client code
      li 3rd party dependencies conflict

section
  h2 Dynamic/Shared Libraries

  p a single object file, that allows calling of predefined set of
    | functions

section
  h3 Pros
  ul
    li Almost complete isolation between library and client
    li Changing the library without recompilation can be achieved

section
  h3 Cons
  ul
    li Non standard
    li A lot of platform specifics
    li DLL boundary

section
  h3 Symbol Visibility
  ul
    li Windows - hidden by default
    li Others - visible by default

section
  h4 Symbol Visibility
  ul
    li.fragment.fade-in Windows
      :cxx
        __declspec(dllimport)
      :cxx
        __declspec(dllexport)

    li.fragment.fade-in g++ / clang++
      code
        pre.
          // compile with flags
          -fvisibility=hidden -fvisibility-inlines-hidden
      :cxx
        __attribute__ ((visibility ("default")))

section
  :markdown
    #### `dllimport` \ `dllexport`
  :cxx
    __declspec(dllexport) int answer = 42;
    
    __declspec(dllexport) int get_answer() {
      return 42;
    }

section
  :markdown
    #### `dllimport` \ `dllexport`
  :cxx
    class __declspec(dllexport) Renderer {
      public:
        void render(const Texture& texture);
    };

    class Texture {
      public:
        __declspec(dllexport) void fill(Color color);

        void fill(byte r, byte g, byte b); // not exported
    };

section
  :markdown
    #### `dllexport`

    Makes symbols to be exported from the DLL - visible to clients

section
  :markdown
    #### `dllimport`

    Makes symbols to be imported from a DLL, the linker is going to look
    for these symbols in all linked DLLs

section
  :markdown
    #### `dllimport` \ `dllexport`

    So the library needs to say `dllexport` and the client needs to
    see `dllimport` for the same symbol

section
  :markdown
    ### `MY_LIBRARY_API`
  :cxx
    #if defined(MY_LIBRARY_IMPL)
      #define MY_LIBRARY_API __declspec(dllexport)
    #else
      #define MY_LIBRARY_API __declspec(dllimport)
    #endif
    
    MY_LIBRARY_API int answer();

  p.fragment.fade-in
    :markdown
      Compile the library with `MY_LIBRARY_IMPL` defined

section
  :markdown
    ### `MY_LIBRARY_API`
  :cxx
    #if defined(_WIN32)
      #define MY_LIBRARY_EXPORT __declspec(dllexport)
      #define MY_LIBRARY_IMPORT __declspec(dllimport)
    #else
      #define MY_LIBRARY_EXPORT __attribute__ ((visibility ("default")))
      #define MY_LIBRARY_IMPORT
    #endif

    #if defined(MY_LIBRARY_IMPL)
      #define MY_LIBRARY_API MY_LIBRARY_EXPORT
    #else
      #define MY_LIBRARY_API MY_LIBRARY_IMPORT
    #endif

section
  h3 Non-Windows & 3rd party dependencies
  p Controlling visibility of symbols - lack of internal linkage

section
  h3 Symbol Maps
  code
    pre.
        VERSION
        {
                global:
                        extern "C++" {
                                library*;
                        };
                local: *;
        };
  p Link with:
    code
      pre.
        -Wl,--version-script=library.map

section
    h2 Lifetime of an application
    .fragment.fade-in
      Build
      ol
        li preprocess
        li compile time
        li link time
    .fragment.fade-in
      Execute
      ol(start = 4)
        li load time
        li run time
      
section
    h3 Linux
    p Symbol resolution is done at load time, not at link time

section
    ul
      li.

        undefined symbols in the library are reported when linking an
        executable, not the library itself

      li Symbols in the executable of a 3rd party library can override your own symbols

    code.fragment.fade-in
      pre.
        # link with
        g++ *.o -Xlinker -Bsymbolic -o myLibrary.so

section
  h2 API

section
  :markdown
    1. Pure `C` 
    2. `C++` with `std::`

section
  :markdown
    ### Pure `C` API

    Pros

    * the most portable - `C` has no mangling
    * easy to use with other languages
      * luajit's libffi (Foreign Function interface)
      * Python - ctype, cffi
      * C# (.NET) - PInvoke

    Cons
      * no ``C++`` features - resource management, OOP, generics 
      * prefix on every function

section
  :markdown
    ### *Opaque Structure*

  :cxx
    // just a forward declaration
    typedef struct lua_State lua_State;
    lua_State* lua_newstate();
    void lua_call(lua_State* state, int arguments, int results);
    void lua_close(lua_State*);

section
  :markdown
    ### `C++` with `C` API

  :cxx
    typedef struct lua_State lua_State;
    extern "C" lua_State* lua_newstate();
    extern "C" {
      int lua_compile(lua_State* state, const char* file);
      int lua_run(lua_State* state, int);
    }
  :cxx
    struct lua_State {
      bool compile(const char* file);
    } ;

    lua_State* lua_newstate() {
      return new lua_State;
    }

    int lua_compile(lua_State* state, const char* file) {
      return state->compile(file)? 1 : 0;
    }

section
  :markdown
    ### Having `std::` in the API

    * Works only for *header-only* libraries or libraries that are
      compiled by the user
    * Or there must be a separate compiliant for each possible
      compiler / runtime / flags combination

section
  :markdown
    ### `std::`

    The standard doesn't define implementation details for the standard
    library. So implementations may differ. For example:

section
  :cxx
    // GCC
    class pseudo_vector {
      T* begin;
      T* end;
      T* end_of_storage;
    };

    // MSVS
    class pseudo_vector {
      T* begin;
      T* end_of_storage;
      T* end;
    };

section
  :cxx
    namespace library {
      void add_random(std::vector<int>& numbers) {
        numbers.push_back(rand());
      }
    }

section
  :markdown

    Implementation may be different when using different compiler options

    Visual Studio has *debug iterators* enabled in *Debug* build. They
    allow detection of incorrect usage of `STL`. For example, using an
    iterator to a vector, after it has been invalidated.

    In *Release* a `vector::iterator` can be a plain pointer, but a
    *debug iterator* is actually a smart pointer

section
  :markdown
     ### Memory allocation

     Allocated memory must be freed from the allocator that allocated it.

     * the library and the client *MUST* use the same allocator
     * the deallocation *MUST* happen in the same module as the
       corresponding allocation

section
  :markdown
    `STL` hides allocations from the user, so it is impossible to be sure
    that the memory will be deallocated from the allocator that allocated
    it.

section
  :markdown
    ## *`C` with classes* / *COM*

    * a `extern "C"` function that initializes the library and returns
      an object that implements the library interface
    * functions and methods take only primitive types and pointers to
      interfaces

section
  :markdown
    #### Lua *`C` with classes* style - declaration
  :cxx
    namespace Lua {
      class State {
        virtual void ~State() = 0;
        virtual void destroy() = 0;
        virtual bool compile(const char* file) = 0;
      };
    }
    extern Lua::State* lua_new_state();

section
  :markdown
    #### Lua *`C` with classes* style - implementation
  :cxx
    namespace Lua {

      class StateImpl: public State {

        virtual void ~StateImpl() {
        }

        virtual void destroy() override {
          delete this;
        }

        virtual bool compile(const char* file) override {
          /...
        }
      };
    }

section
  :markdown
    #### Lua *`C` with classes* style - implementation
  :cxx
    Lua::State* lua_newstate() {
      return new StateImpl;
    }
    namespace Lua {
      void StateImpl::destroy() override {
        delete this;
      }
    }
  :markdown
    Enforces that the `StateImpl` object is deallocated using the
    allocator that allocated it

section
  :markdown
    #### Lua *`C` with classes* style - client
  :cxx
    auto lua = lua_new_state();
    lua->compile("hello.lua");
    lua->destroy();

section
  :markdown
    #### Lua *`C` with classes* style - resources
  :cxx
    struct LuaDestroyer {
      void operator(Lua::State* lua) {
        lua->destroy();
      }
    };

    std::unique_ptr<Lua::State, LuaDestroyer> lua(lua_new_state());
    lua->compile("hello.lua");


section
  :markdown
    ### Why not exporting the StateImpl class directly?
  ul.fragment.fade-in
    li Have to export all of its base classes and member types
    li Exposes the implementation to the client. Client needs to be
      | recompiled if the implementation changes
    li Will work only with one compiler because of the different name
      | mangling schemes


section
  :markdown
    ### Why exporting an *abstract class* works

    An abstract class is just a virtual table - it matches the *COM*
    model, and all compilers implement it in the same way.

section
  :markdown
    ## Resources

    [HowTo: Export C++ classes from a DLL]
    (http://www.codeproject.com/Articles/28969/HowTo-Export-C-classes-from-a-DLL)

section
  :markdown
    ## pImpl
  
    *Pointer-to-Implementation* is a technique for reducing coupling
    between a class (a library) and its clients

section
  :markdown
    ### Pros

    * Allows the class implementation to change with recompiling the
      client
    * Reducing compilation times by including *expensive* headers only in
      a single source file

section
  :markdown
    ### Cons

    * Prevents function inlining 
    * Adds an extra redirection for each call

section
  :markdown
    ### Resources
      * (A Twist on pImpl)[http://coherent-labs.com/a-twist-on-pimpl/]
      * (A Twist on pImpl Gist)[https://gist.github.com/dimitarcl/3771331/]

section
  :markdown
    ### Usage of pImpl

    Almost every project is divided in sub-projects according to some
    principles. For example:
      * Implementation: separating platform specific code
      * Aspect: logging, profiling
      * Functionality: Rendering

section
  :markdown
    ### Usage of pImpl
    
    *pImpl* can be used to implement the interfaces of the internal
    libraries in a project

