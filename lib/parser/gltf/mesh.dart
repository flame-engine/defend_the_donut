import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/primitive.dart';
import 'package:flame_3d/resources.dart' as flame_3d;

/// A set of primitives to be rendered.
///
/// Its global transform is defined by a node that references it.
class Mesh extends GltfNode {
  /// An array of primitives, each defining geometry to be rendered.
  final List<Primitive> primitives;

  /// Array of weights to be applied to the morph targets.
  /// The number of array elements **MUST** match the number of morph targets
  final List<double>? weights;

  Mesh({
    required super.root,
    required this.primitives,
    required this.weights,
  });

  Mesh.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          primitives:
              Parser.objectList(root, map, 'primitives', Primitive.parse) ?? [],
          weights: Parser.floatList(root, map, 'weights'),
        );
  
  flame_3d.Mesh toFlameMesh() {
    final mesh = flame_3d.Mesh();
    for (final primitive in primitives) {
      mesh.addSurface(primitive.toFlameSurface());
    }
    return mesh;
  }
}
