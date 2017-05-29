import math

import vec
import ray
import material


type
  Sphere* = ref object
    center*: Vector3d
    radius*: float
    material*: Material

  AnyHitable* {.explain.} = concept h
    hit(h, Ray, float, float, var HitRecord) is bool

  HitableList*[AnyHitable] = seq[AnyHitable]


proc newSphere*(center: Vector3d, radius: float, mat: Material): Sphere =
  result = Sphere()
  result.center = center
  result.radius = radius
  result.material = mat

proc hit*(s: Sphere, ray: Ray, t_min, t_max: float, rec: var HitRecord): bool =
  let
    oc = ray.origin - s.center
    a = dot(ray.direction, ray.direction)
    b = dot(oc, ray.direction)
    c = dot(oc, oc) - s.radius * s.radius
    discriminant  = b * b - a * c

  if discriminant > 0:
    var temp = (-b - sqrt(b * b - a * c)) / a
    if temp < t_max and temp > t_min:
      rec.t = temp
      rec.p = ray.point_at_p(rec.t)
      rec.normal = (rec.p - s.center) / s.radius
      rec.material = s.material
      return true
    temp = (-b + sqrt(b*b-a*c))/a
    if temp < t_max and temp > t_min:
      rec.t = temp
      rec.p = ray.point_at_p(rec.t)
      rec.normal = (rec.p - s.center) / s.radius
      rec.material = s.material
      return true
  return false

proc hit*(list: HitableList, ray: Ray, t_min, t_max: float, record: var HitRecord): bool =
  var
    temp_rec = newHitRecord()
    hit_anything = false
    closest_so_far = t_max

  for e in list:
    if e.hit(ray, t_min, closest_so_far, temp_rec):
      hit_anything = true
      closest_so_far = temp_rec.t
      record = temp_rec
  return hit_anything
