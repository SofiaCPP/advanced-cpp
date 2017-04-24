section
    h1 Error handling & exceptions

section
    h2 Contents
    ul
        li "manual error handling"
        li exception based
        li std::error_code
        li std::optional
        li logging (& context)

section
    section
        h2 "Manual Error Handling"

    section
        h2 Methods
        ul
            li global error code - errno, ::glError
            li special return values, HRESULT
    section
        :markdown
            ## Global Error Code

            * Windows - ```::GetLastError()```
            * POSIX - ```errno```, ```perror()```
            * OpenGL - ```glGetError()```

    section
        p Only a error code - must always be looked up
        :cxx
            auto handle = ::CreateFileMapping(file, NULL, PAGE_READWRITE,
                    0, 0, 0);
            if (!handle) {
                auto error = ::GetLastError();
                std::cout << "Creating file mapping: " << error << std::endl;
                return;
            }
            auto memory = ::MapViewOfFile(handle, FILE_MAP_READ, 0, 0, 0);
            if (!memory) {
                auto error = ::GetLastError();
                std::cout << "Error mapping view: " << error << std::endl;
            }


    section
        :markdown

            Even worse if we don't have a nice special value for failure,
            like ```nullptr``` for pointers.

    section
        :cxx
            HANDLE handle;
            auto has_error = ::CreateFileMapping(file, NULL, PAGE_READWRITE,
                0, 0, 0, &handle);
            if (has_error) {
                auto error = ::GetLastError();
                std::cout << "Creating file mapping: " << error << std::endl;
                return;
            }
            POINTER memory;
            has_error = ::MapViewOfFile(handle, FILE_MAP_READ, 0, 0, 0,
                &memory);
            if (has_error) {
                auto error = ::GetLastError();
                std::cout << "Error mapping view: " << error << std::endl;
            }

    section
        :markdown
            ## And all we wanted was
        :cxx
            auto handle = ::CreateFileMapping(file, NULL, PAGE_READWRITE,
                0, 0, 0);
            /*
            if (!handle) {
                auto error = ::GetLastError();
                std::cout << "Creating file mapping: " << error << std::endl;
                return;
            }
            */
            auto memory = ::MapViewOfFile(handle, FILE_MAP_READ, 0, 0, 0);
            /*
            if (!memory) {
                auto error = ::GetLastError();
                std::cout << "Error mapping view: " << error << std::endl;
            }
            */

    section
        :markdown
            ## *Last* error
        :cxx
            auto handle = ::CreateFileMapping(file, NULL, PAGE_READWRITE,
                0, 0, 0);
            auto memory = ::MapViewOfFile(handle, FILE_MAP_READ, 0, 0, 0);
            /*
            if (!memory) {
                auto error = ::GetLastError();
                std::cout << "Error mapping view: " << error << std::endl;
            }
        :markdown
            Which error is that?

    section
        :markdown
            ## OpenGL - ```glGetError()```
        :cxx
            auto handle = ::CreateFileMapping(file, NULL, PAGE_READWRITE,
                0, 0, 0);
            auto memory = ::MapViewOfFile(handle, FILE_MAP_READ, 0, 0, 0);
            /*
            if (!memory) {
                auto error = ::GetLastError();
                std::cout << "Error mapping view: " << error << std::endl;
            }
        :markdown
            Which error is that?

    section
        :markdown
            ## Multithreading

            * ```::GetLastError()``` and ```errno``` are thread-local -
              they have a separate value for each thread in the process

    section
        :markdown
            ## Issues with manual error hanlding

            * it is very easy to skip the check for error
            * needs special error values
            * requires adding a lot of code, reducing the clarity of the
              program

    section
        h2 Variants

        :cxx
            HRESULT hr = ::DoSomething();
            if (FAILED(hr)) {

            }

section
    section
        h2 Exceptions

        p.

            Exception is an anomalous event requiring special processing,
            outside of the normal flow.

    section
        h2 Exception Handling

        p The process of responding to the occurance of exceptions.

    section
        h3 Advantages

        p.

            Exceptions allow error handling to happen in a separate flow,
            outside of the main flow of the program.

    section
        h3 Advantages

        p.

            Allow us to focus on the main flow of the program.

    section
        h3 Throwing exceptions
        :cxx
            float sqrt(float x) {
                // C++ allows throwing any type of value
                if (x < 0) throw 42;
                // ...
            }

    section
        h3 Catching exceptions
        :cxx
            try { // try block
                float input;
                std::cin >> input;
                std::cout << sqrt(input) << std::endl;
            }
            catch (int x) { // catch clause
                std::cout << "Please enter a non-negative number" <<
                    std::endl;
            }
            catch (std::exception& e) {
            }

    section
        h3 Exception handling in C++
        p What happens when an exception is thrown in C++?

    section
        ol
            li.fragment.fade-in An exception of type T is thrown
            li.fragment.fade-in The runtime starts looking for an
                | appropriate catch clause
            li.fragment.fade-in If there is no such catch clause
                code std::terminate()
                | is called
            li.fragment.fade-in Otherwise the stack is unwound to the catch
                | clause
            li.fragment.fade-in The catch clause is executed

    section
        :markdown
            *Appropriate* catch clause

            * Takes an exception of the same type or type that is
              convertible to the exception type.
            * It is on the callstack

    section
        :markdown
            *Appropriate* catch clause

            * Starts from the current function. All *catch clauses* are
              checked in order, from top to bottom. The first one matching
              is executed.
            * If there is no matching clause the search goes to the
              function that called the current function and so on.

    section
        :markdown
            ### ```std::exception``` hierarchy

            ```std::exception``` is the base class of all standard C++
            exceptions

    section
        :markdown
            ### ```std::exception```
        :cxx
            class exception {
            public:
                const char* what() const {
                    // returns an explanatory string
                }
            };

    section
        :markdown
            ### ```std::exception```
        :cxx
            class exception {
            public:
                const char* what() const {
                    // returns an explanatory string
                }
            };

    section
        :markdown
            ### ```std::exception``` hierarchy

            * ```std::bad_alloc```
            * ```std::bad_cast```
            * ```std::bad_exception```
            * ```std::logic_error```
            * ```std::runtime_error```

    section
        :markdown
            Custom exceptions should be derived from ```std::exception```

    section
        :markdown
            ### *Throw by value catch by reference*

            ## **NEVER** catch exceptions by value
        :cxx
            catch (std::exception e) {
                // e just got "sliced"
                // the derived object got cut off
            }

    section
        :markdown
            ### Catching derived classes
        :cxx
            catch (std::exception& e) {
                std::cout << e.what() << std::endl;
            }


    section
        :markdown
            ### ```std::terminate```

            ```std::terminate``` calls the currently installed
            ```std::terminate_handler```. The default
            ```std::terminate_handler``` calls ```std::abort```

    section
        :markdown
            ### Stack Unwinding

            The process of destroying the stack frames until the
            appropriate *catch clause* is found.

            During this process all destructors of automatic variables are
            executed. This allows for freeing any resources.

    section
        :markdown
            ### Stack Unwinding

            Throwing an exception during *stack unwinding* is going to
            call ```std::terminate()```. This is the reason to consider
            destructors that throw exceptions a bad practice.

    section
        :markdown
            ### What to do with the exception?

            * let the program/user know that something has failed
            * try again
            * fallback to another solution
            * change and rethrow the exception
            * throw another exception
            * stop the program


    section
        :markdown
            ### ```std::terminate``` is called when ...

    section
        ol
            li an exception is thrown and not caught
            li an exception is thrown during stack unwinding
            li the ctor or dtor of a static or thread-local object throws
                | an exception
            li a function registered with
                code std::exit
                | or
                code std::at_quick_exit
                | throws an exception
            li a noexcept specification is violated
    section
        ol(start = 6)
            li a dynamic exception specification is violated and the
                | default handler for
                code std::unexcepted
                | is executed

            li.

                a non-default handler for std::unexpected throws an
                exception that violates the previously violated dynamic
                exception specification and the specification doesn't
                include std::bad_exception


            li std::nested_exception::rethrow_nested is called for an
                | object that isn't holding a capture exception

            li an exception is thrown out the initial function of
                code std::thread
            li a joinable
                code std::thread
                | is destroyed or assigned to


    section
        ol
            li.fragment.fade-in An exception of type T is thrown
            li.fragment.fade-in The runtime starts looking for an
                | appropriate catch clause
            li.fragment.fade-in If there is no such catch clause
                code std::terminate()
                | is called
            li.fragment.fade-in Otherwise the stack is unwound to the catch
                | clause
            li.fragment.fade-in The catch clause is executed

    section
        h2 Exception Safety

        p.

            A set of guidelines that class library implementers and
            clients use when reasoning about exception handling safety in
            C++ programs.

    section
        :markdown
            ## Exception Safety Guarantees

            * *No-throw guarantee* - *failure transparency*
            * *Strong exception safety* - *commit or rollback*
            * *Basic exception safety* - *no-leak guarantee*
            * *No exception safety*

    section
        :markdown
            ### *No-throw* guarantee

            Operations are guaranteed to succeed.
            All exceptions are handled internally and not visible to the
            client

    section
        :markdown
            ### *Strong exception safety*

            Operations can fail, but failed operations have no side
            effects, as if they didn't attempt to run at all.

    section
        :markdown
            ### *Basic exception safety*
            Operations can fail, failed operations might have side
            effects, but no invariants are broken.

    section
        :markdown
            ### *No exception safety*

            Oh, well, ...

    section
        :markdown
            ### How to write exception safe code

            Follow the begin transaction/commit/rollback pattern

    section
        :cxx
            // m_End points the last element of the vector
            void vector::push_back(T& x) {
                if (size() < capacity()) {
                    new (m_End + 1) T(x);
                    // if it throws, m_End will not be moved
                    ++m_End;
                    // commit the push
                } else {
                    std::vector<T> newvector;
                    newvector.reserve((size() + 1) * 2);
                    newvector.assign(begin(), end());
                    newvector.push_back(x);

                    using std::swap;
                    // commit the push_back
                    swap(*this, newvector);
                }
            }

    section
        :markdown
            ### Exception specifiers

    section
        :markdown
            ## Pros

            * Separete program logic from error handling
            * They can't be ignored.
    section
        :markdown
            ## Cons

            * Implementations - have some overhead even when no exceptions
              occur
                * Windows - there is runtime overhead per function
                * Others - there is overhead in executable size

section
    section
        h2 C++'11 error handling

    section
        ul
            li std::error_code
            li std::optional
            li noexcept

    section
        :markdown
            ### ```std::error_code```

            * Taken from [```boost::system```][1]

            [1]: http://www.boost.org/doc/libs/1_55_0/libs/system/doc/index.html

    section
        :cxx
            void create_directory(const std::string& name, std::error_code&
            error);

            std::error_code error;
            create_directory("path", error);
            if (error)
            {
                if (error == std::errc:file_exists) {
                }
            }

    section
        :markdown
            * ```std::error_code``` is the platform-specific error
            * ```std::errc::*``` are platform-agnostic error conditions

    section
        :markdown
            ### How to add a custom ```error_code```

            http://blog.think-async.com/2010/04/system-error-support-in-c0x-part-1.html

    section
        :markdown
            ### ```std::optional```

            * Was expected in ```C++```14
            * Will become available as *Technical Report* or in ```C++```17
    section
        :markdown
            ### ```boost::optional```

            Allows to express that there is no such value.

        :cxx
            sqrt(-42); ///?

    section
        :cxx
            template <typename T>
            class optional {
                T& get();

                T* get_ptr();

                const T& get_value_or(const T& default) const;

                T& operator*();
                T* operator->();

                explicit operator bool();
            };

section
    section
        :markdown
            ## Logging

            Having only an error (with an callstack if we are lucky) often
            is not enough.

            Logging is essential for understanding what is going on with the
            program.

    section
        :markdown
            ### Logging

            * There is no standard ```C++``` library for logging.

    section
        :markdown
            ### Choosing a logging library

            * Logging is an aspect of the program
            * It crawls all over the place

    section
        :markdown
            ### Logging libraries


            * [glog][glog]
            * [boost log][boost]
            * roll your own (at least for fun)

            [glog]: https://code.google.com/p/google-glog/
            [boost]: http://www.boost.org/doc/libs/1_55_0/libs/log/doc/html/index.html

    section
        :markdown
            ### Criteria

            * Severities, may be even facilities
            * log rotation
            * compile time and run-time impact

    section
        :markdown
            ### What to log?

            * Not too much (it is not free), but enough to understand what
              is going on.
            * All important points in the lifetime of the application.
            * Log only in case of errors - [error context][error]

            [error]: http://bitsquid.blogspot.com/2012/01/sensible-error-handling-part-1.html

section
    section
        h2 Crash reporting

        p At the end there may be crashes in the application

    section
        :markdown
            ### [Breakpad](https://code.google.com/p/google-breakpad/)

            * portable
            * allows automatic crash dump analysis


