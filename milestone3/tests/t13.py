def func(x: int, a: int) -> int:
    ans: int = 1
    while a>0:
        if a%2 == 1:
            ans = ans * x
        x = x*x
        a = a/2
        a=a-1
    return ans

def main():
    print(func(3,4))
main()

