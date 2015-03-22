# normal test
number = 42
opposite = true
number = -42 if opposite

# if test
score = 83
grade = switch
  when score < 80 then 'C'
  when score < 90 then 'B'
  else 'A'

# object,for,function test
square = (x) -> x * x
list = [1]
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
cubes = (math.cube num for num in list)
