def main():
    d: int = 0
    num : int = 45
    b: bool = False
    while(num != 0):
        num //= 10
        d = d + 1
    else:
        print(d)

    x: int = 1
    if(d % 3 ==0 ):
        print("The number of digits is divisible by 3")
    elif ( d%3 ==1 ):
        print("The number of digits is 1 mod 3")
    else:
        print("The number of digits is 2 mod 3 ")
    num = 93
    while(num != 0):
        digit:int = num % 10
        num //= 10
        if(digit % 2 != 0):
            continue
        d = d + 1
        if(digit == 0):
            b = True
            break
    else:
        if(b):
            print("Zero digit not allowed")
            return
    # # print("No. of non_zero digits: ")
    # print(d)
    i:int
    j:int
    k:int
    d=9
    count : int =0
    for i in range(-3, 10):
        print("i=")
        print(i) 
        for j in range(d):
            print("j=")
            print(j)
            for k in range(j):
                print("k=")
                print(k)
                count+=1
                print(count)
                if(i +j ==0):
                    print("Hi")
                    break
                if(i + j == -3):
                    print("Hello")
                    continue
                print(i+j)
            if(j == 5):
                break
                
    print("Count: ")
    print(count)

if __name__ == "__main__":
    main()

