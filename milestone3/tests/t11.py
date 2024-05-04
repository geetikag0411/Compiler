class ShiftReduceParser:

  def __init__(self, name: str):
    self.srname: str = name

class LR0Parser(ShiftReduceParser):

  def __init__(self, myname: str, parentname_: str):
    self.srname = parentname_
    self.lr0name: str = myname


class CLRParser(ShiftReduceParser):

  def __init__(self, myname: str, parentname_: str):
    self.srname = parentname_
    self.clrname: str = myname


class LALRParser(CLRParser):

  def __init__(self, myname: str, clrname_: str, srname_: str):
    self.srname = srname_
    self.clrname = clrname_
    self.lalrname: str = myname
  def print_name(self):
    print(self.lalrname)



def main():
    obj: ShiftReduceParser = ShiftReduceParser("hellp")
    obj1: LALRParser = LALRParser("LALR", "CLR", "Shift-Reduce")
    obj1.print_name()

    obj2: LALRParser = LALRParser("Early", "Universal", "Generic")
    obj2.print_name()

    obj2 = obj1
    obj2.print_name()


# if __name__ == "_main_":
main()
