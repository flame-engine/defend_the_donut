import 'dart:math';

import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:flame_3d/core.dart';

enum AnimationInterpolation {
  /// The animated values are linearly interpolated between keyframes.
  /// When targeting a rotation, spherical linear interpolation (slerp) **SHOULD** be used to interpolate quaternions.
  /// The number of output elements **MUST** equal the number of input elements.
  linear("LINEAR"),

  /// The animated values remain constant to the output of the first keyframe, until the next keyframe.
  /// The number of output elements **MUST** equal the number of input elements.
  step("STEP"),

  /// The animation's interpolation is computed using a cubic spline with specified tangents.
  /// The number of output elements **MUST** equal three times the number of input elements.
  /// For each input element, the output stores three elements, an in-tangent, a spline vertex, and an out-tangent.
  /// There **MUST** be at least two keyframes when using this interpolation.
  cubicSpline("CUBICSPLINE"),
  ;

  final String value;

  const AnimationInterpolation(this.value);

  static AnimationInterpolation valueOf(String value) {
    return values.firstWhere((e) => e.value == value);
  }

  static AnimationInterpolation? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }

  Vector3 lerp(Vector3 a, Vector3 b, double t) {
    return switch (this) {
      linear => vec3lerp(a, b, t),
      step => a,
      cubicSpline => throw UnimplementedError(),
    };
  }

  Vector3 vec3lerp(Vector3 a, Vector3 b, double t) {
    return a + (b - a).scaled(t);
  }

  Quaternion slerp(Quaternion a, Quaternion b, double t) {
    return switch (this) {
      linear => QuaternionUtils.slerp(a, b, t),
      step => a,
      cubicSpline => throw UnimplementedError(),
    };
  }
}

extension QuaternionUtils on Quaternion {
  double dot(Quaternion other) {
    return x * other.x + y * other.y + z * other.z + w * other.w;
  }

  static Quaternion slerp(Quaternion q0, Quaternion q1, double t) {
    final a = slerp2(q0, q1, t);
    if (a[0].isNaN) {
      throw 'Found NaN in slerp ::$q0:: ::$q1:: ::$t:: = ::$a::';
    }
    return a;
  }

  static Quaternion slerp2(
    Quaternion q0,
    Quaternion q1,
    double t, {
    double epsilon = 10e-3,
  }) {
    if (isEqual(q0, q1)) {
      return q0;
    }

    final dot = q0.dot(q1).clamp(-1, 1);
    final angle = acos(dot);

    if (angle.abs() < epsilon) {
      // The quaternions are very close, so linear interpolation is fine
      return lerp(q0, q1, t);
    }

    final a = sin((1 - t) * angle) / sin(angle);
    final b = sin(t * angle) / sin(angle);

    return q0.scaled(a) + q1.scaled(b);
  }

  static Quaternion lerp(Quaternion q0, Quaternion q1, double t) {
    return q0.scaled(1.0 - t) + q1.scaled(t);
  }

  static bool isEqual(Quaternion a, Quaternion b) {
    return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
  }
}
