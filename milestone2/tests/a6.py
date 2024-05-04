class C:
    def __init__(self, c:int, d:int):
        self.a: int = c
        self.d: int = d

    def printc(self):
        print(self.a)

class A:
    def __init__(self, a:int, b:bool):
        self.a : int = a
        self.li: list[bool] = [True, b, b&b, False|True, False] 
        self.b: bool = b
        self.li[4] = True
    
    def printa(self, d:int) -> int:
        print(self.a)
        return self.a

class B(A):
    def __init__(self, a:int, b:bool, c:int ):
        self.c:int = c
        # self.a = self.printa(4) 
        self.b = b
        self.li = [True, b, b, False, False]
        self.obj:C = C(c,b)

class D(B):
    def __init__(self, a:int, b:bool, c:int ):
        self.c = c
        self.a = self.printa(4)
        self.b = b
        self.obj = C(c,a)
        self.d : A = A(4, True)
        self.x : B = B(2,2,2)

def foo() -> int:
    return 1

def main():
  a:B = B(0, False, 0)
  b:B = B(4, True, 1)  
  c:B = B(1, False, 1)
  d:B = B(2, False, 2)
  e:D = D(3, True, 3)
  b.obj.printc()
  b.printa(4)
  b.li[4] = 1

if __name__ == "__main__":
  main()
