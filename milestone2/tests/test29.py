# a: list[float] = [1.2, 3.6 , 4.54]
# x :int
# x = 5+a[2]


class A:
    def __init__(self):
        self.a: list[str] = ["hello", "world"]
        print(self.a[1])

    def func(self):
        print(1)

obj: A = A()
obj.func()
s: str
s = obj.a[0]
