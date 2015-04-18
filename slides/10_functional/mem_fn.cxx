#include <iostream>
#include <string>
#include <functional>
#include <memory>

int main()
{
	typedef std::string::size_type (std::string::*Find)(char,
			std::string::size_type) const;
	auto find = std::mem_fn(static_cast<Find>(&std::string::find));

	auto str = std::make_shared<std::string>("The answer is 42");
	std::cout << find(str, 'a', 0) << std::endl;
	return 0;
}

