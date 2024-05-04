class GrandParent:
  def __init__(self):
    self.a:bool = False

  def show(self, num:int) -> bool:
    print("Hi")
    print(num)
    print(self.a)
    return self.a

  # def show(self) -> bool:
  #   print("Hi")
  #   return self.a


class Parent(GrandParent):
  def __init__(self, num:int):
    self.num:int = num
    self.a = True

  def ret_grand_parent(self) -> list[GrandParent]:
    g1:GrandParent = GrandParent()
    g2:GrandParent = GrandParent()
    g3:GrandParent = GrandParent()
    g4:GrandParent = GrandParent()
    ans:list[GrandParent]=[g1, g2, g3, g4]
    return ans


class Child(Parent):
  def __init__(self, name:str, num:int, b:bool):
    self.num = num
    self.name: str = name
    self.a = b

  def ret_parent(self) -> list[Parent]:
    p1:Parent = Parent(1)
    p2:Parent = Parent(2)
    p3:Parent = Parent(3)
    p4:Parent = Parent(4)
    p5:Parent = Parent(5)
    p6:Parent = Parent(6)
    p7:Parent = Parent(7)
    p8:Parent = Parent(8)
    p9:Parent = Parent(9)
    p10:Parent = Parent(10)

    obj:list[Parent] = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
    print(obj[9].num)
    return obj
  
  def ret_parent2(self) -> list[int]:
    p1:Parent = Parent(1)
    p2:Parent = Parent(2)
    p3:Parent = Parent(3)
    p4:Parent = Parent(4)
    p5:Parent = Parent(5)
    p6:Parent = Parent(6)
    p7:Parent = Parent(7)
    p8:Parent = Parent(8)
    p9:Parent = Parent(9)
    p10:Parent = Parent(10)

    obj:list[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    return obj
  
  def display(self) -> None:
    print(self.name)
    print(self.num)
  

def main():
  p1:Parent = Parent(1)
  p2:Parent = Parent(2)
  p3:Parent = Parent(3)
  p4:Parent = Parent(4)
  p5:Parent = Parent(5)
  p6:Parent = Parent(6)
  p7:Parent = Parent(7)
  p8:Parent = Parent(8)
  p9:Parent = Parent(9)
  p10:Parent = Parent(10)
  print(p2.num)
  obj:list[Parent] = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
  # obj:list[Parent] = [p1, p2]
  print(obj[9].num)
  c:Child = Child("Yello", 100, True)
  lis:list[Parent] = c.ret_parent()
  obj2:Parent = lis[9]
  # lis: list[Parent] = c.ret_parent()
  # print(len(lis))
  obj3: Parent = lis[9]
  print(obj3.num)
  print(c.ret_parent()[9].num)
  # print(c.ret_parent()[3].ret_grand_parent()[1].show())
  print(c.ret_parent()[3].ret_grand_parent()[1].show(5))
  print(c.ret_parent()[3].ret_grand_parent()[1].show(c.ret_parent()[9].num))
  print(obj[3].show(1))
  c.display()

if __name__ == "__main__":
  main()
