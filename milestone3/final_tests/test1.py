class Node:
    def __init__(self, v : int):
        self.left : Node \
            = None
        self.right: Node = None
        self.data : int= v
 
def printInorder(root: Node):
    if root:
        printInorder(root.left)
        print(root.data)
        # print(" ")
        printInorder(root.right)

def printPreOrder(node: Node):
    if node == None:
        return
    print(node.data)
    # print(" ")
    printPreOrder(node.left)
    printPreOrder(node.right)  

def printPostOrder(node: Node):
    if node == None:
        return
    printPostOrder(node.left)
    printPostOrder(node.right)
    print(node.data)
    # print(" ")

def main():
    root: Node = Node(10)
    root.left =\
Node(25)
    root.right = Node(30)
    root.left.left = Node(20)
    root.left.right = Node(35)
    root.right.left = Node(15)
    root.right.right = Node(45)
    print("Inorder Traversal:")
    printInorder(root)
    print("\nPreorder Traversal:")
    printPreOrder(root)
    print("\nPostorder Traversal:")
    printPostOrder(root)
    print("\n")

if __name__ == "__main__":
    main()
