import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/node.dart';
import 'package:flame_3d/resources.dart' as flame_3d;

/// The root nodes of a scene.
class Scene extends GltfNode {
  /// The references to each root node.
  final List<GltfRef<Node>> nodes;

  Scene({
    required super.root,
    required this.nodes,
  });

  Scene.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          nodes: Parser.refList<Node>(root, map, 'nodes')!,
        );

  List<flame_3d.Mesh> toFlameMeshes() {
    return nodes.expand((e) => e.get().toFlameMeshes()).toList();
  }
}
