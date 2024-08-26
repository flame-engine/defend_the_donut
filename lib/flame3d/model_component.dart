import 'package:defend_the_donut/flame3d/model_animation.dart';
import 'package:defend_the_donut/flame3d/model.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';

class ModelComponent extends Object3D {
  final Model model;
  ModelAnimation? _currentAnimation;

  ModelComponent({
    required this.model,
  });

  Aabb3 get aabb => model.aabb;

  @override
  void bind(GraphicsDevice device) {
    final nodes = model.processNodes(_currentAnimation).values;
    for (final node in nodes) {
      final mesh = node.node.mesh;
      if (mesh != null) {
        device.jointsInfo.jointTransformsPerSurface = node.jointTransforms;
        // ignore: invalid_use_of_internal_member
        world.device
          ..model.setFrom(node.combinedTransform)
          ..bindMesh(mesh);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _currentAnimation?.update(dt);
  }

  void playAnimation(String name) {
    final animation = model.animations[name];
    if (animation == null) {
      throw ArgumentError('No animation with name $name');
    }
    animation.reset();
    _currentAnimation = animation;
  }

  void playAnimationIdx(int idx) {
    playAnimation(model.animations.keys.toList()[idx]);
  }

  @override
  bool shouldCull(CameraComponent3D camera) {
    return camera.frustum.intersectsWithAabb3(aabb);
  }
}