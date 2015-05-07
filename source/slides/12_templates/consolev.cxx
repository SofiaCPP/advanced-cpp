#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include <functional>

#include <boost/regex.hpp>
#include <boost/lexical_cast.hpp>

using namespace std::placeholders;

        template <int N, typename T>
        struct nth_type
        {
        };

        template <typename T, typename... R>
        struct nth_type<0, void (T, R...)>
        {
            typedef T type;
        };


        template <int N>
        struct nth_type<N, void ()>
        {
        };

        template <int N, typename T, typename... R>
        struct nth_type<N, void (T, R...)>
        {
            typedef typename nth_type<N - 1, void (R...)>::type type;
        };

        template <int N, typename Function>
        struct ArgType;

        template <int N, typename R, typename... T>
        struct ArgType<N, std::function<R (T...)>>
        {
            typedef typename nth_type<N, void (T...)>::type arg;
            typedef typename
                std::remove_cv<typename std::remove_reference<arg>::type>::type type;
        };

        template <int N>
        struct helper;

        //@{ helper-0
        template <>
        struct helper<0>
        {
            template <typename Function, typename... T>
            static std::string stub(const Function& f,
                    const std::vector<std::string>& args,
                    T&&... pack)
            {
                using boost::lexical_cast;
                using std::string;
                return lexical_cast<string>(f(std::forward<T>(pack)...));
            }
        };
        //@} helper-0


        //@{ helper-n
        template <int N>
        struct helper
        {
            template <typename Function, typename... T>
            static std::string stub(const Function& f,
                    const std::vector<std::string>& args,
                    T&&... pack)
            {
                using boost::lexical_cast;
                using std::string;

                typedef typename ArgType<N - 1, Function>::type Arg;
                return helper<N-1>::stub(f, args,
                        std::forward<Arg>(lexical_cast<Arg>(args[N])),
                        std::forward<T>(pack)...);
            }
        };
        //@} helper-n


class Console
{
    public:
        Console()
            : m_Split("[^\\s]+")
        {
        }

        std::string Execute(const std::string& line)
        {
            auto& parsed = Split(line);
            auto command = m_Commands.find(parsed[0]);
            if (command != m_Commands.end())
            {
                return command->second(parsed);
            }

            return "no such command: " + parsed[0];
        }

        template <typename R, typename... T>
        void AddCommand(std::string name, std::function<R (T...)> function)
        {
            m_Commands.insert(std::make_pair(name, wrap(function)));
        }

    private:
        typedef std::function<std::string (const std::vector<std::string>&)>
            Command;

        typedef std::unordered_map<std::string, Command> CommandMap;

        CommandMap m_Commands;

        const std::vector<std::string>& Split(const std::string& line)
        {

            typedef boost::sregex_iterator iterator;

            m_Line.clear();
            std::transform(iterator(line.begin(), line.end(), m_Split), iterator(),
                    std::back_inserter(m_Line),
                    [](iterator::reference word)
                    {
                        return word.str();
                    });
            return m_Line;
        }

        //@{ wrap
        template <typename R, typename... T>
        static Command wrap(std::function<R (T...)> f)
        {
            return [f](const std::vector<std::string>& args) -> std::string {
                if (args.size() < 1 + sizeof...(T))
                {
                    return "not enough arguments";
                }
                return helper<sizeof...(T)>::stub(f, args);
            };
        };
        //@} wrap

        boost::regex m_Split;
        std::vector<std::string> m_Line;
};

int answer()
{
    return 42;
}

std::string hello()
{
    return "World";
}

std::string greet(const std::string& name)
{
    return "Hello, " + name + '!';
}

template <typename R, typename... T>
std::function<R (T...)> make_fun(R (*f)(T...))
{
    return std::function<R (T...)>(f);
}

template <typename R, typename C>
std::function<R ()> make_fun(C& instance, R (C::*m)())
{
    return std::function<R ()>(std::bind(m, std::ref(instance)));
}

template <typename R, typename C>
std::function<R ()> make_fun(C& instance, R (C::*m)() const)
{
    return std::function<R ()>(std::bind(m, std::ref(instance)));
}

template <typename R, typename C, typename T>
std::function<R (T)> make_fun(C& instance, R (C::*m)(T))
{
    return std::function<R (T)>(std::bind(m, std::ref(instance), _1));
}

template <typename R, typename C, typename T>
std::function<R (T)> make_fun(C& instance, R (C::*m)(T) const)
{
    return std::function<R (T)>(std::bind(m, std::ref(instance), _1));
}

class Sum
{
public:
    Sum()
        : m_Sum(0)
        , m_Count(0)
    {
    }
    double Add(double x)
    {
        ++m_Count;
        return m_Sum += x;
    }
    double Average()
    {
        return m_Sum / m_Count;
    }
private:
    double m_Sum;
    int m_Count;
};

int main()
{
    std::string line;
    Console console;

    console.AddCommand("answer", make_fun(&answer));
    console.AddCommand("hello", make_fun(&hello));
    console.AddCommand("greet", make_fun(&greet));

    Sum sum;

    console.AddCommand("add", make_fun(sum, &Sum::Add));
    console.AddCommand("avg", make_fun(sum, &Sum::Average));

    while (std::getline(std::cin, line))
    {
        std::cout << console.Execute(line) << std::endl;
    }
    return 0;
}

