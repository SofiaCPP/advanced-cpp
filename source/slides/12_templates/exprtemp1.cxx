#include <iostream>
#include <vector>
#include <boost/proto/debug.hpp>
#include <boost/proto/expr.hpp>
#include <boost/proto/operators.hpp>

namespace poly
{
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

		void set(int power, value_type c)
		{
			m_C[power] = c;
		}

		value_type get(int power) const
		{
			return (power < int(m_C.size())) ? m_C[power] : 0;
		}

		int power() const
		{
			return m_C.size() - 1;
		}

	private:
		typedef std::vector<value_type> Container;
		Container m_C;
	};



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

	template <typename T>
	struct is_terminal : boost::mpl::false_
	{};

	template <typename F>
	struct is_terminal<Polynom<F>> : boost::mpl::true_
	{};

	BOOST_PROTO_DEFINE_OPERATORS(is_terminal, boost::proto::default_domain)
}

struct Tag
{
	friend std::ostream &operator<<(std::ostream &s, Tag)
	{
		return s << "Tag";
	}
};

int main()
{
	poly::Polynom<int> a = { 0, 2, 0, 1 }; // x^3 + 2*x
	poly::Polynom<int> b = { 2, 0, 1 }; // x^2 + 2
	//std::cout << a << std::endl;
	//std::cout << b << std::endl;

	auto expressionA = boost::proto::make_expr<Tag>(a);
	auto expressionB = boost::proto::make_expr<Tag>(b);

	boost::proto::display_expr(expressionA + expressionB + expressionA * expressionB + 2 * expressionA);


	return 0;
}

