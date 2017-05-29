import random
import vec


template doWhile*(a, b: untyped): untyped =
  b
  while a:
    b

# Produced a random number between [0, 1)
proc drand48*: float {.inline} =
  return random(1.0)

proc random_in_unit_sphere*: Vector3d {.inline.} =
  var p: Vector3d
  doWhile(dot(p, p) >= 1.0):
    p = vector3d(drand48(), drand48(), drand48()) * 2.0 - vector3d(1.0, 1.0, 1.0)
  return p
