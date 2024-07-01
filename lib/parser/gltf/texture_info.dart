import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';

/// Reference to a texture.
class TextureInfo extends GltfNode {
  /// The index of the texture.
  final int index;

  /// This integer value is used to construct a string in the format `TEXCOORD_<set index>`,
  /// which is a reference to a key in `mesh.primitives.attributes` (e.g. a value of `0` corresponds to `TEXCOORD_0`).
  ///
  /// A mesh primitive **MUST** have the corresponding texture coordinate attributes for the material to be applicable to it.
  final int? texCoord;

  TextureInfo({
    required super.root,
    required this.index,
    this.texCoord,
  });

  TextureInfo.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          index: Parser.integer(map, 'index')!,
          texCoord: Parser.integer(map, 'texCoord'),
        );
}
