import 'dart:collection';

import 'package:defend_the_donut/flame3d/model_animation.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:ordered_set/comparing.dart';

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

  Map<int, ProcessedNode> processNodes(ModelAnimation? currentAnimation) {
    final processedNodes = <int, ProcessedNode>{};

    final inDegree = <int, int>{};
    final adjacencyMap = <int, Set<int>>{};

    for (final node in nodes.values) {
      final idx = node.nodeIndex;
      final deps = node.dependencies;
      inDegree[idx] = deps.length;
      for (final dep in deps) {
        (adjacencyMap[dep] ??= {}).add(idx);
      }
    }

    final queue = Queue<int>.from(
      nodes.values.map((e) => e.nodeIndex).where((e) => inDegree[e] == 0),
    );

    while (queue.isNotEmpty) {
      final idx = queue.removeFirst();
      final node = nodes[idx]!;
      node.processNode(processedNodes, currentAnimation);
      final adjacency = adjacencyMap[idx] ?? {};
      for (final dep in adjacency) {
        inDegree[dep] = inDegree[dep]! - 1;
        if (inDegree[dep] == 0) {
          queue.add(dep);
        }
      }
    }

    if (processedNodes.length != nodes.length) {
      throw StateError('Failed to process all nodes');
    }

    return processedNodes;
  }
}

class ModelNode {
  final int nodeIndex;
  final int? parentNodeIndex;
  final Matrix4 transform;
  final Mesh? mesh;
  final Map<int, ModelJoint> joints;

  ModelNode({
    required this.nodeIndex,
    required this.parentNodeIndex,
    required this.transform,
    required this.mesh,
    required this.joints,
  });

  List<int> get dependencies => [
        if (parentNodeIndex != null) parentNodeIndex!,
        ...joints.values.map((e) => e.nodeIndex),
      ];

  ModelNode.simple({
    required this.nodeIndex,
    required this.mesh,
  })  : parentNodeIndex = null,
        transform = Matrix4.identity(),
        joints = {};

  void processNode(
    Map<int, ProcessedNode> processedNodes,
    ModelAnimation? animation,
  ) {
    final resultMatrix = Matrix4.identity();

    // parent
    final parentNodeIndex = this.parentNodeIndex;
    if (parentNodeIndex != null) {
      resultMatrix.multiply(processedNodes[parentNodeIndex]!.combinedTransform);
    }

    // animation
    final animationTransform = animation?.sample(nodeIndex);
    if (animationTransform != null) {
      resultMatrix.multiply(animationTransform);
    }

    // local
    resultMatrix.multiply(transform);

    final jointTransforms = computeJointsPerSurface(processedNodes);

    processedNodes[nodeIndex] = ProcessedNode(
      node: this,
      animationOnlyTransform: animationTransform ?? Matrix4.identity(),
      combinedTransform: resultMatrix,
      jointTransforms: jointTransforms,
    );
  }

  Map<int, List<Matrix4>> computeJointsPerSurface(
    Map<int, ProcessedNode> processedNodes,
  ) {
    final jointTransformsPerSurface = <int, List<Matrix4>>{};
    final surfaces = mesh?.surfaces ?? [];
    for (final (idx, surface) in surfaces.indexed) {
      final globalToLocalJointMap = surface.jointMap;
      if (globalToLocalJointMap == null) {
        continue;
      }

      final jointTransforms = (globalToLocalJointMap.entries.toList()
            ..sort(Comparing.on((a) => a.value)))
          .map((e) => e.key)
          .map((jointIndex) {
        final joint = joints[jointIndex];
        if (joint == null) {
          throw StateError('Missing joint $jointIndex');
        }

        final jointNodeIndex = joint.nodeIndex;
        final jointNode = processedNodes[jointNodeIndex];
        final nodeTree = <int>[];
        var currentNode = jointNode?.node;
        while (currentNode != null) {
          nodeTree.insert(0, currentNode.nodeIndex);
          currentNode = processedNodes[currentNode.parentNodeIndex]?.node;
        }

        // TODO(luan): figure out the order of operations here
        final transform = Matrix4.identity();
        for (final node in nodeTree) {
          transform.multiply(processedNodes[node]!.node.transform);
          transform.multiply(processedNodes[node]!.animationOnlyTransform);
        }

        final jointTransform = transform;
            // jointNode?.animationOnlyTransform ?? Matrix4.identity();

        return jointTransform.multiplied(joint.inverseBindMatrix);
      }).toList();

      jointTransformsPerSurface[idx] = jointTransforms;
    }

    return jointTransformsPerSurface;
  }
}

class ModelJoint {
  final int nodeIndex;
  final Matrix4 inverseBindMatrix;

  ModelJoint({
    required this.nodeIndex,
    required this.inverseBindMatrix,
  });
}

class ProcessedNode {
  final ModelNode node;
  final Matrix4 animationOnlyTransform;
  final Matrix4 combinedTransform;
  // for each surface within the node's mesh, a list of up to 4 joint transforms
  // with localized indexes according to the surface's localJoints
  final Map<int, List<Matrix4>> jointTransforms;

  ProcessedNode({
    required this.node,
    // TODO(luan): remove this as should not be needed
    required this.animationOnlyTransform,
    required this.combinedTransform,
    required this.jointTransforms,
  });
}
