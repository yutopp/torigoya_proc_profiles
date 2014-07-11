#include <iostream>
#include <cstdio>
#include <unistd.h>

using namespace std;

// undefined symbol...
bool foo();

int main()
{
    foo();
}
