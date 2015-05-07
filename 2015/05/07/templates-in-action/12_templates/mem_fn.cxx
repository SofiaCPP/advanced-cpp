#include <iostream>
#include <vector>
#include <functional>

int main()
{
	auto size = std::mem_fn(&std::vector<int>::size);
	std::vector<int> v = { 1, 2, 3, 4 };
	std::cout << size(v) << std::endl;
	return 0;
}
