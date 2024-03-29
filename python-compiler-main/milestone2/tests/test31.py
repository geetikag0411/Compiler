#
#   is_print_function print ki function body match hone ke baad false ho rha hai.
#   but uske argument mein koi function aa gya to usme bhi is_print_function true rahega
#   to isme bhi shayad stack hi banana padega T_T
#

def good(a: float,b:bool,c:int)->int :
    # a:int 0
    # b:int 4
    if 1<2:
        return a*2
    else:
        a+=1
    return 1

print(good(1,1,1))
# print(good(2))
# print(3)

# class parent:
#     def __init__(self):
#         print("parent init")
#     def show(self) -> None:
#         print("parent show")
# class child(parent):
#     def __init__(self):
#         print("child init")
#     def good(self, x: int) -> None:
#         print("child show")
# c : child = child()
# c.show()             # call function 
# a:parent = child()
# b:child = a
# a:int =  1
# b:int = a + 1


# b=a+1

# a : child = child()  
# b:child = child()
# a.good(5)
# b = a
# i : int = 4
# for i in range(10):
#     print(i)
# a poppapam
#... b popparam
# ... b = a
