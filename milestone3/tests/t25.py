def func(s:str) -> None:
    print(s)
    return

def main():
    s:str = "Hello\n"
    ar:int = 1 + 4
    print(ar)
    print(s)
    print("Gello")
    a:list[str] = ["a", "b", "c"]
    i:int
    for i in range(len(a)):
        print(a[i])
    print(len(a)+5)
    func("H")
    func(s)

if __name__ == "__main__":
    main()
