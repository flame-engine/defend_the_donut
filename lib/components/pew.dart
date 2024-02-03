import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class Pew extends MeshComponent {
  final Vector3 speed;

  Pew({
    required this.speed,
    super.position,
  }) : super(
          mesh: SphereMesh(
            radius: 1,
            material: StandardMaterial(),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);

    position += speed * dt;
  }
}
