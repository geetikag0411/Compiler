def fact(n:int) -> int:
	if not n:
		print(not n)
		# print(~n)
		return 1
	
	if n < 3:
		return n
	
	return n * fact(n - 1)

def main():
	i:int = 0

	for i in range(10):
		if i==3:
			continue
		print(i)
		if i == 4:
			break
	print(i)
	i += 1
	while i < 10:
		print(i + 1)
		if i == 7:
			print(i)
			i += 2
			if i:
				continue
		i += 1

	if False ^ True:
		print(123)
	i=8
	a:list[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	x: int = a[0] -1
	print(x)
	print(a[i]-1)

	for i in range(2, 10):
		if i == 5:
			continue
			print(i)
		print((a[i]-1))
		print(a[i]-1)

	print(fact(6))
	num:int = 64 // 17
	print(num)
	print(i)

main()
