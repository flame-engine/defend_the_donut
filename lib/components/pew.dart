import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:defend_the_donut/components/base_component.dart';
import 'package:defend_the_donut/components/enemy_ship.dart';

class Pew extends BaseComponent {
  final Vector3 speed;

  Pew({
    super.position,
    required Vector3 direction,
  })  : speed = direction.normalized() * _pewSpeed,
        super(
          mesh: SphereMesh(
            radius: _pewRadius,
            material: StandardMaterial(),
          ),
        );

  @override
  void doUpdate(double dt) {
    position += speed * dt;

    for (final enemy in game.descendants().whereType<EnemyShip>()) {
      if (enemy.aabb.containsVector3(position)) {
        enemy.takeDamage();
        removeFromParent();
      }
    }
  }

  static const _pewRadius = 0.1;
  static const _pewSpeed = 50.0;
}
