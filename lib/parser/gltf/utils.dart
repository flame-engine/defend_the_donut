import 'package:flame_3d/extensions.dart';

extension Let<T> on T {
  R let<R>(R Function(T) block) {
    if (this == null) {
      return null as R;
    }
    return block(this!);
  }
}

extension FilterNotNull<T> on List<T?> {
  List<T> filterNotNull() {
    return whereType<T>().toList();
  }
}

extension Vector4Factory on Vector4 {
  static Vector4 fromList(List<num> list) {
    return Vector4(list[0].toDouble(), list[1].toDouble(), list[2].toDouble(),
        list[3].toDouble());
  }
}

extension Vector3Factory on Vector3 {
  static Vector3 fromList(List<num> list) {
    return Vector3(list[0].toDouble(), list[1].toDouble(), list[2].toDouble());
  }
}

extension Vector2Factory on Vector2 {
  static Vector2 fromList(List<num> list) {
    return Vector2(list[0].toDouble(), list[1].toDouble());
  }
}