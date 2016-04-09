#include <celero/Celero.h>
#include <vector>
#include <memory>
#include <type_traits>
#include <algorithm>
#include <atomic>


#include <boost/intrusive_ptr.hpp>

struct IntPtr
{
    IntPtr()
        : RC(1)
    {
    }
    int RC;
    int Value;
};

void intrusive_ptr_add_ref(IntPtr* p) {
    ++p->RC;
}

void intrusive_ptr_release(IntPtr* p) {
    if (--p->RC == 0) {
        delete p;
    }
}

struct IntAtomicPtr
{
    IntAtomicPtr()
        : RC(1)
    {
    }
    std::atomic<int> RC;
    int Value;
};

void intrusive_ptr_add_ref(IntAtomicPtr* p) {
    ++p->RC;
}

void intrusive_ptr_release(IntAtomicPtr* p) {
    if (--p->RC == 0) {
        delete p;
    }
}

CELERO_MAIN

const int size = 1024;

const int samples = 256;
const int iterations = 1024;

BASELINE(Construction, RawPtr, samples, iterations)
{
    int* x;
    celero::DoNotOptimizeAway(x = new int{42});
    delete x;
}

BENCHMARK(Construction, UniquePtr, samples, iterations)
{
    celero::DoNotOptimizeAway(std::unique_ptr<int>(new int{ 42 }));
}

BENCHMARK(Construction, MakeSharedPtr, samples, iterations)
{
    celero::DoNotOptimizeAway(std::make_shared<int>(42));
}

BENCHMARK(Construction, SharedPtr, samples, iterations)
{
    celero::DoNotOptimizeAway(std::shared_ptr<int>(new int{42}));
}

struct PointersFixture : celero::TestFixture
{
    virtual std::vector<int64_t> getExperimentValues() const override
    {
        auto start = 4LL;
        std::vector<int64_t> values(8);
        std::generate(begin(values), end(values), [&start]() {
                return start *= 2;
        });
        return values;
    }
};

template <typename T>
typename std::enable_if<std::is_pointer<T>::value>::type destroy(std::vector<T>& v){
    for (auto p : v) {
        delete p;
    }
}

template <typename T>
typename std::enable_if<!std::is_pointer<T>::value>::type destroy(std::vector<T>& v){
}

template <typename T>
T create(const T&) {
    return new typename std::remove_pointer<T>::type;
}

template <typename T>
std::shared_ptr<T> create(const std::shared_ptr<T>&) {
    return std::make_shared<T>();
}

template <typename T>
boost::intrusive_ptr<T> create(const boost::intrusive_ptr<T>&x) {
    return new T;
}


template <typename T>
struct RandomPointers : PointersFixture
{
    virtual void setUp(int64_t size) override
    {
        container_ = std::vector<T>(size);
        std::generate(begin(container_), end(container_), []{
                return create(T{});
                });
    }

    virtual void tearDown() override {
        destroy(container_);
    }

    std::vector<T> container_;
};

struct SumPtr {
    template <typename T>
    typename std::remove_pointer<T>::type operator()(const typename std::remove_pointer<T>::type& lhs, const T& rhs) const {
        return lhs + *rhs;
    }
    template <typename T>
    T operator()(const T& lhs, const std::shared_ptr<T>& rhs) const {
        return lhs + *rhs;
    }
};

BASELINE_F(Iterate, Raw, RandomPointers<int*>, samples, iterations)
{
    celero::DoNotOptimizeAway(std::accumulate(begin(container_), end(container_), 0, SumPtr()));
}

BENCHMARK_F(Iterate, Shared, RandomPointers<std::shared_ptr<int>>, samples, iterations)
{
    celero::DoNotOptimizeAway(std::accumulate(begin(container_), end(container_), 0, SumPtr()));
}

BASELINE_F(Move, Raw, RandomPointers<int*>, samples, iterations)
{
    std::vector<int*> other(container_.size());
    celero::DoNotOptimizeAway(std::move(begin(container_), end(container_), begin(other)));
}

BENCHMARK_F(Move, Shared, RandomPointers<std::shared_ptr<int>>, samples, iterations)
{
    std::vector<std::shared_ptr<int>> other(container_.size());
    celero::DoNotOptimizeAway(std::move(begin(container_), end(container_), begin(other)));
}

BENCHMARK_F(Move, Intrusive, RandomPointers<boost::intrusive_ptr<IntPtr>>, samples, iterations)
{
    std::vector<boost::intrusive_ptr<IntPtr>> other(container_.size());
    celero::DoNotOptimizeAway(std::move(begin(container_), end(container_), begin(other)));
}

BENCHMARK_F(Move, IntrusiveAtomic, RandomPointers<boost::intrusive_ptr<IntAtomicPtr>>, samples, iterations)
{
    std::vector<boost::intrusive_ptr<IntAtomicPtr>> other(container_.size());
    celero::DoNotOptimizeAway(std::move(begin(container_), end(container_), begin(other)));
}

BASELINE_F(Copy, Raw, RandomPointers<int*>, samples, iterations)
{
    std::vector<int*> other(container_.size());
    celero::DoNotOptimizeAway(std::move(begin(container_), end(container_), begin(other)));
}

BENCHMARK_F(Copy, Shared, RandomPointers<std::shared_ptr<int>>, samples, iterations)
{
    std::vector<std::shared_ptr<int>> other(container_.size());
    celero::DoNotOptimizeAway(std::copy(begin(container_), end(container_), begin(other)));
}

BENCHMARK_F(Copy, Intrusive, RandomPointers<boost::intrusive_ptr<IntPtr>>, samples, iterations)
{
    std::vector<boost::intrusive_ptr<IntPtr>> other(container_.size());
    celero::DoNotOptimizeAway(std::copy(begin(container_), end(container_), begin(other)));
}

BENCHMARK_F(Copy, IntrusiveAtomic, RandomPointers<boost::intrusive_ptr<IntAtomicPtr>>, samples, iterations)
{
    std::vector<boost::intrusive_ptr<IntAtomicPtr>> other(container_.size());
    celero::DoNotOptimizeAway(std::copy(begin(container_), end(container_), begin(other)));
}
