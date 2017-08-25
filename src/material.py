import math

from vectors import Vector


def reflect(v, n):
    return v - n * 2 * v.dot(n)


def refract(v, n, ni_over_nt, refracted):
    uv = Vector.unit(v)
    dt = uv.dot(n)
    discriminant = 1.0 - ni_over_nt * ni_over_nt * (1 - dt * dt)
    if discriminant > 0:
        refracted = (uv - (n * dt)) * ni_over_nt - (n * math.sqrt(discriminant))
        return True
    else:
        return False


def schlick(cosine, ref_idx):
    r0 = (1-ref_idx) / (1+ref_idx)
    r1 = r0 * r0
    return r1 + (1-r1) * pow((1-cosine), 5)


class Material(object):

    def __init__(self, albedo):
        self.albedo = albedo

    def hit(self, ray, t_min, t_max, hit_record):
        raise NotImplementedError

    def scatter(self, ray_in, record, attenuation, scattered):
        raise NotImplementedError


class HitRecord(object):

    def __init__(self, t=0.0, p=Vector(0.0, 0.0, 0.0), normal=Vector(0.0, 0.0, 0.0), material=None):
        self.t = t
        self.p = p
        self.normal = normal
        self.material = material


class Lambertian(Material):
    def scatter(self, ray_in, record, attenuation, scattered):
        target = record.p + record.normal + random_in_unit_sphere()
        scattered = ray(record.p, target-record.p)
        attenuation = lm.albedo
        return true


class Metal(Material):

    def __init__(self, a, fuzz=1.0):
        self.albedo = a
        self.fuzz = abs(fuzz)


class Dielectric(Material):

    def __init__(self, ref_idx):
        self.albedo = 0
        self.ref_idx = ref_idx


# method scatter*(m: Metal, ray_in: Ray, record: var HitRecord, attenuation: var Vector3d, scattered: var Ray): bool =
#   let
#     reflected = reflect(ray_in.direction.unit, record.normal)
#   scattered = ray(record.p, reflected + random_in_unit_sphere() * m.fuzz)
#   attenuation = m.albedo
#   result = dot(scattered.direction, record.normal) > 0


# method scatter*(d: Dielectric, ray_in: Ray, record: var HitRecord, attenuation: var Vector3d, scattered: var Ray): bool =
#   let
#     reflected = reflect(ray_in.direction, record.normal)

#   var
#     outward_normal: Vector3d
#     ni_over_nt: float
#     refracted: Vector3d
#     reflected_prob: float
#     cosine: float

#   attenuation = vector3d(1.0, 1.0, 0.0)

#   if dot(ray_in.direction, record.normal) > 0:
#     outward_normal = -record.normal
#     ni_over_nt = d.ref_idx
#     cosine = d.ref_idx * dot(ray_in.direction, record.normal) / ray_in.direction.len
#   else:
#     outward_normal = record.normal
#     ni_over_nt = 1.0 / d.ref_idx
#     cosine = -dot(ray_in.direction, record.normal) / ray_in.direction.len

#   if refract(ray_in.direction, outward_normal, ni_over_nt, refracted):
#     reflected_prob = schlick(cosine, d.ref_idx)
#   else:
#     scattered = ray(record.p, reflected)
#     reflected_prob = 1.0
#   if drand48() < reflected_prob:
#     scattered = ray(record.p, reflected)
#   else:
#     scattered = ray(record.p, refracted)
#   return true
