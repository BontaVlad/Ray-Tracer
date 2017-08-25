import math
import random

from vectors import Vector
from ray import Ray


def random_in_unit_disk():
    p = Vector(random.random(), random.random(), 0.0) * 2 - Vector(1.0, 1.0)
    while p.dot(p) >= 1.0:
        p = Vector(random.random(), random.random(), 0.0) * 2 - Vector(1.0, 1.0)
    return p


class Camera(object):

    def __init__(self, lookfrom, lookat, vup, vfov, aspect, aperture, focus_dist):
        theta = vfov * (math.pi / 180)
        half_height = math.tan(theta / 2)
        half_width = aspect * half_height

        self.origin = lookfrom
        self.lens_radius = aperture / 2
        self.w = Vector.unit(lookfrom - lookat)
        self.u = Vector.unit(vup.cross(self.w))
        self.v = self.w.cross(self.u)
        self.lower_left_corner = self.origin - (self.u * half_width * focus_dist) - (self.v * half_height * focus_dist) - (self.w * focus_dist)
        self.horizontal = self.u * 2 * half_width * focus_dist
        self.vertical = self.v * 2 * half_height * focus_dist

    def ray(self, s, t):
        rd = random_in_unit_disk() * self.lens_radius
        offset = self.u * rd.x + self.v * rd.y
        direction = self.lower_left_corner + self.horizontal * s + self.vertical * t - self.origin - offset

        return Ray(self.origin + offset, direction)
