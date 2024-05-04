def main():
    x : int = 10
    y : int = 20
    z : int = 30

    if x > y:
        print("x is greater than y")
    elif y > z:
        print("y is greater than z")
    else:
        print("z is greater than x and y")
        if x > 0:
            print("x is positive")
            if y > 0:
                print("y is also positive")
            elif y == 0:
                print("y is zero")
            elif y < 0:
                print("y is negative")
            else:
                print("y is non-positive")
        elif x + y + z > 0:
            print("Sum of x, y, and z is positive")
        elif x + y + z == 0:
            print("Sum of x, y, and z is zero")
        else:
            print("Sum of x, y, and z is negative")
        print("End of nested else")
    print("End of main function")    

if __name__ == "__main__":
    main()
