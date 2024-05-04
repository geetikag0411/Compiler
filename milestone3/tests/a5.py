class Class1:
    def __init__(self, value: int):
        self.value : int = value

    def function1(self) -> int:
        self.result: int = 0
        i : int = 0
        for i in range(self.value):
            if i % 2 == 0:
                self.result += i
            else:
                self.result -= i
        return self.result

    def function2(self) -> int:
        output : int = 0
        i: int = 0
        for i in range(self.value):
            if i < 5:
                output += i
            else:
                output += -i
        return output

    def function3(self) -> bool:
        i : int = 0
        for i in range(self.value):
            if i == 0:
                return True
        return False


class Class2:
    def __init__(self, obj: Class1):
        self.obj_1 : Class1 = obj

    def function1(self) -> int:
        result: int = 0
        i : int = 0
        for i in range(self.obj_1.value):
            if i % 3 == 0:
                result += i
            else:
                result -= i
        return result

    def function2(self) -> int:
        output: int = 0
        i : int = 0
        for i in range(self.obj_1.value):
            if i < 10:
                output += (i)
            else:
                output += (-i) 
        return output

    def function3(self) -> bool:
        i : int = 0
        for i in range(self.obj_1.value):
            if i == 0:
                return True
        return False


def fn() -> None:
    x: int = 0 
    y: int = 0
    return


class Class3:
    def sample(self) -> None:
        return

    def __init__(self, obj: Class2):
        self.obj_2 : Class2 = obj

    def function1(self) -> int:
        result: int = 0
        i : int = 0
        for i in range(self.obj_2.obj_1.value):
            if i % 4 == 0:
                result += i
            else:
                result -= i
        return result

    def function2(self) -> int:
        output: int = 0
        i : int = 0 
        for i in range(self.obj_2.obj_1.value):
            if i < 15:
                output += (i)
            else:
                output += (i)
        return output

    def function3(self) -> bool:
        i : int = 0
        for i in range(self.obj_2.obj_1.value):
            if i == 0:
                return True
        return False


# # Example usage
def main():
    obj1 : Class1 = Class1(10)
    obj2 : Class2 = Class2(obj1)
    obj3 : Class3 = Class3(obj2)

    print(obj1.function1())  # Example function call
    print(obj2.function2())  # Example function call
    print(obj3.function3())  # Example function call

    print(obj3.obj_2.obj_1.function1())  # Example function call

main()
