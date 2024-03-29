class Calculator {
    int add(int x, int y,int z) {
        int result = x + y;
        return result;
    }
}

public class test_7{
    public static void main(String[] args) {
        Calculator calc = new Calculator();
        int x = 5;
        int y = 3;
        int result = calc.add(x, y,8);
    }
}
