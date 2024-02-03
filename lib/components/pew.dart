import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

const _bulletSpeed = 25.0;
const _maxWorldDistance = 10000.0;

class Pew extends MeshComponent {
  final Vector3 speed;

  Pew({
    super.position,
    required Vector3 direction,
  }) : speed = direction.normalized() * _bulletSpeed,
  super(
          mesh: SphereMesh(
            radius: 0.1,
            material: StandardMaterial(),
          ),
        );

  @override
  void update(double dt) {
    position += speed * dt;

    if (position.length2 > _maxWorldDistance) {
      removeFromParent();
    }
  }
}
