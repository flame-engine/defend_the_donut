import 'dart:math' show Random;

const enableAudio = true;

final random = Random();
const worldRadius = 450.0;
const worldRadius2 = worldRadius * worldRadius;

extension Sample<T> on List<T> {
  T sample() => this[random.nextInt(length)];
}
