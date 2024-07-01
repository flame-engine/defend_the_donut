import 'dart:async';

import 'package:defend_the_donut/audio.dart';
import 'package:defend_the_donut/components/donut.dart';
import 'package:defend_the_donut/components/enemy_ship.dart';
import 'package:defend_the_donut/components/pew.dart';
import 'package:defend_the_donut/components/player.dart';
import 'package:defend_the_donut/hud/crosshair.dart';
import 'package:defend_the_donut/menu/end_game_menu.dart';
import 'package:defend_the_donut/hud/hud.dart';
import 'package:defend_the_donut/menu/menu.dart';
import 'package:defend_the_donut/menu/pause_menu.dart';
import 'package:defend_the_donut/keyboard_controlled_camera.dart';
import 'package:defend_the_donut/menu/main_menu.dart';
import 'package:defend_the_donut/parser/glb_parser.dart';
import 'package:defend_the_donut/utils.dart';
import 'package:flame/components.dart' show TimerComponent;
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SpaceGame3D extends FlameGame<SpaceWorld3D>
    with CanPause, HasKeyboardHandlerComponents, SecondaryTapDetector {
  Menu? menu;
  late double donutLife;
  late double timer;

  SpaceGame3D()
      : super(
          world: SpaceWorld3D(),
          camera: KeyboardControlledCamera(
            hudComponents: [],
          ),
        );

  @override
  FutureOr<void> onLoad() async {
    await Audio.init();
    _updateMenu(MainMenu());
  }

  void initGame() async {
    donutLife = 100.0;
    timer = 0.0;

    _removeMenu();
    await camera.viewport.addAll([Crosshair(), Hud()]);
    await world.initGame();
    resume();
  }

  void restartGame() {
    super.pause();
    world.resetGame();
    camera.viewport.removeWhere((c) => c is Hud || c is Crosshair);
    _updateMenu(MainMenu());
  }

  @override
  KeyboardControlledCamera get camera =>
      super.camera as KeyboardControlledCamera;

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      if (isPaused) {
        resume();
      } else {
        pause();
      }
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
      super.pause();
      _updateMenu(EndGameMenu());
    }

    timer += dt;
  }

  void _updateMenu(Menu menu) {
    if (this.menu != menu) {
      _removeMenu();
      camera.viewport.add(this.menu = menu);
    }
  }

  void _removeMenu() {
    final currentMenu = menu;
    if (currentMenu != null) {
      camera.viewport.remove(currentMenu);
      menu = null;
    }
  }

  String get clock {
    final hours = (timer / 60).floor().toString().padLeft(2, '0');
    final minutes = (timer % 60).floor().toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  void onSecondaryTapDown(TapDownInfo info) {
    if (isPaused) {
      return;
    }
    world.player.resetCamera();
  }

  @override
  void pause() {
    super.pause();
    _updateMenu(PauseMenu());
  }

  @override
  void resume() {
    _removeMenu();
    super.resume();
  }
}

class SpaceWorld3D extends World3D with TapCallbacks {
  static const maxEnemies = 32;
  double spawnRate = 0.032;

  @override
  SpaceGame3D get game => findParent<SpaceGame3D>()!;
  KeyboardControlledCamera get camera => game.camera;

  final player = Player(
    position: Vector3(0, 0, -100),
  );

  FutureOr<void> initGame() async {
    await add(MeshComponent(mesh: CuboidMesh(size: Vector3.all(1.0))));

    final result = await GlbParser.parseGlb('objects/cube.glb');
    final oneMesh = result.parse().scenes[0].toFlameMeshes()[0];
    await add(MeshComponent(mesh: oneMesh));

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
        period: 5, // 5 seconds
        repeat: false,
        onTick: () {
          spawnEnemy();
        },
      ),
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
            spawnRate += 0.005;
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
