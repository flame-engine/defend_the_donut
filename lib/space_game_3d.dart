import 'dart:async';

import 'package:flame/components.dart' show TimerComponent;
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:space_nico/components/donut.dart';
import 'package:space_nico/components/enemy_ship.dart';
import 'package:space_nico/components/pew.dart';
import 'package:space_nico/components/player.dart';
import 'package:space_nico/hud/crosshair.dart';
import 'package:space_nico/hud/hud.dart';
import 'package:space_nico/hud/pause_menu.dart';
import 'package:space_nico/hud/simple_hud.dart';
import 'package:space_nico/keyboard_controlled_camera.dart';
import 'package:space_nico/utils.dart';

class SpaceGame3D extends FlameGame<SpaceWorld3D>
    with CanPause, HasKeyboardHandlerComponents {

  double donutLife = 100.0;

  SpaceGame3D()
      : super(
          world: SpaceWorld3D(),
          camera: KeyboardControlledCamera(
            hudComponents: [SimpleHud(), Crosshair(), Hud(), PauseMenu()],
          ),
        );

  @override
  KeyboardControlledCamera get camera =>
      super.camera as KeyboardControlledCamera;

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      pause();
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (random.nextDouble() < 0.05) {
      donutLife -= 0.1;
    }
  }
}

class SpaceWorld3D extends World3D with TapCallbacks {
  SpaceGame3D get game => findParent<SpaceGame3D>()!;
  KeyboardControlledCamera get camera => game.camera;

  final player = Player(
    position: Vector3(0, 0, -100),
  );

  @override
  FutureOr<void> onLoad() async {
    await addAll([
      Donut(
        type: DonutType.donut1,
        position: Vector3(0, 0, 0),
      ),

      player,

      TimerComponent(
        period: 1, // 1 second
        repeat: true,
        onTick: () {
          if (random.nextDouble() < 0.5) {
            spawnEnemy();
          }
        },
      ),
    ]);
  }

  @override
  void onTapUp(TapUpEvent event) {
    add(
      Pew(
        position: camera.position.clone(),
        direction: camera.forward.clone(),
      ),
    );
  }

  Future<void> spawnEnemy() async {
    await add(await EnemyShip.spawnShip());
  }
}
