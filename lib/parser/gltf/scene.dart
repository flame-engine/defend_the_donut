import 'package:defend_the_donut/flame3d/model.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/node.dart';
import 'package:flame_3d/core.dart';

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

  Map<int, ModelNode> toFlameNodes() {
    final nodes = <int, ModelNode>{};
    _toFlameNodes(
      nodes: nodes,
      parentTransform: Matrix4.identity(),
      parent: null,
    );
    return nodes;
  }

  void _toFlameNodes({
    required Map<int, ModelNode> nodes,
    required Matrix4 parentTransform,
    required ModelNode? parent,
  }) {
    for (final nodeRef in this.nodes) {
      _processNode(
        nodes: nodes,
        parentTransform: parentTransform,
        parent: parent,
        nodeRef: nodeRef,
      );
    }
  }

  void _processNode({
    required Map<int, ModelNode> nodes,
    required Matrix4 parentTransform,
    required ModelNode? parent,
    required GltfRef<Node> nodeRef,
  }) {
    final gltfNode = nodeRef.get();
    final combinedTransform = parentTransform * gltfNode.transform;
    final mesh = gltfNode.mesh?.get().toFlameMesh(combinedTransform);
    final node = ModelNode(
      parent: parent,
      mesh: mesh,
    );
    nodes[nodeRef.index] = node;
    for (final child in gltfNode.children) {
      _processNode(
        nodes: nodes,
        parentTransform: combinedTransform,
        parent: node,
        nodeRef: child,
      );
    }
  }
}
