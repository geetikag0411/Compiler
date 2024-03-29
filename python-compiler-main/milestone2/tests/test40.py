i : int = 8
a: int = 9
def func():
    global a
    while(a>0):
        a+=1
        print(i)
func()
