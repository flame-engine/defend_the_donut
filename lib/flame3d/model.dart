import 'package:flame_3d/resources.dart';

import 'model_animations.dart';

class Model {
  final List<Mesh> meshes;
  final Map<String, AnimationController> animations;

  Model({
    required this.meshes,
    required this.animations,
  });
}
