def fib(a:int)->int:
    if a == 0:
        return 0
    elif a == 1:
        return 1
    else:
        return fib(a-1) + fib(a-2)

def find_max(arr:list[int]) -> int:
    max:int = arr[0]
    i:int = 0
    for i in range(1, len(arr)):
        if arr[i] > max:
            max = arr[i]
    return max
def find_min(arr:list[int]) -> int:
    min:int = arr[0]
    i:int = 0
    for i in range(1, len(arr)):
        if arr[i] < min:
            min = arr[i]
    return min

def main():
    arr:list[int] = [1, 8, 9, 4, 10, 3, 6, 4]
    n:int = len(arr)
    print("Length of lis is")
    print(len(arr))
    print("Maximum number in the array:")
    max_element:int = find_max(arr)
    print(max_element)
    print("Minimum number in the array:")
    min_element:int = find_min(arr)
    print(min_element)
    print("Fibonacci series in range min_element and max_elment:")
    i:int = 0
    for i in range(min_element, max_element):
        print(fib(i))

if __name__ == '__main__':
    main()
