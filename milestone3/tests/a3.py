# function definition --> tested
def add(a : int, b : int) -> int:
    return a + b

# function definition with list parameter
def add_list(a : list[int]) -> int:
    print(a[0])
    i : int = 0
    sum : int = 0
    a[i] = 5
    print(len(a))
    for i in range(5):
        print(345)
        sum += i
        sum += 0
    print(123)
    return sum

# function returning value even though it is null
def return_none() -> None:
    return

def main() -> None:
    # function call
    print(add(1, 2))
    
    # function call
    x: list[int] = [1,2,3,4,5]
    # print(99)
    print(add_list(x))
    
    # # function call with list parameter
    sample_list : list[int] = [1, 2, 3, 4, 5]
    # print(add_list(sample_list))
    
    # function returning value even though it is null
    # print(return_none())

if __name__ == "__main__":
    main()
