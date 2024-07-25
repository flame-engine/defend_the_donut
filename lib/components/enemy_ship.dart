import 'dart:async';
import 'dart:math';

import 'package:defend_the_donut/components/beam.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:defend_the_donut/audio.dart';
import 'package:defend_the_donut/components/base_component.dart';
import 'package:defend_the_donut/parser/obj_parser.dart';
import 'package:defend_the_donut/utils.dart';
import 'package:flutter/animation.dart';

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
  double deathTimer = 0.0;

  bool isShootingDonut = false;
  Beam? beam;

  final Map<int, Color> _originalAlbedoColorMap = {};

  EnemyShip({
    required super.mesh,
    required super.position,
    required this.goal,
  });

  @override
  FutureOr<void> onLoad() {
    for (final (i, surface) in mesh.surfaces.indexed) {
      final material = surface.material as SpatialMaterial;
      _originalAlbedoColorMap[i] = material.albedoColor;
    }
  }

  static Future<EnemyShip> spawnShip() async {
    final type = ShipType.values[Random().nextInt(ShipType.values.length)];
    final mesh = await ObjParser.parse(type.path);

    final direction = Vector3(
      _randomCoord(),
      _randomCoord(),
      _randomCoord(),
    )..normalize();

    final targetDistance = worldRadius * (0.1 + random.nextDouble() / 4);
    final goal = direction.clone()..scale(targetDistance);
    final position = direction.clone()..scale(4 / 5 * worldRadius);

    return EnemyShip(mesh: mesh, position: position, goal: goal);
  }

  @override
  void doUpdate(double dt) {
    if (deathTimer > 0.0) {
      deathTimer -= dt;
      if (deathTimer <= 0.0) {
        removeFromParent();
      } else {
        if (deathTimer > 1.0) {
          final progress = 1 - (deathTimer - 1.0);
          _tintMesh((color) {
            return color
                .withRed((color.red + (255 - color.red) * progress).toInt())
                .withGreen((color.green + (255 - color.green) * progress).toInt())
                .withBlue((color.blue + (255 - color.blue) * progress).toInt());
          });
        } else {
          final progress = 1 - Curves.easeInCubic.transform(1 - deathTimer);
          _tintMesh((color) => const Color(0xFFFFFFFF));
          transform.scale.setValues(progress, progress, progress);
        }
      }

      return;
    }

    damageTimer -= dt;
    if (damageTimer < 0) {
      damageTimer = 0;
    }

    if (damageTimer > 0) {
      _tintMesh(damageTimer % 0.1 < 0.05 ? _tintRed : _tintNone);
    } else {
      _tintMesh();
    }

    if (isShootingDonut) {
      game.donutLife -= _shipDps * dt;
      return;
    }

    final target = position.distanceTo(goal);
    if (target < 0.1) {
      isShootingDonut =  true;
      game.world.add(beam = Beam.generate(start: position, end: Vector3.zero()));
    } else {
      final direction = (goal - position)..normalize();
      rotation.setFromTwoVectors(_forward, direction);

      speed.setFrom(direction * _shipAcc);
      position += speed * dt;
      if (position.distanceTo(goal) > target) {
        position.setFrom(goal);
      }
    }
  }

  void takeDamage() {
    if (damageTimer > 0) return;

    life -= 1;
    damageTimer = 0.5;
    if (life <= 0) {
      Audio.explode();
      beam?.removeFromParent();
      deathTimer = 2.0;
    }
  }

  void _tintMesh([
    Color Function(Color) tint = _tintNone,
  ]) {
    for (final (i, surface) in mesh.surfaces.indexed) {
      final material = surface.material as SpatialMaterial;

      final originalColor = _originalAlbedoColorMap[i]!;
      final newColor = tint(originalColor);

      if (material.albedoColor == newColor) {
        continue;
      }

      material.albedoColor = newColor;
    }
  }

  static Color _tintNone(Color color) => color;

  static Color _tintRed(Color color) {
    return color.withRed((color.red + 50).clamp(0, 255)).withAlpha(180);
  }

  static const _shipAcc = 3.6;
  static const _shipDps = 0.4;

  static double _randomCoord() => worldRadius * (2 * random.nextDouble() - 1);

  // this is the "forward" direction with respect to how the ship mesh is oriented
  final _forward = Vector3(0, 0, 1);
}
