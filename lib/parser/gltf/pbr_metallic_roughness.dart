import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/texture_info.dart';
import 'package:flame_3d/extensions.dart';

/// A set of parameter values that are used to define the metallic-roughness material model from Physically-Based Rendering (PBR) methodology.
class PBRMetallicRoughness extends GltfNode {
  /// The factors for the base color of the material.
  /// This value defines linear multipliers for the sampled texels of the base color texture.
  final Vector3? baseColorFactor;

  /// The base color texture.
  ///
  /// The first three components (RGB) **MUST** be encoded with the sRGB transfer function.
  /// They specify the base color of the material. If the fourth component (A) is present, it represents the linear alpha coverage of the material.
  /// Otherwise, the alpha coverage is equal to `1.0`.
  ///
  /// The `material.alphaMode` property specifies how alpha is interpreted.
  /// The stored texels **MUST NOT** be premultiplied. When undefined, the texture **MUST** be sampled as having `1.0` in all components."
  final TextureInfo? baseColorTexture;

  /// The factor for the metalness of the material.
  /// This value defines a linear multiplier for the sampled metalness values of the metallic-roughness texture.
  /// Goes from [0, 1]. Default value is 1.
  final double metallicFactor;

  /// The factor for the roughness of the material.
  /// This value defines a linear multiplier for the sampled roughness values of the metallic-roughness texture.
  /// Goes from [0, 1]. Default value is 1.
  final double roughnessFactor;

  /// The metallic-roughness texture.
  /// The metalness values are sampled from the B channel.
  /// The roughness values are sampled from the G channel.
  /// These values **MUST** be encoded with a linear transfer function.
  /// If other channels are present (R or A), they **MUST** be ignored for metallic-roughness calculations.
  /// When undefined, the texture **MUST** be sampled as having `1.0` in G and B components."
  final TextureInfo? metallicRoughnessTexture;

  PBRMetallicRoughness({
    required super.root,
    required this.baseColorFactor,
    required this.baseColorTexture,
    required this.metallicFactor,
    required this.roughnessFactor,
    required this.metallicRoughnessTexture,
  });

  PBRMetallicRoughness.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          baseColorFactor: Parser.vector3(root, map, 'baseColorFactor'),
          baseColorTexture: Parser.object(
            root,
            map,
            'baseColorTexture',
            TextureInfo.parse,
          ),
          metallicFactor: Parser.float(map, 'metallicFactor') ?? 1.0,
          roughnessFactor: Parser.float(map, 'roughnessFactor') ?? 1.0,
          metallicRoughnessTexture: Parser.object(
            root,
            map,
            'metallicRoughnessTexture',
            TextureInfo.parse,
          ),
        );
}
