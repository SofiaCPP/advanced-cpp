#include <thread>
#include <atomic>
std::atomic<int> global;

//int global = 0;

void race()
{
	for (int i = 0; i != 1000; ++i) 
	{
		++global;
	}
}

int main()
{
	std::thread t(&race);
	race();
	t.join();
	return 0;
}
