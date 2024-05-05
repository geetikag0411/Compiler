def func(x: int, flag: bool) -> None:
    print(x*flag)

def func2(x:int , arr:list[int]) -> bool:
    return x

class A:
    def __init__(self):
        self.flag : bool = 0


def main():
    is_alive: bool = False
    is_alive = 30
    print(is_alive) # 1
    arr: list[bool] = [False, True, False]
    arr[2] = -124
    print(arr[2])   # 1
    arr[1] = 0
    print(arr[1])   # 0
    func(-987, 24)  # -987
    func(-987, 0)   # 0
    # print(func2(47,arr))    # 1
    obj: A = A()
    print(obj.flag) # 0
    obj.flag = 87
    print(obj.flag) # 1
