#include <iostream>
#include <thread>

class Logger {
    public:
        Logger(std::ostream& output)
            : _output(output)
        {
        }

        //@{ variadic
        template <typename... T> // T is template parameter pack
        void Log(const T&... args) // args is parameter pack
        {
            _output << std::this_thread::get_id();
            LogHelper(args...); // expand the pack
            _output << std::endl;
        }
        //@} variadic
    private:
        //@{ recursion
        template <typename T>
        void LogHelper(const T& x)
        {
            _output << ' ' << x;
        }

        template <typename T, typename... R>
        void LogHelper(const T& x, const R&... r)
        {
            _output << ' ' << x;
            // there is one argument less
            // eventually it will reach the base
            LogHelper(r...);
        }
        //@} recursion

        std::ostream& _output;
};

int main() {
    Logger l(std::cout);
    l.Log("The answer is", 42);
    l.Log('q', 'w', 'e', 'r', 't', 'y');
    return 0;
}

