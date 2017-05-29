import vec


type
  Ray* = object
    origin*: Vector3d
    direction*: Vector3d


proc ray*(origin, direction: Vector3d): Ray =
  result.origin = origin
  result.direction = direction

proc point_at_p*(r: Ray, t: float): Vector3d =
  r.origin + r.direction * t
