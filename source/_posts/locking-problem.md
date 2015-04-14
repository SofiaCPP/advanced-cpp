title: Locking problem
date: 2015-04-14 23:30:00
tags:
---

Create a template class that allows to use a not-thread-safe object from
multiple threads.

    #include <string>

    class Queue
    {
        public:
            void push(int number)
            {
                _storage.push_back(number);
            }

            int pop() const
            {
                const auto x = _storage.front();
                _storage.pop_font();
                return x;
            }

            bool empty() const
            {
                return _storage.empty();
            }
        private:
            std::list<int> _numbers;
    };

The `Queue` class is not thread-safe, becuase `std::list` is not thread-safe.
The following code will result in undefined behavior:

    void push_squares(Queue* q)
    {
        for (auto i = 0; i < 100; ++i)
        {
            q->push(i*i);
        }
    }

    void print_squares(Queue* q)
    {
        for (auto i = 0; i < 100; ++i)
        {
            while (q->empty())
            {
                // Do not do this!
            }
            std::cout << q->pop() << std::end;
        }
    }

    int main()
    {
        Queue queue;
        std::thread t(&push_squares, &queue);
        print_squares(&queue);
        t.join();
        return 0;
    }

But if the `Queue` is wrapped in a special, *magic*, class, then the following
code will be correct:

    template <typename T>
    class Magic;

    void push_squares(Magic<Queue> q)
    {
        for (auto i = 0; i < 100; ++i)
        {
            q->push(i*i);
        }
    }

    void print_squares(Magic<Queue> q)
    {
        for (auto i = 0; i < 100; ++i)
        {
            while (q->empty())
            {
                // Do not do this!
            }
            std::cout << q->pop() << std::end;
        }
    }

    int main()
    {
        Magic<Queue> queue;
        std::thread t(&push_squares, queue);
        print_squares(queue);
        t.join();
        return 0;
    }

How the `Magic` template class should look like?
