#include <iostream>
#include <memory>
#include <thread>
#include <string>

void test()
{
    std::cerr << "Error output!" << std::endl;
}

int main() {
    std::thread th( test );
    th.join();

    auto sp = std::make_shared<std::string>("tasukete");
    sp.reset();

    std::cout << "Standard output!" << std::endl;

    constexpr auto a = 1 + 2 + 3 + 4 + 5 + 6 + 7;
    std::cout << a << std::endl;
}
