import 'dart:async';

import 'package:defend_the_donut/audio.dart';
import 'package:defend_the_donut/components/donut.dart';
import 'package:defend_the_donut/components/enemy_ship.dart';
import 'package:defend_the_donut/components/pew.dart';
import 'package:defend_the_donut/components/player.dart';
import 'package:defend_the_donut/hud/crosshair.dart';
import 'package:defend_the_donut/hud/end_game_menu.dart';
import 'package:defend_the_donut/hud/hud.dart';
import 'package:defend_the_donut/hud/pause_menu.dart';
import 'package:defend_the_donut/keyboard_controlled_camera.dart';
import 'package:defend_the_donut/main_menu.dart';
import 'package:defend_the_donut/utils.dart';
import 'package:flame/components.dart' show TimerComponent;
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SpaceGame3D extends FlameGame<SpaceWorld3D>
    with CanPause, HasKeyboardHandlerComponents {
  late double donutLife;
  late double timer;

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
    donutLife = 100.0;
    timer = 0.0;

    camera.viewport.removeWhere((e) => e is MainMenu);
    await camera.viewport.addAll([Crosshair(), Hud(), PauseMenu()]);
    await world.initGame();
    resume();
  }

  void restartGame() {
    pause();
    camera.viewport.removeWhere((e) => e is! MainMenu);
    world.resetGame();
    camera.viewport.add(MainMenu());
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

    if (donutLife <= 0) {
      donutLife = 0;
      camera.viewport.removeWhere((e) => e is PauseMenu);
      pause();
      camera.viewport.add(EndGameMenu());
    }

    timer += dt;
  }

  String get clock {
    final hours = (timer / 60).floor().toString().padLeft(2, '0');
    final minutes = (timer % 60).floor().toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class SpaceWorld3D extends World3D with TapCallbacks {
  static const maxEnemies = 32;
  double spawnRate = 0.1;

  SpaceGame3D get game => findParent<SpaceGame3D>()!;
  KeyboardControlledCamera get camera => game.camera;

  final player = Player(
    position: Vector3(0, 0, -100),
  );

  FutureOr<void> initGame() async {
    await addAll([
      Pew(
        position: Vector3(0, 0, 0),
        direction: Vector3(0, 0, 0),
      ),
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
          if (random.nextDouble() < spawnRate) {
            spawnEnemy();
          } else if (random.nextDouble() < spawnRate) {
            spawnRate += 0.02;
          }
        },
      ),
    ]);
  }

  void resetGame() {
    removeWhere((e) => true);
    spawnRate = 0.1;
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
