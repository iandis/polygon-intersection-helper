import 'dart:math';

import 'package:polygon_intersection/src/polygon_intersection_checker_helper.dart';

typedef Polygon = List<Point<double>>;

abstract final class PolygonUtils {
  static bool checkIfPolygonsIntersect(
    Polygon polygon1,
    Polygon polygon2,
  ) {
    return PolygonIntersectionCheckerHelper.checkIfPolygonEdgesIntersectAnyEdge(polygon1, polygon2) ||
        (PolygonIntersectionCheckerHelper.checkIfPolygonInteriorContainsAnyPoint(polygon1, polygon2) ||
            PolygonIntersectionCheckerHelper.checkIfPolygonInteriorContainsAnyPoint(polygon2, polygon1)) ||
        (PolygonIntersectionCheckerHelper.checkIfPolygonEdgesIntersectAnyCorner(polygon1, polygon2) ||
            PolygonIntersectionCheckerHelper.checkIfPolygonEdgesIntersectAnyCorner(polygon2, polygon1));
  }
}
