#include <iostream>

typedef int (*Function)(int, int);

void call(Function f)
{
	std::cout << f(24, 42) << std::endl;
}

template <typename T>
void call_any(T f)
{
	std::cout << f(24, 42) << std::endl;
}

struct A
{
	void method(int x, int y)
	{
		std::cout << x + y << std::endl;
	}

	void call()
	{
		call_any([&](int x, int y) {
			method(x + y, x * y);
			return 42;
		});
	}
};

// CAPTURE THIS
int main()
{
	call([](int x, int y) { return x + y; });

	int z = 42;
	auto l2 = [&z](int x, int y) { z += x + y; return z;};

	call_any(l2);
	++z;
	call_any(l2);

	A a;
	a.call();

	return 0;
}
