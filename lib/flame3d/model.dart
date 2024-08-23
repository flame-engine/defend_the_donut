import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

import 'model_animation.dart';

class Model {
  final Map<int, ModelNode> nodes;
  final Map<String, ModelAnimation> animations;

  Model({
    required this.nodes,
    required this.animations,
  });

  Model.simple({
    required Mesh mesh,
  })  : nodes = {
          0: ModelNode(parent: null, mesh: mesh),
        },
        animations = {};

  Aabb3 get aabb => _aabb ??= _calculateBoundingBox();
  Aabb3? _aabb;

  Aabb3 _calculateBoundingBox() {
    final box = Aabb3();
    for (final entry in nodes.entries) {
      final mesh = entry.value.mesh;
      if (mesh != null) {
        box.hull(mesh.aabb);
      }
    }
    return box;
  }
}

class ModelNode {
  final ModelNode? parent;
  final Mesh? mesh;

  ModelNode({
    required this.parent,
    required this.mesh,
  });
}
