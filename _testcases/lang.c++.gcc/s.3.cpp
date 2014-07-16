#include <iostream>

auto f()
{
    return 72;
}

int main()
{
    constexpr int x = 0b10101010;

    std::cout << x << std::endl
              << f() << std::endl;

}
