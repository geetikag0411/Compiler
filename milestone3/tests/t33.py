def fib(n:int) -> int:
  if not n:
    return 0
  return n + fib(n-1)

def main():
    print(fib(50000))

if __name__ == "__main__":
	main()
