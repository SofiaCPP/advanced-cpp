#include <iostream>
#include <vector>

namespace poly
{
    //@{ polynom
    template <typename F>
    class Polynom
    {
    public:
        typedef F value_type;

        Polynom(const std::initializer_list<value_type>& initializer)
            : m_C(initializer)
        {}

        Polynom(int power)
            : m_C(power + 1)
        {}

        void set(int power, value_type c) {
            m_C[power] = c;
        }

        value_type get(int power) const {
            return (power < int(m_C.size())) ? m_C[power] : 0;
        }

        int power() const {
            return m_C.size() - 1;
        }

    private:
        typedef std::vector<value_type> Container;
        Container m_C;
    };
    //@} polynom

    namespace detail
    {
        template <typename L, typename R>
        class Mult;

        //@{ sum
        template <typename L, typename R>
        class Sum
        {
        public:
            typedef typename L::value_type value_type;

            Sum(const L& lhs, const R& rhs)
                : m_LHS(lhs)
                , m_RHS(rhs)
            {}

            Sum& operator=(const Sum&) = delete;

            value_type get(int power) const {
                return m_LHS.get(power) + m_RHS.get(power);
            }

            int power() const {
                return std::max(m_LHS.power(), m_RHS.power());
            }

            operator Polynom<value_type>() const {
                auto p = power();
                Polynom<value_type> result(p);
                for (auto i = 0; i <= p; ++i) {
                    result.set(i, get(i));
                }
                return result;
            }

            template <typename RHS>
            Sum<Sum, RHS> operator+(const RHS& rhs) const {
                return Sum<Sum, RHS>(*this, rhs);
            }

            template <typename RHS>
            Mult<Sum, RHS> operator*(const RHS& rhs) const {
                return Mult<Sum, RHS>(*this, rhs);
            }

        private:
            const L& m_LHS;
            const R& m_RHS;
        };
        //@} sum

        //@{ mult
        template <typename L, typename R>
        class Mult
        {
        public:
            typedef typename L::value_type value_type;

            Mult(const L& lhs, const R& rhs)
                : m_LHS(lhs)
                , m_RHS(rhs)
            { }

            Mult& operator=(const Mult&) = delete;

            value_type get(int power) const {
                value_type result = 0;
                for (auto l = 0; l <= power; ++l) {
                    result += m_LHS.get(l) * m_RHS.get(power - l);
                }
                return result;
            }

            int power() const {
                return m_LHS.power() + m_RHS.power();
            }

            operator Polynom<value_type>() const {
                auto p = power();
                Polynom<value_type> result(p);
                for (auto i = 0; i <= p; ++i) {
                    result.set(i, get(i));
                }
                return result;
            }

            template <typename RHS>
            Sum<Mult, RHS> operator+(const RHS& rhs) const {
                return Sum<Mult, RHS>(*this, rhs);
            }

            template <typename RHS>
            Mult<Mult, RHS> operator*(const RHS& rhs) const {
                return Mult<Mult, RHS>(*this, rhs);
            }

        private:
            const L& m_LHS;
            const R& m_RHS;
        };
        //@} mult
    }

    template <typename F>
    std::ostream& operator<<(std::ostream& output, const Polynom<F>& poly)
    {
        bool plus = false;
        for (auto p = poly.power(); p >= 0; --p)
        {
            auto c = poly.get(p);
            if (c)
            {
                if (plus)
                {
                    output << " + ";
                }
                else
                {
                    plus = true;
                }
                output << poly.get(p) << "*x^" << p;
            }
        }
        return output;
    }

    //@{ operators
    template <typename F>
    detail::Sum<Polynom<F>, Polynom<F>> operator+(const Polynom<F>& lhs, const Polynom<F>& rhs)
    {
        return detail::Sum<Polynom<F>, Polynom<F>>(lhs, rhs);
    }

    template <typename F>
    detail::Mult<Polynom<F>, Polynom<F>> operator*(const Polynom<F>& lhs, const Polynom<F>& rhs)
    {
        return detail::Mult<Polynom<F>, Polynom<F>>(lhs, rhs);
    }
    //@} operators

    //@{ all-operators
    template <typename F, typename L, typename R>
    detail::Sum<Polynom<F>, detail::Sum<L, R>> operator+(const Polynom<F>& lhs, const detail::Sum<L, R>& rhs)
    {
        return detail::Sum<Polynom<F>, detail::Sum<L, R>>(lhs, rhs);
    }

    template <typename F, typename L, typename R>
    detail::Mult<Polynom<F>, detail::Sum<L, R>> operator*(const Polynom<F>& lhs, const detail::Sum<L, R>& rhs)
    {
        return detail::Mult<Polynom<F>, detail::Sum<L, R>>(lhs, rhs);
    }

    template <typename F, typename L, typename R>
    detail::Mult<Polynom<F>, detail::Mult<L, R>> operator*(const Polynom<F>& lhs, const detail::Mult<L, R>& rhs)
    {
        return detail::Mult<Polynom<F>, detail::Mult<L, R>>(lhs, rhs);
    }

    template <typename F, typename L, typename R>
    detail::Sum<Polynom<F>, detail::Mult<L, R>> operator+(const Polynom<F>& lhs, const detail::Mult<L, R>& rhs)
    {
        return detail::Sum<Polynom<F>, detail::Mult<L, R>>(lhs, rhs);
    }
    //@} all-operators
}

int main()
{
    poly::Polynom<int> a = { 0, 2, 0, 1 }; // x^3 + 2*x
    poly::Polynom<int> b = { 2, 0, 1 }; // x^2 + 2
    std::cout << a << std::endl;
    std::cout << b << std::endl;
    poly::Polynom<int> c = a + b;
    std::cout << c << std::endl;
    poly::Polynom<int> d = a * b;
    std::cout << d << std::endl;
    {
        poly::Polynom<int> r = a + b + a;
        std::cout << r << std::endl;
    }
    {
        poly::Polynom<int> r = a + b * a;
        std::cout << r << std::endl;
    }
    {
        poly::Polynom<int> r = a * b * a;
        std::cout << r << std::endl;
    }
    return 0;
}

