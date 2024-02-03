import 'dart:async';
import 'dart:math';

import 'package:flame_3d/game.dart';
import 'package:space_nico/components/base_component.dart';
import 'package:space_nico/obj_parser.dart';
import 'package:space_nico/utils.dart';

const _shipAcc = 2.0;

const _worldRadius = 100.0;
double _randomCoord() => _worldRadius * (random.nextDouble() - 0.5);

// this is the "forward" direction with respect to how the ship mesh is oriented
final _forward = Vector3(0, 0, 1);

enum ShipType {
  speederA('objects/craft_speederA.obj'),
  speederB('objects/craft_speederB.obj'),
  speederC('objects/craft_speederC.obj'),
  speederD('objects/craft_speederD.obj');

  final String path;

  const ShipType(this.path);
}

class EnemyShip extends BaseComponent {
  final Vector3 speed = Vector3.zero();
  final Vector3 goal;

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
}
