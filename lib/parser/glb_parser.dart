import 'dart:convert';
import 'dart:typed_data';

import 'package:defend_the_donut/parser/gltf/accessor.dart';
import 'package:defend_the_donut/parser/gltf/buffer.dart';
import 'package:defend_the_donut/parser/gltf/buffer_view.dart';
import 'package:defend_the_donut/parser/gltf/glb_chunk.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/material.dart';
import 'package:defend_the_donut/parser/gltf/mesh.dart';
import 'package:defend_the_donut/parser/gltf/node.dart';
import 'package:defend_the_donut/parser/gltf/scene.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';

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

  Map<String, Object?> jsonChunk() {
    final chunk = chunks.firstWhere((GlbChunk chunk) => chunk.type == 'JSON');
    return jsonDecode(_parseString(chunk.data));
  }

  Iterable<GlbChunk> binaryChunks() {
    return chunks.where((GlbChunk chunk) => chunk.type == 'BIN\x00');
  }

  Uint8List buffer(int index) {
    return binaryChunks().toList()[index].data;
  }

  GltfRoot parse() {
    final json = jsonChunk();
    final root = GltfRoot();

    root.chunks = binaryChunks().toList();

    root.scene = json['scene'] as int;
    root.scenes = (json['scenes'] as List<Object?>)
        .map((e) => Scene.parse(root, e as Map<String, Object?>))
        .toList();
    root.nodes = (json['nodes'] as List<Object?>)
        .map((e) => Node.parse(root, e as Map<String, Object?>))
        .toList();
    root.meshes = (json['meshes'] as List<Object?>)
        .map((e) => Mesh.parse(root, e as Map<String, Object?>))
        .toList();
    root.materials = (json['materials'] as List<Object?>)
        .map((e) => Material.parse(root, e as Map<String, Object?>))
        .toList();
    root.accessors = (json['accessors'] as List<Object?>)
        .map((e) => RawAccessor.parse(root, e as Map<String, Object?>))
        .toList();
    root.bufferViews = (json['bufferViews'] as List<Object?>)
        .map((e) => BufferView.parse(root, e as Map<String, Object?>))
        .toList();
    root.buffers = (json['buffers'] as List<Object?>)
        .map((e) => Buffer.parse(root, e as Map<String, Object?>))
        .toList();

    return root;
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
    final json = jsonChunk() as Map<String, dynamic>;
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

int _parseInt(Uint8List bytes) {
  final byteData = ByteData.view(bytes.buffer);
  return byteData.getUint32(0, Endian.little);
}

String _parseString(Uint8List bytes) {
  return String.fromCharCodes(bytes);
}
