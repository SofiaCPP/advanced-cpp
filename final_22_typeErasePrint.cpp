//Write a struct that accepts any type and prints it to an output stream.
//struct Printable
//{
//    ...
//
//    void PrintTo(std::ostream &out);
//	
//    ...
//};

#include <iostream>
#include <functional>

struct Printable
{
	template <typename T>
	Printable(T value)
	{
		func = [value](std::ostream &out) {out << value; };
	}

	void PrintTo(std::ostream &out)
	{
		func(out);
	}

private:
	std::function<void(std::ostream&)> func;
};

int main()
{
	Printable x(42);
	Printable y(3.14);
	Printable z("test");

	x.PrintTo(std::cout);
	std::cout << std::endl;
	y.PrintTo(std::cout);
	std::cout << std::endl;
	z.PrintTo(std::cout);
	std::cout << std::endl;

	std::cin.get();
	return 0;
}

