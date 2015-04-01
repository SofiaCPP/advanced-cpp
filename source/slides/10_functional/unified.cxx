#include <iostream>
#include <functional>

class A
{
	public:
		int print(int x) const
		{
			std::cout << "A::print: " << this << std::endl;
			return x * 2;
		}

};

int print(const A& a, int x)
{
	std::cout << "print: " << &a << std::endl;
	return x * x;
}

int main()
{
	std::function<int (const A&, int)> printer;
	if (!printer)
	{
		std::cout << "empty function" << std::endl;
	}
	printer = print;
	A a;
	std::cout << printer(a, 4) << std::endl;

	printer = &A::print;

	std::cout << printer(a, 5) << std::endl;

	return 0;
}

