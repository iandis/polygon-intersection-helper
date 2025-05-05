import 'package:polygon_intersection/polygon_intersection.dart';
import 'package:test/test.dart';
import 'dart:math';

// Helper to convert raw coordinate arrays to List<Point<double>>
List<Point<double>> toPoints(List<List<double>> raw) => raw.map((p) => Point<double>(p[0], p[1])).toList();

class PolygonTestCase {
  const PolygonTestCase({
    required this.description,
    required this.polygon1,
    required this.polygon2,
    required this.expected,
  });

  final String description;
  final List<List<double>> polygon1;
  final List<List<double>> polygon2;
  final bool expected;
}

void main() {
  group('checkIfPolygonsIntersect', () {
    final testCases = <PolygonTestCase>[
      PolygonTestCase(
        description: 'should intersect: triangle over square center',
        polygon1: [
          [0, 0],
          [1, 0],
          [1, 1],
          [0, 1]
        ],
        polygon2: [
          [0, -1],
          [2, 0.5],
          [0, 2]
        ],
        expected: true,
      ),
      PolygonTestCase(
        description: 'should intersect: triangle clipping square edge',
        polygon1: [
          [0, 0],
          [1, 0],
          [1, 1],
          [0, 1]
        ],
        polygon2: [
          [0.5, -1],
          [2, 0.5],
          [0.5, 2]
        ],
        expected: true,
      ),
      PolygonTestCase(
        description: 'should not intersect: triangle outside square',
        polygon1: [
          [0, 0],
          [1, 0],
          [1, 1],
          [0, 1]
        ],
        polygon2: [
          [1, -1],
          [2, 0.5],
          [1, 2]
        ],
        expected: false,
      ),
      PolygonTestCase(
        description: 'should intersect: small triangle inside square',
        polygon1: [
          [0, 0],
          [3, 0],
          [3, 3],
          [0, 3]
        ],
        polygon2: [
          [1, 1],
          [2, 1.5],
          [1, 2]
        ],
        expected: true,
      ),
      PolygonTestCase(
        description: 'should not intersect: both polygons empty',
        polygon1: [],
        polygon2: [],
        expected: false,
      ),
    ];

    for (final testCase in testCases) {
      test(testCase.description, () {
        final p1 = toPoints(testCase.polygon1);
        final p2 = toPoints(testCase.polygon2);
        expect(PolygonUtils.checkIfPolygonsIntersect(p1, p2), testCase.expected);
      });
    }
  });
}
