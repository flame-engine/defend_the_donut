import 'dart:typed_data';

import 'package:defend_the_donut/parser/gltf/buffer.dart';
import 'package:defend_the_donut/parser/gltf/buffer_view_target.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';

/// A view into a buffer generally representing a subset of the buffer.
class BufferView extends GltfNode {
  /// The reference to the buffer.
  final GltfRef<Buffer> buffer;

  /// The length of the bufferView in bytes.
  final int byteLength;

  /// The offset into the buffer in bytes.
  final int byteOffset;

  /// The stride, in bytes, between vertex attributes.
  ///
  /// When this is not defined, data is tightly packed.
  /// When two or more accessors use the same buffer view, this field **MUST** be defined.
  final int? byteStride;

  /// The hint representing the intended GPU buffer type to use with this buffer view.
  final BufferViewTarget? target;

  Uint8List data([int accessorOffset = 0]) {
    final data = root.chunks[buffer.index].data;
    final totalOffset = byteOffset + accessorOffset;
    return data.sublist(
      totalOffset,
      totalOffset + byteLength,
    );
  }

  BufferView({
    required super.root,
    required this.buffer,
    required this.byteLength,
    required this.byteOffset,
    required this.byteStride,
    required this.target,
  });

  BufferView.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          buffer: Parser.ref(root, map, 'buffer')!,
          byteLength: Parser.integer(map, 'byteLength')!,
          byteOffset: Parser.integer(map, 'byteOffset') ?? 0,
          byteStride: Parser.integer(map, 'byteStride'),
          target: BufferViewTarget.parse(map, 'target'),
        );
}
