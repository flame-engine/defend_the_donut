import 'dart:ui' as dart;
import 'dart:convert';
import 'dart:typed_data';

import 'package:defend_the_donut/parser/gltf/buffer_view.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/mime_type.dart';
import 'package:flame_3d/resources.dart' as flame3d;

/// Image data used to create a texture.
class Image extends GltfNode {
  /// The URI (or IRI) of the image.
  ///
  /// Relative paths are relative to the current glTF asset.
  /// Instead of referencing an external file, this field **MAY** contain a `data:`-URI.
  /// This field **MUST NOT** be defined when `bufferView` is defined.
  final String? uri;

  /// The image's media type.
  ///
  /// This field **MUST** be defined when `bufferView` is defined.
  final MimeType? mimeType;

  /// The reference to the bufferView that contains the image.
  /// This field **MUST NOT** be defined when `uri` is defined.
  final GltfRef<BufferView>? bufferView;

  /// During initialization each image will be parsed only once into a Flame
  /// texture.
  late final flame3d.ImageTexture _flameTexture;

  Image({
    required super.root,
    required this.uri,
    required this.mimeType,
    required this.bufferView,
  });

  Image.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          uri: Parser.string(map, 'uri'),
          mimeType: MimeType.parse(map, 'mimeType'),
          bufferView: Parser.ref(root, map, 'bufferView'),
        );

  Future<void> init() async {
    _flameTexture = await parseFlameTexture();
  }

  Uint8List data() {
    final uri = this.uri;
    if (uri != null) {
      const prefix = 'data:text/plain;base64,';
      return base64Decode(uri.substring(prefix.length));
    } else {
      final bufferView = this.bufferView?.get();
      if (bufferView == null) {
        throw Exception('Either `uri` or `bufferView` must be defined');
      }
      return bufferView.data();
    }
  }

  Future<dart.Image> parseDartImage() async {
    final bytes = data();
    final codec = await dart.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<flame3d.ImageTexture> parseFlameTexture() async {
    return flame3d.ImageTexture.create(await parseDartImage());
  }

  flame3d.ImageTexture toFlameTexture() {
    return _flameTexture;
  }
}
