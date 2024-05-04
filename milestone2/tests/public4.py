def binarySearch(array:list[int], x: int, low: int, high: int) -> int:
  while low <= high:
    mid: int = low + (high - low) // 2
    if array[mid] == x:
      return mid
    elif array[mid] < x:
      he:int=5
      low = mid + 1
    else:
      high = mid - 1
  return -1


def main():
  (7,8,9)
  array2:list[int] = [1,(2)]
  array:list[int]= [3, (array2[1]), (12<<2), 6//3*1.9, 7, 8, 9]
  result:int = binarySearch(array, 4, 0, len(array) - 1)

  if result != -1:
    print("Element is present at index:")
    print(result)
  else:
    print("Element is not present")


if __name__ == "__main__":
  main()
