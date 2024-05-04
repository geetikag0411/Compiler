class Temp:
  def __init__(self):
    self.a:bool = True

  def show(self, x:list[int]) -> bool:
    return self.a + x[1]


def main():
  li:list[int] = [564, 0, 3]
  obj:Temp = Temp()
#   print(obj.show([1, 2, 3]))

  if li[1]:
    print("IF")
    if 0:
      print("IF-IF")
    elif 1:
      print("IF-ELIF")
    else:
      print("IF-ELSE")
  elif li[0]:
    print("ELIF")
    if 0:
      print("ELIF-IF")
    elif 0:
      print("ELIF-ELIF")
    else:
      print("ELIF-ELSE")
  else:
    print("ELSE")
    if 0:
      print("ELSE-IF")
    elif 1:
      print("ELSE-ELIF")
    else:
      print("ELSE-ELSE")
  # print(obj.show(obj.a))


if __name__ == "__main__":
  main()
