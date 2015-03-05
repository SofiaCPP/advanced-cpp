#include <memory>

int main() {
	{
		std::unique_ptr<int[]> d(new int[2]);
		int x = d[24];
	}
	return 0;
}
