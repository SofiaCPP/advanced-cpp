#include <iostream>
#include <vector>
#include <list>
#include <algorithm>

template <typename C>
auto run(C& c) -> typename C::value_type
{
	std::iota(begin(c), end(c), 0);
	return std::accumulate(begin(c), end(c), 0);
}

int main(int argc, char * []) {
  int r = 0;
  int n = 1024 * 1024;
  if (argc != 1) {
    std::cout << "list" << std::endl;
    std::list<int> l(n);
    r = run(l);
  } else {
    std::cout << "vector" << std::endl;
    std::vector<int> v(n);
    auto l = []() { std::cout << "qwerty" << std::endl; };
    r = run(v);
  }
  std::cout << r << std::endl;
  return 0;
}

