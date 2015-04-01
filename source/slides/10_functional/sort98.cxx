#include <iostream>
#include <algorithm>
#include <iterator>

//@{ comparator
#include <functional>
//@}

int main()
{
	int numbers[] = { 1, 2, 3, 4, 5 };

	//@{ sort
	std::sort(numbers, numbers + 5, std::greater<int>());
	//@}

	std::copy(numbers, numbers + 5,
			std::ostream_iterator<int>(std::cout, " "));
	std::cout << std::endl;

	return 0;
}

