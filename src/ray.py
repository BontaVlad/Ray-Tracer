class Ray(object):

    def __init__(self, origin, direction):
        self.origin = origin
        self.direction = direction

    def point_at_p(self, t):
        return self.origin + self.direction * t
