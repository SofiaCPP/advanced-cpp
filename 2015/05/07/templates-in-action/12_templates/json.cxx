#include <iostream>
#include <string>
#include <vector>
#include <map>

template <typename Derived>
class Dump {
	public:
		Dump(std::ostream& output)
			: _output(output)
		{
		}

		void dump(int x)
		{
		}

		void dump(const std::string& s)
		{
		}

	private:
		std::ostream& _output;
};


int main() {

	return 0;
}

