import 'package:flame_audio/flame_audio.dart';

class Audio {
  static late final AudioPool _pewPool;
  static late final AudioPool _failedPewPool;

  static Future<void> init() async {
    _pewPool = await FlameAudio.createPool('sfx/laser.mp3', maxPlayers: 5, minPlayers: 3);
    _failedPewPool = await FlameAudio.createPool('sfx/error.mp3', maxPlayers: 5, minPlayers: 3);
  }

  static void pew() {
    _pewPool.start();
  }

  static void failedPew() {
    _failedPewPool.start();
  }

  static void boost() {
    FlameAudio.play('sfx/boost.mp3');
  }

  static void explode() {
    FlameAudio.play('sfx/explode.mp3');
  }
}
