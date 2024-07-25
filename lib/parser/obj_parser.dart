import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:defend_the_donut/surface_tool.dart';

class Face {
  const Face(this.vertex, this.texCoord, this.normal);

  final List<int> vertex;
  final List<int> texCoord;
  final List<int> normal;

  Face.empty()
      : vertex = [],
        texCoord = [],
        normal = [];
}

class ObjParser {
  static Future<Map<String, SpatialMaterial>> _parseMaterial(
    String filePath,
  ) async {
    final lines = (await Flame.assets.readFile(filePath)).split('\n');

    final materials = <String, SpatialMaterial>{};
    SpatialMaterial? currentMat;
    for (final line in lines) {
      final [type, ...parts] = line.split(' ');
      switch (type) {
        // Comment
        case '#':
          continue;
        // Creating a new material
        case 'newmtl':
          currentMat = SpatialMaterial(
            albedoTexture: ColorTexture(const Color(0xFFFFFFFF)),
          );
          materials[parts[0].trim()] = currentMat;
          break;
        // Diffuse color
        case 'Kd':
          currentMat?.albedoColor = Color.fromARGB(
            255,
            (double.parse(parts[0]) * 255).toInt(),
            (double.parse(parts[1]) * 255).toInt(),
            (double.parse(parts[2]) * 255).toInt(),
          );
          break;
      }
    }
    return materials;
  }

  static Future<Mesh> parse(String filePath, {Mesh? applyTo}) async {
    final vertices = <Vector3>[];
    final normals = <Vector3>[];
    final texCoords = <Vector2>[];
    final faces = <String, List<Face>>{};

    final lines = (await Flame.assets.readFile(filePath)).split('\n');

    var matName = 'default';

    final materials = <String, SpatialMaterial>{};
    for (final line in lines) {
      final [type, ...parts] = line.split(' ');

      switch (type) {
        // Comment
        case '#':
          continue;
        // Vertex
        case 'v':
          vertices.add(Vector3.array(parts.map(double.parse).toList()));
          break;
        // Normal
        case 'vn':
          normals.add(Vector3.array(parts.map(double.parse).toList()));
          break;
        // UV
        case 'vt':
          texCoords.add(Vector2.array(parts.map(double.parse).toList()));
          break;
        // Face
        case 'f':
          if (parts.length == 3) {
            // Single triangle

            final face = Face.empty();
            for (final value in parts) {
              final indices = value.split('/');
              face.vertex.add(int.parse(indices[0]) - 1);
              if (indices[1].isNotEmpty) {
                face.texCoord.add(int.parse(indices[1]) - 1);
              }
              if (indices.length > 2) {
                face.normal.add(int.parse(indices[2]) - 1);
              }
            }
            faces[matName]?.add(face);
          } else if (parts.length > 4) {
            // Triangulate
            // TODO(wolfen):
          }
          break;
        // Material library
        case 'mtllib':
          final relative = (filePath.split('/')..removeLast()).join('/');
          materials.addAll(await _parseMaterial('$relative/${parts[0]}'.trim()));
          break;
        // Material
        case 'usemtl':
          matName = parts[0].trim();

          if (!faces.containsKey(matName)) {
            if (!materials.containsKey(matName)) {
              // TODO(wolfen): material not found?
            }
            faces[matName] = [];
          }
          break;
      }
    }

    var mesh = applyTo ?? Mesh();
    for (final materialGroup in faces.keys) {
      final surface = SurfaceTool()..setMaterial(materials[materialGroup]!);

      for (final face in faces[materialGroup]!) {
        if (face.vertex.length == 3) {
          // Vertices
          final fanVertices = [
            vertices[face.vertex[0]],
            vertices[face.vertex[1]],
            vertices[face.vertex[2]],
          ];

          // Tex coords
          final fanTexCoords = <Vector2>[];
          if (face.texCoord.isNotEmpty) {
            for (final k in [0, 2, 1]) {
              final f = face.texCoord[k];
              if (f > -1) {
                final uv = texCoords[f];
                fanTexCoords.add(uv);
              }
            }
          }

          // Normals
          final fanNormals = [
            if (face.normal.isNotEmpty) ...[
              normals[face.normal[0]],
              normals[face.normal[1]],
              normals[face.normal[2]],
            ],
          ];

          surface.addTriangleFan(fanVertices, fanTexCoords, fanNormals);
        }
      }
      mesh = surface.apply(mesh);
    }
    return mesh;
  }
}
