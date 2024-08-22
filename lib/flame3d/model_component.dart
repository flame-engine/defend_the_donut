import 'package:defend_the_donut/flame3d/model_animations.dart';
import 'package:defend_the_donut/flame3d/model.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';

class ModelComponent extends Object3D {
  final Model model;
  AnimationController? _currentAnimation;

  ModelComponent({
    required this.model,
  });

  @override
  void bind(GraphicsDevice device) {
    for (final mesh in model.meshes) {
      // ignore: invalid_use_of_internal_member
      world.device
        ..model.setFrom(transformMatrix)
        ..bindMesh(mesh);
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
}
