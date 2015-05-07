#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include <functional>

#include <boost/regex.hpp>
#include <boost/lexical_cast.hpp>

using namespace std::placeholders;


class Console
{
    public:
        Console()
            : m_Split("[^\\s]+")
        {
        }

        //@{ execute
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
        //@} execute

        //@{ add-command
        template <typename R, typename... T>
        void AddCommand(std::string name, std::function<R (T...)> function)
        {
            m_Commands.insert(std::make_pair(name, wrap(function)));
        }
        //@} add-command

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

        //@{ wrap0
        template <typename R>
        static Command wrap(std::function<R ()> f)
        {
            return [f](const std::vector<std::string>&) {
                return boost::lexical_cast<std::string>(f());
            };
        };
        //@} wrap0

        //@{ wrap1
        template <typename R, typename T>
        static Command wrap(std::function<R (T)> f)
        {
            using boost::lexical_cast;

            return [f](const std::vector<std::string>& args) {
                typedef typename std::remove_cv<typename
                    std::remove_reference<T>::type>::type Arg0;

                auto argument0 = lexical_cast<Arg0>(args[1]);
                return lexical_cast<std::string>(f(argument0));
            };
        };
        //@} wrap1

        //@{ wrap2
        template <typename R, typename T0, typename T1>
        static Command wrap(std::function<R (T0, T1)> f)
        {
            using boost::lexical_cast;

            return [f](const std::vector<std::string>& args) {
                typedef typename std::remove_cv<typename
                    std::remove_reference<T0>::type>::type Arg0;
                typedef typename std::remove_cv<typename
                    std::remove_reference<T1>::type>::type Arg1;

                auto argument0 = lexical_cast<Arg0>(args[1]);
                auto argument1 = lexical_cast<Arg1>(args[2]);
                return lexical_cast<std::string>(f(argument0, argument1));
            };
        };
        //@} wrap2

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

