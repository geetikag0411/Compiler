# flag:bool = True
 
# if flag:
#     print(1324)
#     print(13254)
# elif flag:
#     x:int = 1
#     a:str = "idk"
# elif flag:
#     print("Aergsdf")
#     print(True)
# elif flag:
#     b:bool = 94
#     y:float = 345.1345
# else:
#     print(a)

# y = 0.0

def foo_int(x:int) -> int:
  x = 3
  print(3)
  return 0

# # a:int = 5
# # print(foo())
# # b:int = 5
# # class A:
# #   def __init__(self):
# #     self.x: int = 1
# #     self.y:int = 2

def f(x:int) -> None:
  x += 1
  foo_int(x)
  return
  
class B:
  def __init__(self, x:int):
    print(x)
    self.a:int = x
    f(1)
  def foo_int(self, a:int, b:int) -> int:
    f(1)
    # print(a)
    return a -b - self.a

  def foo2_void(a:int, b:int) -> None:
    b += 1
    return

  def foo2_int(self, a:int, b:int) -> int:
    return a+b
  
  def func(self, a:int) -> int:
    print(a)
    return a + 1
  
  def f(self) -> None:
    # print(1)
    return

def foo5(a:int, b:int, c:int, d:int, e:int, f:int, g:int) -> int:
    return a+b+c + d + e + f + g

# obj:B = B()
# print(obj.foo().x)

# if "compare" > "Compare" > "compare":
# def f(a:int, b:int) -> int:
#   return 5

# def func(a:int) -> int:
#   return 0

# def foo(a:int) -> int:
#   x:int = func(4)
#   return x + a

def foo_list(a:list[int]) -> None:
  print(a[2])

def foo2_int(a:int, b:int) -> int:
  return a

def main():
  f(2)
  a:list[int] = [1, 2 , 4]
  print(a[2])
  foo_list(a)
  r:int = foo2_int(4,6)
  print(r)
  b:list[int]= [1, 2, 3]
  i:int = 0
  j:int = 1
  a[i] = b[j]
  a[i] = b[j] + 1
  a[i] = b[j] + b[j - 1]
  a[i] = b[j]
  a[i] += b[j]
  print(a[i])
  if a[0]:
      print("false")
  x2:list[str] = ["a", "b", "c"]
  s:str = "asdfa"
  strm:str = "new"
  # # if x2[0] > x2[1]:
  # #     print("True")
  li:list[int] = [1, 2, 3]

  print(b[1])

  obj:B = B(-10)
  print(foo2_int(1, 2))
  x:int = obj.foo2_int(4,5)
  print(x)
  ac:int = 4 + 5
  ab:int = 5
  c:int = ab + 43

  # p:int = foo(ac, c, 3)
  p:int = obj.foo2_int(ac, c)
  print(p)
  p = obj.foo2_int(4,5)
  print(p)
  p = obj.a
  print(p)
  x = obj.func(0)
  print(x)
  obj.f()
  x= foo5(1, 2,3,4,5,6,7)
  print(x)

main()
