# x:int=1
# def fn()->int:
# 	x=2

# fn()

# def func()->None:
#     b : int = a
# a : int = 5
# func()


# def func(a : bool, b : float)-> int:
# 	return 1

# class example:
# 	def __init__(self, c : int, d : int):
# 		self.c : int = c
# 		self.d : int = d

# obj : example = example(3, 4)

# def add(a:int , b:int , c:int)->None:
# 	return a+b+c
# add(2, 3.5, True)

# # f : int = func(2 * 3, 6 + obj.c) # here obj.c is an attribute

# a : list[int] = [1.3, True, 5] 

class InnerClass:
    
    def __init__(self, b:str):
        self.b : str = b

class OuterClass:
    
    def __init__(self, a:InnerClass):
        self.a : InnerClass = a  # a is an instance of InnerClass

    def show(self) -> None:
        print(self.a.b)  # Accessing the b attribute of the object stored in a

# Creating an instance of InnerClass
inner_instance : InnerClass = InnerClass("Hello")

# Creating an instance of OuterClass, passing the instance of InnerClass
outer_instance:OuterClass = OuterClass(inner_instance)

# Calling the show method, which prints the value of self.a.b
outer_instance.show()  # Outputs: Hello
