#include <iostream>
#include <algorithm>
#include <vector>
#include <string>
#include <functional>
#include <iterator>

int main()
{
	std::vector<std::string> v;
	v.push_back("x");
	v.push_back("y");

	std::transform(v.begin(), v.end(), v.begin(),
			std::bind2nd(std::plus<std::string>(), ";"));

	std::copy(v.begin(), v.end(),
			std::ostream_iterator<std::string>(std::cout, "\n"));
	return 0;
}

