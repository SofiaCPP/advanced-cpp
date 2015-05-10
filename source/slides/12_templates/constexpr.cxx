namespace ctc
{

namespace detail
{

constexpr int sqrt_i(int x, int i) {
    return (i * i > x)? i - 1 : sqrt_i(x, i + 1);
}

constexpr bool is_prime_i(int x, int i, int m) {
    return (i > m) || (x % i && is_prime_i(x, i + 1, m));
}

}

constexpr int sqrt(int x) {
    return detail::sqrt_i(x, 1);
}

constexpr bool is_prime(int x) {
    return (x > 1) && detail::is_prime_i(x, 2, sqrt(x));
}

}


int main() {
    static_assert(ctc::sqrt(4) == 2, "omg");
    static_assert(ctc::sqrt(10) == 3, "omg");
    static_assert(ctc::sqrt(65536) == 256, "omg");
    static_assert(ctc::is_prime(2), "omg");
    static_assert(ctc::is_prime(23), "omg");
    static_assert(ctc::is_prime(233), "omg");
    static_assert(ctc::is_prime(2333), "omg");
    static_assert(ctc::is_prime(23333), "omg");
    static_assert(!ctc::is_prime(233333), "omg");
    static_assert(ctc::is_prime(2333323), "omg");
}
