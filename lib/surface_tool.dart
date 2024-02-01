import 'dart:collection';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class SurfaceTool {
  late List<Vertex> vertices;
  late List<int> indices;

  Color _lastColor = const Color(0xFFFFFFFF);
  final Vector3 _lastNormal = Vector3.zero();
  final Vector2 _lastTexCoord = Vector2.zero();
  Material _lastMaterial = StandardMaterial();

  SurfaceTool() {
    vertices = [];
    indices = [];
  }

  void setColor(Color color) => _lastColor = color;

  void setNormal(Vector3 normal) => _lastNormal.setFrom(normal);

  void setTexCoord(Vector2 texCoord) => _lastTexCoord.setFrom(texCoord);

  void setMaterial(Material material) {
    _lastMaterial = material;
  }

  void addTriangleFan(
    List<Vector3> vertices,
    List<Vector2> texCoords, [
    List<Vector3> normals = const [],
    List<Color> colors = const [],
    // TODO(wolfen): support tangents
  ]) {
    assert(vertices.length == 3, 'Expected a length of 3 for vertices');

    void addPoint(int n) {
      if (texCoords.length > n) {
        setTexCoord(texCoords[n]);
      }
      if (colors.length > n) {
        setColor(colors[n]);
      }
      if (normals.length > n) {
        setNormal(normals[n]);
      }
      // TODO(wolfen): tangents
      addVertex(vertices[n]);
    }

    for (int i = 0; i < vertices.length - 2; i++) {
      addPoint(0);
      addPoint(i + 1);
      addPoint(i + 2);
    }
  }

  void addVertex(Vector3 position) {
    final vertex = Vertex(
      position: position,
      texCoords: _lastTexCoord,
      normal: _lastNormal,
      color: _lastColor,
    );

    vertices.add(vertex);
  }

  void addIndex(int index) {
    indices.add(index);
  }

  void index() {
    if (indices.isNotEmpty) {
      return;
    }

    final indexMap = HashMap<Vertex, int>();
    final oldVertices = List.from(vertices);
    vertices.clear();

    for (final vertex in oldVertices) {
      int? idx = indexMap[vertex];
      if (idx == null) {
        idx = indexMap.length;
        vertices.add(vertex);
        indexMap[vertex] = idx;
      }
      indices.add(idx);
    }
  }

  void apply(Geometry geometry) {
    index();

    geometry.setVertices(vertices);
    geometry.setIndices(indices);
  }
}
