import 'dart:math';

class PolygonIntersectionCheckerHelper {
  static bool checkIfPolygonEdgesIntersectAnyEdge(List<Point<double>> polygon1, List<Point<double>> polygon2) {
    for (int i = 0; i < polygon1.length; i++) {
      var a = polygon1[i];
      var b = polygon1[(i + 1) % polygon1.length];
      for (int j = 0; j < polygon2.length; j++) {
        var c = polygon2[j];
        var d = polygon2[(j + 1) % polygon2.length];
        if (checkIfEdgeIntersectsEdge(a, b, c, d)) return true;
      }
    }
    return false;
  }

  static bool checkIfEdgeIntersectsEdge(Point<double> a, Point<double> b, Point<double> c, Point<double> d) {
    if (!checkIfLinesAreParallel(a, b, c, d)) {
      return checkIfNonParallelLineSegmentInteriorsIntersect(a, b, c, d);
    }
    return false;
  }

  static bool checkIfLinesAreParallel(Point<double> a, Point<double> b, Point<double> c, Point<double> d) {
    double det = (b.x - a.x) * (d.y - c.y) - (d.x - c.x) * (b.y - a.y);
    return det == 0;
  }

  static bool checkIfNonParallelLineSegmentInteriorsIntersect(
    Point<double> a,
    Point<double> b,
    Point<double> c,
    Point<double> d,
  ) {
    double det = (b.x - a.x) * (d.y - c.y) - (d.x - c.x) * (b.y - a.y);
    double lambda = ((d.y - c.y) * (d.x - a.x) + (c.x - d.x) * (d.y - a.y)) / det;
    double gamma = ((a.y - b.y) * (d.x - a.x) + (b.x - a.x) * (d.y - a.y)) / det;
    return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1);
  }

  static bool checkIfPolygonInteriorContainsAnyPoint(List<Point<double>> polygon1, List<Point<double>> polygon2) {
    for (var point in polygon2) {
      if (checkIfPolygonInteriorContainsPoint(polygon1, point)) return true;
    }
    return false;
  }

  static bool checkIfPolygonInteriorContainsPoint(List<Point<double>> polygon, Point<double> point) {
    int numCrossings = 0;
    for (int i = 0; i < polygon.length; i++) {
      var a = polygon[i];
      var b = polygon[(i + 1) % polygon.length];
      if (checkIfPointsAreCollinear([a, b, point])) {
        var axis = {'o': a, 'u': findVersorBetweenPoints(a, b)};
        var coords = convertCollinearPointsTo1D([a, b, point], axis);
        const tol = 0.0001;
        if (coords[0] < coords[2] + tol && coords[2] - tol < coords[1]) return false;
      } else if (checkIfHorizontalLineCrosses(a, b, point)) {
        numCrossings++;
      }
    }
    return numCrossings % 2 == 1;
  }

  static List<double> convertCollinearPointsTo1D(List<Point<double>> points, Map<String, Point<double>> axis) {
    return points.map((p) => dot(vectorBetween(axis['o']!, p), axis['u']!)).toList();
  }

  static bool checkIfHorizontalLineCrosses(Point<double> a, Point<double> b, Point<double> p) {
    const tol = 0.0001;
    bool AyCyBy = ((a.y - tol) < p.y) && ((b.y - tol) > p.y);
    bool ByCyAy = ((a.y - tol) > p.y) && ((b.y - tol) < p.y);
    return (AyCyBy || ByCyAy) && (p.x < ((b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x - tol));
  }

  static bool checkIfPolygonEdgesIntersectAnyCorner(List<Point<double>> polygon1, List<Point<double>> polygon2) {
    for (int i = 0; i < polygon2.length; i++) {
      var corner = [
        polygon2[(i - 1 + polygon2.length) % polygon2.length],
        polygon2[i],
        polygon2[(i + 1) % polygon2.length]
      ];
      if (checkIfPolygonEdgesIntersectCorner(polygon1, corner)) return true;
    }
    return false;
  }

  static bool checkIfPolygonEdgesIntersectCorner(List<Point<double>> polygon, List<Point<double>> corner) {
    const tol = 0.0001;
    for (int i = 0; i < polygon.length; i++) {
      var a = polygon[i];
      var b = polygon[(i + 1) % polygon.length];
      if (checkIfPointsAreCollinear([a, b, corner[1]])) {
        var axis = {'o': a, 'u': findVersorBetweenPoints(a, b)};
        var coords = convertCollinearPointsTo1D([a, b, corner[1]], axis);
        if (coords[0] < coords[2] + tol && coords[2] - tol < coords[1]) {
          List<Point<double>> polyCorner;
          if (areEqual1D(coords[0], coords[2])) {
            polyCorner = [polygon[(i - 1 + polygon.length) % polygon.length], a, b];
          } else if (areEqual1D(coords[1], coords[2])) {
            polyCorner = [a, b, polygon[(i + 2) % polygon.length]];
          } else {
            polyCorner = [a, corner[1], b];
          }
          return checkIfCornersIntersect(polyCorner, corner);
        }
      }
    }
    return false;
  }

  static bool checkIfPointsAreCollinear(List<Point<double>> pts) {
    const tol = 0.0001;
    List<Point<double>> filtered = [pts[0]];
    Point<double>? u;
    for (int i = 1; i < pts.length; i++) {
      if (!filtered.any((p) => areEqual(p, pts[i]))) {
        if (u == null) {
          u = findVersorBetweenPoints(filtered[0], pts[i]);
        } else {
          var v = findVersorBetweenPoints(filtered[0], pts[i]);
          if ((1 - dot(u, v)).abs() >= tol) return false;
        }
        filtered.add(pts[i]);
      }
    }
    return true;
  }

  static bool areEqual1D(double a, double b, [double tol = 0.0001]) => (a - b).abs() < tol;

  static Point<double> vectorBetween(Point<double> a, Point<double> b) => Point(b.x - a.x, b.y - a.y);

  static double dot(Point<double> u, Point<double> v) => u.x * v.x + u.y * v.y;

  static double norm(Point<double> u) => sqrt(u.x * u.x + u.y * u.y);

  static Point<double> unit(Point<double> u) {
    double n = norm(u);
    return Point(u.x / n, u.y / n);
  }

  static Point<double> findVersorBetweenPoints(Point<double> a, Point<double> b) => unit(vectorBetween(a, b));

  static double distance(Point<double> a, Point<double> b) => norm(vectorBetween(a, b));

  static bool areEqual(Point<double> a, Point<double> b, [double tol = 0.0001]) => distance(a, b) < tol;

  static double findCounterClockwiseAngleBetweenVectors(Point<double> u, Point<double> v) {
    u = unit(u);
    v = unit(v);
    double dotProd = dot(u, v);
    double det = u.x * v.y - u.y * v.x;
    return (atan2(det, dotProd) * 180 / pi + 360) % 360;
  }

  static Point<double> rotateVectorCounterClockwise(Point<double> u, double angle) {
    angle = angle * pi / 180;
    return Point(
      u.x * cos(angle) - u.y * sin(angle),
      u.x * sin(angle) + u.y * cos(angle),
    );
  }

  static Point<double> findBisectorVersor(Point<double> u, Point<double> v) {
    double angle = findCounterClockwiseAngleBetweenVectors(u, v);
    return rotateVectorCounterClockwise(u, angle / 2);
  }

  static double findSmallestAngleBetweenVectors(Point<double> u, Point<double> v) {
    return acos(dot(unit(u), unit(v))) * 180 / pi;
  }

  static bool checkIfCornersIntersect(List<Point<double>> corner1, List<Point<double>> corner2) {
    Point<double> v1 = vectorBetween(corner1[1], corner1[0]);
    Point<double> v2 = vectorBetween(corner1[1], corner1[2]);
    double angle1 = findCounterClockwiseAngleBetweenVectors(v2, v1);
    Point<double> bisector1 = findBisectorVersor(v2, v1);

    Point<double> v3 = vectorBetween(corner2[1], corner2[0]);
    Point<double> v4 = vectorBetween(corner2[1], corner2[2]);
    double angle2 = findCounterClockwiseAngleBetweenVectors(v4, v3);
    Point<double> bisector2 = findBisectorVersor(v4, v3);

    double angleBetween = findSmallestAngleBetweenVectors(bisector1, bisector2);
    double maxAngle = angle1 / 2 + angle2 / 2;

    return angleBetween < maxAngle;
  }
}
