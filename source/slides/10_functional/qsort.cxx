#include <iostream>
#include <algorithm>
#include <iterator>
#include <cstdlib>

//@{ comparator
int greater(const void* lhs, const void* rhs) {
	const int* l = static_cast<const int*>(lhs);
	const int* r = static_cast<const int*>(rhs);
	return *r - *l;
}
//@} comparator

int main()
{
	int numbers[] = { 1, 2, 3, 4, 5 };

	//@{ sort
	std::qsort(numbers, 5, sizeof(int), &greater);
	//@} sort

	std::copy(numbers, numbers + 5,
			std::ostream_iterator<int>(std::cout, " "));
	std::cout << std::endl;

	return 0;
}
