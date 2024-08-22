import 'package:flame_3d/core.dart';

abstract class AnimationSpline<T> {
  final List<(double, T)> values;

  AnimationSpline({
    required this.values,
  });

  AnimationSpline.from({
    required List<double> times,
    required List<T> values,
  }) : values = List.generate(times.length, (index) {
          return (times[index], values[index]);
        });

  T lerp(T a, T b, double t);
}

class Vector3AnimationSpline extends AnimationSpline<Vector3> {
  Vector3AnimationSpline.from({
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return a + (b - a) * t;
  }
}

class QuaternionAnimationSpline extends AnimationSpline<Quaternion> {
  QuaternionAnimationSpline.from({
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Quaternion lerp(Quaternion a, Quaternion b, double t) {
    throw UnimplementedError();
  }
}

class AnimationController<T> {
  final AnimationSpline<T> animation;
  int _currentIndex = 0;

  AnimationController({
    required this.animation,
  });

  static AnimationController<Vector3> vector3({
    required List<double> times,
    required List<Vector3> values,
  }) {
    return AnimationController(
      animation: Vector3AnimationSpline.from(times: times, values: values),
    );
  }

  static AnimationController<Quaternion> quaternion({
    required List<double> times,
    required List<Quaternion> values,
  }) {
    return AnimationController(
      animation: QuaternionAnimationSpline.from(times: times, values: values),
    );
  }

  T sample(double time) {
    final values = animation.values;
    while (_currentIndex < values.length - 1 &&
        values[_currentIndex + 1].$1 < time) {
      _currentIndex++;
    }

    if (_currentIndex == values.length - 1) {
      return values.last.$2;
    }

    final t0 = values[_currentIndex].$1;
    final t1 = values[_currentIndex + 1].$1;
    final t = (time - t0) / (t1 - t0);

    final value0 = values[_currentIndex].$2;
    final value1 = values[_currentIndex + 1].$2;

    return animation.lerp(value0, value1, t);
  }
}
