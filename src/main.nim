import math

import stb_image/write as stbiw
import progress

import vec
import ray
import geometry
import camera
import util
import material



proc random_scene(): HitableList[Sphere] =
  let
    vec_point = vector3d(4.0, 0.2, 0)

  var
    world = HitableList[Sphere](@[
      newSphere(vector3d(0.0, -1000.0, 0.0), 1000.0, newLambertian(vector3d(0.5, 0.5, 0.5))),
      newSphere(vector3d(0.0, 1.0, 0.0), 1.0, newDielectric(1.5)),
      newSphere(vector3d(-4.0, 1.0, 0.0), 1.0, newLambertian(vector3d(0.4, 0.2, 0.1))),
      newSphere(vector3d(4.0, 1.0, 0.0), 1.0, newMetal(vector3d(0.7, 0.6, 0.5), 0.0))
    ])
    center: Vector3d
    chose_mat: float

  for a in -11 .. 11:
    for b in -11 .. 11:
      chose_mat = drand48()
      center = vector3d(a.float + 0.9 * drand48(), 0.2, b.float + 0.9 * drand48())
      if (center - vec_point).len > 0.9:
        if chose_mat < 0.8:
          let color = vector3d(drand48() * drand48(), drand48() * drand48(), drand48() * drand48())
          world.add(newSphere(center, 0.2, newLambertian(color)))
        elif chose_mat < 0.95:
          let color = vector3d(0.5 + (1 + drand48()), 0.5 * (1 + drand48()), 0.5 * (1 + drand48()))
          world.add(newSphere(center, 0.2, newMetal(color, 0.5 * drand48())))
        else:
          world.add(newSphere(center, 0.2, newDielectric(1.5)))
  return world


proc color(r: var Ray, world: HitableList, depth: int): Vector3d =
  var
    record = newHitRecord()
  if world.hit(r, 0.001, Inf, record):
    var
      scattered: Ray
      attenuation: Vector3d
    if depth < 50 and record.material.scatter(r, record, attenuation, scattered):
      return attenuation * color(scattered, world, depth+1)
    else:
      return vector3d(0.0, 0.0, 0.0)
  else:
    let
      t = (r.direction.unit.y + 1.0) * 0.5
    return vector3d(1.0, 1.0, 1.0) * (1.0-t) + vector3d(0.5, 0.7, 1.0) * t


proc main =
  let
    nx = 800
    ny = 600
    ns = 100
    lookfrom = vector3d(13.0, 2.0, 3.0)
    lookat = vector3d(0.0, 0.0, 0.0)
    dist_to_focus = 10.0
    aperture = 0.1
    cam = newCamera(lookfrom, lookat, vector3d(0.0, 1.0, 0.0), 20, float(nx)/float(ny), aperture, dist_to_focus)

  var
    data: seq[uint8] = @[]
    # world = HitableList[Sphere](@[
    #   newSphere(vector3d(0.0, 0.0, -1.0), 0.5, newLambertian(vector3d(0.1, 0.2, 0.5))),
    #   newSphere(vector3d(0.0, -100.5, -1.0), 100.0, newLambertian(vector3d(0.8, 0.8, 0.0))),
    #   newSphere(vector3d(1.0, 0.0, -1.0), 0.5, newMetal(vector3d(0.8, 0.6, 0.2), 0.0)),
    #   newSphere(vector3d(-1.0, 0.0, -1.0), 0.5, newDielectric(1.5)),
    #   newSphere(vector3d(-1.0, 0.0, -1.0), -0.45, newDielectric(1.5)),
    # ])
    world = random_scene()
    bar = newProgressBar(total=nx*ny*ns)


  for j in countdown(ny-1, 0):
    for i in countup(0, nx-1):
      var col = vector3d(0.0, 0.0, 0.0)
      for s in countup(0, ns-1):
        let
          u = (i.float + drand48()) / nx.float
          v = (j.float + drand48()) / ny.float
        var r = cam.ray(u, v)
        col += color(r, world, 0)
        bar.increment()

      col /= ns.float
      data.add((255.99 * sqrt(col.x)).uint8.clamp(0, 255))
      data.add((255.99 * sqrt(col.y)).uint8.clamp(0, 255))
      data.add((255.99 * sqrt(col.z)).uint8.clamp(0, 255))


  bar.finish()
  stbiw.writePNG("test.png", nx, ny, stbiw.RGB, data)

when isMainModule:
  main()
