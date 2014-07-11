import sys

def main():
    sys.stderr.write( "Error output!\n" )
    sys.stdout.write( "Standard output!\n" )

    a = 1 + 2 + 3 + 4 + 5 + 6 + 7;
    sys.stdout.write( "{0}\n".format( a ) )

if __name__ == "__main__":
    main()