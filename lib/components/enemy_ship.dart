import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:defend_the_donut/audio.dart';
import 'package:defend_the_donut/components/base_component.dart';
import 'package:defend_the_donut/obj_parser.dart';
import 'package:defend_the_donut/utils.dart';

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
  double damageTimer = 0.0;

  final Map<int, Color> _originalAlbedoColorMap = {};

  EnemyShip({
    required super.mesh,
    required Vector3 position,
  })  : goal = position,
        super(position: position);

  @override
  FutureOr<void> onLoad() {
    for (int i = 0; i < mesh.surfaceCount; i++) {
      final material = mesh.getMaterialToSurface(i)! as StandardMaterial;
      _originalAlbedoColorMap[i] = material.albedoColor;
    }
  }

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
    damageTimer -= dt;
    if (damageTimer < 0) {
      damageTimer = 0;
    }

    if (damageTimer > 0) {
      _tintMesh(apply: damageTimer % 0.1 < 0.05);
    } else {
      _tintMesh(apply: false);
    }

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
    if (damageTimer > 0) return;

    life -= 1;
    damageTimer = 0.5;
    if (life <= 0) {
      Audio.explode();
      removeFromParent();
    }
  }

  void _tintMesh({
    required bool apply,
  }) {
    for (int i = 0; i < mesh.surfaceCount; i++) {
      final material = mesh.getMaterialToSurface(i)! as StandardMaterial;

      final originalColor = _originalAlbedoColorMap[i]!;
      final currentColor = apply ? _tint(originalColor) : originalColor;

      if (material.albedoColor == currentColor) {
        continue;
      }

      material.albedoColor = currentColor;
      mesh.addMaterialToSurface(i, material);
    }
  }

  Color _tint(Color color) {
    return color.withRed((color.red + 50).clamp(0, 255)).withAlpha(180);
  }

  static const _shipAcc = 2.0;

  static double _randomCoord() => worldRadius * (2 * random.nextDouble() - 1);

  // this is the "forward" direction with respect to how the ship mesh is oriented
  final _forward = Vector3(0, 0, 1);
}
