def if_else_check(n : int)-> int:
    if n < 0:
        return -n
    print("here")
    if n == 0:
        print("zero")
        n += 4564
        n *= 98
        return if_else_check(n - 3)
    elif n == 1:
        print("one")
        n += 87455
        n ^= 5
        return if_else_check(n - 3)
    elif n == 2:
        print("two")
        n //= 435
        n **= 34
        return if_else_check(n - 3)
    else:
        print("nonzero")
        n -= 977
        n //= 87
        return if_else_check(n - 3)
    print("end")    
def if_else(n:int):
    if n==1:
        print(1)
    elif n==2:
        print(2)
    elif n==3:
        print(3)
    else:
        print(4)

def main():
    x:int = if_else_check(364)
    if_else(1)
    if_else(2)
    if_else(3)
    if_else(4)
    print(x)
    print(-2//2)
    print(-2%2)
    print(-1//2)
    print(-1/2)
    print(1%2)


if __name__ == "__main__":
    main()
