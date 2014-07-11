#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>

using namespace std;

int main()
{
    for( int i=0; i<5; ++i ) {
        sleep( 1 );
        std::cout << "loop: " << i << std::endl;
    }
}
