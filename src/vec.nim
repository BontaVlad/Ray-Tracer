import math
import strfmt


type
  Vector3d* = object
    x*, y*, z*: float

proc vector3d*(x, y, z: float): Vector3d {.inline.}=
  result.x = x
  result.y = y
  result.z = z

proc len*(v: Vector3d): float =
  sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

proc `$` *(v: Vector3d): string =
  "[x: {}, y: {}, z: {}]".fmt(v.x, v.y, v.z)

proc `+` *(v1, v2: Vector3d): Vector3d {.inline.} =
  result.x = v1.x + v2.x
  result.y = v1.y + v2.y
  result.z = v1.z + v2.z

proc `+=`*(u: var Vector3d, v: Vector3d): Vector3d {.inline, discardable.} =
  u.x += v.x
  u.y += v.y
  u.z += v.z

proc `/=`*(u: var Vector3d, f: float): Vector3d {.inline, discardable.} =
  u.x /= f
  u.y /= f
  u.z /= f

proc `-` *(v1, v2: Vector3d): Vector3d {.inline.} =
  result.x = v1.x - v2.x
  result.y = v1.y - v2.y
  result.z = v1.z - v2.z

proc `-` *(v: Vector3d): Vector3d {.inline.} =
  result.x = -v.x
  result.y = -v.y
  result.z = -v.z

proc `*` *(v1, v2: Vector3d): Vector3d {.inline.} =
  result.x = v1.x * v2.x
  result.y = v1.y * v2.y
  result.z = v1.z * v2.z

proc `*` *(v: Vector3d, n: float): Vector3d {.inline.} =
  result.x = v.x * n
  result.y = v.y * n
  result.z = v.z * n

proc `/` *(v1, v2: Vector3d): Vector3d {.inline.} =
  result.x = v1.x / v2.x
  result.y = v1.y / v2.y
  result.z = v1.z / v2.z

proc `/` *(v1: Vector3d, n: float): Vector3d {.inline.} =
  result.x = v1.x / n
  result.y = v1.y / n
  result.z = v1.z / n

proc dot*(u, v: Vector3d): float {.inline.} =
  (u.x * v.x) + (u.y * v.y) + (u.z * v.z)

proc cross*(u, v: Vector3d): Vector3d {.inline.} =
  result.x = (u.y * v.z) - (u.z * v.y)
  result.y = -((u.x * v.z) - (u.z * v.x))
  result.z = (u.x * v.y) - (u.y * v.x)

proc unit*(v: Vector3d): Vector3d {.inline.} =
  v / v.len
