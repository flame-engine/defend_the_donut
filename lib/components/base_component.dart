import 'package:flame/components.dart';
import 'package:flame_3d/components.dart';
import 'package:flutter/foundation.dart';
import 'package:space_nico/space_game_3d.dart';

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
  }

  void doUpdate(double dt) {}
}