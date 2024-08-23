import 'package:flame_3d/core.dart';

Matrix4 matrix4({
  Vector3? translation,
  Quaternion? rotation,
  Vector3? scale,
}) {
  return Matrix4.compose(
    translation ?? Vector3.zero(),
    rotation ?? Quaternion.identity(),
    scale ?? Vector3.all(1.0),
  );
}
