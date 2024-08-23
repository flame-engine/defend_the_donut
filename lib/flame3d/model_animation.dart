import 'package:defend_the_donut/flame3d/matrix4_utils.dart';
import 'package:defend_the_donut/parser/gltf/animation_interpolation.dart';
import 'package:flame_3d/core.dart';

abstract class AnimationSpline<T> {
  final AnimationInterpolation interpolation;
  final List<(double, T)> values;

  AnimationSpline({
    required this.interpolation,
    required this.values,
  });

  AnimationSpline.from({
    required this.interpolation,
    required List<double> times,
    required List<T> values,
  }) : values = List.generate(times.length, (index) {
          return (times[index], values[index]);
        });

  T lerp(T a, T b, double t);
  Matrix4 asTransform(T value);
}

class TranslationAnimationSpline extends AnimationSpline<Vector3> {
  TranslationAnimationSpline.from({
    required super.interpolation,
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return interpolation.lerp(a, b, t);
  }

  @override
  Matrix4 asTransform(Vector3 value) {
    return matrix4(translation: value);
  }
}

class ScaleAnimationSpline extends AnimationSpline<Vector3> {
  ScaleAnimationSpline.from({
    required super.interpolation,
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return interpolation.lerp(a, b, t);
  }

  @override
  Matrix4 asTransform(Vector3 value) {
    return matrix4(scale: value);
  }
}

class RotationAnimationSpline extends AnimationSpline<Quaternion> {
  RotationAnimationSpline.from({
    required super.interpolation,
    required super.times,
    required super.values,
  }) : super.from();

  @override
  Quaternion lerp(Quaternion a, Quaternion b, double t) {
    return interpolation.slerp(a, b, t);
  }

  @override
  Matrix4 asTransform(Quaternion value) {
    return matrix4(rotation: value);
  }
}

class AnimationController<T> {
  final int nodeIdx;
  final AnimationSpline<T> animation;
  final double _lastTime;
  int _currentIndex = 0;
  double _clock = 0;

  AnimationController({
    required this.nodeIdx,
    required this.animation,
  }) : _lastTime = animation.values.last.$1;

  void update(double dt) {
    _clock += dt;
    while (_clock > _lastTime) {
      _clock -= _lastTime;
      _currentIndex = 0;
    }
  }

  Matrix4 sampleTransform() {
    return animation.asTransform(sample());
  }

  T sample() => _sample(_clock);

  T _sample(double time) {
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

  void reset() {
    _currentIndex = 0;
    _clock = 0;
  }
}

class ModelAnimation {
  final String name;
  final Map<int, List<AnimationController>> channels;

  ModelAnimation({
    required this.name,
    required this.channels,
  });

  void update(double dt) {
    _iterate((channel) => channel.update(dt));
  }

  void reset() {
    _iterate((channel) => channel.reset());
  }

  void _iterate(void Function(AnimationController) consumer) {
    for (final nodes in channels.values) {
      for (final channel in nodes) {
        consumer(channel);
      }
    }
  }
}
