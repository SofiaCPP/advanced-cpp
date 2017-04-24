#include <iostream>
#include <fstream>
#include <functional>
#include <algorithm>
#include <iterator>
#include <string>
#include <vector>

class Person
{
public:
	Person()
	{
	}

	Person(std::string first, std::string last)
		: first_name(std::move(first))
		  , last_name(std::move(last))
	{
	}
	const std::string& first() const
	{
		return first_name;
	}

	std::string first_name;
	std::string last_name;
};

std::ostream& operator<<(std::ostream& output, const Person& person)
{
	return output << person.first() << ' ' << person.last_name;
}

std::istream& operator>>(std::istream& input, Person& person)
{
	return input >> person.first_name >> person.last_name;
}

typedef std::vector<Person> Persons;

Persons read(const char* file)
{
	std::ifstream input(file);
	Persons persons;
	typedef std::istream_iterator<Person> iterator;

	std::copy(iterator(input), iterator(), std::back_inserter(persons));

	return persons;
}

void dump(const Persons& persons)
{
	std::copy(persons.begin(), persons.end(),
			std::ostream_iterator<Person>(std::cout, "\n"));
}



int main(int argc, const char* argv[])
{
	std::vector<Person> persons = read("persons.txt");
	dump(persons);

	std::cout << "sort by first name" << std::endl;
	std::sort(persons.begin(), persons.end(), [](const Person& lhs, const
				Person& rhs) {
		return lhs.first() < rhs.first();
	});
	dump(persons);

	std::cout << "sort by last name" << std::endl;
	std::sort(persons.begin(), persons.end(), [](const Person& lhs, const
				Person& rhs) {
		return lhs.last_name > rhs.last_name;
	});
	dump(persons);

	return 0;
}

