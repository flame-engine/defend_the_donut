import 'dart:async';

import 'package:flame/components.dart' show TimerComponent;
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:defend_the_donut/audio.dart';
import 'package:defend_the_donut/components/donut.dart';
import 'package:defend_the_donut/components/enemy_ship.dart';
import 'package:defend_the_donut/components/player.dart';
import 'package:defend_the_donut/hud/crosshair.dart';
import 'package:defend_the_donut/hud/hud.dart';
import 'package:defend_the_donut/hud/pause_menu.dart';
import 'package:defend_the_donut/keyboard_controlled_camera.dart';
import 'package:defend_the_donut/main_menu.dart';
import 'package:defend_the_donut/utils.dart';

class SpaceGame3D extends FlameGame<SpaceWorld3D>
    with CanPause, HasKeyboardHandlerComponents {

  double donutLife = 100.0;

  SpaceGame3D()
      : super(
          world: SpaceWorld3D(),
          camera: KeyboardControlledCamera(
            hudComponents: [MainMenu()],
          ),
        );

  @override
  FutureOr<void> onLoad() async {
    await Audio.init();
  }

  void initGame() async {
    camera.viewport.removeWhere((e) => e is MainMenu);
    await camera.viewport.addAll([Crosshair(), Hud(), PauseMenu()]);
    await world.initGame();
    resume();
  }

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

    if (isPaused) {
      return;
    }
    if (random.nextDouble() < 0.05) {
      donutLife -= 0.1;
    }
  }
}

class SpaceWorld3D extends World3D with TapCallbacks {
  static const maxEnemies = 32;

  SpaceGame3D get game => findParent<SpaceGame3D>()!;
  KeyboardControlledCamera get camera => game.camera;

  final player = Player(
    position: Vector3(0, 0, -100),
  );

  FutureOr<void> initGame() async {
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
          if (children.whereType<EnemyShip>().length >= maxEnemies) {
            return;
          }
          if (random.nextDouble() < 0.5) {
            spawnEnemy();
          }
        },
      ),
    ]);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (game.isPaused) {
      return;
    }
    player.pew();
  }

  Future<void> spawnEnemy() async {
    await add(await EnemyShip.spawnShip());
  }
}
