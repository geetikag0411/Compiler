class Shape:
    def __init__(self, id: str):
        self.id: str = id

    def print_id(self) -> None:
        print("id")
        print(self.id)


class Polygon(Shape):
    def __init__(self, id: str, sides: int):
        self.id = id
        self.sides: int = sides
    
    def print_sides(self) -> None:
        print("Sides:")
        print(self.sides)

    

class Triangle(Polygon):
    def __init__(self, id: str, side1: int, side2: int, side3: int):
        self.id = id
        self.sides = 3
        self.side1: int = side1
        self.side2: int = side2
        self.side3: int = side3
    
    def perimeter(self) -> int:
        return self.side1 + self.side2 + self.side3
    
    def display_info(self):
        self.print_id()
        self.print_sides()
        print("Perimeter:")
        print(self.perimeter())


class Rectangle(Polygon):
    def __init__(self, id: str, width: int, height: int):
        self.id = id
        self.sides = 4
        self.width: int = width
        self.height: int = height
    
    def area(self) -> int:
        return self.width * self.height
    
    def perimeter(self) -> int:
        return 2 * (self.width + self.height)
    
    def display_info(self):
        self.print_id()
        self.print_sides()
        print("Perimeter:")
        print(self.perimeter())
        print("Area:")
        print(self.area())


def main():
    triangle: Triangle = Triangle("t1", 3, 4, 5)
    triangle.display_info()
    print("")
    rectangle: Rectangle = Rectangle("r1", 6, 8)
    rectangle.display_info()

main()
