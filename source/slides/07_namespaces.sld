section
    section
        :markdown
            ## Namespaces

            Namespace is a group of functions, classes, constants and
            variables.

    section
        :markdown
            ### Namespaces

            * Allow us to group related functions / classes
            * Prevent name clashes between different parts of code
            * Allow us to hide implementation details 

    section
        :markdown

            Namespaces are open, i.e. you can define different members of
            the namespace in different files.

    section
        :cxx

            namespace ui
            {
                class Button;
            }

    section
        :markdown
            ### `using namespace`

            `using namespace std` brings all the names from the
            `std` namespaces in the current scope - namespace,
            function, block.

    section
        :markdown
            ### `using namespace`

            It is a really bad practice to use `using namespace` at
            anything but function or block level in headers.

            You never know where this header is going to be included.

    section
        :markdown
            ### `using namespace`

            It is a good practice to avoid `using namespace` at
            anything but function or block level.

            Otherwise the names may clash in a *unity* build

    section
        :markdown
            ### *unity* build

            Building the whole program/library from a single (or reduced
            number of) translation units. It is implemented as
            `#include`-ing multiple C++ source files in a single C++
            file and compiling it instead of the original files.

    section
        :markdown
            ### *unity* build

            * speeds up build by reducing
              * template instantiation duplicates
              * functions that need to be linked
            * allows the compiler to inline more functions (because their
              definitions are visible)

    section
        :markdown
            ### *Anonymous* namespaces

            * `namespace` without a name
            * allow private definitions for a translation unit
              * definitions in anonymous namespaces are global for the
                translation unit
              * they can not be accessed by any other translation unit

    section
        :cxx
            namespace {
                int aswer();
            }


section
    section
        :markdown
            ## Argument Dependent Lookup (ADL)

            * a.k.a Koenig Lookup

    section
        :markdown
            ### ADL

            What is the interface of a type T?

    section
        ul
            li.fragment.fade-in public methods of T
            li.fragment.fade-in any function that takes T as an argument

    section
        :markdown
            ### Unqualified call

            Calling a function without explicitly specifying the namespace
            of the function.

            The compiler searches matching function declarations for an
            unqualified call in the current namespace and in the
            associated namespaces of each argument type for the call

    section
        :cxx
            namespace math {
                class Polynom {
                };

                std::ostream& operator<< (std::ostream& output,
                    const Polynom& p)
                {
                    // ...
                }

                void swap(Polynom& l, Polynom& r);
            }

            int main() {
                Polynom p;
                // finds the operator << in math
                std::cout << p << std::endl;
            }

    section
        :markdown
            ### `use function` trick

            * bring a set of definitions from a namespace to the current
              scope
            * use an unqualified call for the function

    section
        :cxx
            template <typename T, typename A, typename I>
            void fast_erase(std::vector<T, A>& v, I iterator)
            {
                // bring all std swap overloads
                using std::swap;

                // ADL finds math::swap(Polynom&, Polynom&)
                swap(*iterator, v.back());

                v.pop_back();
            }

            std::vector<Polynom> v;

            fast_erase(v, v.begin());

    section
        :markdown
            ## Associated namespaces

            * primitive types have no associated namespaces
            * the associated namespace of user defined type T are:
              * the namespace where T is defined
              * the namespaces of T base classes

