#include <iostream>
#include <algorithm>
#include <iterator>

bool is_even(int x)
{
    return x % 2 == 0;
}

//@{ less-than
template <typename T>
struct less_than_t
{
    explicit less_than_t(T value)
        : _value(value)
    {}

    bool operator()(T x) const {
        return x < _value;
    }

    T _value;
};

template <typename T>

less_than_t<T> less_than(T x)
{
    return less_than_t<T>(x);
}
//@} less-than


int main()
{
	int numbers[] = { 1, 2, 4, 8, 5, 3, 6, 9, 7 };
    const int size = 9;

	//@{ partition-even
    // still not inlined
	std::partition(numbers, numbers + size, &is_even);
	//@} partition-even

	std::copy(numbers, numbers + size,
			std::ostream_iterator<int>(std::cout, " "));
	std::cout << std::endl;

	//@{ partition
	std::partition(numbers, numbers + size, less_than(5));
	//@} partition

	std::copy(numbers, numbers + size,
			std::ostream_iterator<int>(std::cout, " "));
	std::cout << std::endl;

	return 0;
}

