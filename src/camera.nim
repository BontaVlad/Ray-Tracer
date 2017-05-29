import math

import ray
import vec
import util


type
  Camera* = object
    lower_left_corner*: Vector3d
    horizontal*: Vector3d
    vertical*: Vector3d
    origin*: Vector3d
    lens_radius*: float
    u, v, w: Vector3d


proc random_in_unit_disk: Vector3d =
  var p: Vector3d
  doWhile dot(p, p) >= 1.0:
    p = vector3d(drand48(), drand48(), 0.0) * 2 - vector3d(1.0, 1, 0)
  return p


proc newCamera*(lookfrom, lookat, vup: Vector3d, vfov, aspect, aperture, focus_dist: float): Camera =
  let
    theta = vfov * (PI / 180)
    half_height = tan(theta / 2)
    half_width = aspect * half_height

  result.origin = lookfrom
  result.lens_radius = aperture / 2
  result.w = unit(lookfrom - lookat)
  result.u = unit(cross(vup, result.w))
  result.v = cross(result.w, result.u)
  result.lower_left_corner = result.origin - (result.u * half_width * focus_dist) -
                            (result.v * half_height * focus_dist) -
                            (result.w * focus_dist)
  result.horizontal = result.u * 2 * half_width * focus_dist
  result.vertical = result.v * 2 * half_height * focus_dist

proc ray*(camera: Camera, s, t: float): Ray =
  let
    rd = random_in_unit_disk() * camera.lens_radius
    offset = camera.u * rd.x + camera.v * rd.y
    direction = camera.lower_left_corner + camera.horizontal * s + camera.vertical * t - camera.origin - offset
  result = ray(camera.origin + offset, direction)
