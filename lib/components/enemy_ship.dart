import 'dart:async';
import 'dart:math';

import 'package:flame_3d/game.dart';
import 'package:space_nico/components/base_component.dart';
import 'package:space_nico/obj_parser.dart';
import 'package:space_nico/utils.dart';

enum ShipType {
  speeder1('objects/ships/speeder_1.obj'),
  speeder2('objects/ships/speeder_2.obj'),
  speeder3('objects/ships/speeder_3.obj'),
  speeder4('objects/ships/speeder_4.obj');

  final String path;

  const ShipType(this.path);
}

class EnemyShip extends BaseComponent {
  final Vector3 speed = Vector3.zero();
  final Vector3 goal;

  double life = 3.0;

  EnemyShip({
    required super.mesh,
    required Vector3 position,
  })  : goal = position,
        super(position: position);

  static Future<EnemyShip> spawnShip() async {
    final type = ShipType.values[Random().nextInt(ShipType.values.length)];
    final mesh = await ObjParser.parse(type.path);

    final position = Vector3(
      _randomCoord(),
      _randomCoord(),
      _randomCoord(),
    );

    return EnemyShip(mesh: mesh, position: position);
  }

  @override
  void doUpdate(double dt) {
    position += speed * dt;
    rotation.setFromTwoVectors(_forward, speed.normalized());

    if (position.distanceTo(goal) < 0.001) {
      // new goal
      speed.setZero();
      goal.setValues(_randomCoord(), _randomCoord(), _randomCoord());
    } else {
      final direction = goal - position;
      speed.setFrom(direction.normalized() * _shipAcc);
    }
  }

  void takeDamage() {
    life -= 1;
    if (life <= 0) {
      removeFromParent();
    }
  }

  static const _shipAcc = 2.0;

  static double _randomCoord() => worldRadius * (2 * random.nextDouble() - 1);

  // this is the "forward" direction with respect to how the ship mesh is oriented
  final _forward = Vector3(0, 0, 1);
}
