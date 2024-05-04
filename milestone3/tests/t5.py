def square(x: int) -> int:
    return ((x*x))

def main():
    i: int
    j: int
    for i in range(10):
        for j in range(5):
            print(square(i+j))

main()
