import 'package:flame/components.dart';
import 'package:flame_3d/components.dart';
import 'package:flutter/foundation.dart';
import 'package:defend_the_donut/space_game_3d.dart';
import 'package:defend_the_donut/utils.dart';

class BaseComponent extends MeshComponent with HasGameReference<SpaceGame3D> {
  BaseComponent({
    required super.mesh,
    required super.position,
  });

  @override
  @nonVirtual
  void update(double dt) {
    if (game.isPaused) {
      return;
    }

    super.update(dt);
    doUpdate(dt);

    if (position.length2 > worldRadius2) {
      removeFromParent();
    }
  }

  void doUpdate(double dt) {}
}