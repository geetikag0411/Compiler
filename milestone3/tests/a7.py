def cnt_bits(n: int) -> int:
    cnt : int = 0
    while n > 0:
        if n % 2 == 1:
            cnt = cnt + 1
        n //= 2
    return cnt

def f(sss : str) -> str:
    x : int = 10
    y : int = 20
    i : int = 0
    while x < y and cnt_bits(x) < 10:
        x = x + 1
        print("x is increased by 1")
        if x == 15:
            break
        else:
            continue
        print("kkk")
        for i in range(cnt_bits((x & 7) ^ (y | 9)) + 10 + 9 * 10 + 9*8*7*6*5) :
            print("Inside for loop")
            x += (y & 6)
            y += (x * 8)
            if (x == 0) or ( y + 2 * x > 0):
                break

    print("while loop end")

    s : str = "You can not drink cow because earth is a carrot"
    return s



def main():
    # Define a list of integers
    num_list: list[int] = [1, (2 ^ 7), (3 | 90), cnt_bits((1 + 2) % 2), (5)]
    i: int
    for i in range(len(num_list)):
        print(num_list[i])
    # Define a list of strings
    str_list: list[str] = ["apple", "banana", "cherry", f("h")]
    for i in range(len(str_list)):
        print(str_list[i])
    # Print the lists
    # print("List of integers:", num_list)
    # class A():
    #     def __init__(self):
    #         self.s : str = "This course is giving me nightmares"



if __name__ == "__main__":
    main()
