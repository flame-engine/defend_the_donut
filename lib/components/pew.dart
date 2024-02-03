import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:space_nico/components/base_component.dart';
import 'package:space_nico/components/enemy_ship.dart';

const _pewRadius = 0.1;
const _pewSpeed = 50.0;
const _maxWorldDistance = 10000.0;

class Pew extends BaseComponent {
  final Vector3 speed;

  Pew({
    super.position,
    required Vector3 direction,
  }) : speed = direction.normalized() * _pewSpeed,
  super(
          mesh: SphereMesh(
            radius: _pewRadius,
            material: StandardMaterial(),
          ),
        );

  @override
  void doUpdate(double dt) {
    position += speed * dt;

    if (position.length2 > _maxWorldDistance) {
      removeFromParent();
    } else {
      for (final enemy in game.descendants().whereType<EnemyShip>()) {
        if (enemy.aabb.containsVector3(position)) {
          removeFromParent();
          enemy.removeFromParent();
        }
      }
    }
  }
}
