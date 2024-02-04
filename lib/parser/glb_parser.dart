import 'dart:convert';
import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// Parses GLB and GLTF file formats as per specified by:
/// https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.pdf
class GlbParser {
  static Future<Glb> parseGlb(String filePath) async {
    final content = await Flame.assets.readBinaryFile(filePath);

    int cursor = 0;
    Uint8List read(int bytes) {
      cursor += bytes;
      return content.sublist(cursor - bytes, cursor);
    }

    final magic = _parseString(read(4));
    if (magic.toString() != 'glTF') {
      throw Exception('Invalid magic number $magic');
    }

    final version = _parseInt(read(4));
    if (version != 2) {
      throw Exception('Invalid version $version');
    }

    final length = _parseInt(read(4));

    final chunks = <GlbChunk>[];
    while (cursor < content.length) {
      final chunkLength = _parseInt(read(4));
      final chunkType = _parseString(read(4));
      final chunkData = read(chunkLength);

      chunks.add(
        GlbChunk(
          length: chunkLength,
          type: chunkType,
          data: chunkData,
        ),
      );
    }

    return Glb(
      version: version,
      length: length,
      chunks: chunks,
    );
  }
}

class Glb {
  final int version;
  final int length;
  final List<GlbChunk> chunks;

  Glb({
    required this.version,
    required this.length,
    required this.chunks,
  });

  Map<String, dynamic> jsonChunk() {
    final chunk = chunks.firstWhere((GlbChunk chunk) => chunk.type == 'JSON');
    return jsonDecode(_parseString(chunk.data));
  }

  Iterable<GlbChunk> _buffers() {
    return chunks.where((GlbChunk chunk) => chunk.type == 'BIN\x00');
  }

  Uint8List buffer(int index) {
    return _buffers().toList()[index].data;
  }

  void describe() {
    print('version: $version length: $length');
    print('chunks: ${chunks.map((e) => e.type).join(', ')}');

    final mesh = toMesh();
    print(mesh);
  }

  Mesh toMesh() {
    final json = jsonChunk();
    final primitives = json['meshes'][0]['primitives'];

    final mesh = Mesh();
    for (final primitive in primitives) {
      final attributes = primitive['attributes'];

      final indices = _accessScalarData(primitive['indices']!);
      final positions = _accessVector3Data(attributes['POSITION']!);
      final normals = _accessVector3Data(attributes['NORMAL']!);
      final texCoords = _accessVector2Data(attributes['TEXCOORD_0']!);

      _constructSurfaceWithUniqueVertices(
        mesh,
        positions,
        normals,
        texCoords,
        indices,
      );
    }
    return mesh;
  }

  List<Vector3> _accessVector3Data(int accessorIndex) {
    final rawData = _accessData(accessorIndex);
    final result = <Vector3>[];
    for (int i = 0; i < rawData.length; i += 3) {
      result.add(
        Vector3(
          rawData[i].toDouble(),
          rawData[i + 1].toDouble(),
          rawData[i + 2].toDouble(),
        ),
      );
    }
    return result;
  }

  void _constructSurfaceWithUniqueVertices(
    Mesh mesh,
    List<Vector3> positions,
    List<Vector3> normals,
    List<Vector2> texCoords,
    List<int> indices,
  ) {
    final uniqueVertices = <Vertex>[];
    final newIndices = <int>[];

    for (int i = 0; i < indices.length; i += 3) {
      // For each face, create unique vertices
      for (int j = 0; j < 3; j++) {
        final index = indices[i + j];
        final position = positions[index];
        final normal = normals[index];
        final texCoord = texCoords.length > index
            ? texCoords[index]
            : Vector2(0, 0); // Handle missing texCoords

        // Check if this combination exists
        final vertex = Vertex(
          position: position,
          normal: normal,
          texCoord: texCoord,
        );
        final existingIndex = uniqueVertices.indexOf(vertex);
        if (existingIndex == -1) {
          // Not found, add new vertex
          uniqueVertices.add(vertex);
          newIndices.add(uniqueVertices.length - 1);
        } else {
          // Reuse existing vertex index
          newIndices.add(existingIndex);
        }
      }
    }

    mesh.addSurface(uniqueVertices, newIndices);
  }

  List<Vector2> _accessVector2Data(int accessorIndex) {
    final rawData = _accessData(accessorIndex);
    final result = <Vector2>[];
    for (int i = 0; i < rawData.length; i += 2) {
      result.add(
        Vector2(
          rawData[i].toDouble(),
          rawData[i + 1].toDouble(),
        ),
      );
    }
    return result;
  }

  List<int> _accessScalarData(int accessorIndex) {
    List<num> rawData = _accessData(accessorIndex);
    return rawData.map<int>((e) => e.toInt()).toList();
  }

  List<num> _accessData(int index) {
    final json = jsonChunk();
    final ac = json["accessors"][index];
    final bv = json["bufferViews"][ac["bufferView"]];
    final buff = buffer(bv["buffer"]);

    final offset = bv["byteOffset"] + ac["byteOffset"];
    final length = bv["byteLength"];

    final data = buff.sublist(offset, offset + length);
    return _convertDataType(data, ac["componentType"]);
  }

  List<num> _convertDataType(Uint8List bytes, int componentType) {
    final byteData = bytes.buffer.asByteData();

    final (format, step) = switch (componentType) {
      5126 => (byteData.getFloat32, 4),
      5123 => (byteData.getUint16, 2),
      5125 => (byteData.getUint32, 4),
      _ => throw Exception('Invalid component type $componentType'),
    };
    int cursor = 0;
    final result = <num>[];
    while (cursor <= bytes.length - step) {
      result.add(format(cursor));
      cursor += step;
    }
    return result;
  }
}

class GlbChunk {
  final int length;
  final String type;
  final Uint8List data;

  GlbChunk({
    required this.length,
    required this.type,
    required this.data,
  });
}

int _parseInt(Uint8List bytes) {
  final byteData = ByteData.view(bytes.buffer);
  return byteData.getUint32(0, Endian.little);
}

String _parseString(Uint8List bytes) {
  return String.fromCharCodes(bytes);
}
