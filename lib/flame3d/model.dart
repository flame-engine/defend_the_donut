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
          0: ModelNode.simple(
            nodeIndex: 0,
            mesh: mesh,
          ),
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
  final int nodeIndex;
  final ModelNode? parent;
  final Matrix4 transform;
  final Mesh? mesh;

  ModelNode({
    required this.nodeIndex,
    required this.parent,
    required this.transform,
    required this.mesh,
  });

  ModelNode.simple({
    required this.nodeIndex,
    required this.mesh,
  })  : parent = null,
        transform = Matrix4.identity();

  Matrix4 computeTransform(ModelAnimation? animation) {
    final resultMatrix = Matrix4.identity();

    // parent
    resultMatrix.multiply(parent?.computeTransform(animation) ?? Matrix4.identity());

    // animation
    final animationTransform = animation?.sample(nodeIndex);
    if (animationTransform != null) {
      resultMatrix.multiply(animationTransform);
    }

    // local
    resultMatrix.multiply(transform);

    return resultMatrix;
  }
}
