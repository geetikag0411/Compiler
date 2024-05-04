class A:
    def _init_(self):
        self.a: int = 2
        self.b: float = 15.324

    def add(self, x: int) -> int:
        return x + self.a
    
class B(A):
    def _init_(self, num: int):
        self.a = 5
        self.c: str = "Hey!"
        self.b = 132.132
        self.obj: A = A()
        self.num: int = num
    
class C(B):
    def _init_(self):
        self.x: bool = False

def main():
    obj: C = C()
    print(obj.obj.a)
    x: int = obj.add(3)
    print(x)

if __name__ == "_main_":
    main()
