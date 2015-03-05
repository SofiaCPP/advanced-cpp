#include <memory>

int main() {
  int* p;
  {
    std::unique_ptr<int[]> d(new int[2]);
    p = d.get();
  }
  *p = 42;
  return 0;
}
