import 'package:defend_the_donut/parser/gltf/accessor.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/material.dart';
import 'package:defend_the_donut/parser/gltf/morph_target.dart';
import 'package:defend_the_donut/parser/gltf/primitive_mode.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart' as flame_3d;

class Primitive extends GltfNode {
  /// The topology type of primitives to render.
  final PrimitiveMode mode;

  /// A plain JSON object, where each key corresponds to a mesh attribute semantic and each value is the index of the accessor containing attribute's data.
  /// Typical keys include: `POSITION`, `NORMAL`, `TEXCOORD_0`, etc.
  final Map<String, int> attributes;

  /// The reference to the accessor that contains the vertex indices.
  /// When this is undefined, the primitive defines non-indexed geometry.
  /// When defined, the accessor **MUST** have `SCALAR` type and an unsigned integer component type.
  final GltfRef<IntAccessor> indices;

  /// The reference to the material to apply to this primitive when rendering.
  final GltfRef<Material>? material;

  /// An array of morph targets.
  final List<MorphTarget> targets;

  Primitive({
    required super.root,
    required this.mode,
    required this.attributes,
    required this.indices,
    required this.material,
    required this.targets,
  });

  GltfRef<Vector3Accessor>? get positions {
    final position = attributes['POSITION'];
    if (position == null) {
      return null;
    }
    return GltfRef<Vector3Accessor>(
      root: root,
      index: position,
    );
  }

  GltfRef<Vector3Accessor>? get normals {
    final normal = attributes['NORMAL'];
    if (normal == null) {
      return null;
    }
    return GltfRef<Vector3Accessor>(
      root: root,
      index: normal,
    );
  }

  GltfRef<Vector2Accessor>? get texCoords {
    final textCoords = attributes['TEXCOORD_0'];
    if (textCoords == null) {
      print(attributes.keys.join(', '));
      return null;
    }
    return GltfRef<Vector2Accessor>(
      root: root,
      index: textCoords,
    );
  }

  Iterable<flame_3d.Vertex> toFlameVertices() sync* {
    final positions = this.positions!.get().typedData();
    final texCoords = this.texCoords?.get().typedData();
    final normals = this.normals?.get().typedData();

    for (var i = 0; i < positions.length; i++) {
      yield flame_3d.Vertex(
        position: positions[i],
        // TODO: consider null textures
        texCoord: texCoords?.elementAt(i) ?? Vector2.zero(),
        normal: normals?.elementAt(i),
      );
    }
  }

  flame_3d.Surface toFlameSurface() {
    print('''

      creating flame surface
      positions: ${toFlameVertices().map((e) => e.position).join('\n')}
      texels: ${toFlameVertices().map((e) => e.texCoord).join('\n')}
      indices: ${indices.get().typedData()}

    ''');
    return flame_3d.Surface(
      vertices: toFlameVertices().toList(),
      indices: indices.get().typedData(),
      // TODO: implement material
      // material?.get().toFlameMaterial(),
    );
  }

  Primitive.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          mode: PrimitiveMode.parse(map, 'mode')!,
          attributes: Parser.mapInt(map, 'attributes') ?? {},
          indices: Parser.ref(root, map, 'indices')!,
          material: Parser.ref(root, map, 'material'),
          targets: Parser.objectList<MorphTarget>(
                root,
                map,
                'targets',
                MorphTarget.parse,
              ) ??
              [],
        );
}