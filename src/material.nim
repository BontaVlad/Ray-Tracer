import math

import ray
import geometry
import vec
import util
import ray


type
  Material* = ref object of RootObj
    albedo*: Vector3d

  Lambertian* = ref object of Material

  Metal* = ref object of Material
    fuzz*: float

  Dielectric* = ref object of Material
    ref_idx*: float

  HitRecord* = object
    t*: float
    p*: Vector3d
    normal*: Vector3d
    material*: Material


proc newHitRecord*(t=0.0, p=vector3d(0.0, 0.0, 0.0), normal=vector3d(0.0, 0.0, 0.0)): HitRecord {.inline.}=
  result = HitRecord()
  result.t = t
  result.p = p
  result.normal = normal


proc newLambertian*(a: Vector3d): Lambertian =
  result = new(Lambertian)
  result.albedo = a


proc newMetal*(a: Vector3d, fuzz = 1.0): Metal =
  result = new(Metal)
  result.albedo = a
  result.fuzz = abs(fuzz).clamp(0, 1)

proc newDielectric*(ref_idx: float): Dielectric =
  result = new(Dielectric)
  result.ref_idx = ref_idx


proc hit*(m: Material, ray: Ray, t_min, t_max: float, hit_record: var HitRecord): bool =
  result = false


proc reflect(v, n: Vector3d): Vector3d =
  result = v - n * 2 * dot(v, n)


proc refract(v, n: Vector3d, ni_over_nt: float, refracted: var Vector3d): bool =
  let
    uv = v.unit
    dt = dot(uv, n)
    discriminant = 1.0 - ni_over_nt * ni_over_nt * (1 - dt * dt)
  if discriminant > 0:
    refracted = (uv - (n * dt)) * ni_over_nt - (n * sqrt(discriminant))
    return true
  else:
    return false

proc schlick(cosine, ref_idx: float): float =
  let
    r0 = (1-ref_idx) / (1+ref_idx)
    r1 = r0 * r0
  result = r1 + (1-r1) * pow((1-cosine), 5)

method scatter*(met: Material, ray_in: Ray, record: var HitRecord, attenuation: var Vector3d, scattered: var Ray): bool {.base.} =
  quit "sould overwride"


method scatter*(lm: Lambertian, ray_in: Ray, record: var HitRecord, attenuation: var Vector3d, scattered: var Ray): bool =
  let target = record.p + record.normal + random_in_unit_sphere()
  scattered = ray(record.p, target-record.p)
  attenuation = lm.albedo
  return true


method scatter*(m: Metal, ray_in: Ray, record: var HitRecord, attenuation: var Vector3d, scattered: var Ray): bool =
  let
    reflected = reflect(ray_in.direction.unit, record.normal)
  scattered = ray(record.p, reflected + random_in_unit_sphere() * m.fuzz)
  attenuation = m.albedo
  result = dot(scattered.direction, record.normal) > 0


method scatter*(d: Dielectric, ray_in: Ray, record: var HitRecord, attenuation: var Vector3d, scattered: var Ray): bool =
  let
    reflected = reflect(ray_in.direction, record.normal)

  var
    outward_normal: Vector3d
    ni_over_nt: float
    refracted: Vector3d
    reflected_prob: float
    cosine: float

  attenuation = vector3d(1.0, 1.0, 0.0)

  if dot(ray_in.direction, record.normal) > 0:
    outward_normal = -record.normal
    ni_over_nt = d.ref_idx
    cosine = d.ref_idx * dot(ray_in.direction, record.normal) / ray_in.direction.len
  else:
    outward_normal = record.normal
    ni_over_nt = 1.0 / d.ref_idx
    cosine = -dot(ray_in.direction, record.normal) / ray_in.direction.len

  if refract(ray_in.direction, outward_normal, ni_over_nt, refracted):
    reflected_prob = schlick(cosine, d.ref_idx)
  else:
    scattered = ray(record.p, reflected)
    reflected_prob = 1.0
  if drand48() < reflected_prob:
    scattered = ray(record.p, reflected)
  else:
    scattered = ray(record.p, refracted)
  return true
