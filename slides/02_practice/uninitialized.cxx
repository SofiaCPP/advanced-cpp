#include <iostream>

struct X
{
	X()
		: m_X(42)
	{}

	int f() {
		if (m_Z) {
			std::cout << "true";
		}
		return m_Z? 2 :3;
	}

	int m_X;

	bool m_Z;
};

int main()
{
	int x;
	int y = (x % 2)? x / 2 : x;
	X z;
	z.f();
	std::cout << y << std::endl;
}
