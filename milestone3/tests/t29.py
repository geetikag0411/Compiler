def func(x:int)->list[int]:
    new_lint: list[int] = [x,x+1,x+2]
    return new_lint

class a():
    def __init__(self,x:int):
        self.new_lint: list[int] = func(x);

def spawn_obj(b:int)->a:
    obj : a = a(b)
    return obj
    
class b(a):
    def __init__(self,x:int):
        self.new_lint = func(x)

    def return_a_list(self, d : bool)->list[a]:        
        if(d == True):
            obj:list[a] = [spawn_obj(1),spawn_obj(2),spawn_obj(3)]
        else:
            obj = [spawn_obj(4),spawn_obj(5),spawn_obj(6)]
        return obj

def main():
    a1: a = a(1)
    print(a1.new_lint[0])
    a2 :list[int] = a1.new_lint
    a3 :list[int] = func(1)
    b1: b = b(1)
    a4 :list[a] = b1.return_a_list(True)
    a5 :list[a] = b1.return_a_list(False)
    
    if(a5[0].new_lint[0] == a4[0].new_lint[1]):
        print("a1 and a3 are equal")
    else:
        print("a1 and a3 are not equal")

main()
